import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/notification_item.dart';
import 'auth_repository.dart';
import 'demande_aide_repository.dart';
import 'don_financier_repository.dart' hide ClientAuthentifie;
import 'http_client_provider.dart';

class NotificationRepository {
  static String get baseUrl => AuthRepository.baseUrl;
  final FlutterSecureStorage stockage = const FlutterSecureStorage();
  final DemandeAideRepository demandeRepo = DemandeAideRepository();
  final http.Client _client;
  final bool _ownsClient;

  NotificationRepository({http.Client? client})
      : _client = client ?? ClientAuthentifie(http.Client(), AuthRepository().recupererToken),
        _ownsClient = client == null;

  http.Client? _streamClient;

  // 1. Récupère l'historique des notifications depuis le backend Spring Boot
  Future<List<NotificationItem>> recupererHistoriqueBackend(
    String telephone, {
    int? beneficiaireId,
  }) async {
    final telNettoye = telephone.replaceAll(RegExp(r'\s+'), '');
    final resultat = <NotificationItem>[];

    // 1.a Recherche par numéro de téléphone
    if (telNettoye.isNotEmpty) {
      try {
        final url = Uri.parse('$baseUrl/api/notifications/user/$telNettoye');
        final reponse = await _client
            .get(url, headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 6));

        if (reponse.statusCode == 200) {
          final dynamic donnees = jsonDecode(utf8.decode(reponse.bodyBytes));
          if (donnees is List) {
            resultat.addAll(
              donnees
                  .whereType<Map<String, dynamic>>()
                  .map(NotificationItem.fromJson),
            );
          }
        }
      } catch (e) {
        debugPrint('Info historique notifications backend par téléphone : $e');
      }
    }

    // 1.b Si vide et beneficiaireId présent, tentative par identifiant bénéficiaire
    if (resultat.isEmpty && beneficiaireId != null) {
      try {
        final url = Uri.parse('$baseUrl/api/notifications/beneficiaire/$beneficiaireId');
        final reponse = await _client
            .get(url, headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 6));

        if (reponse.statusCode == 200) {
          final dynamic donnees = jsonDecode(utf8.decode(reponse.bodyBytes));
          if (donnees is List) {
            resultat.addAll(
              donnees
                  .whereType<Map<String, dynamic>>()
                  .map(NotificationItem.fromJson),
            );
          }
        }
      } catch (_) {}
    }

    return resultat;
  }

  // 2. Synthétise les notifications réelles depuis les dons reçus, demandes et statut du bénéficiaire (particulier et structure)
  Future<List<NotificationItem>> synthetiserDepuisMetier(int? beneficiaireId) async {
    if (beneficiaireId == null) return [];
    final notifications = <NotificationItem>[];

    try {
      // A. Notifications des dons reçus / aides distribuées
      final aides = await demandeRepo.getAidesDistribueesByBeneficiaire(beneficiaireId);
      final Set<int> demandesAvecDonsDistribues = {};

      for (final aide in aides) {
        if (aide.demandeAideId != null) {
          demandesAvecDonsDistribues.add(aide.demandeAideId!);
        }
        final dateDistribution =
            DateTime.tryParse(aide.dateDistribution ?? '') ?? DateTime.now();

        // Dons financiers reçus
        for (final affFin in aide.affectationsFinancieres) {
          final montant = affFin.montantAffecte;
          final date = DateTime.tryParse(affFin.dateAffectation ?? '') ?? dateDistribution;
          final montantLisible = montant.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]} ',
          );

          notifications.add(
            NotificationItem(
              id: 'don_fin_${affFin.id}',
              type: TypeNotification.donRecu,
              titre: 'Nouveau don reçu !',
              message: 'Une contribution de $montantLisible FCFA a été allouée à votre demande.',
              date: date,
              demandeId: aide.demandeAideId,
              montant: montant,
            ),
          );
        }

        // Dons matériels reçus
        for (final affMat in aide.affectationsMaterielles) {
          final date = DateTime.tryParse(affMat.dateAffectation ?? '') ?? dateDistribution;
          notifications.add(
            NotificationItem(
              id: 'don_mat_${affMat.id}',
              type: TypeNotification.donRecu,
              titre: 'Don matériel alloué',
              message: 'Votre demande a reçu ${affMat.quantiteAffectee} ${affMat.unite} de ${affMat.designation}.',
              date: date,
              demandeId: aide.demandeAideId,
              quantite: '${affMat.quantiteAffectee} ${affMat.unite}',
            ),
          );
        }

        // Remise effective ou programmation de l'aide
        final statutAide = aide.statut.toUpperCase();
        if (statutAide == 'DISTRIBUEE') {
          notifications.add(
            NotificationItem(
              id: 'distrib_${aide.id}',
              type: TypeNotification.distributionEffectuee,
              titre: 'Aide distribuée avec succès',
              message: 'Votre aide a été remise au lieu de distribution : ${aide.lieuDistribution ?? "Lieu convenu"}.',
              date: dateDistribution,
              demandeId: aide.demandeAideId,
            ),
          );
        } else if (statutAide == 'PREVUE' || statutAide == 'EN_COURS') {
          notifications.add(
            NotificationItem(
              id: 'distrib_prev_${aide.id}',
              type: TypeNotification.distributionPrevue,
              titre: 'Distribution en cours de préparation',
              message: 'La distribution de votre aide se prépare au lieu : ${aide.lieuDistribution ?? "Lieu convenu"}.',
              date: dateDistribution,
              demandeId: aide.demandeAideId,
            ),
          );
        }
      }

      // B. Notifications basées sur le statut des demandes d'aide
      final demandes = await demandeRepo.chargerMesDemandes(beneficiaireId: beneficiaireId);
      for (final demande in demandes) {
        final statut = demande.statut.toUpperCase();
        final titreDemande = demande.titre.trim();
        final dateDemande = demande.dateCreation ?? DateTime.now();

        if (statut == 'VALIDEE' || statut == 'ACCEPTEE' || statut == 'APPROUVEE') {
          notifications.add(
            NotificationItem(
              id: 'demande_val_${demande.id}',
              type: TypeNotification.demandeValidee,
              titre: 'Demande validée',
              message: 'Votre demande « $titreDemande » a été validée et est maintenant ouverte aux donateurs.',
              date: dateDemande,
              demandeId: demande.id,
            ),
          );
        } else if (statut == 'REJETEE' || statut == 'REFUSEE') {
          final motif = (demande.motif != null && demande.motif!.trim().isNotEmpty)
              ? '\nMotif : ${demande.motif!.trim()}'
              : '';
          notifications.add(
            NotificationItem(
              id: 'demande_rej_${demande.id}',
              type: TypeNotification.demandeRefusee,
              titre: 'Demande non retenue',
              message: 'Votre demande « $titreDemande » a été refusée.$motif',
              date: dateDemande,
              demandeId: demande.id,
            ),
          );
        }

        // Objectif 100% atteint
        if (demande.pourcentageCollecte >= 100) {
          notifications.add(
            NotificationItem(
              id: 'demande_100_${demande.id}',
              type: TypeNotification.objectifAtteint,
              titre: 'Objectif atteint à 100% !',
              message: 'Félicitations ! Votre demande « $titreDemande » a atteint la totalité de son objectif.',
              date: dateDemande,
              demandeId: demande.id,
            ),
          );
        } else if (demande.montantCollecte != null &&
            demande.montantCollecte! > 0 &&
            !demandesAvecDonsDistribues.contains(demande.id)) {
          final montantLisible = demande.montantCollecte!.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]} ',
          );
          notifications.add(
            NotificationItem(
              id: 'demande_dons_${demande.id}',
              type: TypeNotification.donRecu,
              titre: 'Dons reçus sur votre demande',
              message: 'Votre demande « $titreDemande » a collecté $montantLisible FCFA grâce aux généreux donateurs.',
              date: dateDemande,
              demandeId: demande.id,
              montant: demande.montantCollecte,
            ),
          );
        }
      }

      // C. Notification de statut du compte (Particulier ou Structure)
      try {
        final bData = await demandeRepo.getBeneficiaire(beneficiaireId);
        if (bData != null) {
          final statutCompte = (bData['statut'] ?? '').toString().toUpperCase();
          final typeBeneficiaire = (bData['typeBeneficiaire'] ?? '').toString().toUpperCase();
          final nomStructure = bData['nomStructure']?.toString();
          final estStructure = typeBeneficiaire == 'STRUCTURE';

          if (statutCompte == 'VALIDE' ||
              statutCompte == 'VALIDEE' ||
              statutCompte == 'ACTIF' ||
              statutCompte == 'APPROUVE') {
            notifications.add(
              NotificationItem(
                id: 'compte_valide_$beneficiaireId',
                type: TypeNotification.compteValide,
                titre: estStructure ? 'Structure validée' : 'Compte validé',
                message: estStructure
                    ? 'Votre compte structure ${nomStructure != null && nomStructure.isNotEmpty ? "« $nomStructure » " : ""}a été validé avec succès par l’administrateur. Vous pouvez désormais publier et suivre vos demandes d’aide.'
                    : 'Votre compte bénéficiaire particulier a été validé par votre organisation partenaire. Vous pouvez dès à présent créer et suivre vos demandes d’aide.',
                date: DateTime.now().subtract(const Duration(hours: 2)),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Info notification statut compte : $e');
      }
    } catch (e) {
      debugPrint('Info synthèse notifications métier : $e');
    }

    return notifications;
  }

  // 2b. Synthétise les notifications réelles pour le donateur
  Future<List<NotificationItem>> synthetiserDepuisMetierDonateur(int? donateurId) async {
    if (donateurId == null) return [];
    final notifications = <NotificationItem>[];

    try {
      final donRepo = DonFinancierRepository(baseUrl: baseUrl, client: _client);
      final dons = await donRepo.getByDonateur(donateurId);

      for (final don in dons) {
        final montantLisible = don.montant.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]} ',
        );
        final dateDon = don.dateDon ?? DateTime.now();

        notifications.add(
          NotificationItem(
            id: 'don_donateur_${don.id}',
            type: TypeNotification.donRecu,
            titre: 'Don enregistré avec succès',
            message: 'Votre don de $montantLisible FCFA a bien été pris en compte. Merci pour votre générosité !',
            date: dateDon,
            demandeId: don.demandeAideId,
            montant: don.montant,
          ),
        );
      }
    } catch (e) {
      debugPrint('Info synthèse notifications donateur : $e');
    }

    return notifications;
  }

  // 3. Fusionne, applique l'état "lu / non lu" et trie chronologiquement
  Future<List<NotificationItem>> chargerToutesNotifications({
    required String telephone,
    int? beneficiaireId,
    int? donateurId,
  }) async {
    final futures = <Future<List<NotificationItem>>>[
      recupererHistoriqueBackend(telephone, beneficiaireId: beneficiaireId),
    ];

    if (beneficiaireId != null) {
      futures.add(synthetiserDepuisMetier(beneficiaireId));
    }
    if (donateurId != null) {
      futures.add(synthetiserDepuisMetierDonateur(donateurId));
    }

    final listes = await Future.wait(futures);
    final brutes = listes.expand((l) => l).toList();
    final vues = <String, NotificationItem>{};

    for (final item in brutes) {
      vues[item.id] = item;
    }

    // Récupérer les IDs marqués comme lus
    final lusString = await stockage.read(key: 'notifications_lues');
    final idsLus = (lusString ?? '').split(',').toSet();

    final resultats = vues.values.map((notif) {
      if (idsLus.contains(notif.id)) {
        return notif.copyWith(lu: true);
      }
      return notif;
    }).toList();

    resultats.sort((a, b) => b.date.compareTo(a.date));
    return resultats;
  }

  // 4. Marquer une notification comme lue
  Future<void> marquerCommeLue(String id) async {
    final lusString = await stockage.read(key: 'notifications_lues');
    final idsLus = (lusString ?? '').split(',').where((e) => e.isNotEmpty).toSet();
    idsLus.add(id);
    await stockage.write(key: 'notifications_lues', value: idsLus.join(','));
  }

  // 5. Tout marquer comme lu
  Future<void> toutMarquerCommeLu(List<NotificationItem> notifications) async {
    final ids = notifications.map((n) => n.id).toSet();
    await stockage.write(key: 'notifications_lues', value: ids.join(','));
  }

  // 6. Écouter le flux Server-Sent Events (SSE) du backend Spring Boot en temps réel
  Stream<NotificationItem> ecouterStream(String telephone) async* {
    final telNettoye = telephone.replaceAll(RegExp(r'\s+'), '');
    if (telNettoye.isEmpty) return;

    _streamClient?.close();
    _streamClient = ClientAuthentifie(http.Client(), AuthRepository().recupererToken);

    try {
      final request = http.Request(
        'GET',
        Uri.parse('$baseUrl/api/notifications/stream/$telNettoye'),
      );
      request.headers['Accept'] = 'text/event-stream';

      final response = await _streamClient!.send(request);

      if (response.statusCode == 200) {
        String buffer = '';
        await for (final chunk in response.stream.transform(utf8.decoder)) {
          buffer += chunk;
          final lines = buffer.split('\n');
          buffer = lines.removeLast();

          for (final line in lines) {
            final trimmed = line.trim();
            if (trimmed.startsWith('data:')) {
              final rawJson = trimmed.substring(5).trim();
              if (rawJson.isNotEmpty && rawJson != 'null') {
                try {
                  final decoded = jsonDecode(rawJson);
                  if (decoded is Map<String, dynamic>) {
                    if (decoded['type'] != 'CONNECTED') {
                      yield NotificationItem.fromJson(decoded);
                    }
                  }
                } catch (_) {}
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Flux SSE fermé ou erreur : $e');
    }
  }

  void fermerStream() {
    _streamClient?.close();
    _streamClient = null;
    if (_ownsClient) _client.close();
  }
}

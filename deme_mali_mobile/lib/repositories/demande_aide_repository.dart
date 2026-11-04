import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/aide_recue.dart';
import '../models/beneficiaire.dart';
import '../models/categorie_demande.dart';
import '../models/demande_aide.dart';
import 'auth_repository.dart';
import '../models/justificatif.dart';
import '../models/type_justificatif.dart';



class DemandeAideRepository {
  static String get baseUrl => AuthRepository.baseUrl;
  final FlutterSecureStorage stockage = const FlutterSecureStorage();

  /// Cache en mémoire des rapports techniques indexés par demandeAideId
  final Map<int, Map<String, dynamic>?> _cacheRapportTechnique = {};

  /// Réinitialiser le cache pour forcer un rechargement frais
  void viderCacheRapports() {
    _cacheRapportTechnique.clear();
  }

  Future<Map<String, String>> _headers() async {
    final token = await stockage.read(key: 'accessToken');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Enrichit en parallèle une liste de demandes avec le montant final validé et le nombre de donateurs
  Future<List<DemandeAide>> _enrichirDemandes(List<DemandeAide> demandes) async {
    if (demandes.isEmpty) return demandes;

    return Future.wait(
      demandes.map((d) async {
        DemandeAide res = d;
        try {
          final results = await Future.wait([
            getRapportTechniqueByDemande(d.id),
            getNombreDonateursParDemande(d.id),
          ]);
          final rTech = results[0] as Map<String, dynamic>?;
          final nbDonateurs = results[1] as int;

          double? mFinal;
          String? descTech;
          if (rTech != null) {
            mFinal = (rTech['montantFinal'] is num)
                ? (rTech['montantFinal'] as num).toDouble()
                : double.tryParse(rTech['montantFinal']?.toString() ?? '');
            descTech = rTech['descriptionTechnique']?.toString();
          }

          res = res.copyWith(
            montantFinal: (mFinal != null && mFinal > 0) ? mFinal : res.montantFinal,
            descriptionTechnique: descTech ?? res.descriptionTechnique,
            nombreDonateurs: nbDonateurs,
          );
        } catch (_) {}
        return res;
      }),
    );
  }

  /// Récupérer toutes les demandes d'aide (GET /api/demandes-aide)
  Future<List<DemandeAide>> getAll() async {
    final url = Uri.parse('$baseUrl/api/demandes-aide');
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      final List<dynamic> liste = jsonDecode(utf8.decode(response.bodyBytes));
      final demandes = liste
          .map((item) => DemandeAide.fromJson(item as Map<String, dynamic>))
          .toList();
      demandes.sort(DemandeAide.comparerPlusRecentDAbord);
      return _enrichirDemandes(demandes);
    }
    throw Exception('Erreur ${response.statusCode} lors de la récupération des demandes : ${response.body}');
  }

  /// Récupérer les demandes d'un bénéficiaire spécifique (GET /api/demandes-aide/beneficiaire/{beneficiaireId})
  Future<List<DemandeAide>> getByBeneficiaire(int beneficiaireId) async {
    final url = Uri.parse('$baseUrl/api/demandes-aide/beneficiaire/$beneficiaireId');
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      final List<dynamic> liste = jsonDecode(utf8.decode(response.bodyBytes));
      final demandes = liste
          .map((item) => DemandeAide.fromJson(item as Map<String, dynamic>))
          .toList();
      demandes.sort(DemandeAide.comparerPlusRecentDAbord);
      return _enrichirDemandes(demandes);
    }
    throw Exception('Erreur ${response.statusCode} lors du chargement des demandes du bénéficiaire $beneficiaireId');
  }

  /// Récupérer une demande par son identifiant (GET /api/demandes-aide/{id})
  Future<DemandeAide> getById(int id) async {
    final url = Uri.parse('$baseUrl/api/demandes-aide/$id');
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      var demande = DemandeAide.fromJson(data);

      // Si le montant final n'est pas encore présent dans le DTO de la demande,
      // on le récupère automatiquement via la chaîne Étude de terrain -> Rapport Besoin -> Rapport Technique
      if (!demande.aMontantFinalCertifie) {
        try {
          final rTech = await getRapportTechniqueByDemande(id);
          if (rTech != null) {
            final double? mFinal = (rTech['montantFinal'] is num)
                ? (rTech['montantFinal'] as num).toDouble()
                : double.tryParse(rTech['montantFinal']?.toString() ?? '');
            final String? descTech = rTech['descriptionTechnique']?.toString();
            if (mFinal != null && mFinal > 0) {
              demande = demande.copyWith(
                montantFinal: mFinal,
                descriptionTechnique: descTech,
              );
            }
          }
        } catch (_) {}
      }

      // Enrichir avec le nombre de donateurs
      try {
        final nb = await getNombreDonateursParDemande(id);
        demande = demande.copyWith(nombreDonateurs: nb);
      } catch (_) {}

      return demande;
    }
    throw Exception('Erreur ${response.statusCode} lors de la récupération de la demande $id');
  }

  /// Récupérer le rapport technique lié à une demande d'aide en enchaînant :
  /// 1. GET /api/etudes-terrain/demande/{demandeAideId}
  /// 2. GET /api/rapports-besoin/etude-terrain/{etudeTerrainId}
  /// 3. GET /api/rapports-techniques/rapport-besoin/{rapportBesoinId}
  Future<Map<String, dynamic>?> getRapportTechniqueByDemande(int demandeAideId) async {
    if (_cacheRapportTechnique.containsKey(demandeAideId)) {
      return _cacheRapportTechnique[demandeAideId];
    }

    try {
      final headers = await _headers();

      // 1. Récupérer l'étude de terrain liée à la demande
      final urlEtude = Uri.parse('$baseUrl/api/etudes-terrain/demande/$demandeAideId');
      final respEtude = await http.get(urlEtude, headers: headers);
      if (respEtude.statusCode != 200) {
        _cacheRapportTechnique[demandeAideId] = null;
        return null;
      }
      final etudeData = jsonDecode(utf8.decode(respEtude.bodyBytes));
      if (etudeData == null) {
        _cacheRapportTechnique[demandeAideId] = null;
        return null;
      }

      dynamic etudeId;
      if (etudeData is Map<String, dynamic>) {
        etudeId = etudeData['id'];
      } else if (etudeData is List && etudeData.isNotEmpty) {
        final premier = etudeData.first;
        if (premier is Map<String, dynamic>) {
          etudeId = premier['id'];
        }
      }
      if (etudeId == null) {
        _cacheRapportTechnique[demandeAideId] = null;
        return null;
      }

      // 2. Récupérer le rapport de besoin lié à cette étude de terrain
      final urlBesoin = Uri.parse('$baseUrl/api/rapports-besoin/etude-terrain/$etudeId');
      final respBesoin = await http.get(urlBesoin, headers: headers);
      if (respBesoin.statusCode != 200) {
        _cacheRapportTechnique[demandeAideId] = null;
        return null;
      }
      final besoinData = jsonDecode(utf8.decode(respBesoin.bodyBytes));
      if (besoinData == null) {
        _cacheRapportTechnique[demandeAideId] = null;
        return null;
      }

      dynamic besoinId;
      dynamic rapportTechniqueId;
      dynamic montantEstimeBesoin;
      String? descriptionBesoin;

      if (besoinData is Map<String, dynamic>) {
        besoinId = besoinData['id'];
        rapportTechniqueId = besoinData['rapportTechniqueId'];
        montantEstimeBesoin = besoinData['montantEstime'];
        descriptionBesoin = besoinData['solutionProposee']?.toString() ??
            besoinData['descriptionSituation']?.toString();
      } else if (besoinData is List && besoinData.isNotEmpty) {
        final premier = besoinData.first;
        if (premier is Map<String, dynamic>) {
          besoinId = premier['id'];
          rapportTechniqueId = premier['rapportTechniqueId'];
          montantEstimeBesoin = premier['montantEstime'];
          descriptionBesoin = premier['solutionProposee']?.toString() ??
              premier['descriptionSituation']?.toString();
        }
      }

      if (besoinId == null) {
        _cacheRapportTechnique[demandeAideId] = null;
        return null;
      }

      // 3. Récupérer le rapport technique lié à ce rapport de besoin
      // Option A : via l'ID direct s'il était renseigné
      if (rapportTechniqueId != null) {
        final urlDirect = Uri.parse('$baseUrl/api/rapports-techniques/$rapportTechniqueId');
        final respDirect = await http.get(urlDirect, headers: headers);
        if (respDirect.statusCode == 200) {
          final data = jsonDecode(utf8.decode(respDirect.bodyBytes));
          if (data is Map<String, dynamic>) {
            _cacheRapportTechnique[demandeAideId] = data;
            return data;
          }
        }
      }

      // Option B : via GET /api/rapports-techniques/rapport-besoin/{rapportBesoinId}
      final urlTech = Uri.parse('$baseUrl/api/rapports-techniques/rapport-besoin/$besoinId');
      final respTech = await http.get(urlTech, headers: headers);
      if (respTech.statusCode == 200) {
        final techData = jsonDecode(utf8.decode(respTech.bodyBytes));
        if (techData is Map<String, dynamic>) {
          if (techData['montantFinal'] == null && montantEstimeBesoin != null) {
            techData['montantFinal'] = montantEstimeBesoin;
          }
          _cacheRapportTechnique[demandeAideId] = techData;
          return techData;
        }
      }

      // Option C : Chercher dans la liste globale de repli
      final urlAllTech = Uri.parse('$baseUrl/api/rapports-techniques');
      final respAllTech = await http.get(urlAllTech, headers: headers);
      if (respAllTech.statusCode == 200) {
        final list = jsonDecode(utf8.decode(respAllTech.bodyBytes));
        if (list is List) {
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              final rBId = item['rapportBesoinId'] ??
                  (item['rapportBesoin'] is Map ? item['rapportBesoin']['id'] : null);
              if (rBId == besoinId) {
                _cacheRapportTechnique[demandeAideId] = item;
                return item;
              }
            }
          }
        }
      }

      // Option D : Si le rapport technique n'est pas encore finalisé mais qu'un montant estimé
      // a été saisi lors du rapport de besoin de l'étude de terrain, on l'utilise comme montant validé
      if (montantEstimeBesoin != null) {
        final fallback = {
          'montantFinal': montantEstimeBesoin,
          'descriptionTechnique': descriptionBesoin,
        };
        _cacheRapportTechnique[demandeAideId] = fallback;
        return fallback;
      }

      _cacheRapportTechnique[demandeAideId] = null;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Récupérer les demandes filtrées par statut (GET /api/demandes-aide/statut/{statut})
  Future<List<DemandeAide>> getByStatut(String statut) async {
    final url = Uri.parse('$baseUrl/api/demandes-aide/statut/$statut');
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      final List<dynamic> liste = jsonDecode(utf8.decode(response.bodyBytes));
      final demandes = liste
          .map((item) => DemandeAide.fromJson(item as Map<String, dynamic>))
          .toList();
      demandes.sort(DemandeAide.comparerPlusRecentDAbord);
      return _enrichirDemandes(demandes);
    }
    throw Exception('Erreur ${response.statusCode} pour le statut $statut');
  }

  /// Récupérer les demandes disponibles pour les dons (GET /api/demandes-aide/disponibles-pour-don)
  Future<List<DemandeAide>> getDemandesDisponiblesPourDon() async {
    final url = Uri.parse('$baseUrl/api/demandes-aide/disponibles-pour-don');
    final response = await http.get(url, headers: await _headers());

    if (response.statusCode == 200) {
      final List<dynamic> liste = jsonDecode(utf8.decode(response.bodyBytes));
      final demandes = liste
          .map((item) => DemandeAide.fromJson(item as Map<String, dynamic>))
          .toList();
      demandes.sort(DemandeAide.comparerPlusRecentDAbord);
      return _enrichirDemandes(demandes);
    }
    throw Exception('Erreur ${response.statusCode} lors de la récupération des demandes disponibles');
  }

  /// Créer une nouvelle demande d'aide (POST /api/demandes-aide)
  Future<DemandeAide> creer(Map<String, dynamic> dto) async {
    final url = Uri.parse('$baseUrl/api/demandes-aide');
    final response = await http.post(
      url,
      headers: await _headers(),
      body: jsonEncode(dto),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes));
      return DemandeAide.fromJson(data);
    }
    throw Exception(
        'Erreur ${response.statusCode} lors de la création : ${response.body}');
  }

  /// Modifier une demande d'aide encore en attente (PUT /api/demandes-aide/{id})
  Future<DemandeAide> modifierDemande(int id, Map<String, dynamic> dto) async {
    final url = Uri.parse('$baseUrl/api/demandes-aide/$id');
    final response = await http.put(
      url,
      headers: await _headers(),
      body: jsonEncode(dto),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(utf8.decode(response.bodyBytes));
      return DemandeAide.fromJson(data);
    }
    throw Exception(
        'Erreur ${response.statusCode} lors de la modification : ${response.body}');
  }

  /// Récupérer les catégories de demande (GET /api/categories-demande)
  Future<List<CategorieDemande>> getCategories() async {
    try {
      final url = Uri.parse('$baseUrl/api/categories-demande');
      final response = await http.get(url, headers: await _headers());
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data
            .map((item) =>
                CategorieDemande.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Récupérer l'organisation partenaire liée au bénéficiaire (GET /api/beneficiaires/{id})
  Future<int?> getOrganisationDuBeneficiaire(int beneficiaireId) async {
    try {
      final url = Uri.parse('$baseUrl/api/beneficiaires/$beneficiaireId');
      final response = await http.get(url, headers: await _headers());
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final orgId = data['organisationPartenaireId'] ??
            data['organisationId'] ??
            data['organisationPartenaire']?['id'] ??
            data['organisation']?['id'];
        if (orgId is int) return orgId;
        // if (orgId is num) return orgId.toInt();
        // if (orgId is String) return int.tryParse(orgId);
      }
    } catch (_) {}
    return null;
  }

  /// Récupérer les détails complets d'un bénéficiaire (GET /api/beneficiaires/{id})
  Future<Map<String, dynamic>?> getBeneficiaire(int beneficiaireId) async {
    try {
      final url = Uri.parse('$baseUrl/api/beneficiaires/$beneficiaireId');
      final response = await http.get(url, headers: await _headers());
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// Récupérer les détails d'une organisation partenaire (GET /api/organisations-partenaires/{id})
  Future<Map<String, dynamic>?> getOrganisationPartenaire(int organisationId) async {
    try {
      final url = Uri.parse('$baseUrl/api/organisations-partenaires/$organisationId');
      final response = await http.get(url, headers: await _headers());
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  /// Récupérer le profil complet d'un bénéficiaire avec les infos de son organisation partenaire
  Future<Beneficiaire?> getProfilBeneficiaireComplet(int beneficiaireId) async {
    try {
      final bData = await getBeneficiaire(beneficiaireId);
      final telStocke = await stockage.read(key: 'userTelephone');
      final nomStocke = await stockage.read(key: 'userNom');
      final prenomStocke = await stockage.read(key: 'userPrenom');
      final photoStockee = await stockage.read(key: 'userPhotoPath_$beneficiaireId') ??
          await stockage.read(key: 'userPhotoPath');

      if (bData == null) {
        return Beneficiaire(
          id: beneficiaireId,
          nom: nomStocke ?? '',
          prenom: prenomStocke ?? '',
          telephone: telStocke,
          photoUrl: photoStockee,
        );
      }

      Map<String, dynamic>? orgData;
      final orgId = bData['organisationPartenaireId'] ??
          bData['organisationId'] ??
          bData['organisationPartenaire']?['id'];
      if (orgId is int) {
        orgData = await getOrganisationPartenaire(orgId);
      } else if (orgId is num) {
        orgData = await getOrganisationPartenaire(orgId.toInt());
      } else if (orgId is String) {
        final parsed = int.tryParse(orgId);
        if (parsed != null) {
          orgData = await getOrganisationPartenaire(parsed);
        }
      }

      return Beneficiaire.fromApi(
        beneficiaireJson: bData,
        organisationJson: orgData,
        telephoneFallback: telStocke,
        nomFallback: nomStocke,
        prenomFallback: prenomStocke,
        photoFallback: photoStockee,
      );
    } catch (_) {
      return null;
    }
  }


  /// Récupérer le nombre de donateurs ayant contribué à une demande d'aide
  Future<int> getNombreDonateursParDemande(int demandeAideId) async {
    try {
      final url = Uri.parse('$baseUrl/api/dons-financiers/demande/$demandeAideId');
      final response = await http.get(url, headers: await _headers());
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is List) {
          final donateursUniques = data
              .whereType<Map<String, dynamic>>()
              .map((d) => d['donateurId'])
              .where((id) => id != null)
              .toSet();
          return donateursUniques.isNotEmpty ? donateursUniques.length : data.length;
        }
      }
    } catch (_) {}
    return 0;
  }

  /// Récupérer toutes les distributions associées à un bénéficiaire (GET /api/aides-distribuees/beneficiaire/{beneficiaireId})
  Future<List<AideRecue>> getAidesDistribueesByBeneficiaire(int beneficiaireId) async {
    try {
      final url = Uri.parse('$baseUrl/api/aides-distribuees/beneficiaire/$beneficiaireId');
      final response = await http.get(url, headers: await _headers());
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final list = data
            .whereType<Map<String, dynamic>>()
            .map(AideRecue.fromJson)
            .toList();

        return await Future.wait(list.map((aide) async {
          if (aide.demandeAideId != null) {
            final nb = await getNombreDonateursParDemande(aide.demandeAideId!);
            return aide.copyWith(nombreDonateurs: nb);
          }
          return aide;
        }));
      }
    } catch (_) {}
    return [];
  }

  /// Récupérer uniquement les distributions terminées d'une demande (GET /api/aides-distribuees/demande/{demandeAideId}/distribuees)
  Future<List<AideRecue>> getAidesDistribueesByDemande(int demandeAideId) async {
    try {
      final url = Uri.parse('$baseUrl/api/aides-distribuees/demande/$demandeAideId/distribuees');
      final response = await http.get(url, headers: await _headers());
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final list = data
            .whereType<Map<String, dynamic>>()
            .map(AideRecue.fromJson)
            .toList();

        final nb = await getNombreDonateursParDemande(demandeAideId);
        return list.map((a) => a.copyWith(nombreDonateurs: nb)).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Méthode d'aide pour l'écran bénéficiaire
  /// Si beneficiaireId est fourni, filtre par bénéficiaire, sinon récupère toutes les demandes
  Future<List<DemandeAide>> chargerMesDemandes({int? beneficiaireId}) async {
    if (beneficiaireId != null) {
      return getByBeneficiaire(beneficiaireId);
    }
    return getAll();
  }

  /// Modifier les informations du profil du bénéficiaire
  Future<bool> modifierProfil({
    required int userId,
    required String nom,
    required String prenom,
    required String telephone,
    String? ville,
    String? adresse,
  }) async {
    try {
      final headers = await _headers();
      final body = jsonEncode({
        'id': userId,
        'nom': nom.trim(),
        'prenom': prenom.trim(),
        'telephone': telephone.trim(),
        if (ville != null && ville.trim().isNotEmpty) 'ville': ville.trim(),
        if (adresse != null && adresse.trim().isNotEmpty) 'adresse': adresse.trim(),
      });

      // 1. Appel API utilisateur
      final urlUtilisateur = Uri.parse('$baseUrl/api/utilisateurs/$userId');
      final resp = await http.put(urlUtilisateur, headers: headers, body: body);

      // 2. Si besoin, appel API bénéficiaire particulier
      if (resp.statusCode != 200 && resp.statusCode != 204) {
        final urlParticulier = Uri.parse('$baseUrl/api/beneficiaires/particuliers/$userId');
        await http.put(urlParticulier, headers: headers, body: body);
      }

      // 3. Mettre à jour le stockage local
      await stockage.write(key: 'userNom', value: nom.trim());
      await stockage.write(key: 'userPrenom', value: prenom.trim());
      await stockage.write(key: 'userTelephone', value: telephone.trim());

      return true;
    } catch (_) {
      // Sauvegarder localement même en cas de problème réseau
      await stockage.write(key: 'userNom', value: nom.trim());
      await stockage.write(key: 'userPrenom', value: prenom.trim());
      await stockage.write(key: 'userTelephone', value: telephone.trim());
      return true;
    }
  }

  /// Récupérer les types de justificatifs disponibles (GET /api/types-justificatif)
  Future<List<TypeJustificatif>> getTypesJustificatifs() async {
    try {
      final url = Uri.parse('$baseUrl/api/types-justificatif');
      final response = await http.get(url, headers: await _headers());
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data
            .whereType<Map<String, dynamic>>()
            .map(TypeJustificatif.fromJson)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Téléverser une liste de justificatifs pour une demande d'aide (POST /api/justificatifs)
  Future<List<Justificatif>> uploaderJustificatifs({
    required int demandeAideId,
    required int typeJustificatifId,
    required List<Justificatif> justificatifs,
  }) async {
    if (justificatifs.isEmpty) return [];

    final url = Uri.parse('$baseUrl/api/justificatifs');
    final request = http.MultipartRequest('POST', url);

    final token = await stockage.read(key: 'accessToken');
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';

    request.fields['demandeAideId'] = demandeAideId.toString();
    request.fields['typeJustificatifId'] = typeJustificatifId.toString();

    for (final j in justificatifs) {
      bool ajoute = false;
      if (j.chemin != null && j.chemin!.isNotEmpty) {
        try {
          request.files.add(
            await http.MultipartFile.fromPath(
              'fichiers',
              j.chemin!,
              filename: j.nom,
            ),
          );
          ajoute = true;
        } catch (_) {}
      }

      if (!ajoute && j.octets != null && j.octets!.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'fichiers',
            j.octets!,
            filename: j.nom,
          ),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data
          .whereType<Map<String, dynamic>>()
          .map(Justificatif.fromJson)
          .toList();
    }

    throw Exception(
      'Erreur ${response.statusCode} lors du téléversement des justificatifs : ${response.body}',
    );
  }

  /// Sauvegarder la photo de profil de l'utilisateur (multipart POST /api/utilisateurs/{id}/photo)
  Future<bool> enregistrerPhotoProfil({
    required int beneficiaireId,
    required String cheminFichier,
  }) async {
    try {
      await stockage.write(key: 'userPhotoPath_$beneficiaireId', value: cheminFichier);
      await stockage.write(key: 'userPhotoPath', value: cheminFichier);

      // Envoi multipart au backend Spring Boot
      final token = await stockage.read(key: 'accessToken');
      final uri = Uri.parse('$baseUrl/api/utilisateurs/$beneficiaireId/photo');
      final req = http.MultipartRequest('POST', uri);
      if (token != null && token.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $token';
      }
      req.headers['Accept'] = 'application/json';
      req.files.add(await http.MultipartFile.fromPath('photo', cheminFichier));

      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final data = jsonDecode(utf8.decode(resp.bodyBytes));
        final nomPhoto = data['nomFichier'] ?? data['photo'] ?? data['url'];
        if (nomPhoto != null) {
          await stockage.write(
            key: 'userPhotoPath_$beneficiaireId',
            value: nomPhoto.toString(),
          );
          await stockage.write(
            key: 'userPhotoPath',
            value: nomPhoto.toString(),
          );
        }
        return true;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Supprimer la photo de profil de l'utilisateur (DELETE /api/utilisateurs/{id}/photo)
  Future<void> supprimerPhotoProfil(int beneficiaireId) async {
    await stockage.delete(key: 'userPhotoPath_$beneficiaireId');
    await stockage.delete(key: 'userPhotoPath');
    try {
      final token = await stockage.read(key: 'accessToken');
      final uri = Uri.parse('$baseUrl/api/utilisateurs/$beneficiaireId/photo');
      await http.delete(uri, headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
    } catch (_) {}
  }
}

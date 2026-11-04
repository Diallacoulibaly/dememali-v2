
import 'package:flutter/material.dart';

import '../models/donnees_personnelles_particulier.dart';
import '../repositories/particulier_repository.dart';
import 'utilitaires_inscription.dart';

class InscriptionParticulierController extends ChangeNotifier {
  final ParticulierRepository repository = ParticulierRepository();

  bool chargement = false;
  String? erreur;

  // Convertit les libellés du formulaire en valeurs d'enum du backend
  static const Map<String, String> typesBeneficiaire = {
    'Famille': 'FAMILLE',
    'Personne seule': 'PERSONNE',
  };

  static const Map<String, String> situationsMatrimoniales = {
    'Célibataire': 'CELIBATAIRE',
    'Marié(e)': 'MARIE',
    'Divorcé(e)': 'DIVORCE',
    'Veuf(ve)': 'VEUVE',
  };

  // Le backend stocke le type de handicap sous forme de texte ("Aucun"...)
  static const Map<String, String> handicaps = {
    'Aucun handicap': 'Aucun',
    'Handicap moteur': 'Moteur',
    'Handicap visuel': 'Visuel',
    'Handicap auditif': 'Auditif',
    'Handicap mental': 'Mental',
  };

  Future<bool> inscrire({
    required DonneesPersonnellesParticulier personnel,
    required int organisationPartenaireId,
    required String situationMatrimoniale,
    required int nombreEnfants,
    required String handicap,
    required String description,
    required DateTime dateNaissance,
  }) async {
    chargement = true;
    erreur = null;
    notifyListeners();

    try {
      final date = '${dateNaissance.year.toString().padLeft(4, '0')}-'
          '${dateNaissance.month.toString().padLeft(2, '0')}-'
          '${dateNaissance.day.toString().padLeft(2, '0')}';

      await repository.inscrire(
        personnel: DonneesPersonnellesParticulier(
          nom: personnel.nom,
          prenom: personnel.prenom,
          adresse: personnel.adresse,
          ville: personnel.ville,
          telephone: normaliserTelephone(personnel.telephone),
          motDePasse: personnel.motDePasse,
          genre: personnel.genre,
        ),
        organisationPartenaireId: organisationPartenaireId,
        situationMatrimonial: situationsMatrimoniales[situationMatrimoniale] ?? situationMatrimoniale,
        nombreEnfants: nombreEnfants,
        typeHandicap: handicaps[handicap] ?? handicap,
        descriptionSituation: description,
        dateNaissance: date,
      );
      return true;
    } catch (e, stackTrace) {
      debugPrint('ERREUR INSCRIPTION PARTICULIER : $e');
      debugPrint('DÉTAILS : $stackTrace');
      erreur = messageErreurInscription(e);
      return false;
    } finally {
      chargement = false;
      notifyListeners();
    }
  }
}

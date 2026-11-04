import 'package:flutter/material.dart';

import '../repositories/structure_repository.dart';
import 'utilitaires_inscription.dart';

class InscriptionStructureController extends ChangeNotifier {
  final StructureRepository repository = StructureRepository();

  bool chargement = false;
  String? erreur;

  Future<bool> inscrire({
    required String nom,
    required String prenom,
    required String telephone,
    required String motDePasse,
    required String ville,
    required String adresse,
    required int organisationPartenaireId,
    required String nomStructure,
    required String nif,
    required String email,
    String? documentJustificatif,
  }) async {
    chargement = true;
    erreur = null;
    notifyListeners();

    try {
      await repository.inscrire(
        nom: nom,
        prenom: prenom,
        telephone: normaliserTelephone(telephone),
        motDePasse: motDePasse,
        ville: ville,
        adresse: adresse,
        organisationPartenaireId: organisationPartenaireId,
        nomStructure: nomStructure,
        nif: nif,
        email: email,
        documentJustificatif: documentJustificatif,
      );
      return true;
    } catch (e, stackTrace) {
      debugPrint('ERREUR INSCRIPTION STRUCTURE : $e');
      debugPrint('DÉTAILS : $stackTrace');
      erreur = messageErreurInscription(e);
      return false;
    } finally {
      chargement = false;
      notifyListeners();
    }
  }
}

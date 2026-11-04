
import 'package:flutter/material.dart';

import '../repositories/donateur_repository.dart';
import 'utilitaires_inscription.dart';

class InscriptionDonateurController extends ChangeNotifier {
  final DonateurRepository repository = DonateurRepository();

  bool chargement = false;
  String? erreur;

  // Convertit le libellé du formulaire en valeur de l'enum Sexe du backend
  static String versSexe(String genre) {
    return genre == 'Femme' ? 'FEMININ' : 'MASCULIN';
  }

  Future<bool> inscrire({
    required String nom,
    required String prenom,
    required String telephone,
    required String motDePasse,
    required String genre,
    required int paysId,
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
        sexe: versSexe(genre),
        paysId: paysId,
      );
      return true;
    } catch (e, stackTrace) {
      debugPrint('ERREUR INSCRIPTION DONATEUR : $e');
      debugPrint('DÉTAILS : $stackTrace');

      erreur = messageErreurInscription(e);
      return false;
    } finally {
      chargement = false;
      notifyListeners();
    }
  }
}

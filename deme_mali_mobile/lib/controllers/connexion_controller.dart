import 'package:flutter/material.dart';

import '../models/reponse_connexion.dart';
import '../repositories/auth_repository.dart';

class ConnexionController extends ChangeNotifier {
  final AuthRepository repository = AuthRepository();

  bool chargement = false;
  String? erreur;
  ReponseConnexion? resultat;

  Future<bool> connecter({
    required String telephone,
    required String motDePasse,
  }) async {
    if (telephone.trim().isEmpty || motDePasse.isEmpty) {
      erreur = 'Veuillez remplir tous les champs.';
      notifyListeners();
      return false;
    }

    chargement = true;
    erreur = null;
    notifyListeners();

    try {
      resultat = await repository.connexion(
        telephone: telephone.trim(),
        motDePasse: motDePasse,
      );

      final utilisateur = resultat!.utilisateur;

      debugPrint('Connexion réussie !');
      debugPrint('Utilisateur : ${utilisateur.telephone}');
      debugPrint('Prénom : ${utilisateur.prenom}');
      debugPrint('Nom : ${utilisateur.nom}');
      debugPrint('Rôle : ${utilisateur.role}');

      return true;
    } catch (e, stackTrace) {
      debugPrint('ERREUR DE CONNEXION : $e');
      debugPrint('DÉTAILS : $stackTrace');

      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      erreur = msg.isNotEmpty
          ? msg
          : 'Échec de la connexion. Vérifiez vos identifiants.';

      return false;
    } finally {
      chargement = false;
      notifyListeners();
    }
  }
}

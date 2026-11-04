
import 'package:flutter/material.dart';

import '../authentification/connexion.dart';
import '../bienvenue/bienvenue.dart';

const String messageCompteCree =
    'Compte créé avec succès. Connectez-vous avec votre numéro '
    'et votre mot de passe.';

const String messageCompteParticulierEnAttente =
    'Inscription enregistrée. Votre compte est en attente de validation '
    'par l''organisation partenaire. Vous pourrez vous connecter dès '
    'que l''organisation aura validé votre dossier.';

const String messageCompteStructureEnAttente =
    'Inscription enregistrée. Votre compte est en attente de validation '
    'par l''administrateur. Vous pourrez vous connecter dès '
    'que l''administrateur aura validé votre structure.';

const String messageCompteEnAttente =
    'Inscription enregistrée. Votre compte est en attente de validation '
    'par l’administrateur. Vous pourrez vous connecter une '
    'fois votre compte validé.';

// Après une inscription réussie : retour à l'accueil, ouverture du formulaire
// de connexion (le retour depuis la connexion ramène à l'accueil) et message
// de confirmation.
void redirigerVersConnexion(
    BuildContext context, {
      String message = messageCompteCree,
    }) {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const BienvenuePage()),
        (route) => false,
  );
  navigator.push(
    MaterialPageRoute(builder: (_) => const ConnexionPage()),
  );

  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 7),
    ),
  );
}

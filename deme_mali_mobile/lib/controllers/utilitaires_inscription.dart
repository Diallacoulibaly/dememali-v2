// Transforme une exception d'inscription en message lisible et guidant pour l'utilisateur
String messageErreurInscription(Object e) {
  final message = e.toString().replaceFirst('Exception: ', '').trim();
  final minuscules = message.toLowerCase();

  if (message.contains('ClientException') ||
      message.contains('SocketException') ||
      message.contains('XMLHttpRequest') ||
      minuscules.contains('connection refused') ||
      minuscules.contains('impossible de joindre')) {
    return 'Impossible de joindre le serveur. Vérifiez votre connexion Internet et réessayez.';
  }

  if (minuscules.contains('existe déjà') ||
      minuscules.contains('existe deja') ||
      minuscules.contains('déjà utilisé') ||
      minuscules.contains('deja utilise') ||
      minuscules.contains('duplicata') ||
      minuscules.contains('duplicate') ||
      minuscules.contains('integrityconstraint') ||
      minuscules.contains('uk6wo7b684svg7hmrpxnkbf4uun')) {
    return 'Ce numéro de téléphone est déjà associé à un autre compte. Veuillez vous connecter ou utiliser un autre numéro.';
  }

  if (message.contains('500') || minuscules.contains('internal server error')) {
    return 'Le serveur n’a pas pu enregistrer l’inscription (500). Veuillez réessayer.';
  }

  if (message.contains('400') || minuscules.contains('bad request')) {
    return 'Certaines informations saisies sont incomplètes ou invalides. Veuillez vérifier le formulaire.';
  }

  if (message.contains('403') || minuscules.contains('forbidden')) {
    return 'Action non autorisée. Veuillez vérifier vos autorisations.';
  }

  if (message.contains('404') || minuscules.contains('not found')) {
    return 'Service d’inscription introuvable (404). Vérifiez l’adresse du serveur.';
  }

  if (message.startsWith('Erreur HTTP')) {
    return 'Le serveur a répondu : $message';
  }

  return message.isEmpty
      ? "Une erreur est survenue lors de l'enregistrement. Veuillez réessayer."
      : message;
}

// Supprime les espaces du numéro pour avoir un format unique en base
String normaliserTelephone(String telephone) {
  return telephone.replaceAll(RegExp(r'\s+'), '');
}

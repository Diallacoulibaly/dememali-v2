
import 'package:flutter/material.dart';
import '../../../../styles/couleurs.dart';

class BoutonsBienvenue extends StatelessWidget {
  final VoidCallback onInscription;
  final VoidCallback onConnexion;

  const BoutonsBienvenue({
    super.key,
    required this.onInscription,
    required this.onConnexion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // BOUTON CRÉER UN COMPTE
        SizedBox(
          width: double.infinity,
          height: 43,
          child: ElevatedButton(
            onPressed: onInscription,
            style: ElevatedButton.styleFrom(
              backgroundColor: CouleursApp.vert,
              foregroundColor: CouleursApp.blanc,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Créer un compte',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // BOUTON SE CONNECTER
        SizedBox(
          width: double.infinity,
          height: 43,
          child: OutlinedButton(
            onPressed: onConnexion,
            style: OutlinedButton.styleFrom(
              foregroundColor: CouleursApp.vert,
              side: const BorderSide(
                color: CouleursApp.vert,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Se connecter',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

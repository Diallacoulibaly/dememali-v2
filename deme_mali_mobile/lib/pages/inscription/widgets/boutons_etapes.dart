
import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

// Boutons « Retour » (blanc) et « Suivant → » (vert) du bas d'écran
class BoutonsEtapes extends StatelessWidget {
  final VoidCallback onRetour;
  final VoidCallback? onSuivant;
  final bool chargement;
  final String texteSuivant;
  final bool afficherFleche;

  const BoutonsEtapes({
    super.key,
    required this.onRetour,
    required this.onSuivant,
    this.chargement = false,
    this.texteSuivant = 'Suivant',
    this.afficherFleche = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: chargement ? null : onRetour,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.white,
                foregroundColor: CouleursApp.noir,
                elevation: 2,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Retour',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: chargement ? null : onSuivant,
              style: ElevatedButton.styleFrom(
                backgroundColor: CouleursApp.vert,
                disabledBackgroundColor: const Color(0xFFA8CBB8),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                elevation: 2,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: chargement
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    texteSuivant,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (afficherFleche) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward, size: 16),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

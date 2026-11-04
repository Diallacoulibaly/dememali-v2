import 'package:flutter/material.dart';
import '../../../../styles/couleurs.dart';

class BarreProgressionEtapes extends StatelessWidget {
  const BarreProgressionEtapes({
    super.key,
    required this.etapeActuelle,
    required this.titre,
    required this.onRetour,
  });

  final int etapeActuelle; // 1, 2 ou 3
  final String titre;
  final VoidCallback onRetour;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Ligne haute : Bouton retour + Titre + Badge étape
        Row(
          children: [
            InkWell(
              onTap: onRetour,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: CouleursApp.noir, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                titre,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: CouleursApp.noir,
                ),
              ),
            ),
            // Badge étape (ex: • 1 sur 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: CouleursApp.blanc,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: CouleursApp.jaune, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: CouleursApp.jaune,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$etapeActuelle sur 3',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: CouleursApp.noir,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Barre de progression en 3 segments
        Row(
          children: [
            for (int i = 1; i <= 3; i++) ...[
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= etapeActuelle
                        ? CouleursApp.vert
                        : Colors.black.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              if (i < 3) const SizedBox(width: 8),
            ],
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../styles/couleurs.dart';

// Carte d'action individuelle
class CarteAction extends StatelessWidget {
  const CarteAction({
    super.key,
    required this.icone,
    required this.couleurFondIcone,
    required this.couleurIcone,
    required this.titre,
    required this.sousTitre,
    required this.onTap,
  });

  final IconData icone;
  final Color couleurFondIcone;
  final Color couleurIcone;
  final String titre;
  final String sousTitre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        constraints: const BoxConstraints(minHeight: 168),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: CouleursApp.blanc,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge d'icône avec coins arrondis
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: couleurFondIcone,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(icone, color: couleurIcone, size: 26),
              ),
            ),

            const SizedBox(height: 16),

            // Titre et sous-titre
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: CouleursApp.noir,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  sousTitre,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.48),
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

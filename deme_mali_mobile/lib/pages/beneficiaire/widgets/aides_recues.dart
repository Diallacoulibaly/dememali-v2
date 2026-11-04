import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

class AidesRecues extends StatelessWidget {
  const AidesRecues({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Mes aides reçues',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: CouleursApp.noir,
        ),
      ),
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: CouleursApp.blanc,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: CouleursApp.jaune.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: CouleursApp.vert,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Les informations sur les aides distribuées seront affichées ici.',
                style: TextStyle(
                  color: CouleursApp.noir,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

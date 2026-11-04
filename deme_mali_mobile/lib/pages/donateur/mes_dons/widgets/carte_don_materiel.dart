
import 'package:flutter/material.dart';

import '/../../models/don_materiel.dart';
import 'package:deme_mali_mobile/styles/couleurs.dart';

class CarteDonMateriel extends StatelessWidget {
  final DonMateriel don;

  const CarteDonMateriel({
    super.key,
    required this.don,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: CouleursApp.vert.withAlpha(35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CouleursApp.fond,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: CouleursApp.vert,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  don.designation,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.noir,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Quantité : ${don.quantite} ${don.unite}',
                  style: TextStyle(
                    fontSize: 13,
                    color: CouleursApp.noir.withAlpha(170),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CouleursApp.fond,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Réception : ${don.statutReception}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: CouleursApp.vert,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

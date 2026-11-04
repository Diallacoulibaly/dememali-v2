
import 'package:flutter/material.dart';

import '/../../models/don_financier.dart';
import 'package:deme_mali_mobile/styles/couleurs.dart';

class CarteDonFinancier extends StatelessWidget {
  final DonFinancier don;

  const CarteDonFinancier({
    super.key,
    required this.don,
  });

  @override
  Widget build(BuildContext context) {
    final titre =
    don.titreDemandeAide?.trim().isNotEmpty == true
        ? don.titreDemandeAide!
        : 'Don financier général';

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
              Icons.payments_outlined,
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
                  titre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.noir,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mode de paiement : ${don.modePaiement}',
                  style: TextStyle(
                    fontSize: 13,
                    color: CouleursApp.noir.withAlpha(170),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${don.montant.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.vert,
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

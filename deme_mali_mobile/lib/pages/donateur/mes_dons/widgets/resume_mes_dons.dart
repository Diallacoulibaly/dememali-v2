
import 'package:flutter/material.dart';
import 'package:deme_mali_mobile/styles/couleurs.dart';

class ResumeMesDons extends StatelessWidget {
  final int nombreDons;
  final double montantTotal;

  const ResumeMesDons({
    super.key,
    required this.nombreDons,
    required this.montantTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _construireCarte(
            icone: Icons.volunteer_activism_outlined,
            titre: 'Nombre de dons',
            valeur: '$nombreDons',
            couleurIcone: CouleursApp.vert,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _construireCarte(
            icone: Icons.account_balance_wallet_outlined,
            titre: 'Total financier',
            valeur: '${montantTotal.toStringAsFixed(0)} FCFA',
            couleurIcone: CouleursApp.jaune,
          ),
        ),
      ],
    );
  }

  Widget _construireCarte({
    required IconData icone,
    required String titre,
    required String valeur,
    required Color couleurIcone,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: couleurIcone, size: 28),
          const SizedBox(height: 12),
          Text(
            titre,
            style: const TextStyle(
              fontSize: 12,
              color: CouleursApp.noir,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            valeur,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: CouleursApp.noir,
            ),
          ),
        ],
      ),
    );
  }
}

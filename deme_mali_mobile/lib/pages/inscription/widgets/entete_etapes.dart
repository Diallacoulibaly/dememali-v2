
import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

// En-tête des formulaires en plusieurs étapes : logo, pastille « 1 sur 2 »,
// barre de progression, titre et sous-titre.
class EnteteEtapes extends StatelessWidget {
  final int etape;
  final int total;
  final String titre;
  final String sousTitre;

  const EnteteEtapes({
    super.key,
    required this.etape,
    required this.total,
    required this.titre,
    required this.sousTitre,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/logo_acceuil.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/logo_Acceuil.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error2, stackTrace2) => Image.asset(
                  'assets/images/logo_accueil.png',
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Dèmè Mali',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: CouleursApp.noir,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: CouleursApp.jaune),
              ),
              child: Text(
                '$etape sur $total',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: CouleursApp.noir,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // BARRE DE PROGRESSION
        Row(
          children: List.generate(total, (index) {
            final atteint = index < etape;
            return Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: index < total - 1 ? 3 : 0),
                decoration: BoxDecoration(
                  color: atteint
                      ? CouleursApp.vert
                      : const Color(0xFFE6E1D5),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),

        Text(
          titre,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: CouleursApp.noir,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          sousTitre,
          style: const TextStyle(
            fontSize: 11,
            height: 1.4,
            color: Color(0xFF777777),
          ),
        ),
      ],
    );
  }
}

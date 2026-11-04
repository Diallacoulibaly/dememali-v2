
import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

// En-tête commun : bouton retour rond + titre (+ sous-titre optionnel)
class EnteteInscription extends StatelessWidget {
  final String titre;
  final String? sousTitre;

  const EnteteInscription({
    super.key,
    required this.titre,
    this.sousTitre,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: CouleursApp.noir,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                titre,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CouleursApp.noir,
                ),
              ),
            ),
          ],
        ),
        if (sousTitre != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 46),
            child: Text(
              sousTitre!,
              style: const TextStyle(
                fontSize: 11,
                height: 1.4,
                color: Color(0xFF777777),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

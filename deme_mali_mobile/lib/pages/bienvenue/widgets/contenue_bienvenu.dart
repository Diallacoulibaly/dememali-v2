
import 'package:flutter/material.dart';
import '../../../../styles/couleurs.dart';

class ContenuBienvenue extends StatelessWidget {
  const ContenuBienvenue({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // LOGO
        Center(
          child: Image.asset(
            'assets/images/logo_acceuil.png',
            width: 95,
            height: 95,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/logo_Acceuil.png',
              width: 115,
              height: 115,
              fit: BoxFit.contain,
              errorBuilder: (context, error2, stackTrace2) => Image.asset(
                'assets/images/logo_accueil.png',
                width: 115,
                height: 115,
                fit: BoxFit.contain,
                errorBuilder: (context, error3, stackTrace3) => Container(
                  width: 115,
                  height: 115,
                  decoration: BoxDecoration(
                    color: CouleursApp.vert.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volunteer_activism,
                    size: 60,
                    color: CouleursApp.vert,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 3),

        // NOM DE L'APPLICATION
        const Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Dèmè ',
                  style: TextStyle(
                    color: CouleursApp.vert,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'Mali',
                  style: TextStyle(
                    color: CouleursApp.jaune,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // TITRE
        const Text(
          'Bienvenue sur\nDèmè Mali',
          style: TextStyle(
            color: CouleursApp.vert,
            fontSize: 22,
            height: 1.15,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        // DESCRIPTION
        const Text(
          'Ensemble, facilitons les dons et l’accès '
              'à l’aide en toute transparence.',
          style: TextStyle(
            color: CouleursApp.noir,
            fontSize: 14,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

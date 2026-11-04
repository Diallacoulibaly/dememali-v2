
import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

class WidgetPresentation extends StatelessWidget {
  const WidgetPresentation({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Titre centré, sans retour à la ligne supplémentaire.
        const SizedBox(
          width: double.infinity,
          child: Text(
            'Un petit geste peut\nchanger une vie',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CouleursApp.vert,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Description centrée.
        const SizedBox(
          width: double.infinity,
          child: Text(
            'Chaque don contribue à répondre à un besoin réel : '
                'santé, éducation, alimentation, etc.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CouleursApp.noir,
              fontSize: 14,
              height: 1.35,
            ),
          ),
        ),

        const SizedBox(height: 26),

        // Illustrations remontées et espacées.
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _illustration(
              icon: Icons.volunteer_activism,
              label: 'Don',
            ),

            const Icon(
              Icons.arrow_forward,
              color: CouleursApp.vert,
              size: 25,
            ),

            _illustration(
              icon: Icons.groups,
              label: 'Besoin réel',
            ),
          ],
        ),
      ],
    );
  }

  Widget _illustration({
    required IconData icon,
    required String label,
  }) {
    return SizedBox(
      width: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFE2F0E7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: CouleursApp.vert,
              size: 43,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: CouleursApp.vert,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

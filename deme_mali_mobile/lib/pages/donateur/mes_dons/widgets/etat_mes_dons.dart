
import 'package:flutter/material.dart';
import 'package:deme_mali_mobile/styles/couleurs.dart';

class EtatMesDons extends StatelessWidget {
  final String message;

  const EtatMesDons({
    super.key,
    this.message = 'Aucun don pour le moment.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 36,
      ),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: CouleursApp.fond,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.volunteer_activism_outlined,
              size: 42,
              color: CouleursApp.vert,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Mes dons',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CouleursApp.noir,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: CouleursApp.noir.withAlpha(170),
            ),
          ),
        ],
      ),
    );
  }
}

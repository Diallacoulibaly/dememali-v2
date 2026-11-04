
import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

class WidgetLogo extends StatelessWidget {
  const WidgetLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo_acceuil.png',
          width: 82,
          height: 82,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/images/logo_accueil.png',
            width: 82,
            height: 82,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text: 'Dèmè ',
                style: TextStyle(color: CouleursApp.vert),
              ),
              TextSpan(
                text: 'Mali',
                style: TextStyle(color: CouleursApp.jaune),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

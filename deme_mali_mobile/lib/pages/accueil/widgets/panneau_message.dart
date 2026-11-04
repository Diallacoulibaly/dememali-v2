
import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

class PanneauMessage extends StatelessWidget {
  const PanneauMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      child: Text(
        'Votre geste peut apporter une aide concrète.',
        textAlign: TextAlign.left,
        style: TextStyle(
          color: CouleursApp.blanc,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
      ),
    );
  }
}

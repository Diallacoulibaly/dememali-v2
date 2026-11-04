
import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

class BoutonContinuer extends StatelessWidget {
  final bool actif;
  final VoidCallback onPressed;

  const BoutonContinuer({
    super.key,
    required this.actif,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 43,
      child: ElevatedButton(
        onPressed: actif ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: CouleursApp.vert,
          disabledBackgroundColor: const Color(0xFFA8CBB8),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          'Continuer',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

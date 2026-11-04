
import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

class BoutonConnexion extends StatelessWidget {
  final bool chargement;
  final VoidCallback onPressed;

  const BoutonConnexion({
    super.key,
    required this.chargement,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: chargement ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: CouleursApp.vert,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFA8CBB8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: chargement
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text('Se connecter'),
      ),
    );
  }
}

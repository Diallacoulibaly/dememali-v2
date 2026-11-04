
import 'package:flutter/material.dart';

class LogoAnime extends StatelessWidget {
  final double taille;

  const LogoAnime({
    super.key,
    required this.taille,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: taille,
      height: taille,
      child: Image.asset(
        'assets/images/logo_acceuil.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/logo_accueil.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

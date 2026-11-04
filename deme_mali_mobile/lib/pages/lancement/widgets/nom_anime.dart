
import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

class NomAnime extends StatelessWidget {
  final String texte;

  const NomAnime({
    super.key,
    required this.texte,
  });

  @override
  Widget build(BuildContext context) {
    const String partieVerte = 'Dèmè';

    final int longueurVerte =
    texte.length < partieVerte.length
        ? texte.length
        : partieVerte.length;

    final String texteVert =
    texte.substring(0, longueurVerte);

    final String texteJaune =
    texte.length > partieVerte.length
        ? texte.substring(partieVerte.length)
        : '';

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: texteVert,
            style: const TextStyle(
              color: CouleursApp.vert,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: texteJaune,
            style: const TextStyle(
              color: CouleursApp.jaune,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

class BoutonDemandeAide extends StatelessWidget {
  const BoutonDemandeAide({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: onPressed, icon: const Icon(Icons.add_circle_outline),
      label: const Text('Faire une demande d’aide'),
      style: ElevatedButton.styleFrom(
        backgroundColor: CouleursApp.vert, foregroundColor: CouleursApp.blanc,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ));
}

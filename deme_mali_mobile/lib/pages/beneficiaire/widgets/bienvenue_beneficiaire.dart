import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

class BienvenueBeneficiaire extends StatelessWidget {
  const BienvenueBeneficiaire({super.key, required this.prenom});
  final String prenom;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Bonjour${prenom.trim().isEmpty ? '' : ', $prenom'} 👋',
        style: const TextStyle(color: CouleursApp.noir, fontSize: 23, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      const Text('Heureux de vous retrouver sur Dèmè Mali.',
        style: TextStyle(color: Colors.black54, fontSize: 14)),
    ],
  );
}

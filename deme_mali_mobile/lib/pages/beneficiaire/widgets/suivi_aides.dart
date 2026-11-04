import 'package:flutter/material.dart';
import '../../../models/demande_aide.dart';
import '../../../styles/couleurs.dart';

class SuiviAides extends StatelessWidget {
  const SuiviAides({super.key, required this.demandes});
  final List<DemandeAide> demandes;

  @override
  Widget build(BuildContext context) {
    final waiting = demandes.where((d) => d.statut.toUpperCase() == 'EN_ATTENTE').length;
    final accepted = demandes.where((d) => ['VALIDEE','VALIDÉE','ACCEPTEE','ACCEPTÉE'].contains(d.statut.toUpperCase())).length;
    final rejected = demandes.where((d) => ['REJETEE','REJETÉE'].contains(d.statut.toUpperCase())).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Suivi de mes aides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: CouleursApp.noir)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _Indicateur(nombre: '$waiting', titre: 'En attente', icone: Icons.hourglass_empty)),
        const SizedBox(width: 10),
        Expanded(child: _Indicateur(nombre: '$accepted', titre: 'Validées', icone: Icons.check_circle_outline)),
        const SizedBox(width: 10),
        Expanded(child: _Indicateur(nombre: '$rejected', titre: 'Rejetées', icone: Icons.cancel_outlined)),
      ]),
    ]);
  }
}

class _Indicateur extends StatelessWidget {
  const _Indicateur({required this.nombre, required this.titre, required this.icone});
  final String nombre, titre;
  final IconData icone;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
    decoration: BoxDecoration(color: CouleursApp.blanc, borderRadius: BorderRadius.circular(16)),
    child: Column(children: [
      Icon(icone, color: CouleursApp.vert, size: 22),
      const SizedBox(height: 8),
      Text(nombre, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: CouleursApp.noir)),
      const SizedBox(height: 4),
      Text(titre, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.black54)),
    ]),
  );
}

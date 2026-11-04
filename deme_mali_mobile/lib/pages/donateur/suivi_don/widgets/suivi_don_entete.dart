import 'package:flutter/material.dart';

import 'package:deme_mali_mobile/styles/couleurs.dart';

import '../../../../models/don_financier.dart';
import '../../../../models/don_materiel.dart';

class SuiviDonEntete extends StatelessWidget {
  final DonFinancier? donFinancier;
  final DonMateriel? donMateriel;

  const SuiviDonEntete({
    super.key,
    this.donFinancier,
    this.donMateriel,
  }) : assert(
  (donFinancier != null) != (donMateriel != null),
  'Fournir un seul type de don.',
  );

  @override
  Widget build(BuildContext context) {
    final financier = donFinancier != null;

    final titre = financier
        ? (donFinancier!.titreDemandeAide ?? 'Don financier')
        : donMateriel!.designation;

    final dateDon = financier ? donFinancier!.dateDon : null;

    final montantOuQuantite = financier
        ? '${_nombre(donFinancier!.montant)} FCFA'
        : '${donMateriel!.quantite} ${donMateriel!.unite}';

    final modePaiement =
    financier ? donFinancier!.modePaiement : null;

    final statut = financier ? null : donMateriel!.statutReception;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CouleursApp.vert.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  financier
                      ? Icons.payments_outlined
                      : Icons.inventory_2_outlined,
                  color: CouleursApp.vert,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  titre,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.noir,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Montant ou quantité
          Text(
            montantOuQuantite,
            softWrap: true,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: CouleursApp.vert,
            ),
          ),

          if (dateDon != null) ...[
            const SizedBox(height: 5),
            Text(
              'Date du don : ${_formaterDate(dateDon)}',
              softWrap: true,
              style: const TextStyle(color: Colors.black54),
            ),
          ],

          if (modePaiement != null && modePaiement.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Paiement : $modePaiement',
              softWrap: true,
              style: const TextStyle(color: Colors.black54),
            ),
          ],

          if (statut != null && statut.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Réception : ${_formaterStatut(statut)}',
              softWrap: true,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }

  String _nombre(double valeur) {
    return valeur.toStringAsFixed(
      valeur == valeur.roundToDouble() ? 0 : 2,
    );
  }

  String _formaterDate(DateTime date) {
    final jour = date.day.toString().padLeft(2, '0');
    final mois = date.month.toString().padLeft(2, '0');

    return '$jour/$mois/${date.year}';
  }

  String _formaterStatut(String statut) {
    return statut
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map(
          (mot) => mot.isEmpty
          ? mot
          : '${mot[0].toUpperCase()}${mot.substring(1)}',
    )
        .join(' ');
  }
}
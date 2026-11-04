import 'package:flutter/material.dart';

import '/../../../models/aide_distribuee.dart';
import '/../../../styles/couleurs.dart';
import 'details_destinataire_aide_widget.dart';
import 'preuves_distribution_widget.dart';

class CarteAideDistribueeWidget extends StatelessWidget {
  const CarteAideDistribueeWidget({
    super.key,
    required this.aide,
  });

  final AideDistribuee aide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CouleursApp.vert.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.noir.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PHOTOS ET VIDÉOS : TOUTE LA LARGEUR DE LA CARTE
          SizedBox(
            width: double.infinity,
            height: 220,
            child: PreuvesDistributionWidget(aide: aide),
          ),

          // INFORMATIONS SUR LE BÉNÉFICIAIRE OU LA DEMANDE
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: DetailsDestinataireAideWidget(aide: aide),
          ),

          // DATE ET LIEU DE DISTRIBUTION
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFEAE5DB),
                ),

                const SizedBox(height: 16),

                if (aide.dateDistribution != null &&
                    aide.dateDistribution.toString().trim().isNotEmpty)
                  _LigneInformation(
                    icone: Icons.calendar_today_outlined,
                    texte: 'Date : ${aide.dateDistribution}',
                  ),

                if ((aide.lieuDistribution ?? '').trim().isNotEmpty)
                  _LigneInformation(
                    icone: Icons.location_on_outlined,
                    texte: 'Lieu : ${aide.lieuDistribution}',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LigneInformation extends StatelessWidget {
  const _LigneInformation({
    required this.icone,
    required this.texte,
  });

  final IconData icone;
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: CouleursApp.vert.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icone,
              size: 17,
              color: CouleursApp.vert,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                texte,
                style: const TextStyle(
                  color: CouleursApp.noir,
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
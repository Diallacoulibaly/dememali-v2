
import 'package:flutter/material.dart';

import '/../../../models/organisation_partenaire.dart';
import '/../../../styles/couleurs.dart';

class AProposOrganisationWidget extends StatelessWidget {
  const AProposOrganisationWidget({
    super.key,
    required this.organisation,
  });

  final OrganisationPartenaire organisation;

  @override
  Widget build(BuildContext context) {
    final description = organisation.description?.trim() ?? '';

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITRE À PROPOS
          const Text(
            'À propos',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: CouleursApp.noir,
            ),
          ),

          const SizedBox(height: 5),

          // PETIT TRAIT VERT SOUS LE TITRE
          Container(
            width: 78,
            height: 3,
            decoration: BoxDecoration(
              color: CouleursApp.vert,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 12),

          // DESCRIPTION
          Text(
            description.isNotEmpty
                ? description
                : 'Aucune description disponible pour cette organisation.',
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: description.isNotEmpty
                  ? CouleursApp.noir.withValues(alpha: 0.70)
                  : CouleursApp.noir.withValues(alpha: 0.45),
            ),
          ),
        ],
      ),
    );
  }
}

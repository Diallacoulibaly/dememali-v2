
import 'package:flutter/material.dart';

import '/../models/organisation_partenaire.dart';
import '/../styles/couleurs.dart';

class CarteOrganisation extends StatelessWidget {
  final OrganisationPartenaire organisation;
  final bool estAimee;
  final VoidCallback onLike;
  final VoidCallback onVoirOrganisation;
  final VoidCallback onSoutenir;

  const CarteOrganisation({
    super.key,
    required this.organisation,
    required this.estAimee,
    required this.onLike,
    required this.onVoirOrganisation,
    required this.onSoutenir,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: CouleursApp.vert.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône représentant l'organisation
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: CouleursApp.vert.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_outlined,
                  color: CouleursApp.vert,
                  size: 30,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      organisation.nomOrganisation,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CouleursApp.noir,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      organisation.typeOrganisation,
                      style: const TextStyle(
                        color: CouleursApp.vert,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (organisation.ville.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              organisation.ville,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Bouton J'aime et nombre de likes
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: estAimee
                        ? 'Retirer des favoris'
                        : 'Ajouter aux favoris',
                    onPressed: onLike,
                    icon: Icon(
                      estAimee
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: estAimee
                          ? Colors.red
                          : CouleursApp.vert,
                      size: 27,
                    ),
                  ),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 16,
                        color: CouleursApp.vert,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${organisation.nombreLikes}',
                        style: const TextStyle(
                          color: CouleursApp.noir,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onVoirOrganisation,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CouleursApp.vert,
                    side: const BorderSide(
                      color: CouleursApp.vert,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Voir l'organisation",
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  onPressed: onSoutenir,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CouleursApp.vert,
                    foregroundColor: CouleursApp.blanc,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 12,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Soutenir',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

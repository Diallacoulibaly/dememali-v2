
import 'package:flutter/material.dart';

import 'package:deme_mali_mobile/models/organisation_partenaire.dart';
import 'package:deme_mali_mobile/styles/couleurs.dart';

class EnteteOrganisationWidget extends StatelessWidget {
  const EnteteOrganisationWidget({
    super.key,
    required this.organisation,
  });

  final OrganisationPartenaire organisation;

  @override
  Widget build(BuildContext context) {
    final informations = <_InformationOrganisation>[
      _InformationOrganisation(
        icone: Icons.location_on_outlined,
        titre: 'Ville',
        valeur: organisation.ville,
      ),
      if ((organisation.adresse ?? '').trim().isNotEmpty)
        _InformationOrganisation(
          icone: Icons.map_outlined,
          titre: 'Adresse',
          valeur: organisation.adresse!.trim(),
        ),
      if ((organisation.email ?? '').trim().isNotEmpty)
        _InformationOrganisation(
          icone: Icons.email_outlined,
          titre: 'E-mail',
          valeur: organisation.email!.trim(),
        ),
      if ((organisation.telephoneOrganisation ?? '').trim().isNotEmpty)
        _InformationOrganisation(
          icone: Icons.phone_outlined,
          titre: 'Téléphone',
          valeur: organisation.telephoneOrganisation!.trim(),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // EN-TÊTE : FLÈCHE DE RETOUR ET TITRE
        Row(
          children: [
            IconButton(
              tooltip: '',
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                size: 20,
                color: CouleursApp.noir,
              ),
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Text(
                "Profil de l'organisation",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: CouleursApp.noir,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // CARTE DES INFORMATIONS DE L'ORGANISATION
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: CouleursApp.blanc,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: CouleursApp.noir.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: CouleursApp.noir.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IDENTITÉ DE L'ORGANISATION
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: CouleursApp.vert.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.account_balance_outlined,
                      size: 32,
                      color: CouleursApp.vert,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          organisation.nomOrganisation,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: CouleursApp.noir,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          organisation.typeOrganisation,
                          style: TextStyle(
                            fontSize: 12,
                            color: CouleursApp.noir.withValues(alpha: 0.60),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Divider(
                height: 1,
                color: Color(0xFFEAE5DB),
              ),

              const SizedBox(height: 16),

              // COORDONNÉES DE L'ORGANISATION
              const Text(
                'Coordonnées',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: CouleursApp.noir,
                ),
              ),

              const SizedBox(height: 14),

              // DEUX INFORMATIONS PAR LIGNE
              LayoutBuilder(
                builder: (context, constraints) {
                  final largeurElement = (constraints.maxWidth - 12) / 2;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 14,
                    children: informations.map((information) {
                      return SizedBox(
                        width: largeurElement,
                        child: _LigneCoordonnee(
                          information: information,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 16),

              // NOMBRE DE LIKES
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7B500).withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite_rounded,
                        size: 15,
                        color: Color(0xFFB88700),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${organisation.nombreLikes} likes',
                        style: const TextStyle(
                          color: CouleursApp.noir,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InformationOrganisation {
  const _InformationOrganisation({
    required this.icone,
    required this.titre,
    required this.valeur,
  });

  final IconData icone;
  final String titre;
  final String valeur;
}

class _LigneCoordonnee extends StatelessWidget {
  const _LigneCoordonnee({
    required this.information,
  });

  final _InformationOrganisation information;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            information.icone,
            size: 16,
            color: CouleursApp.vert,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                information.titre,
                style: TextStyle(
                  fontSize: 10,
                  color: CouleursApp.noir.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                information.valeur,
                softWrap: true,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: CouleursApp.noir,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

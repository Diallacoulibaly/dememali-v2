import 'package:flutter/material.dart';
import '/../models/organisation_partenaire.dart';
import 'carte_organisation.dart';

class ListeOrganisations extends StatelessWidget {
  final List<OrganisationPartenaire> organisations;
  final bool Function(OrganisationPartenaire organisation) estAimee;
  final void Function(OrganisationPartenaire organisation) onLike;
  final void Function(OrganisationPartenaire organisation) onVoirOrganisation;
  final void Function(OrganisationPartenaire organisation) onSoutenir;

  const ListeOrganisations({
    super.key,
    required this.organisations,
    required this.estAimee,
    required this.onLike,
    required this.onVoirOrganisation,
    required this.onSoutenir,
  });

  @override
  Widget build(BuildContext context) {
    if (organisations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey),
              SizedBox(height: 12),
              Text('Aucune organisation trouvée.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: organisations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final organisation = organisations[index];
        return CarteOrganisation(
          key: ValueKey(organisation.id),
          organisation: organisation,
          estAimee: estAimee(organisation),
          onLike: () => onLike(organisation),
          onVoirOrganisation: () => onVoirOrganisation(organisation),
          onSoutenir: () => onSoutenir(organisation),
        );
      },
    );
  }
}


import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/organisation_partenaire.dart';
import '../repositories/organisation_partenaire_repository.dart';

/// Chargement des organisations validées pour un donateur.
final organisationPartenaireControllerProvider =
FutureProvider.family<List<OrganisationPartenaire>, int>(
      (ref, donateurId) async {
    final repository = ref.watch(
      organisationPartenaireRepositoryProvider,
    );

    return repository.getOrganisationsAvecLikes(
      donateurId: donateurId,
    );
  },
);

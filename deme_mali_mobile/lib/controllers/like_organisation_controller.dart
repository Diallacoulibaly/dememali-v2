
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/like_organisation.dart';
import '../models/organisation_partenaire.dart';
import '../repositories/like_organisation_repository.dart';

final likeOrganisationControllerProvider =
Provider<LikeOrganisationController>((ref) {
  return LikeOrganisationController(ref);
});

class LikeOrganisationController {
  final Ref ref;

  LikeOrganisationController(this.ref);

  LikeOrganisationRepository get _repository {
    return ref.read(likeOrganisationRepositoryProvider);
  }

  /// Aimer une organisation.
  Future<void> aimer({
    required int donateurId,
    required int organisationId,
  }) async {
    final like = LikeOrganisation(
      donateurId: donateurId,
      organisationId: organisationId,
    );

    await _repository.aimerOrganisation(like);

    ref.invalidate(organisationsAimeesProvider(donateurId));
  }

  /// Retirer le like.
  Future<void> retirer({
    required int donateurId,
    required int organisationId,
  }) async {
    final like = LikeOrganisation(
      donateurId: donateurId,
      organisationId: organisationId,
    );

    await _repository.retirerLike(like);

    ref.invalidate(organisationsAimeesProvider(donateurId));
  }

  /// Charger les organisations aimées.
  Future<List<OrganisationPartenaire>> chargerOrganisationsAimees(
      int donateurId,
      ) {
    return _repository.getOrganisationsAimees(donateurId);
  }
}

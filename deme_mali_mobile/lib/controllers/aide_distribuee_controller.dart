
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/aide_distribuee.dart';
import '../repositories/aide_distribuee_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/http_client_provider.dart';

/// Provider du repository des aides distribuées.
final aideDistribueeRepositoryProvider =
Provider<AideDistribueeRepository>((ref) {
  final baseUrl = AuthRepository.baseUrl;

  final repository = AideDistribueeRepository(
    baseUrl: baseUrl,
    client: ref.watch(httpClientProvider),
  );

  return repository;
});

/// Récupérer les distributions d'une organisation.
final aidesDistribueesParOrganisationProvider =
FutureProvider.family<List<AideDistribuee>, int>(
      (ref, organisationId) {
    final repository = ref.watch(
      aideDistribueeRepositoryProvider,
    );

    return repository.getByOrganisation(organisationId);
  },
);

/// Récupérer toutes les distributions liées à une demande.
final aidesDistribueesParDemandeProvider =
FutureProvider.family<List<AideDistribuee>, int>(
      (ref, demandeAideId) {
    final repository = ref.watch(
      aideDistribueeRepositoryProvider,
    );

    return repository.getByDemande(demandeAideId);
  },
);

/// Récupérer toutes les distributions liées à un bénéficiaire.
final aidesDistribueesParBeneficiaireProvider =
FutureProvider.family<List<AideDistribuee>, int>(
      (ref, beneficiaireId) {
    final repository = ref.watch(
      aideDistribueeRepositoryProvider,
    );

    return repository.getByBeneficiaire(beneficiaireId);
  },
);

/// Récupérer uniquement les distributions terminées d'une demande.
final aidesDistribueesTermineesParDemandeProvider =
FutureProvider.family<List<AideDistribuee>, int>(
      (ref, demandeAideId) {
    final repository = ref.watch(
      aideDistribueeRepositoryProvider,
    );

    return repository.getDistribueesByDemande(demandeAideId);
  },
);

/// Récupérer uniquement les distributions terminées d'un bénéficiaire.
final aidesDistribueesTermineesParBeneficiaireProvider =
FutureProvider.family<List<AideDistribuee>, int>(
      (ref, beneficiaireId) {
    final repository = ref.watch(
      aideDistribueeRepositoryProvider,
    );

    return repository.getDistribueesByBeneficiaire(beneficiaireId);
  },
);

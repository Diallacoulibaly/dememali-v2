
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/affectation_don_materiel.dart';
import '../repositories/affectation_don_materiel_repository.dart';

/// Récupère les affectations matérielles d'un don précis.
final affectationsMateriellesParDonProvider =
FutureProvider.family<List<AffectationDonMateriel>, int>(
      (ref, donMaterielId) {
    final repository = ref.watch(
      affectationDonMaterielRepositoryProvider,
    );

    return repository.getByDonMateriel(donMaterielId);
  },
);

/// Récupère les affectations matérielles directes d'un bénéficiaire.
final affectationsMateriellesParBeneficiaireProvider =
FutureProvider.family<List<AffectationDonMateriel>, int>(
      (ref, beneficiaireId) {
    final repository = ref.watch(
      affectationDonMaterielRepositoryProvider,
    );

    return repository.getByBeneficiaire(beneficiaireId);
  },
);

/// Récupère toutes les affectations matérielles.
final toutesAffectationsMateriellesProvider =
FutureProvider<List<AffectationDonMateriel>>((ref) {
  final repository = ref.watch(
    affectationDonMaterielRepositoryProvider,
  );

  return repository.getAll();
});

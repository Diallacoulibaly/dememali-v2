
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/affectation_don.dart';
import '../repositories/affectation_don_repository.dart';

/// Affectations d'un don financier.
final affectationsFinancieresParDonProvider =
FutureProvider.family<List<AffectationDon>, int>(
      (ref, donFinancierId) {
    final repository = ref.watch(
      affectationDonRepositoryProvider,
    );

    return repository.getByDon(donFinancierId);
  },
);

/// Affectations financières d'une demande d'aide.
final affectationsFinancieresParDemandeProvider =
FutureProvider.family<List<AffectationDon>, int>(
      (ref, demandeAideId) {
    final repository = ref.watch(
      affectationDonRepositoryProvider,
    );

    return repository.getByDemande(demandeAideId);
  },
);

/// Toutes les affectations financières.
final toutesAffectationsFinancieresProvider =
FutureProvider<List<AffectationDon>>((ref) {
  final repository = ref.watch(
    affectationDonRepositoryProvider,
  );

  return repository.getAll();
});

/// Détail d'une affectation financière.
final affectationFinanciereParIdProvider =
FutureProvider.family<AffectationDon, int>(
      (ref, id) {
    final repository = ref.watch(
      affectationDonRepositoryProvider,
    );

    return repository.getById(id);
  },
);

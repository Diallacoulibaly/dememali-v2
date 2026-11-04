
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/beneficiaire.dart';
import '../repositories/beneficiaire_repository.dart';

/// Charger un bénéficiaire par son identifiant.
final beneficiaireDetailProvider =
FutureProvider.family<Beneficiaire, int>((ref, id) {
  final repository = ref.watch(beneficiaireRepositoryProvider);
  return repository.getBeneficiaireById(id);
});


import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/categorie_demande.dart';
import '../repositories/categorie_demande_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/http_client_provider.dart';

// Provider du repository des catégories.
final categorieDemandeRepositoryProvider =
Provider<CategorieDemandeRepository>((ref) {
  return CategorieDemandeRepository(
    baseUrl: AuthRepository.baseUrl,
    client: ref.watch(httpClientProvider),
  );
});

// Contrôleur pour charger les catégories de demandes.
final categorieDemandeControllerProvider =
FutureProvider<List<CategorieDemande>>((ref) {
  final repository =
  ref.watch(categorieDemandeRepositoryProvider);

  return repository.obtenirCategories();
});

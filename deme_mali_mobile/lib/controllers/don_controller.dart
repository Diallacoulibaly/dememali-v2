
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/don.dart';
import '../repositories/don_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/http_client_provider.dart';

/// Repository des dons
final donRepositoryProvider = Provider<DonRepository>((ref) {
  return DonRepository(
    baseUrl: AuthRepository.baseUrl,
    client: ref.watch(httpClientProvider),
  );
});

/// Controller des dons avec Riverpod
final donControllerProvider =
AsyncNotifierProvider<DonController, List<Don>>(
  DonController.new,
);

class DonController extends AsyncNotifier<List<Don>> {
  late final DonRepository _donRepository;

  @override
  Future<List<Don>> build() async {
    _donRepository = ref.watch(donRepositoryProvider);
    return _donRepository.getAll();
  }

  /// Recharger tous les dons
  Future<void> chargerDons() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(
          () => _donRepository.getAll(),
    );
  }

  /// Récupérer les dons d'un donateur
  Future<List<Don>> chargerDonsDonateur(int donateurId) {
    return _donRepository.getByDonateur(donateurId);
  }

  /// Récupérer les dons d'une demande
  Future<List<Don>> chargerDonsDemande(int demandeAideId) {
    return _donRepository.getByDemande(demandeAideId);
  }

  /// Compter les donateurs distincts d'une demande
  Future<int> compterDonateurs(int demandeAideId) {
    return _donRepository.compterDonateurs(demandeAideId);
  }
}

/// Provider du nombre de donateurs par demande
final nombreDonateursProvider =
FutureProvider.family<int, int>((ref, demandeAideId) async {
  final repository = ref.watch(donRepositoryProvider);

  return repository.compterDonateurs(demandeAideId);
});

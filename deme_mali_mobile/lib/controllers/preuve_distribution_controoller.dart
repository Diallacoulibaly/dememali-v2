
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/preuve_distribution.dart';
import '../repositories/preuve_distribution_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/http_client_provider.dart';

final preuveDistributionRepositoryProvider =
Provider<PreuveDistributionRepository>((ref) {
  final baseUrl = AuthRepository.baseUrl;

  final repository = PreuveDistributionRepository(
    baseUrl: baseUrl,
    client: ref.watch(httpClientProvider),
  );

  return repository;
});

final preuvesParDistributionProvider =
FutureProvider.family<List<PreuveDistribution>, int>(
      (ref, aideDistribueeId) {
    final repository = ref.watch(
      preuveDistributionRepositoryProvider,
    );

    return repository.getByDistribution(aideDistribueeId);
  },
);

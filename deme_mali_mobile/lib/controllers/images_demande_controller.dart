import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/image_demande.dart';
import '../repositories/image_demande_repository.dart';

final imageDemandeControllerProvider =
FutureProvider.autoDispose.family<List<ImageDemande>, int>((ref, demandeId) {
  final repository = ref.watch(imageDemandeRepositoryProvider);
  return repository.getImagesDemande(demandeId);
});

final imageDemandeDetailControllerProvider =
FutureProvider.autoDispose.family<ImageDemande, int>((ref, id) {
  final repository = ref.watch(imageDemandeRepositoryProvider);
  return repository.getImageById(id);
});
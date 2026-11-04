
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/etude_terrain.dart';
import '../repositories/etude_terrain_repository.dart';

final etudeTerrainControllerProvider =
FutureProvider.family<EtudeTerrain?, int>(
      (ref, demandeId) {
    final repository = ref.watch(
      etudeTerrainRepositoryProvider,
    );

    return repository.getEtudePourDemande(demandeId);
  },
);

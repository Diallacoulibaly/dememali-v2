
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/rapport_besoin.dart';
import '../repositories/rapport_besoin_repository.dart';

/// Charger le rapport de besoin à partir de l'identifiant
/// de l'étude de terrain.
final rapportBesoinControllerProvider =
FutureProvider.family<RapportBesoin?, int>(
      (ref, etudeTerrainId) {
    final repository = ref.watch(
      rapportBesoinRepositoryProvider,
    );

    return repository.getRapportBesoinPourEtude(
      etudeTerrainId,
    );
  },
);

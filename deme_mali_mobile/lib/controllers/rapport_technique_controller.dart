
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/rapport_technique.dart';
import '../repositories/rapport_technique_repository.dart';

// Provider Riverpod pour charger le rapport technique
// à partir de l'identifiant de la demande.
final rapportTechniqueProvider =
FutureProvider.family<RapportTechnique?, int>(
      (ref, demandeId) {
    final repository = ref.watch(
      rapportTechniqueRepositoryProvider,
    );

    return repository.getRapportTechniquePourDemande(
      demandeId,
    );
  },
);

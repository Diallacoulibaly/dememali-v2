import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/badge_donateur_model.dart';
import '../repositories/badge_repository.dart';

/// Badges du semestre actuel d'un donateur.
final badgesActuelsProvider =
FutureProvider.family<List<BadgeDonateurModel>, int>(
      (ref, donateurId) {
    final repository = ref.watch(badgeRepositoryProvider);

    return repository.obtenirBadgesActuels(donateurId);
  },
);

/// Historique des badges d'un donateur.
final historiqueBadgesProvider =
FutureProvider.family<List<BadgeDonateurModel>, int>(
      (ref, donateurId) {
    final repository = ref.watch(badgeRepositoryProvider);

    return repository.obtenirHistorique(donateurId);
  },
);

/// Badges d'un semestre précis.
final badgesSemestreProvider = FutureProvider.family<
    List<BadgeDonateurModel>,
    ({int donateurId, int annee, String semestre})>(
      (ref, parametres) {
    final repository = ref.watch(badgeRepositoryProvider);

    return repository.obtenirBadgesSemestre(
      donateurId: parametres.donateurId,
      annee: parametres.annee,
      semestre: parametres.semestre,
    );
  },
);

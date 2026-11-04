
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/don_financier.dart';
import '../repositories/don_financier_repository.dart';

// Charger tous les dons financiers.
final donFinancierControllerProvider =
FutureProvider<List<DonFinancier>>((ref) {
  final repository = ref.watch(
    donFinancierRepositoryProvider,
  );

  return repository.getAll();
});

// Charger un don financier par son identifiant.
final donFinancierDetailControllerProvider =
FutureProvider.family<DonFinancier, int>(
      (ref, id) {
    final repository = ref.watch(
      donFinancierRepositoryProvider,
    );

    return repository.getById(id);
  },
);

// Charger les dons financiers d'un donateur.
final donsFinanciersDonateurControllerProvider =
FutureProvider.family<List<DonFinancier>, int>(
      (ref, donateurId) {
    final repository = ref.watch(
      donFinancierRepositoryProvider,
    );

    return repository.getByDonateur(donateurId);
  },
);

// Charger les dons financiers d'une demande d'aide.
final donsFinanciersDemandeControllerProvider =
FutureProvider.family<List<DonFinancier>, int>(
      (ref, demandeAideId) {
    final repository = ref.watch(
      donFinancierRepositoryProvider,
    );

    return repository.getByDemande(demandeAideId);
  },
);

// Charger le montant total des dons financiers confirmés.
final totalDonsFinanciersControllerProvider =
FutureProvider<double>((ref) {
  final repository = ref.watch(
    donFinancierRepositoryProvider,
  );

  return repository.getTotalDons();
});

// Charger le total des dons financiers affectés.
final totalDonsAffectesControllerProvider =
FutureProvider<double>((ref) {
  final repository = ref.watch(
    donFinancierRepositoryProvider,
  );

  return repository.getTotalDonsAffectes();
});

// Charger le total des dons financiers généraux.
final totalDonsGenerauxControllerProvider =
FutureProvider<double>((ref) {
  final repository = ref.watch(
    donFinancierRepositoryProvider,
  );

  return repository.getTotalDonsGeneraux();
});

// Paramètres pour une période de calcul.
class PeriodeDonFinancier {
  final int donateurId;
  final DateTime debut;
  final DateTime fin;

  const PeriodeDonFinancier({
    required this.donateurId,
    required this.debut,
    required this.fin,
  });
}

// Charger le total des dons financiers confirmés
// d'un donateur pendant une période.
final totalDonsFinanciersParPeriodeControllerProvider =
FutureProvider.family<double, PeriodeDonFinancier>(
      (ref, periode) {
    final repository = ref.watch(
      donFinancierRepositoryProvider,
    );

    return repository.getTotalConfirmeParPeriode(
      donateurId: periode.donateurId,
      debut: periode.debut,
      fin: periode.fin,
    );
  },
);

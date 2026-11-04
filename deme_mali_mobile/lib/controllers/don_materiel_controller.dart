import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/don_materiel.dart';
import '../repositories/don_materiel_repository.dart';
import 'badge_controller.dart';

// 1. Consultation des dons matériels par demande d'aide
final donsMaterielsParDemandeProvider =
FutureProvider.family<List<DonMateriel>, int>(
      (ref, demandeAideId) {
    final repository =
    ref.watch(donMaterielRepositoryProvider);

    return repository.getDonsParDemande(demandeAideId);
  },
);

// Alias de rétrocompatibilité
final donMaterielControllerProvider = donsMaterielsParDemandeProvider;

// 2. Consultation des dons matériels par donateur
final donsMaterielsParDonateurProvider =
FutureProvider.family<List<DonMateriel>, int>(
      (ref, donateurId) {
    final repository =
    ref.watch(donMaterielRepositoryProvider);

    return repository.getByDonateur(donateurId);
  },
);

// 3. Provider pour créer un don matériel général
final creationDonMaterielProvider =
Provider<CreationDonMaterielController>((ref) {
  final repository =
  ref.watch(donMaterielRepositoryProvider);

  return CreationDonMaterielController(ref, repository);
});

// 4. Contrôleur de création
class CreationDonMaterielController {
  final Ref ref;
  final DonMaterielRepository repository;

  CreationDonMaterielController(this.ref, this.repository);

  Future<DonMateriel> creer({
    required String designation,
    required int quantite,
    required String unite,
    required String etatMateriel,
    required bool anonyme,
    required int donateurId,
    int? demandeAideId,
    int? organisationPartenaireId,
    required String adresseLivraison,
  }) async {
    final don = await repository.creerDonMateriel(
      designation: designation,
      quantite: quantite,
      unite: unite,
      etatMateriel: etatMateriel,
      anonyme: anonyme,
      donateurId: donateurId,
      adresseLivraison: adresseLivraison,
      demandeAideId: demandeAideId,
      organisationPartenaireId: organisationPartenaireId,
    );

    // Actualiser les listes et forcer le rafraîchissement des badges
    ref.invalidate(donsMaterielsParDonateurProvider(donateurId));
    ref.invalidate(badgesActuelsProvider(donateurId));
    ref.invalidate(historiqueBadgesProvider(donateurId));

    if (demandeAideId != null) {
      ref.invalidate(donsMaterielsParDemandeProvider(demandeAideId));
    }

    return don;
  }
}

// 5. Paramètres pour la statistique par période
class PeriodeDonMateriel {
  final int donateurId;
  final DateTime debut;
  final DateTime fin;

  const PeriodeDonMateriel({
    required this.donateurId,
    required this.debut,
    required this.fin,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PeriodeDonMateriel &&
            other.donateurId == donateurId &&
            other.debut == debut &&
            other.fin == fin);
  }

  @override
  int get hashCode => Object.hash(donateurId, debut, fin);
}

// 6. Statistique : Valeur du matériel réellement reçu
final valeurMaterielleRecueProvider =
FutureProvider.family<double, PeriodeDonMateriel>(
      (ref, periode) {
    final repository =
    ref.watch(donMaterielRepositoryProvider);

    return repository.getValeurMaterielleRecue(
      donateurId: periode.donateurId,
      debut: periode.debut,
      fin: periode.fin,
    );
  },
);

// Alias de rétrocompatibilité
final valeurMaterielleRecueControllerProvider = valeurMaterielleRecueProvider;

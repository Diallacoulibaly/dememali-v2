import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/paiement_don.dart';
import '../repositories/paiement_don_repository.dart';
import 'badge_controller.dart';
import 'don_financier_controller.dart';

// Fournir le contrôleur de paiement.
final paiementDonControllerProvider = Provider<PaiementDonController>((ref) {
  final repository = ref.watch(
    paiementDonRepositoryProvider,
  );

  return PaiementDonController(ref, repository);
});

class PaiementDonController {
  final Ref ref;
  final PaiementDonRepository repository;

  PaiementDonController(this.ref, this.repository);

  // Effectuer un paiement via le backend.
  Future<PaiementDon> effectuerPaiement({
    required double montant,
    required String numeroTelephone,
    required String codeSecret,
    required int donateurId,
    required String modePaiement,
    required bool anonyme,
    int? demandeAideId,
    int? organisationPartenaireId,
  }) async {
    final paiement = await repository.effectuerPaiement(
      montant: montant,
      numeroTelephone: numeroTelephone,
      codeSecret: codeSecret,
      donateurId: donateurId,
      modePaiement: modePaiement,
      anonyme: anonyme,
      demandeAideId: demandeAideId,
      organisationPartenaireId: organisationPartenaireId,
    );

    // Actualiser les données si le paiement est confirmé.
    if (paiement.statut == 'CONFIRME') {
      ref.invalidate(donFinancierControllerProvider);
      ref.invalidate(donFinancierDetailControllerProvider);
      ref.invalidate(totalDonsFinanciersControllerProvider);
      ref.invalidate(totalDonsAffectesControllerProvider);
      ref.invalidate(totalDonsGenerauxControllerProvider);

      ref.invalidate(
        donsFinanciersDonateurControllerProvider(donateurId),
      );

      // Invalider immédiatement les badges pour forcer le rechargement
      ref.invalidate(badgesActuelsProvider(donateurId));
      ref.invalidate(historiqueBadgesProvider(donateurId));

      if (demandeAideId != null) {
        ref.invalidate(
          donsFinanciersDemandeControllerProvider(demandeAideId),
        );
      }
    }

    return paiement;
  }
}

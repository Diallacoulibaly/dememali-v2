import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/aide_recue.dart';
import '../models/beneficiaire.dart';
import '../models/demande_aide.dart';
import '../repositories/demande_aide_repository.dart';

/// 1. Provider du Repository :
final demandeAideRepositoryProvider = Provider<DemandeAideRepository>(
  (ref) => DemandeAideRepository(),
);

/// 2. FutureProvider pour les demandes du bénéficiaire :
final mesDemandesBeneficiaireProvider = FutureProvider<List<DemandeAide>>(
  (ref) async {
    final repo = ref.watch(demandeAideRepositoryProvider);
    final userIdStr = await repo.stockage.read(key: 'userId');
    final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
    final demandes = await repo.chargerMesDemandes(beneficiaireId: userId);
    demandes.sort(DemandeAide.comparerPlusRecentDAbord);
    return demandes;
  },
);

/// Demandes validées avec étude terminée des autres bénéficiaires, visibles en lecture.
final demandesPartenairesBeneficiaireProvider = FutureProvider<List<DemandeAide>>(
  (ref) async {
    final repo = ref.watch(demandeAideRepositoryProvider);
    final userIdStr = await repo.stockage.read(key: 'userId');
    final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
    if (userId == null) return [];

    final demandes = await repo.getAll();
    return demandes.where((demande) => demande.beneficiaireId != userId).toList();
  },
);

/// 3. FutureProvider pour les aides reçues / distribuées du bénéficiaire :
final mesAidesDistribueesProvider = FutureProvider.autoDispose<List<AideRecue>>(
  (ref) async {
    final repo = ref.watch(demandeAideRepositoryProvider);
    final userIdStr = await repo.stockage.read(key: 'userId');
    final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
    if (userId == null) return [];
    return repo.getAidesDistribueesByBeneficiaire(userId);
  },
);

/// 4. FutureProvider pour le profil complet du bénéficiaire et son organisation partenaire :
final profilBeneficiaireProvider = FutureProvider.autoDispose<Beneficiaire?>(
  (ref) async {
    final repo = ref.watch(demandeAideRepositoryProvider);
    final userIdStr = await repo.stockage.read(key: 'userId');
    final userId = userIdStr != null ? int.tryParse(userIdStr) : null;
    if (userId == null) return null;
    return repo.getProfilBeneficiaireComplet(userId);
  },
);

/// 5. Notifier pour retenir l'onglet actuellement affiché :
/// 0: Accueil, 1: Mes demandes, 2: Aides reçues, 3: Profil
class OngletBeneficiaireNotifier extends Notifier<int> {
  @override
  int build() => 0;

  @override
  set state(int value) => super.state = value;

  void changerOnglet(int index) => state = index;
}

final ongletActifBeneficiaireProvider =
    NotifierProvider<OngletBeneficiaireNotifier, int>(
  OngletBeneficiaireNotifier.new,
);



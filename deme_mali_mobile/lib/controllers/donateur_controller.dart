
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/donateur.dart';
import '../repositories/donateur_repository.dart';

final donateurControllerProvider =
Provider<DonateurController>((ref) {
  return DonateurController(
    ref,
    ref.watch(donateurRepositoryProvider),
  );
});

class DonateurController {
  final Ref ref;
  final DonateurRepository repository;

  DonateurController(this.ref, this.repository);

  Future<Donateur> getById(int id) async {
    return repository.getById(id);
  }

  Future<List<Donateur>> getAll() async {
    return repository.getAll();
  }

  Future<Donateur> creer(Map<String, dynamic> donnees) async {
    final donateur = await repository.creer(donnees);

    ref.invalidate(tousLesDonateursProvider);
    return donateur;
  }

  Future<Donateur> modifierPays({
    required int donateurId,
    required int paysId,
  }) async {
    final donateur = await repository.modifierPays(
      donateurId: donateurId,
      paysId: paysId,
    );

    ref.invalidate(donateurProvider(donateurId));
    ref.invalidate(tousLesDonateursProvider);

    return donateur;
  }
}

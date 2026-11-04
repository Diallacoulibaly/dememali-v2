
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/don_financier.dart';
import '../models/don_materiel.dart';
import '../repositories/don_financier_repository.dart';
import '../repositories/don_materiel_repository.dart';

class MesDonsData {
  final List<DonFinancier> donsFinanciers;
  final List<DonMateriel> donsMateriels;

  const MesDonsData({
    required this.donsFinanciers,
    required this.donsMateriels,
  });

  int get nombreTotal =>
      donsFinanciers.length + donsMateriels.length;

  double get montantTotalFinancier {
    return donsFinanciers.fold<double>(
      0.0,
          (total, don) => total + don.montant,
    );
  }
}

final mesDonsProvider =
FutureProvider.family<MesDonsData, int>(
      (ref, donateurId) async {
    final repositoryFinancier =
    ref.watch(donFinancierRepositoryProvider);

    final repositoryMateriel =
    ref.watch(donMaterielRepositoryProvider);

    List<DonFinancier> donsFinanciers;
    List<DonMateriel> donsMateriels;

    try {
      donsFinanciers =
      await repositoryFinancier.getByDonateur(donateurId);
      print(
        'DONS FINANCIERS CHARGÉS : ${donsFinanciers.length}',
      );
    } catch (e, stackTrace) {
      print('ERREUR DONS FINANCIERS : $e');
      print(stackTrace);
      rethrow;
    }

    try {
      donsMateriels =
      await repositoryMateriel.getByDonateur(donateurId);
      print(
        'DONS MATÉRIELS CHARGÉS : ${donsMateriels.length}',
      );
    } catch (e, stackTrace) {
      print('ERREUR DONS MATÉRIELS : $e');
      print(stackTrace);
      rethrow;
    }

    return MesDonsData(
      donsFinanciers: donsFinanciers,
      donsMateriels: donsMateriels,
    );
  },
);

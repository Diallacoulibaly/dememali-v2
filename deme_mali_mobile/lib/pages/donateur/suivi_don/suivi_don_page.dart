
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/don_financier.dart';
import '../../../models/don_materiel.dart';
import '../../../models/affectation_don.dart';
import '../../../models/affectation_don_materiel.dart';

import '../../../controllers/affectation_don_controller.dart';
import '../../../controllers/affectation_don_materiel_controller.dart';
import '../../../controllers/demande_aide_controller.dart';

import 'package:deme_mali_mobile/styles/couleurs.dart';
import 'widgets/suivi_don_entete.dart';
import 'widgets/suivi_don_timeline.dart';
import 'widgets/suivi_don_etat.dart';

class SuiviDonPage extends ConsumerWidget {
  final DonFinancier? donFinancier;
  final DonMateriel? donMateriel;

  const SuiviDonPage({
    super.key,
    this.donFinancier,
    this.donMateriel,
  }) : assert(
  (donFinancier != null) != (donMateriel != null),
  'Fournir un seul type de don.',
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financier = donFinancier != null;
    final donId = financier ? donFinancier!.id : donMateriel!.id;

    final demandeDirecteId = financier
        ? donFinancier!.demandeAideId
        : donMateriel!.demandeAideId;

    final financieres = financier
        ? ref.watch(affectationsFinancieresParDonProvider(donId))
        : const AsyncValue<List<AffectationDon>>.data([]);

    final materielles = !financier
        ? ref.watch(affectationsMateriellesParDonProvider(donId))
        : const AsyncValue<List<AffectationDonMateriel>>.data([]);

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: AppBar(
        title: const Text('Suivi de mon don',

          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),),
        backgroundColor: CouleursApp.fond,
        foregroundColor: CouleursApp.noir,
        elevation: 0,

      ),
      body: RefreshIndicator(
        color: CouleursApp.vert,
        onRefresh: () async {
          if (financier) {
            ref.invalidate(
              affectationsFinancieresParDonProvider(donId),
            );
          } else {
            ref.invalidate(
              affectationsMateriellesParDonProvider(donId),
            );
          }

          if (demandeDirecteId != null) {
            ref.invalidate(
              demandeAideDetailProvider(demandeDirecteId),
            );
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            SuiviDonEntete(
              donFinancier: donFinancier,
              donMateriel: donMateriel,
            ),
            const SizedBox(height: 20),
            const Text(
              'Progression de votre don',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: CouleursApp.noir,
              ),
            ),
            const SizedBox(height: 12),

            if (financier)
              financieres.when(
                loading: () => _chargement(),
                error: (e, _) => SuiviDonEtat(
                  message:
                  'Impossible de charger les affectations financières.',
                  detail: '$e',
                  onRetry: () => ref.invalidate(
                    affectationsFinancieresParDonProvider(donId),
                  ),
                ),
                data: (items) {
                  if (demandeDirecteId == null) {
                    return SuiviDonTimeline(
                      donFinancier: donFinancier,
                      affectations: items,
                    );
                  }

                  final demandeAsync = ref.watch(
                    demandeAideDetailProvider(demandeDirecteId),
                  );

                  return demandeAsync.when(
                    loading: () => _chargement(),
                    error: (e, _) => SuiviDonEtat(
                      message:
                      'Impossible de charger la demande associée.',
                      detail: '$e',
                      onRetry: () => ref.invalidate(
                        demandeAideDetailProvider(demandeDirecteId),
                      ),
                    ),
                    data: (demande) => SuiviDonTimeline(
                      donFinancier: donFinancier,
                      affectations: items,
                      demandeAide: demande,
                    ),
                  );
                },
              )
            else
              materielles.when(
                loading: () => _chargement(),
                error: (e, _) => SuiviDonEtat(
                  message:
                  'Impossible de charger les affectations matérielles.',
                  detail: '$e',
                  onRetry: () => ref.invalidate(
                    affectationsMateriellesParDonProvider(donId),
                  ),
                ),
                data: (items) {
                  if (demandeDirecteId == null) {
                    return SuiviDonTimeline(
                      donMateriel: donMateriel,
                      affectationsMaterielles: items,
                    );
                  }

                  final demandeAsync = ref.watch(
                    demandeAideDetailProvider(demandeDirecteId),
                  );

                  return demandeAsync.when(
                    loading: () => _chargement(),
                    error: (e, _) => SuiviDonEtat(
                      message:
                      'Impossible de charger la demande associée.',
                      detail: '$e',
                      onRetry: () => ref.invalidate(
                        demandeAideDetailProvider(demandeDirecteId),
                      ),
                    ),
                    data: (demande) => SuiviDonTimeline(
                      donMateriel: donMateriel,
                      affectationsMaterielles: items,
                      demandeAide: demande,
                    ),
                  );
                },
              ),

            const SizedBox(height: 12),

          ],
        ),
      ),
    );
  }

  Widget _chargement() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: CircularProgressIndicator(
          color: CouleursApp.vert,
        ),
      ),
    );
  }
}

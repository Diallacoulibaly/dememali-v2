
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/../../controllers/mes_dons_controller.dart';
import 'widgets/resume_mes_dons.dart';
import 'widgets/filtres_mes_dons.dart';
import 'widgets/carte_don_financier.dart';
import 'widgets/carte_don_materiel.dart';
import 'widgets/etat_mes_dons.dart';

// Adapte ce chemin à l'emplacement réel du fichier.
import 'package:deme_mali_mobile/pages/donateur/suivi_don/suivi_don_page.dart';
class MesDonsPage extends ConsumerStatefulWidget {
  final int donateurId;

  const MesDonsPage({
    super.key,
    required this.donateurId,
  });

  @override
  ConsumerState<MesDonsPage> createState() => _MesDonsPageState();
}

class _MesDonsPageState extends ConsumerState<MesDonsPage> {
  FiltreMesDons filtreSelectionne = FiltreMesDons.tous;

  static const Color couleurFond = Color(0xFFF7F3EA);
  static const Color vert = Color(0xFF0F7A4B);
  static const Color noir = Color(0xFF1F1F1F);

  @override
  Widget build(BuildContext context) {
    final resultat = ref.watch(
      mesDonsProvider(widget.donateurId),
    );

    return Scaffold(
      backgroundColor: couleurFond,
      appBar: AppBar(
        backgroundColor: couleurFond,
        foregroundColor: noir,
        elevation: 0,
        title: const Text(
          'Mes dons',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: resultat.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: vert),
        ),
        error: (erreur, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Impossible de charger vos dons.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        data: (donnees) {
          final donsFinanciers =
          filtreSelectionne == FiltreMesDons.materiels
              ? donnees.donsFinanciers
              .where((don) => false)
              .toList()
              : donnees.donsFinanciers;

          final donsMateriels =
          filtreSelectionne == FiltreMesDons.financiers
              ? donnees.donsMateriels
              .where((don) => false)
              .toList()
              : donnees.donsMateriels;

          final aucunDon =
              donsFinanciers.isEmpty && donsMateriels.isEmpty;

          return RefreshIndicator(
            color: vert,
            onRefresh: () async {
              await ref.refresh(
                mesDonsProvider(widget.donateurId).future,
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Votre générosité fait la différence.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 20),

                ResumeMesDons(
                  nombreDons: donnees.nombreTotal,
                  montantTotal: donnees.montantTotalFinancier,
                ),

                const SizedBox(height: 28),

                const Text(
                  'Historique de mes dons',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: noir,
                  ),
                ),
                const SizedBox(height: 14),

                FiltresMesDons(
                  filtreSelectionne: filtreSelectionne,
                  onFiltreChange: (nouveauFiltre) {
                    setState(() {
                      filtreSelectionne = nouveauFiltre;
                    });
                  },
                ),

                const SizedBox(height: 20),

                if (aucunDon)
                  const EtatMesDons(
                    message: 'Aucun don dans cette catégorie.',
                  )
                else ...[
                  if (donsFinanciers.isNotEmpty) ...[
                    const Text(
                      'Dons financiers',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: vert,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...donsFinanciers.map(
                          (don) => InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SuiviDonPage(
                                donFinancier: don,
                              ),
                            ),
                          );
                        },
                        child: CarteDonFinancier(don: don),
                      ),
                    ),
                  ],

                  if (donsMateriels.isNotEmpty) ...[
                    if (donsFinanciers.isNotEmpty)
                      const SizedBox(height: 16),

                    const Text(
                      'Dons matériels',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: vert,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ...donsMateriels.map(
                          (don) => InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SuiviDonPage(
                                donMateriel: don,
                              ),
                            ),
                          );
                        },
                        child: CarteDonMateriel(don: don),
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

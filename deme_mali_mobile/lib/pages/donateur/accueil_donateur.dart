
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/demande_aide_controller.dart';
import '../../models/categorie_demande.dart';
import '../../styles/couleurs.dart';

import 'widgets/entete_donateur.dart';
import 'widgets/banniere_don_general.dart';
import 'widgets/titre_demandes.dart';
import 'widgets/filtres_categories.dart';
import 'widgets/liste_demandes_don.dart';
import 'liste_demande_don/liste_demandes_don.dart';

class AccueilDonateurPage extends ConsumerStatefulWidget {
  final String prenom;
  final int donateurId;

  const AccueilDonateurPage({
    super.key,
    required this.prenom,
    required this.donateurId,
  });

  @override
  ConsumerState<AccueilDonateurPage> createState() =>
      _AccueilDonateurPageState();
}

class _AccueilDonateurPageState
    extends ConsumerState<AccueilDonateurPage> {
  int? categorieSelectionneeId;

  @override
  Widget build(BuildContext context) {
    final demandesAsync = ref.watch(demandeAideControllerProvider);

    final categories = demandesAsync.maybeWhen(
      data: (demandes) {
        final categoriesParId = <int, CategorieDemande>{};

        for (final demande in demandes) {
          final id = demande.categorieDemandeId;
          final nom = demande.categorieDemandeNom?.trim() ?? '';

          if (id != null && nom.isNotEmpty) {
            categoriesParId.putIfAbsent(
              id,
                  () => CategorieDemande.fromDemande(
                id: id,
                nom: nom,
              ),
            );
          }
        }

        final resultat = categoriesParId.values.toList()
          ..sort(
                (a, b) => a.nom.toLowerCase().compareTo(
              b.nom.toLowerCase(),
            ),
          );

        return resultat;
      },
      orElse: () => <CategorieDemande>[],
    );

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: RefreshIndicator(
          color: CouleursApp.vert,
          onRefresh: () => ref
              .read(demandeAideControllerProvider.notifier)
              .actualiser(),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    EnteteDonateur(
                      prenom: widget.prenom,
                      donateurId: widget.donateurId,
                    ),
                    BanniereDonGeneral(
                      donateurId: widget.donateurId,
                      prenom: widget.prenom,
                    ),
                    TitreDemandes(
                      onVoirTout: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListeDemandesDonPage(
                              donateurId: widget.donateurId,
                              prenom: widget.prenom,
                              categorieInitialeId: categorieSelectionneeId,
                            ),
                          ),
                        );
                      },
                    ),
                    FiltresCategories(
                      categories: categories,
                      categorieSelectionneeId: categorieSelectionneeId,
                      onSelectionChanged: (id) {
                        setState(() {
                          categorieSelectionneeId = id;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
            body: ListeDemandesDon(
              donateurId: widget.donateurId,
              prenom: widget.prenom,
              categorieSelectionneeId: categorieSelectionneeId,
            ),
          ),
        ),
      ),
    );
  }
}

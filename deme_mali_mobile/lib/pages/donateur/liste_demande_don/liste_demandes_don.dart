
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/demande_aide_controller.dart';
import '../../../controllers/categorie_demande_controller.dart';
import '../../../models/demande_aide.dart';
import '../../../models/categorie_demande.dart';

import '../widgets/carte_demande_don.dart';
import 'widgets/entete_liste_demandes.dart';
import '../detail/detail_demande_page.dart';
import '../don/faire_un_don_page.dart';
import '../don/don_financier/don_financier_page.dart';

class ListeDemandesDonPage extends ConsumerStatefulWidget {
  final int donateurId;
  final int? organisationPartenaireId;
  final int? categorieInitialeId;
  final String prenom;


  const ListeDemandesDonPage({
    super.key,
    required this.donateurId,
    this.organisationPartenaireId,
    this.categorieInitialeId,
    required this.prenom
  });

  @override
  ConsumerState<ListeDemandesDonPage> createState() =>
      _ListeDemandesDonPageState();
}

class _ListeDemandesDonPageState
    extends ConsumerState<ListeDemandesDonPage> {
  String texteRecherche = '';
  int? categorieSelectionneeId;

  @override
  void initState() {
    super.initState();
    categorieSelectionneeId = widget.categorieInitialeId;
  }

  // FILTRAGE DES DEMANDES
  List<DemandeAide> filtrerDemandes(
    List<DemandeAide> demandes, {
    required int? categorieId,
  }) {
    final recherche = texteRecherche.trim().toLowerCase();

    return demandes.where((demande) {
      final correspondRecherche =
          demande.titre.toLowerCase().contains(recherche) ||
          demande.descriptionSituation.toLowerCase().contains(recherche);

      final correspondCategorie =
          categorieId == null ||
              demande.categorieDemandeId ==
                  categorieId;

      return correspondRecherche && correspondCategorie;
    }).toList();
  }

  // OUVERTURE DU FORMULAIRE DE DON
  void _ouvrirChoixDon(DemandeAide demande) {
    if (demande.estFinanciere) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DonFinancierPage(
            prenom: widget.prenom,
            donateurId: widget.donateurId,
            demandeAideId: demande.id,
            organisationPartenaireId:
            widget.organisationPartenaireId,
          ),
        ),
      );
    } else if (demande.estMaterielle) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FaireUnDonPage(
            donateurId: widget.donateurId,
            demandeAideId: demande.id,
            organisationPartenaireId: widget.organisationPartenaireId,
            prenom: widget.prenom,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Le type de cette demande est inconnu.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final demandesAsync =
    ref.watch(demandeAideControllerProvider);
    final categoriesConnues =
        ref.watch(categorieDemandeControllerProvider).asData?.value ??
            const <CategorieDemande>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EA),
      body: SafeArea(
        child: demandesAsync.when(
          // CHARGEMENT
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF0F7A4B),
            ),
          ),

          // ERREUR DE CHARGEMENT
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 42,
                    color: Color(0xFF0F7A4B),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Impossible de charger les demandes.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // DONNÉES CHARGÉES
          data: (demandes) {
            // CATÉGORIES DISPONIBLES
            final categoriesParId =
            <int, CategorieDemande>{};

            final idsPresents = demandes
                .map((demande) => demande.categorieDemandeId)
                .whereType<int>()
                .toSet();
            for (final categorie in categoriesConnues) {
              if (idsPresents.contains(categorie.id)) {
                categoriesParId[categorie.id] = categorie;
              }
            }

            for (final demande in demandes) {
              final id = demande.categorieDemandeId;
              final nom = demande.categorieDemandeNom?.trim();

              if (id != null &&
                  nom != null &&
                  nom.isNotEmpty) {
                categoriesParId.putIfAbsent(
                  id,
                      () => CategorieDemande(
                    id: id,
                    nom: nom,
                  ),
                );
              }
            }

            final categories =
            categoriesParId.values.toList()
              ..sort(
                    (a, b) => a.nom
                    .toLowerCase()
                    .compareTo(
                  b.nom.toLowerCase(),
                ),
              );

            // VÉRIFICATION DES SÉLECTIONS
            final categorieActive =
            categorieSelectionneeId != null &&
                categoriesParId.containsKey(
                  categorieSelectionneeId,
                )
                ? categorieSelectionneeId
                : null;

            // NOMS DES CATÉGORIES POUR L'EN-TÊTE
            final nomsCategories = <String>[
              'Toutes',
              ...categories.map(
                    (categorie) => categorie.nom,
              ),
            ];

            final nomCategorieActive =
            categorieActive == null
                ? 'Toutes'
                : categoriesParId[categorieActive]?.nom ??
                'Toutes';

            // FILTRAGE DES RÉSULTATS
            final resultats = filtrerDemandes(
              demandes,
              categorieId: categorieActive,
            );

            return RefreshIndicator(
              onRefresh: () => ref
                  .read(demandeAideControllerProvider.notifier)
                  .actualiser(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: EnteteListeDemandes(
                  categories: nomsCategories,
                  categorieSelectionnee: nomCategorieActive,

                  onCategorieChanged: (nom) {
                    setState(() {
                      if (nom == 'Toutes') {
                        categorieSelectionneeId = null;
                      } else {
                        final correspondances = categories.where(
                              (categorie) =>
                          categorie.nom == nom,
                        );

                        categorieSelectionneeId =
                        correspondances.isEmpty
                            ? null
                            : correspondances.first.id;
                      }
                    });
                  },

                  onRechercheChanged: (valeur) {
                    setState(() {
                      texteRecherche = valeur;
                    });
                  },

                  nombreDemandes: resultats.length,
                  )),

                  if (resultats.isEmpty)
                    const SliverToBoxAdapter(child: SizedBox(
                      height: 180,
                      child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: Color(0xFF0F7A4B),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Aucune demande trouvée',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F1F1F),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Essayez de modifier votre recherche '
                                'ou vos filtres.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF777777),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                    ))
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      24,
                    ),
                      sliver: SliverList(delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final demande = resultats[index];

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 14,
                        ),
                        child: CarteDemandeDon(
                          demande: demande,
                          onFaireDon: () {
                            _ouvrirChoixDon(demande);
                          },
                          onVoirDetail: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailDemandePage(
                                      demande: demande,
                                      donateurId: widget.donateurId,
                                      prenom: widget.prenom,
                                      organisationPartenaireId:
                                      widget.organisationPartenaireId,

                                    ),
                              ),
                            );
                          },
                        ),
                      );
                        },
                        childCount: resultats.length,
                      )),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

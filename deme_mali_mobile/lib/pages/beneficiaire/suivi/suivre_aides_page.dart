import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/accueil_beneficiaire_controller.dart';
import '../../../models/demande_aide.dart';
import '../../../styles/couleurs.dart';
import '../detail/detail_aide_page.dart';
import '../widgets/barre_navigation_beneficiaire.dart';

class SuivreAidesPage extends ConsumerStatefulWidget {
  const SuivreAidesPage({super.key});

  @override
  ConsumerState<SuivreAidesPage> createState() => _SuivreAidesPageState();
}

class _SuivreAidesPageState extends ConsumerState<SuivreAidesPage> {
  // Filtre actif : 0 = Toutes, 1 = En cours, 2 = Terminées
  int _filtreIndex = 0;

  String _formaterMontant(num montant) {
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return montant.toInt().toString().replaceAllMapped(regex, (m) => '${m[1]} ');
  }

  @override
  Widget build(BuildContext context) {
    final demandesAsync = ref.watch(mesDemandesBeneficiaireProvider);

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      bottomNavigationBar: const BarreNavigationBeneficiaire(),
      body: SafeArea(
        child: RefreshIndicator(
          color: CouleursApp.vert,
          onRefresh: () async {
            ref.read(demandeAideRepositoryProvider).viderCacheRapports();
            ref.invalidate(mesDemandesBeneficiaireProvider);
            await ref.read(mesDemandesBeneficiaireProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bouton retour circulaire blanc
                InkWell(
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      ref.read(ongletActifBeneficiaireProvider.notifier).state = 0;
                    }
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: CouleursApp.blanc,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, color: CouleursApp.noir, size: 20),
                  ),
                ),

              const SizedBox(height: 18),

              // Titre principal
              const Text(
                'Suivre mes aides',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: CouleursApp.noir,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Suivez l’avancement des collectes destinées à vos demandes d’aide.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black.withValues(alpha: 0.55),
                ),
              ),

              const SizedBox(height: 20),

              // Données réelles ou exemples
              demandesAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: CouleursApp.vert),
                  ),
                ),
                error: (err, stack) => const Center(
                  child: Text('Impossible de charger le suivi.'),
                ),
                data: (demandes) {
                  final listeBrute = demandes.isNotEmpty ? demandes : _demandesExemples;

                  final countToutes = listeBrute.length;
                  final countEnCours = listeBrute.where((d) {
                    final st = (d.statutCollecte ?? d.statut).toUpperCase();
                    return !st.contains('DISTRIB') && !st.contains('TERM') && !st.contains('CLOT');
                  }).length;
                  final countTerminees = listeBrute.where((d) {
                    final st = (d.statutCollecte ?? d.statut).toUpperCase();
                    return st.contains('DISTRIB') || st.contains('TERM') || st.contains('CLOT');
                  }).length;

                  // Filtrage de la liste
                  final listeFiltree = listeBrute.where((d) {
                    final st = (d.statutCollecte ?? d.statut).toUpperCase();
                    final estTerminee = st.contains('DISTRIB') || st.contains('TERM') || st.contains('CLOT');
                    if (_filtreIndex == 1) return !estTerminee;
                    if (_filtreIndex == 2) return estTerminee;
                    return true;
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Onglets filtres uniformisés
                      _buildSelecteurFiltres(
                        totalToutes: countToutes,
                        totalEnCours: countEnCours,
                        totalTerminees: countTerminees,
                      ),

                      const SizedBox(height: 20),

                      if (listeFiltree.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: CouleursApp.blanc,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              'Aucune demande pour ce filtre.',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: [
                            for (final d in listeFiltree) ...[
                              _carteSuivi(context, d),
                              const SizedBox(height: 16),
                            ],
                          ],
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  /// Sélecteur de filtres sous forme de pilules uniformisées
  Widget _buildSelecteurFiltres({
    required int totalToutes,
    required int totalEnCours,
    required int totalTerminees,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildItemFiltre(
            index: 0,
            label: 'Toutes',
            count: totalToutes,
          ),
          const SizedBox(width: 8),
          _buildItemFiltre(
            index: 1,
            label: 'En cours',
            count: totalEnCours,
          ),
          const SizedBox(width: 8),
          _buildItemFiltre(
            index: 2,
            label: 'Terminées',
            count: totalTerminees,
          ),
        ],
      ),
    );
  }

  Widget _buildItemFiltre({
    required int index,
    required String label,
    required int count,
  }) {
    final actif = _filtreIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _filtreIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: actif ? CouleursApp.vert : CouleursApp.blanc,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: actif ? CouleursApp.vert : Colors.black.withValues(alpha: 0.1),
          ),
          boxShadow: actif
              ? [
                  BoxShadow(
                    color: CouleursApp.vert.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: actif ? FontWeight.w700 : FontWeight.w600,
                color: actif ? CouleursApp.blanc : CouleursApp.noir,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: actif
                    ? CouleursApp.blanc.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: actif ? CouleursApp.blanc : CouleursApp.noir,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _carteSuivi(BuildContext context, DemandeAide demande) {
    final collecte = demande.montantCollecte ?? 0.0;
    final necessaire = demande.montantTotalRequis > 0
        ? demande.montantTotalRequis
        : ((demande.montantNecessaire != null && demande.montantNecessaire! > 0)
            ? demande.montantNecessaire!
            : 500000.0);
    final ratio = demande.ratioCollecte;
    final pourcentage = demande.pourcentageCollecte;

    final sousTitre = demande.categorieDemandeNom ??
        demande.typeDemandeAide ??
        (demande.titre.toLowerCase().contains('alimentaire')
            ? 'Besoin alimentaire pour ma famille'
            : 'Besoin pour des soins médicaux');

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetailAidePage(demande: demande),
          ),
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CouleursApp.blanc,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              demande.titre,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: CouleursApp.noir,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sousTitre,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withValues(alpha: 0.55),
              ),
            ),

            const SizedBox(height: 16),

            // Montant collecté + Objectif + Pourcentage
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_formaterMontant(collecte)} FCFA collectés',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: CouleursApp.vert,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      demande.aMontantFinalCertifie
                          ? 'sur ${_formaterMontant(necessaire)} FCFA (validés)'
                          : 'sur ${_formaterMontant(necessaire)} FCFA',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: demande.aMontantFinalCertifie ? FontWeight.w700 : FontWeight.normal,
                        color: demande.aMontantFinalCertifie ? CouleursApp.vert : Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                    if (demande.aMontantFinalCertifie) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, size: 14, color: CouleursApp.vert),
                    ],
                  ],
                ),
                Text(
                  '$pourcentage %',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: CouleursApp.vert,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Barre de progression
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: const Color(0xFFF0EAE1),
                valueColor: const AlwaysStoppedAnimation<Color>(CouleursApp.vert),
              ),
            ),

            if ((demande.nombreDonateurs ?? 0) > 0) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.people_alt_outlined, size: 13, color: CouleursApp.vert),
                  const SizedBox(width: 5),
                  Text(
                    '${demande.nombreDonateurs} donateur${demande.nombreDonateurs! > 1 ? 's ont' : ' a'} contribué à ce don',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CouleursApp.vert,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Boutons d'état
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: CouleursApp.jaune,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (demande.statutCollecte != null && demande.statutCollecte!.isNotEmpty)
                        ? demande.statutCollecte!
                        : (pourcentage >= 100 ? 'Collecte terminée' : 'Collecte en cours'),
                    style: const TextStyle(
                      color: CouleursApp.blanc,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Row(
                  children: const [
                    Text(
                      'Voir les détails',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: CouleursApp.vert,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: CouleursApp.vert,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const List<DemandeAide> _demandesExemples = [
    DemandeAide(
      id: 1,
      titre: 'Aide médicale',
      descriptionSituation: 'Besoin pour des soins médicaux',
      niveauUrgence: 'URGENTE',
      statut: 'VALIDEE',
      montantNecessaire: 500000,
      montantCollecte: 350000,
    ),
    DemandeAide(
      id: 2,
      titre: 'Aide alimentaire',
      descriptionSituation: 'Besoin alimentaire pour ma famille',
      niveauUrgence: 'MOYENNE',
      statut: 'VALIDEE',
      montantNecessaire: 500000,
      montantCollecte: 200000,
    ),
  ];
}

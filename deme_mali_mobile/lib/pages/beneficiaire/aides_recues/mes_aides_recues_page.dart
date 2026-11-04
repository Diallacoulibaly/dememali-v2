import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/accueil_beneficiaire_controller.dart';
import '../../../models/aide_recue.dart';
import '../../../styles/couleurs.dart';

class MesAidesRecuesPage extends ConsumerStatefulWidget {
  const MesAidesRecuesPage({super.key});

  @override
  ConsumerState<MesAidesRecuesPage> createState() => _MesAidesRecuesPageState();
}

class _MesAidesRecuesPageState extends ConsumerState<MesAidesRecuesPage> {
  // Filtre actif : 0 = Toutes, 1 = Liées aux demandes, 2 = Aides directes
  int _filtreIndex = 0;

  @override
  Widget build(BuildContext context) {
    final aidesAsync = ref.watch(mesAidesDistribueesProvider);

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: RefreshIndicator(
          color: CouleursApp.vert,
          onRefresh: () async {
            ref.invalidate(mesAidesDistribueesProvider);
            await ref.read(mesAidesDistribueesProvider.future);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bouton retour circulaire blanc : ramène à l'accueil (onglet 0) ou pop
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
                  'Mes dons reçus',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: CouleursApp.noir,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Historique des dons et distributions qui vous ont été accordés.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),

                const SizedBox(height: 20),

                // Gestion des états API
                aidesAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: CouleursApp.vert),
                    ),
                  ),
                  error: (err, stack) => _buildBlocErreur(),
                  data: (toutesAides) {
                    // Filtrage selon l'onglet sélectionné
                    final listesFiltrees = toutesAides.where((aide) {
                      if (_filtreIndex == 1) return aide.estLieeADemande;
                      if (_filtreIndex == 2) return !aide.estLieeADemande;
                      return true;
                    }).toList();

                    final countToutes = toutesAides.length;
                    final countLiees = toutesAides.where((a) => a.estLieeADemande).length;
                    final countDirectes = toutesAides.where((a) => !a.estLieeADemande).length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Onglets de filtre (Toutes, Liées aux demandes, Directes)
                        _buildSelecteurFiltres(
                          totalToutes: countToutes,
                          totalLiees: countLiees,
                          totalDirectes: countDirectes,
                        ),

                        const SizedBox(height: 20),

                        // Affichage de la liste ou de l'état vide
                        if (listesFiltrees.isEmpty)
                          _buildEtatVide(toutesAides.isEmpty)
                        else
                          Column(
                            children: [
                              for (final aide in listesFiltrees) ...[
                                _carteAideRecue(context, aide),
                                const SizedBox(height: 14),
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

  /// Sélecteur de filtres sous forme de pilules
  Widget _buildSelecteurFiltres({
    required int totalToutes,
    required int totalLiees,
    required int totalDirectes,
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
            label: 'Liées aux demandes',
            count: totalLiees,
          ),
          const SizedBox(width: 8),
          _buildItemFiltre(
            index: 2,
            label: 'Aides directes',
            count: totalDirectes,
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

  /// Carte d'une aide distribuée reçue
  Widget _carteAideRecue(BuildContext context, AideRecue aide) {
    return InkWell(
      onTap: () => _afficherDetailsAide(context, aide),
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
            // Ligne haute : Référence + Badge (Liée à une demande / Aide directe)
            Row(
              children: [
                Text(
                  aide.reference,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withValues(alpha: 0.5),
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: aide.estLieeADemande
                        ? CouleursApp.vert.withValues(alpha: 0.12)
                        : Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        aide.estLieeADemande
                            ? Icons.link_rounded
                            : Icons.volunteer_activism_rounded,
                        size: 13,
                        color: aide.estLieeADemande ? CouleursApp.vert : Colors.orange[800],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        aide.estLieeADemande
                            ? 'Demande ${aide.demandeAideId}'
                            : 'Aide directe',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: aide.estLieeADemande ? CouleursApp.vert : Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Titre de l'aide
            Text(
              aide.titreAffiche,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: CouleursApp.noir,
              ),
            ),
            const SizedBox(height: 6),

            // Grand montant ou valeur reçue
            Text(
              aide.valeurAffichee,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: aide.aDonFinancier ? CouleursApp.vert : CouleursApp.noir,
              ),
            ),

            // Nombre de donateurs ayant contribué
            if (aide.totalDonateurs > 0) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.people_alt_outlined, size: 14, color: CouleursApp.vert),
                  const SizedBox(width: 5),
                  Text(
                    '${aide.totalDonateurs} donateur${aide.totalDonateurs > 1 ? 's ont' : ' a'} contribué à ce don',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: CouleursApp.vert,
                    ),
                  ),
                ],
              ),
            ],

            // Si présence d'articles matériels supplémentaires, afficher un récapitulatif propre
            if (aide.aDonMateriel && aide.aDonFinancier) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: aide.affectationsMaterielles.map((art) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${art.quantiteAffectee} ${art.unite} ${art.designation}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.noir,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 14),
            Divider(color: Colors.black.withValues(alpha: 0.07)),
            const SizedBox(height: 10),

            // Ligne basse : Date de distribution + Lieu + Bouton Voir détails
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Text(
                  aide.dateAffichee,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Voir les détails',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: CouleursApp.vert,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: CouleursApp.vert,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Dialogue modal affichant les détails complets de l'aide distribuée
  void _afficherDetailsAide(BuildContext context, AideRecue aide) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: CouleursApp.blanc,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poignée supérieure
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Titre et référence
              Text(
                aide.reference,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                aide.titreAffiche,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: CouleursApp.noir,
                ),
              ),

              const SizedBox(height: 16),

              // Résumé valeur
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CouleursApp.vert.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL REÇU',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: CouleursApp.vert.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      aide.valeurAffichee,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: CouleursApp.vert,
                      ),
                    ),
                    if (aide.totalDonateurs > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.people_alt_rounded, size: 15, color: CouleursApp.vert),
                          const SizedBox(width: 6),
                          Text(
                            '${aide.totalDonateurs} donateur${aide.totalDonateurs > 1 ? 's ont' : ' a'} contribué à ce don',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: CouleursApp.vert,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Détails des affectations financières
              if (aide.affectationsFinancieres.isNotEmpty) ...[
                const Text(
                  'Versements financiers',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: CouleursApp.noir,
                  ),
                ),
                const SizedBox(height: 8),
                for (final aff in aide.affectationsFinancieres)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Don #${aff.donFinancierId}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black.withValues(alpha: 0.65),
                          ),
                        ),
                        Text(
                          '${aff.montantAffecte.round()} FCFA',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: CouleursApp.vert,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
              ],

              // Détails des affectations matérielles
              if (aide.affectationsMaterielles.isNotEmpty) ...[
                const Text(
                  'Articles matériels remis',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: CouleursApp.noir,
                  ),
                ),
                const SizedBox(height: 8),
                for (final art in aide.affectationsMaterielles)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          art.designation,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withValues(alpha: 0.75),
                          ),
                        ),
                        Text(
                          '${art.quantiteAffectee} ${art.unite}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: CouleursApp.noir,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
              ],

              // Lieu de distribution si renseigné
              if (aide.lieuDistribution != null && aide.lieuDistribution!.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: CouleursApp.vert),
                    const SizedBox(width: 8),
                    Text(
                      'Lieu : ${aide.lieuDistribution}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Bouton Fermer
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CouleursApp.vert,
                    foregroundColor: CouleursApp.blanc,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Fermer',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// État vide
  Widget _buildEtatVide(bool aucunElementAuTotal) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: CouleursApp.vert.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              size: 32,
              color: CouleursApp.vert,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            aucunElementAuTotal
                ? 'Aucun don reçu pour le moment'
                : 'Aucun don pour ce filtre',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: CouleursApp.noir,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            aucunElementAuTotal
                ? 'Les distributions de dons financiers et matériels associées à votre profil s\'afficheront ici.'
                : 'Sélectionnez un autre filtre pour consulter vos autres dons.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black.withValues(alpha: 0.55),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Bloc erreur
  Widget _buildBlocErreur() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 36),
          const SizedBox(height: 10),
          const Text(
            'Impossible de charger vos dons reçus.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => ref.invalidate(mesAidesDistribueesProvider),
            child: const Text(
              'Réessayer',
              style: TextStyle(color: CouleursApp.vert, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}



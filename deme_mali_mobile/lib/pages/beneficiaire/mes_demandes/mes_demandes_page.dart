import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/accueil_beneficiaire_controller.dart';
import '../../../models/demande_aide.dart';
import '../../../styles/couleurs.dart';
import '../demande/choix_type_demande_page.dart';
import '../detail/detail_aide_page.dart';
import '../demande/demande_aide_stepper_page.dart';

class MesDemandesPage extends ConsumerWidget {
  const MesDemandesPage({super.key});

  Widget _badgeStatut(String statut) {
    Color fond;
    Color texte;
    String libelle;

    final s = statut.toUpperCase();
    if (s.contains('VALIDE') || s.contains('ACCEPTE')) {
      fond = CouleursApp.vert;
      texte = CouleursApp.blanc;
      libelle = 'Acceptée';
    } else if (s.contains('REJET') || s.contains('REFUS')) {
      fond = const Color(0xFF1E252B);
      texte = CouleursApp.blanc;
      libelle = 'Refusée';
    } else {
      fond = const Color(0xFFF7B500);
      texte = CouleursApp.noir;
      libelle = 'En attente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        libelle,
        style: TextStyle(
          color: texte,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _formaterDate(DateTime? date) {
    if (date == null) return '18 septembre 2026';
    const mois = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    final jour = date.day.toString().padLeft(2, '0');
    final nomMois = mois[date.month - 1];
    return '$jour $nomMois ${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demandesAsync = ref.watch(mesDemandesBeneficiaireProvider);
    final partenairesAsync = ref.watch(demandesPartenairesBeneficiaireProvider);

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bouton retour circulaire blanc : ramène à l'accueil (onglet 0)
                    InkWell(
                      onTap: () {
                        ref.read(ongletActifBeneficiaireProvider.notifier).state = 0;
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
                      'Mes demandes',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: CouleursApp.noir,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Retrouvez toutes les demandes d\'aide que vous avez envoyées.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Liste des demandes depuis l'API
                    demandesAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(color: CouleursApp.vert),
                        ),
                      ),
                      error: (err, stack) => Container(
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
                            const Text('Impossible de récupérer vos demandes.'),
                            TextButton(
                              onPressed: () => ref.invalidate(mesDemandesBeneficiaireProvider),
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      ),
                      data: (listeBrute) {
                        final demandes = [...listeBrute]..sort(DemandeAide.comparerPlusRecentDAbord);
                        if (demandes.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                            decoration: BoxDecoration(
                              color: CouleursApp.blanc,
                              borderRadius: BorderRadius.circular(20),
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
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: CouleursApp.vert.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.inbox_outlined,
                                    color: CouleursApp.vert,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Aucune demande enregistrée',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: CouleursApp.noir,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Vous n\'avez pas encore créé de demande d\'aide. Cliquez ci-dessous pour déposer votre premier dossier.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black.withValues(alpha: 0.55),
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const ChoixTypeDemandePage(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add, size: 18),
                                  label: const Text('Faire une demande'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CouleursApp.vert,
                                    foregroundColor: CouleursApp.blanc,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: [
                            for (int i = 0; i < demandes.length; i++) ...[
                              _carteDemande(context, demandes[i], i + 1),
                              const SizedBox(height: 14),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 26),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Demandes des organisations partenaires',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: CouleursApp.noir,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Actualiser les demandes',
                          onPressed: () => ref.invalidate(demandesPartenairesBeneficiaireProvider),
                          icon: const Icon(Icons.refresh, color: CouleursApp.vert),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Demandes validées dont l’étude de terrain est terminée.',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    partenairesAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(color: CouleursApp.vert),
                        ),
                      ),
                      error: (error, stack) => TextButton(
                        onPressed: () => ref.invalidate(demandesPartenairesBeneficiaireProvider),
                        child: const Text('Impossible de charger les demandes. Réessayer'),
                      ),
                      data: (demandes) {
                        if (demandes.isEmpty) {
                          return const Text('Aucune demande disponible pour le moment.');
                        }
                        return Column(
                          children: [
                            for (int i = 0; i < demandes.length; i++) ...[
                              _carteDemande(context, demandes[i], i + 1),
                              const SizedBox(height: 14),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _carteDemande(BuildContext context, DemandeAide demande, int index) {
    final dateStr = _formaterDate(demande.dateCreation);

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
            // Titre de la demande + Badge statut sur la même ligne (identique à la capture)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    demande.titre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: CouleursApp.noir,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _badgeStatut(demande.statut),
              ],
            ),

            const SizedBox(height: 6),

            // Description courte
            Text(
              demande.descriptionSituation.isNotEmpty
                  ? demande.descriptionSituation
                  : 'Demande d\'aide pour des besoins essentiels',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withValues(alpha: 0.55),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 14),
            Divider(color: Colors.black.withValues(alpha: 0.07)),
            const SizedBox(height: 10),

            // Ligne basse : Date + Actions (anti-débordement)
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 13,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dateStr,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.black.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                if (demande.statut.toUpperCase() == 'EN_ATTENTE' ||
                    (!demande.statut.toUpperCase().contains('VALIDE') &&
                        !demande.statut.toUpperCase().contains('ACCEPTE') &&
                        !demande.statut.toUpperCase().contains('REJET') &&
                        !demande.statut.toUpperCase().contains('REFUS'))) ...[
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DemandeAideStepperPage(
                            typeDemandeAide: demande.estMaterielle ? 'MATERIELLE' : 'FINANCIERE',
                            demandeAModifier: demande,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: CouleursApp.vert.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined, size: 13, color: CouleursApp.vert),
                          SizedBox(width: 3),
                          Text(
                            'Modifier',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: CouleursApp.vert,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Détails',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CouleursApp.vert,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right,
                      size: 15,
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
}


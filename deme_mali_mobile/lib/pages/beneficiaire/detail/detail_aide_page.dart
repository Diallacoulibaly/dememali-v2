import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/accueil_beneficiaire_controller.dart';
import '../../../models/aide_recue.dart';
import '../../../models/article_demande.dart';
import '../../../models/demande_aide.dart';
import '../../../styles/couleurs.dart';
import '../widgets/barre_navigation_beneficiaire.dart';
import '../demande/demande_aide_stepper_page.dart';

class DetailAidePage extends ConsumerStatefulWidget {
  const DetailAidePage({
    super.key,
    required this.demande,
  });

  final DemandeAide demande;

  @override
  ConsumerState<DetailAidePage> createState() => _DetailAidePageState();
}

class _DetailAidePageState extends ConsumerState<DetailAidePage> {
  late DemandeAide _demande;
  List<AideRecue> _aidesDistribuees = [];
  bool _chargement = true;

  @override
  void initState() {
    super.initState();
    _demande = widget.demande;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerDonnees();
    });
  }

  Future<void> _chargerDonnees() async {
    if (!mounted) return;
    setState(() => _chargement = true);
    final repo = ref.read(demandeAideRepositoryProvider);
    try {
      final futures = await Future.wait([
        repo.getById(widget.demande.id),
        repo.getAidesDistribueesByDemande(widget.demande.id),
        repo.getRapportTechniqueByDemande(widget.demande.id),
      ]);
      if (!mounted) return;
      var d = futures[0] as DemandeAide;
      final aides = futures[1] as List<AideRecue>;
      final rTech = futures[2] as Map<String, dynamic>?;

      if (rTech != null) {
        final double? mFinal = (rTech['montantFinal'] is num)
            ? (rTech['montantFinal'] as num).toDouble()
            : double.tryParse(rTech['montantFinal']?.toString() ?? '');
        final String? descTech = rTech['descriptionTechnique']?.toString();
        if (mFinal != null && mFinal > 0) {
          d = d.copyWith(
            montantFinal: mFinal,
            descriptionTechnique: descTech,
          );
        }
      }

      setState(() {
        _demande = d;
        _aidesDistribuees = aides;
        _chargement = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _chargement = false);
    }
  }

  bool get _estModifiable {
    final s = _demande.statut.toUpperCase();
    return s == 'EN_ATTENTE' ||
        (!s.contains('VALIDE') &&
            !s.contains('ACCEPTE') &&
            !s.contains('REJET') &&
            !s.contains('REFUS'));
  }

  Future<void> _ouvrirModification() async {
    final modifie = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DemandeAideStepperPage(
          typeDemandeAide: _demande.estMaterielle ? 'MATERIELLE' : 'FINANCIERE',
          demandeAModifier: _demande,
        ),
      ),
    );
    if (modifie == true && mounted) {
      _chargerDonnees();
    }
  }

  String _formaterNombre(num valeur) {
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return valeur.toInt().toString().replaceAllMapped(regex, (m) => '${m[1]} ');
  }

  String _formaterDate(DateTime? dt) {
    if (dt == null) return 'Date non renseignée';
    const mois = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    final m = (dt.month >= 1 && dt.month <= 12) ? mois[dt.month - 1] : '';
    // N'afficher l'heure que si elle est renseignée (différente de 00:00)
    if (dt.hour != 0 || dt.minute != 0) {
      final h = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} $m ${dt.year} à $h:$min';
    }
    return '${dt.day} $m ${dt.year}';
  }

  Widget _badgeStatut(String statut, String? statutCollecte) {
    final s = statut.toUpperCase();
    Color couleurFond;
    Color couleurTexte;
    Color pointCouleur;
    String label;

    if (s == 'VALIDEE' || s == 'EN_COURS') {
      couleurFond = CouleursApp.vert.withValues(alpha: 0.12);
      couleurTexte = CouleursApp.vert;
      pointCouleur = CouleursApp.vert;
      label = (statutCollecte != null && statutCollecte.isNotEmpty)
          ? statutCollecte
          : 'Collecte en cours';
    } else if (s == 'EN_ATTENTE') {
      couleurFond = const Color(0xFFFEF3D6);
      couleurTexte = const Color(0xFFB45309);
      pointCouleur = const Color(0xFFB45309);
      label = 'En attente de validation';
    } else if (s.contains('REJET') || s.contains('REFUS')) {
      couleurFond = const Color(0xFFFDE8E8);
      couleurTexte = const Color(0xFFDC2626);
      pointCouleur = const Color(0xFFDC2626);
      label = 'Demande rejetée';
    } else if (s.contains('TERMIN') || s.contains('DISTRIB')) {
      couleurFond = const Color(0xFFE0F2FE);
      couleurTexte = const Color(0xFF0369A1);
      pointCouleur = const Color(0xFF0369A1);
      label = 'Aide clôturée / reçue';
    } else {
      couleurFond = Colors.black.withValues(alpha: 0.08);
      couleurTexte = CouleursApp.noir;
      pointCouleur = CouleursApp.noir;
      label = statut;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: couleurFond,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: pointCouleur,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: couleurTexte,
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeInfo({
    required IconData icone,
    required String label,
    Color? couleur,
  }) {
    final c = couleur ?? Colors.black.withValues(alpha: 0.7);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: c),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _demande;
    final totalRequis = d.montantTotalRequis;
    final collecte = d.montantCollecte ?? 0.0;
    final ratio = d.ratioCollecte;
    final pourcentage = d.pourcentageCollecte;
    final reste = (totalRequis - collecte).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      bottomNavigationBar: const BarreNavigationBeneficiaire(),
      body: SafeArea(
        child: RefreshIndicator(
          color: CouleursApp.vert,
          onRefresh: _chargerDonnees,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barre supérieure avec bouton retour et bouton rafraîchir
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
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
                    const Text(
                      'Détail de l’aide',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: CouleursApp.noir,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_estModifiable) ...[
                          InkWell(
                            onTap: _ouvrirModification,
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: CouleursApp.vert.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                                border: Border.all(color: CouleursApp.vert.withValues(alpha: 0.2)),
                              ),
                              child: const Icon(Icons.edit_outlined, color: CouleursApp.vert, size: 20),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        InkWell(
                          onTap: _chargement ? null : _chargerDonnees,
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
                            child: _chargement
                                ? const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: CouleursApp.vert,
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded, color: CouleursApp.vert, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Carte 1 : En-tête et métadonnées de la demande
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: CouleursApp.blanc,
                    borderRadius: BorderRadius.circular(24),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _badgeStatut(d.statut, d.statutCollecte),
                          if (d.niveauUrgence.isNotEmpty)
                            _badgeInfo(
                              icone: Icons.priority_high_rounded,
                              label: d.niveauUrgence,
                              couleur: d.niveauUrgence.toLowerCase().contains('urgent')
                                  ? Colors.redAccent
                                  : CouleursApp.vert,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Text(
                        d.titre,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: CouleursApp.noir,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Date de dépôt
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 14, color: Colors.black.withValues(alpha: 0.45)),
                          const SizedBox(width: 6),
                          Text(
                            _formaterDate(d.dateCreation),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withValues(alpha: 0.55),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (d.categorieDemandeNom != null && d.categorieDemandeNom!.isNotEmpty)
                            _badgeInfo(
                              icone: Icons.category_outlined,
                              label: d.categorieDemandeNom!,
                              couleur: CouleursApp.vert,
                            ),
                          _badgeInfo(
                            icone: Icons.group_outlined,
                            label: (d.typeDemande ?? 'Individuelle') +
                                (d.nombrePersonne != null && d.nombrePersonne! > 1
                                    ? ' (${d.nombrePersonne} personnes)'
                                    : ''),
                          ),
                          _badgeInfo(
                            icone: d.articles.isNotEmpty
                                ? Icons.inventory_2_outlined
                                : Icons.account_balance_wallet_outlined,
                            label: d.articles.isNotEmpty ? 'Aide matérielle' : 'Aide financière',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (_estModifiable) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF9EE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: CouleursApp.jaune.withValues(alpha: 0.45)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFFB45309), size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Demande modifiable (En attente)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Tant que votre demande n'a pas encore été validée, vous pouvez modifier ses informations (titre, besoin, montant ou justificatifs).",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF78350F),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: ElevatedButton.icon(
                            onPressed: _ouvrirModification,
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text(
                              'Modifier ma demande',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CouleursApp.vert,
                              foregroundColor: CouleursApp.blanc,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Carte 2 : Progression financière / Collecte
                if (totalRequis > 0 || collecte > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: CouleursApp.blanc,
                      borderRadius: BorderRadius.circular(24),
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
                        const Text(
                          'Progression de la collecte',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: CouleursApp.noir,
                          ),
                        ),
                        const SizedBox(height: 14),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${_formaterNombre(collecte)} FCFA',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: CouleursApp.vert,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: CouleursApp.vert.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$pourcentage %',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: CouleursApp.vert,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        if (d.aMontantFinalCertifie) ...[
                          Row(
                            children: [
                              Text(
                                'sur ${_formaterNombre(totalRequis)} FCFA validés',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black.withValues(alpha: 0.75),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF81C784)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, size: 13, color: Color(0xFF2E7D32)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Étude de terrain',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (d.montantNecessaire != null && d.montantNecessaire! != totalRequis) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Estimation initiale du demandeur : ${_formaterNombre(d.montantNecessaire!)} FCFA',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black.withValues(alpha: 0.45),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ] else ...[
                          Text(
                            'sur ${_formaterNombre(totalRequis)} FCFA nécessaires (provisoire)',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black.withValues(alpha: 0.65),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Évaluation de terrain en cours • Montant provisoire',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFF7B500),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFF0EBE1),
                            valueColor: const AlwaysStoppedAnimation<Color>(CouleursApp.vert),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$pourcentage % de l’objectif atteint',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: CouleursApp.vert,
                              ),
                            ),
                            if (reste > 0)
                              Text(
                                'Reste : ${_formaterNombre(reste)} FCFA',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black.withValues(alpha: 0.6),
                                ),
                              ),
                          ],
                        ),
                        if ((d.nombreDonateurs ?? 0) > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: CouleursApp.vert.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.people_alt_rounded, size: 15, color: CouleursApp.vert),
                                const SizedBox(width: 6),
                                Text(
                                  '${d.nombreDonateurs} donateur${d.nombreDonateurs! > 1 ? 's ont' : ' a'} contribué à ce don',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: CouleursApp.vert,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                // Carte 3 : Liste des articles demandés (si présents)
                if (d.articles.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSectionArticles(d.articles),
                ],

                const SizedBox(height: 16),

                // Carte 4 : À propos de la demande / Description
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: CouleursApp.blanc,
                    borderRadius: BorderRadius.circular(24),
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
                      const Text(
                        'Description du besoin',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: CouleursApp.noir,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        d.descriptionSituation.trim().isNotEmpty
                            ? d.descriptionSituation
                            : 'Aucune description détaillée renseignée pour cette demande.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),

                // Carte Rapport Technique / Évaluation terrain (si renseignée)
                if (d.descriptionTechnique != null && d.descriptionTechnique!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: CouleursApp.vert.withValues(alpha: 0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: CouleursApp.vert.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: CouleursApp.vert.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.assignment_turned_in_rounded,
                                size: 18,
                                color: CouleursApp.vert,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Rapport technique (Étude de terrain)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: CouleursApp.vert,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          d.descriptionTechnique!,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.black.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Carte 5 : Motif de rejet ou remarque (si présent)
                if (d.motif != null && d.motif!.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, color: Color(0xFFDC2626), size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Remarque / Motif',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                d.motif!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: Color(0xFF7F1D1D),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Carte 6 : Aides distribuées / Dons reçus
                _buildSectionDistributions(_aidesDistribuees),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionArticles(List<ArticleDemande> articles) {
    final total = articles.fold(0.0, (s, a) => s + a.sousTotal);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(24),
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
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: CouleursApp.vert, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Articles demandés',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: CouleursApp.noir,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: CouleursApp.vert,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${articles.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: CouleursApp.blanc,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final a in articles)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAF9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: CouleursApp.vert.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: CouleursApp.vert,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.designation,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: CouleursApp.noir,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          a.prixUnitaireEstime != null && a.prixUnitaireEstime! > 0
                              ? '${a.prixUnitaireEstime!.round()} FCFA / ${a.unite}'
                              : 'Unité : ${a.unite}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: CouleursApp.blanc,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      '${a.quantiteDemandee} ${a.unite}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: CouleursApp.vert,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (total > 0) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9EE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: CouleursApp.jaune.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Estimation totale articles :',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B5838),
                    ),
                  ),
                  Text(
                    '${_formaterNombre(total)} FCFA',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: CouleursApp.noir,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionDistributions(List<AideRecue> aides) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(24),
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
          Row(
            children: [
              const Icon(Icons.volunteer_activism_outlined,
                  color: CouleursApp.vert, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Aides & Dons reçus',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: CouleursApp.noir,
                ),
              ),
              if (aides.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: CouleursApp.vert,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${aides.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: CouleursApp.blanc,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          if (aides.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAF9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Aucun don ou distribution enregistré pour l’instant. Les contributions des partenaires s’afficheront ici.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            for (final a in aides)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAF9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: CouleursApp.vert.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline_rounded,
                        color: CouleursApp.vert,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.titreAffiche,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: CouleursApp.noir,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (a.lieuDistribution != null && a.lieuDistribution!.isNotEmpty)
                                a.lieuDistribution!,
                              if (a.dateAffichee.isNotEmpty)
                                a.dateAffichee,
                            ].join(' • '),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.black.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (a.valeurAffichee.isNotEmpty)
                      Text(
                        a.valeurAffichee,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: CouleursApp.vert,
                        ),
                      ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

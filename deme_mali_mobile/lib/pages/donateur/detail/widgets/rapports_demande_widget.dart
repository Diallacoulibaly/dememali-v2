
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../controllers/etude_terrain_controller.dart';
import '../../../../controllers/rapport_besoin_controller.dart';
import '../../../../controllers/rapport_technique_controller.dart';
import '../../../../models/demande_aide.dart';
import '../../../../models/rapport_besoin.dart';
import '../../../../models/rapport_technique.dart';
import '../../../../styles/couleurs.dart';

class RapportsDemandeWidget extends ConsumerWidget {
  final DemandeAide demande;

  const RapportsDemandeWidget({
    super.key,
    required this.demande,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final etudeAsync =
    ref.watch(etudeTerrainControllerProvider(demande.id));

    final techniqueAsync =
    ref.watch(rapportTechniqueProvider(demande.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // RAPPORT DE BESOIN
        etudeAsync.when(
          loading: () => _chargement(),
          error: (_, __) => _messageErreur(
            'Impossible de charger le rapport de besoin.',
          ),
          data: (etude) {
            if (etude == null) {
              return _messageVide(
                Icons.description_outlined,
                'Rapport de besoin',
                'Le rapport sera disponible lorsqu’une étude de terrain sera enregistrée.',
              );
            }

            final besoinAsync =
            ref.watch(rapportBesoinControllerProvider(etude.id));

            return besoinAsync.when(
              loading: () => _chargement(),
              error: (_, __) => _messageErreur(
                'Impossible de charger le rapport de besoin.',
              ),
              data: (rapport) => _rapportBesoin(rapport),
            );
          },
        ),

        const SizedBox(height: 18),

        // RAPPORT TECHNIQUE
        techniqueAsync.when(
          loading: () => _chargement(),
          error: (_, __) => _messageErreur(
            'Impossible de charger le rapport technique.',
          ),
          data: (rapport) => _rapportTechnique(rapport),
        ),
      ],
    );
  }

  // ==================================================
  // RAPPORT DE BESOIN
  // ==================================================

  Widget _rapportBesoin(RapportBesoin? rapport) {
    if (rapport == null) {
      return _messageVide(
        Icons.description_outlined,
        'Rapport de besoin',
        'Aucun rapport de besoin disponible pour le moment.',
      );
    }

    return _carte(
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _entete(
            icone: Icons.description_outlined,
            titre: 'Rapport de besoin',
            sousTitre: 'Identification et analyse des besoins',
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFFEFEFEF)),
          const SizedBox(height: 16),
          if (rapport.titre?.trim().isNotEmpty == true)
            _blocInformation(
              titre: 'Titre du rapport',
              valeur: rapport.titre!,
              icone: Icons.title,
            ),

          _blocInformation(
            titre: 'Besoin identifié',
            valeur: rapport.besoinIdentifie,
            icone: Icons.volunteer_activism_outlined,
          ),

          _blocInformation(
            titre: 'Description de la situation',
            valeur: rapport.descriptionSituation,
            icone: Icons.info_outline,
          ),

          _blocInformation(
            titre: 'Solution proposée',
            valeur: rapport.solutionProposee,
            icone: Icons.lightbulb_outline,
          ),

          if (rapport.montantEstime != null) ...[
            const SizedBox(height: 5),
            _montantEstime(rapport.montantEstime!),
          ],

          if (rapport.dateCreation != null) ...[
            const SizedBox(height: 15),
            const Divider(color: Color(0xFFEFEFEF)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 15,
                  color: CouleursApp.vert,
                ),
                const SizedBox(width: 8),
                Text(
                  'Créé le ${_date(rapport.dateCreation!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: CouleursApp.noir.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ==================================================
  // RAPPORT TECHNIQUE
  // ==================================================

  Widget _rapportTechnique(RapportTechnique? rapport) {
    if (rapport == null) {
      return _messageVide(
        Icons.assignment_outlined,
        'Rapport technique',
        'Aucun rapport technique disponible pour le moment.',
      );
    }

    return _carte(
      enfant: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _entete(
            icone: Icons.assignment_outlined,
            titre: 'Rapport technique',
            sousTitre: 'Évaluation des ressources nécessaires',
          ),

          const SizedBox(height: 20),

          // MONTANT FINAL
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: CouleursApp.vert.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: CouleursApp.vert.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: CouleursApp.vert,
                      size: 19,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      'Montant final estimé',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CouleursApp.noir.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _montant(rapport.montantFinal),
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.vert,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // TITRE DES ARTICLES
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Détail des besoins',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.noir,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: CouleursApp.jaune.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${rapport.details.length} article(s)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: CouleursApp.noir,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          if (rapport.details.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CouleursApp.fond,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Aucun article détaillé dans ce rapport.',
                style: TextStyle(
                  fontSize: 13,
                  color: CouleursApp.noir,
                ),
              ),
            )
          else
            ...rapport.details.asMap().entries.map((entry) {
              final index = entry.key;
              final detail = entry.value;

              final montantDetail = detail.montant ??
                  (detail.quantite * (detail.prixUnitaire ?? 0));

              return _carteArticle(
                index: index + 1,
                designation: detail.designation,
                quantite: '${detail.quantite} ${detail.unite}',
                prixUnitaire: _montant(detail.prixUnitaire ?? 0),
                montant: _montant(montantDetail),
              );
            }),
        ],
      ),
    );
  }

  // ==================================================
  // EN-TETE DES CARTES
  // ==================================================

  Widget _entete({
    required IconData icone,
    required String titre,
    required String sousTitre,
  }) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: CouleursApp.vert.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icone,
            color: CouleursApp.vert,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titre,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: CouleursApp.noir,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                sousTitre,
                style: TextStyle(
                  fontSize: 12,
                  color: CouleursApp.noir.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================================================
  // INFORMATIONS DU RAPPORT DE BESOIN
  // ==================================================

  Widget _blocInformation({
    required String titre,
    required String? valeur,
    required IconData icone,
  }) {
    if (valeur == null || valeur.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 17),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: CouleursApp.fond,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icone,
              size: 17,
              color: CouleursApp.vert,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: CouleursApp.noir.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  valeur,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: CouleursApp.noir,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // MONTANT ESTIME DU RAPPORT DE BESOIN
  // ==================================================

  Widget _montantEstime(num montant) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: CouleursApp.jaune.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.payments_outlined,
            color: CouleursApp.noir,
            size: 20,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Montant estimé',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: CouleursApp.noir,
              ),
            ),
          ),
          Text(
            _montant(montant),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: CouleursApp.vert,
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // CARTE ARTICLE
  // ==================================================

  Widget _carteArticle({
    required int index,
    required String designation,
    required String quantite,
    required String prixUnitaire,
    required String montant,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CouleursApp.fond,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CouleursApp.vert.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CouleursApp.jaune.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.noir,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  designation,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: CouleursApp.noir,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _detailArticle('Quantité', quantite),
              ),
              Expanded(
                child: _detailArticle('Prix unitaire', prixUnitaire),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFE5E1D9)),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Montant',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: CouleursApp.noir,
                ),
              ),
              Text(
                montant,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: CouleursApp.vert,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailArticle(String titre, String valeur) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titre,
          style: TextStyle(
            fontSize: 11,
            color: CouleursApp.noir.withValues(alpha: 0.55),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          valeur,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: CouleursApp.noir,
          ),
        ),
      ],
    );
  }

  // ==================================================
  // CARTE PRINCIPALE
  // ==================================================

  Widget _carte({required Widget enfant}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: CouleursApp.noir.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: enfant,
    );
  }

  // ==================================================
  // CHARGEMENT, ERREUR ET ABSENCE DE DONNEES
  // ==================================================

  Widget _chargement() {
    return _carte(
      enfant: const Center(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: CircularProgressIndicator(
            color: CouleursApp.vert,
          ),
        ),
      ),
    );
  }

  Widget _messageErreur(String message) {
    return _carte(
      enfant: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: CouleursApp.noir,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageVide(
      IconData icone,
      String titre,
      String message,
      ) {
    return _carte(
      enfant: Column(
        children: [
          Icon(
            icone,
            size: 32,
            color: CouleursApp.vert.withValues(alpha: 0.65),
          ),
          const SizedBox(height: 10),
          Text(
            titre,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: CouleursApp.noir,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: CouleursApp.noir.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // FORMATAGE
  // ==================================================

  String _montant(num valeur) {
    final texte = valeur.round().toString();

    return '${texte.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ' ',
    )} FCFA';
  }

  String _date(DateTime valeur) {
    return '${valeur.day.toString().padLeft(2, '0')}/'
        '${valeur.month.toString().padLeft(2, '0')}/'
        '${valeur.year}';
  }
}

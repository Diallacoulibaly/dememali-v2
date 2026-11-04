import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/don_controller.dart';
import '../../../controllers/don_materiel_controller.dart';
import '../../../controllers/images_demande_controller.dart';
import '../../../controllers/rapport_technique_controller.dart';
import '../../../models/demande_aide.dart';
import '../../../models/don_materiel.dart';
import '../../../models/rapport_technique.dart';
import '../../../styles/couleurs.dart';
import '../../../models/image_demande.dart';


class CarteDemandeDon extends ConsumerWidget {
  final DemandeAide demande;
  final VoidCallback onFaireDon;
  final VoidCallback? onVoirDetail;

  const CarteDemandeDon({
    super.key,
    required this.demande,
    required this.onFaireDon,
    this.onVoirDetail,
  });

  String formaterMontant(num montant) {
    final texte = montant.round().toString();

    return '${texte.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ' ',
    )} FCFA';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rapportAsync =
    ref.watch(rapportTechniqueProvider(demande.id));

    final imagesAsync =
    ref.watch(imageDemandeControllerProvider(demande.id));

    final donsAsync =
    ref.watch(donMaterielControllerProvider(demande.id));

    final nombreDonateursAsync =
    ref.watch(nombreDonateursProvider(demande.id));

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.noir.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onVoirDetail,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 600;

              return Padding(
                padding: EdgeInsets.all(mobile ? 0 : 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PHOTO ET INFORMATIONS PRINCIPALES
                    if (mobile) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 175,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _construireImage(imagesAsync),
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: CouleursApp.jaune,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  demande.estFinanciere
                                      ? 'Financière'
                                      : demande.estMaterielle
                                      ? 'Matérielle'
                                      : 'Demande d’aide',
                                  style: const TextStyle(
                                    color: CouleursApp.noir,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          12,
                          12,
                          12,
                          0,
                        ),
                        child: _informationsDemande(mobile: true),
                      ),
                    ] else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 112,
                              height: 112,
                              child: _construireImage(imagesAsync),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _informationsDemande(
                              mobile: false,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                            size: 22,
                          ),
                        ],
                      ),
                    ],

                    // INFORMATIONS DE COLLECTE
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        12,
                        mobile ? 14 : 12,
                        12,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (demande.estFinanciere)
                            _progressionFinanciere(rapportAsync)
                          else if (demande.estMaterielle)
                            _progressionMaterielle(
                              rapportAsync,
                              donsAsync,
                              nombreDonateursAsync,
                            ),

                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 10),

                          // STATISTIQUES DES DEMANDES FINANCIÈRES
                          if (demande.estFinanciere)
                            _statistiquesFinancieres(
                              rapportAsync,
                              nombreDonateursAsync,
                            ),

                          const SizedBox(height: 12),

                          // BOUTON FAIRE UN DON
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: onFaireDon,
                              icon: const Icon(
                                Icons.favorite_outline,
                                size: 17,
                              ),
                              label: const Text('Faire un don'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CouleursApp.vert,
                                foregroundColor: CouleursApp.blanc,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: mobile ? 12 : 0),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // IMAGE DE LA DEMANDE
  // IMAGE DE LA DEMANDE
  Widget _construireImage(
      AsyncValue<List<ImageDemande>> imagesAsync,
      ) {
    return imagesAsync.when(
      data: (images) {
        if (images.isEmpty || images.first.urlImage.isEmpty) {
          return _aucuneImage();
        }

        return Image.network(
          images.first.urlImage,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,errorBuilder: (_, _, _) => _aucuneImage(),
          loadingBuilder: (context, child, progression) {
            if (progression == null) return child;
            return _chargementImage();
          },
        );

      },
      loading: () => _chargementImage(),
      error: (_, _) => _aucuneImage(),
    );
  }

  // TYPE, TITRE ET DESCRIPTION
  Widget _informationsDemande({
    required bool mobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!mobile) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: CouleursApp.vert.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              demande.estFinanciere
                  ? 'Financière'
                  : demande.estMaterielle
                  ? 'Matérielle'
                  : 'Demande d’aide',
              style: const TextStyle(
                color: CouleursApp.vert,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 7),
        ],
        Text(
          demande.titre,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: CouleursApp.noir,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          demande.descriptionSituation.isNotEmpty
              ? demande.descriptionSituation
              : 'Aucune description disponible.',
          maxLines: mobile ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: CouleursApp.noir.withValues(alpha: 0.70),
            fontSize: 11,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  // IMAGE PAR DÉFAUT
  // MESSAGE QUAND IL N'Y A PAS D'IMAGE
  Widget _aucuneImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: CouleursApp.fond,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            color: CouleursApp.vert,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            'Aucune image illustrative',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CouleursApp.noir.withValues(alpha: 0.65),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // PENDANT LE CHARGEMENT DE L'IMAGE
  Widget _chargementImage() {
    return Container(
      color: CouleursApp.fond,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: CouleursApp.vert,
        ),
      ),
    );
  }
  // PROGRESSION DES DEMANDES FINANCIÈRES
  Widget _progressionFinanciere(
      AsyncValue<RapportTechnique?> rapportAsync,
      ) {
    final collecte = (demande.montantCollecte ?? 0).toDouble();

    return rapportAsync.when(
      data: (rapport) {
        final objectif = rapport?.montantFinal ?? 0.0;

        return _barreProgression(
          titre: '',
          montantRecu: collecte,
          objectif: objectif,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const Text(
        'Impossible de charger le rapport technique.',
        style: TextStyle(fontSize: 11),
      ),
    );
  }

  // AFFICHAGE SIMPLIFIÉ DES DEMANDES MATÉRIELLES
  Widget _progressionMaterielle(
      AsyncValue<RapportTechnique?> rapportAsync,
      AsyncValue<List<DonMateriel>> donsAsync,
      AsyncValue<int> nombreDonateursAsync,
      ) {
    return rapportAsync.when(
      data: (rapport) {
        if (rapport == null || rapport.details.isEmpty) {
          return const Text(
            'Besoins matériels non disponibles.',
            style: TextStyle(fontSize: 11),
          );
        }

        return donsAsync.when(
          data: (dons) {
            double valeurMaterielRecu = 0;

            // Évite de compter deux fois les quantités lorsque
            // plusieurs détails ont la même désignation et unité.
            final quantitesDejaCompte = <String, int>{};

            for (final detail in rapport.details) {
              final necessaire =
              detail.quantite > 0 ? detail.quantite : 0;

              final cle =
                  '${detail.designation.trim().toLowerCase()}|'
                  '${detail.unite.trim().toLowerCase()}';

              final quantiteDisponible = _quantiteRecue(
                detail.designation,
                detail.unite,
                dons,
              );

              final dejaCompte = quantitesDejaCompte[cle] ?? 0;
              final recue =
              (quantiteDisponible - dejaCompte).clamp(0, necessaire);

              quantitesDejaCompte[cle] = dejaCompte + recue;

              final prix = (detail.prixUnitaire ?? 0).toDouble();

              if (prix > 0 && prix.isFinite) {
                valeurMaterielRecu += recue * prix;
              }
            }

            final montantFinancier =
            (demande.montantCollecte ?? 0).toDouble();
            final montantObjectif = rapport.montantFinal.toDouble();

            // Objectif - dons financiers - valeur du matériel reçu.
            final montantRestant = (montantObjectif -
                montantFinancier -
                valeurMaterielRecu)
                .clamp(0.0, double.infinity);

            // Afficher au maximum deux articles.
            final detailsAffiches = rapport.details.take(2).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Articles nécessaires',
                  style: TextStyle(
                    color: CouleursApp.noir,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                ...detailsAffiches.map((detail) {
                  final necessaire =
                  detail.quantite > 0 ? detail.quantite : 0;

                  final recue = _quantiteRecue(
                    detail.designation,
                    detail.unite,
                    dons,
                  ).clamp(0, necessaire);

                  return _ligneArticleMateriel(
                    designation: detail.designation,
                    unite: detail.unite,
                    quantitePrevue: necessaire,
                    quantiteRecue: recue,
                    prixUnitaire: (detail.prixUnitaire ?? 0).toDouble(),
                  );
                }),

                if (rapport.details.length > 2)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 2,
                      bottom: 8,
                    ),
                    child: Text(
                      'Et ${rapport.details.length - 2} autre(s) article(s) '
                          'dans les détails de la demande.',
                      style: TextStyle(
                        color: CouleursApp.noir.withValues(alpha: 0.65),
                        fontSize: 10,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // MONTANT RESTANT ET DONATEURS SANS FOND COLORÉ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Montant restant à financer',
                            style: TextStyle(
                              color: CouleursApp.noir.withValues(alpha: 0.70),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formaterMontant(montantRestant),
                            style: const TextStyle(
                              color: CouleursApp.vert,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: _statistiqueDonateurs(nombreDonateursAsync),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const Text(
            'Impossible de charger les réceptions.',
            style: TextStyle(fontSize: 11),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const Text(
        'Impossible de charger le rapport technique.',
        style: TextStyle(fontSize: 11),
      ),
    );
  }

  // ARTICLE MATÉRIEL SANS BARRE DE PROGRESSION NI FOND COLORÉ
  Widget _ligneArticleMateriel({
    required String designation,
    required String unite,
    required int quantitePrevue,
    required int quantiteRecue,
    required double prixUnitaire,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            designation,
            style: const TextStyle(
              color: CouleursApp.noir,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Reçu : $quantiteRecue / $quantitePrevue $unite',
                  style: TextStyle(
                    color: CouleursApp.noir.withValues(alpha: 0.75),
                    fontSize: 11,
                  ),
                ),
              ),
              if (prixUnitaire > 0)
                Text(
                  formaterMontant(prixUnitaire),
                  style: const TextStyle(
                    color: CouleursApp.vert,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // BARRE DE PROGRESSION RÉUTILISABLE
  // Utilisée uniquement pour les demandes financières.
  Widget _barreProgression({
    required String titre,
    required double montantRecu,
    required double objectif,
    String? libelleMontant,
  }) {
    final progression = objectif > 0
        ? (montantRecu / objectif).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (titre.isNotEmpty) ...[
          Text(
            titre,
            style: const TextStyle(
              color: CouleursApp.noir,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
        ],
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progression,
                  minHeight: 8,
                  backgroundColor: CouleursApp.fond,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    CouleursApp.vert,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(progression * 100).round()}%',
              style: const TextStyle(
                color: CouleursApp.vert,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          libelleMontant ??
              '${formaterMontant(montantRecu)} collectés sur '
                  '${formaterMontant(objectif)}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: CouleursApp.noir.withValues(alpha: 0.70),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // STATISTIQUES DES DEMANDES FINANCIÈRES
  Widget _statistiquesFinancieres(
      AsyncValue<RapportTechnique?> rapportAsync,
      AsyncValue<int> nombreDonateursAsync,
      ) {
    final besoinInitial =
    (demande.montantNecessaire ?? 0).toDouble();

    return rapportAsync.when(
      data: (rapport) {
        final montantRapport = rapport?.montantFinal ?? 0.0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _statistique(
                Icons.track_changes,
                'Montant demandé',
                formaterMontant(besoinInitial),
              ),
            ),
            Container(
              width: 1,
              height: 42,
              color: CouleursApp.fond,
            ),
            Expanded(
              child: _statistique(
                Icons.description_outlined,
                'Montant validé',
                formaterMontant(montantRapport),
              ),
            ),
            Container(
              width: 1,
              height: 42,
              color: CouleursApp.fond,
            ),
            Expanded(
              child: _statistiqueDonateurs(nombreDonateursAsync),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _statistique(
              Icons.track_changes,
              'Montant demandé',
              formaterMontant(besoinInitial),
            ),
          ),
          Container(
            width: 1,
            height: 42,
            color: CouleursApp.fond,
          ),
          Expanded(
            child: _statistique(
              Icons.description_outlined,
              'Montant par étude de terrain',
              formaterMontant(besoinInitial),
            ),
          ),
          Container(
            width: 1,
            height: 42,
            color: CouleursApp.fond,
          ),
          Expanded(
            child: _statistiqueDonateurs(nombreDonateursAsync),
          ),
        ],
      ),
    );
  }

  // NOMBRE DE DONATEURS SANS ICÔNE
  Widget _statistiqueDonateurs(
      AsyncValue<int> nombreDonateursAsync,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: nombreDonateursAsync.when(
        loading: () => _contenuStatistiqueDonateurs('Chargement...'),
        error: (_, _) => _contenuStatistiqueDonateurs('Erreur'),
        data: (nombre) => _contenuStatistiqueDonateurs('$nombre'),
      ),
    );
  }

  Widget _contenuStatistiqueDonateurs(String valeur) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Donateurs',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: CouleursApp.noir,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          valeur,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: CouleursApp.noir,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // STATISTIQUE RÉUTILISABLE
  Widget _statistique(
      IconData icone,
      String titre,
      String valeur,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 19,
            color: CouleursApp.noir.withValues(alpha: 0.80),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CouleursApp.noir.withValues(alpha: 0.65),
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  valeur,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CouleursApp.noir,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // QUANTITÉ RÉELLEMENT REÇUE POUR UN ARTICLE
  int _quantiteRecue(
      String designation,
      String unite,
      List<DonMateriel> dons,
      ) {
    return dons.where((don) {
      final memeDesignation =
          don.designation.trim().toLowerCase() ==
              designation.trim().toLowerCase();

      final memeUnite =
          don.unite.trim().toLowerCase() ==
              unite.trim().toLowerCase();

      final statut =
          don.statutReception.toString().split('.').last;

      return memeDesignation &&
          memeUnite &&
          (statut == 'RECU' || statut == 'PARTIELLEMENT_RECU');
    }).fold<int>(
      0,
          (total, don) => total + don.quantiteRecue,
    );
  }
}
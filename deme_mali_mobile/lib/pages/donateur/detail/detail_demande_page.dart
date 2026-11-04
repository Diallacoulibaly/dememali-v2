import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/demande_aide.dart';
import '../../../controllers/don_controller.dart';
import '../../../controllers/images_demande_controller.dart';
import '../../../controllers/rapport_technique_controller.dart';
import '../../../styles/couleurs.dart';

import 'widgets/historique_demande_widget.dart';
import 'widgets/etude_terrain_widget.dart';
import 'widgets/rapports_demande_widget.dart';

import 'package:deme_mali_mobile/pages/donateur/don/don_financier/don_financier_page.dart';
import 'package:deme_mali_mobile/pages/donateur/don/faire_un_don_page.dart';

class DetailDemandePage extends ConsumerStatefulWidget {
  final DemandeAide demande;
  final VoidCallback? onFaireDon;
  final int? organisationPartenaireId;
  final int donateurId;
  final String prenom;

  const DetailDemandePage({
    super.key,
    required this.demande,
    this.organisationPartenaireId,
    required this.donateurId,
    required this.prenom,
    this.onFaireDon,
  });

  @override
  ConsumerState<DetailDemandePage> createState() =>
      _DetailDemandePageState();
}

class _DetailDemandePageState
    extends ConsumerState<DetailDemandePage> {
  int rubriqueSelectionnee = 0;

  // Navigation selon le type de demande
  void _faireUnDon() {
    final demande = widget.demande;

    if (demande.estFinanciere) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DonFinancierPage(
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
          builder: (context) => FaireUnDonPage(
            prenom: widget.prenom,
            donateurId: widget.donateurId,
            demandeAideId: demande.id,
            organisationPartenaireId:
            widget.organisationPartenaireId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Type de demande non reconnu.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final demande = widget.demande;

    final imagesAsync =
    ref.watch(imageDemandeControllerProvider(demande.id));

    final donateursAsync =
    ref.watch(nombreDonateursProvider(demande.id));

    // Récupération du rapport technique
    final rapportAsync =
    ref.watch(rapportTechniqueProvider(demande.id));

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      appBar: AppBar(
        title: const Text('Détail de la demande'),
        backgroundColor: CouleursApp.fond,
        foregroundColor: CouleursApp.noir,
        elevation: 0,
      ),

      // Organisation de la page avec les onglets fixes
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          children: [
            // CARTE PRINCIPALE FIXE
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: CouleursApp.blanc,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image de la demande
                  // Image de la demande
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 190,
                      child: imagesAsync.when(
                        skipLoadingOnReload: true,
                        data: (images) {
                          if (images.isEmpty ||
                              images.first.urlImage.isEmpty) {
                            return _aucuneImage();
                          }

                          return Image.network(
                            images.first.urlImage,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _aucuneImage(),
                            loadingBuilder: (context, child, progression) {
                              if (progression == null) return child;
                              return _chargementImage();
                            },
                          );
                        },
                        loading: () => _chargementImage(),
                        error: (_, __) => _aucuneImage(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Titre
                  Text(
                    demande.titre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CouleursApp.noir,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    demande.descriptionSituation.isNotEmpty
                        ? demande.descriptionSituation
                        : 'Aucune description disponible.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: CouleursApp.noir.withValues(alpha: 0.75),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Les trois statistiques sur une seule ligne
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: rapportAsync.when(
                          data: (rapport) => _indicateur(
                            'Montant nécessaire',
                            _formaterMontant(
                              rapport?.montantFinal ?? 0,
                            ),
                          ),
                          loading: () => _indicateur(
                            'Montant nécessaire',
                            '...',
                          ),
                          error: (_, __) => _indicateur(
                            'Montant nécessaire',
                            'Indisponible',
                          ),
                        ),
                      ),

                      _separateurVertical(),

                      Expanded(
                        child: _indicateur(
                          'Montant collecté',
                          _formaterMontant(
                            demande.montantCollecte ?? 0,
                          ),
                        ),
                      ),

                      _separateurVertical(),

                      Expanded(
                        child: donateursAsync.when(
                          data: (nombre) => _indicateur(
                            'Donateurs',
                            '$nombre',
                          ),
                          loading: () => _indicateur(
                            'Donateurs',
                            '...',
                          ),
                          error: (_, __) => _indicateur(
                            'Donateurs',
                            '${demande.nombreDonateurs}',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Bouton Faire un don
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _faireUnDon,
                      icon: const Icon(Icons.favorite_outline),
                      label: const Text('Faire un don'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CouleursApp.vert,
                        foregroundColor: CouleursApp.blanc,
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
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

            const SizedBox(height: 14),

            // ONGLETS FIXES
            Row(
              children: [
                _boutonRubrique('Historique', 0),
                const SizedBox(width: 5),
                _boutonRubrique('Rapports', 1),
                const SizedBox(width: 5),
                _boutonRubrique('Étude terrain', 2),
              ],
            ),

            const SizedBox(height: 12),

            // SEUL LE CONTENU DE LA RUBRIQUE EST SCROLLABLE
            Expanded(
              child: SingleChildScrollView(
                child: rubriqueSelectionnee == 0
                    ? HistoriqueDemandeWidget(demande: demande)
                    : rubriqueSelectionnee == 1
                    ? RapportsDemandeWidget(demande: demande)
                    : EtudeTerrainWidget(demande: demande),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Présentation d'une statistique sans icône ni fond
  Widget _indicateur(String titre, String valeur) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          titre,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            fontSize: 10,
            height: 1.3,
            fontWeight: FontWeight.w500,
            color: CouleursApp.noir.withValues(alpha: 0.60),
          ),
        ),
        const SizedBox(height: 7),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            valeur,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: CouleursApp.vert,
            ),
          ),
        ),
      ],
    );
  }

  // Séparateur vertical entre les statistiques
  Widget _separateurVertical() {
    return Container(
      width: 1,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      color: CouleursApp.noir.withValues(alpha: 0.12),
    );
  }

  // Boutons des rubriques
  Widget _boutonRubrique(String titre, int index) {
    final selectionne = rubriqueSelectionnee == index;

    return Expanded(
      child: SizedBox(
        height: 44,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              rubriqueSelectionnee = index;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: selectionne
                ? CouleursApp.vert
                : CouleursApp.blanc,
            foregroundColor: selectionne
                ? CouleursApp.blanc
                : CouleursApp.noir,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            titre,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Image par défaut
  // Message quand il n'y a pas d'image
  Widget _aucuneImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: CouleursApp.fond,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            color: CouleursApp.vert,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Aucune image illustrative',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: CouleursApp.noir.withValues(alpha: 0.65),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // Pendant le chargement de l'image
  Widget _chargementImage() {
    return Container(
      color: CouleursApp.fond,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: CouleursApp.vert,
        ),
      ),
    );
  }

  // Formatage des montants
  String _formaterMontant(num montant) {
    final texte = montant.round().toString();

    return '${texte.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ' ',
    )} FCFA';
  }
}
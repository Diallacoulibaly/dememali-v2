import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../controllers/accueil_beneficiaire_controller.dart';
import '../../../../controllers/demande_aide_controller.dart';
import '../../../../models/demande_aide.dart';
import '../../../../styles/couleurs.dart';
import 'widgets/barre_progression_etapes.dart';
import 'widgets/etape1_infos.dart';
import 'widgets/etape2_articles.dart';
import 'widgets/etape2_montant.dart';
import 'widgets/etape3_justificatifs.dart';

/// Page d'affichage du formulaire de demande d'aide.
/// Elle respecte l'architecture en ne contenant AUCUNE logique métier :
/// toute la logique et le changement d'état sont délégués au Provider `demandeAideFormControllerProvider`.
class DemandeAideStepperPage extends ConsumerStatefulWidget {
  const DemandeAideStepperPage({
    super.key,
    this.typeDemandeAide = 'FINANCIERE',
    this.demandeAModifier,
  });

  /// Nature de la demande choisie : 'FINANCIERE' ou 'MATERIELLE'
  final String typeDemandeAide;

  /// Demande existante à modifier (si mode édition)
  final DemandeAide? demandeAModifier;

  @override
  ConsumerState<DemandeAideStepperPage> createState() => _DemandeAideStepperPageState();
}

class _DemandeAideStepperPageState extends ConsumerState<DemandeAideStepperPage> {
  // Contrôleurs de texte pour les champs de saisie
  late final TextEditingController _titreController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _montantController;
  late final TextEditingController _nombrePersonneController;

  @override
  void initState() {
    super.initState();
    final controller = ref.read(demandeAideFormControllerProvider);
    if (widget.demandeAModifier != null) {
      controller.preparerPourModification(widget.demandeAModifier!);
    } else {
      controller.reinitialiser();
      controller.definirTypeDemandeAide(widget.typeDemandeAide);
    }
    _titreController = TextEditingController(text: controller.titre);
    _descriptionController =
        TextEditingController(text: controller.description);
    _montantController = TextEditingController(
        text: controller.montant > 0 ? controller.montant.toInt().toString() : '');
    _nombrePersonneController =
        TextEditingController(text: controller.nombrePersonne.toString());

    // Charger dynamiquement les catégories depuis le backend Spring Boot
    Future.microtask(() => controller.chargerCategories());
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _montantController.dispose();
    _nombrePersonneController.dispose();
    super.dispose();
  }

  void _afficherMessage(String texte, {bool succes = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texte),
        backgroundColor: succes ? CouleursApp.vert : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Récupérer le contrôleur depuis Riverpod
    final controller = ref.watch(demandeAideFormControllerProvider);

    // ListenableBuilder reconstruit l'UI dès que le contrôleur appelle notifyListeners()
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: CouleursApp.fond,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Barre de progression supérieure
                  BarreProgressionEtapes(
                    etapeActuelle: controller.etape,
                    titre: controller.etape == 3
                        ? 'Justificatifs'
                        : (controller.etape == 2 && controller.estMaterielle)
                            ? 'Articles demandés'
                            : (controller.estModification ? 'Modifier la demande' : 'Demander une aide'),
                    onRetour: () {
                      if (controller.etape > 1) {
                        controller.changerEtape(controller.etape - 1);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // 2. Affichage de l'étape courante
                  if (controller.etape == 1)
                    Etape1Infos(
                      titreController: _titreController,
                      descriptionController: _descriptionController,
                      urgenceSelectionnee: controller.urgence,
                      onUrgenceChange: controller.changerUrgence,
                      typeAideSelectionne: controller.typeAide,
                      onTypeAideChange: controller.changerTypeAide,
                      nombrePersonneController: _nombrePersonneController,
                      categories: controller.categories,
                      categorieSelectionnee: controller.categorieIdSelectionnee,
                      onCategorieChange: controller.changerCategorie,
                      chargementCategories: controller.chargementCategories,
                      onContinuer: () {
                        final nb =
                            int.tryParse(_nombrePersonneController.text) ?? 1;
                        final ok = controller.validerEtape1(
                          titreSaisi: _titreController.text,
                          descriptionSaisie: _descriptionController.text,
                          nbPersonneSaisi: nb,
                        );
                        if (!ok && controller.messageErreur != null) {
                          _afficherMessage(controller.messageErreur!);
                        }
                      },
                    )
                  else if (controller.etape == 2 && controller.estMaterielle)
                    Etape2Articles(
                      articlesInitiaux: controller.articles,
                      montantController: _montantController,
                      onArticlesChange: controller.enregistrerBrouillonArticles,
                      onRetour: () => controller.changerEtape(1),
                      onContinuer: (articlesSaisis) {
                        double montant = double.tryParse(_montantController.text
                                .replaceAll(RegExp(r'\D'), '')) ??
                            0;
                        if (montant <= 0) {
                          final totalEstime = articlesSaisis.fold(
                              0.0, (somme, a) => somme + a.sousTotal);
                          if (totalEstime > 0) {
                            montant = totalEstime;
                            _montantController.text =
                                montant.round().toString();
                          }
                        }
                        final ok = controller.validerEtape2Materielle(
                          articlesSaisis: articlesSaisis,
                          montantSaisi: montant,
                        );
                        if (!ok && controller.messageErreur != null) {
                          _afficherMessage(controller.messageErreur!);
                        }
                      },
                    )
                  else if (controller.etape == 2)
                    Etape2Montant(
                      montantController: _montantController,
                      onRetour: () => controller.changerEtape(1),
                      onContinuer: () {
                        final montant = double.tryParse(_montantController.text
                                .replaceAll(RegExp(r'\D'), '')) ??
                            0;
                        final ok = controller.validerEtape2(
                          montantSaisi: montant,
                        );
                        if (!ok && controller.messageErreur != null) {
                          _afficherMessage(controller.messageErreur!);
                        }
                      },
                    )
                  else
                    Etape3Justificatifs(
                      typeJustificatif: controller.typeJustificatifNomSelectionne,
                      typesDisponibles: controller.typesJustificatifsNoms,
                      fichiers: controller.justificatifs,
                      chargement: controller.chargement,
                      onTypeJustificatifChange: controller.changerTypeJustificatifParNom,
                      onAjouterFichier: () async {
                        final succes = await controller.choisirFichier();
                        if (succes) {
                          _afficherMessage('Fichier ajouté avec succès.', succes: true);
                        } else if (controller.messageErreur != null) {
                          _afficherMessage(controller.messageErreur!);
                        }
                      },
                      onSupprimerFichier: controller.supprimerJustificatif,
                      onRetour: () => controller.changerEtape(2),
                      onEnvoyer: () async {
                        final ok = await controller.envoyerDemande();
                        if (!context.mounted) return;

                        if (ok) {
                          // Rafraîchir les données de la page d'accueil
                          ref.invalidate(mesDemandesBeneficiaireProvider);

                          _afficherMessage(
                            controller.estModification
                                ? 'Votre demande a été modifiée avec succès !'
                                : 'Votre demande d\'aide a été transmise avec succès !',
                            succes: true,
                          );
                          Navigator.of(context).pop(true);
                        } else if (controller.messageErreur != null) {
                          _afficherMessage(controller.messageErreur!);
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

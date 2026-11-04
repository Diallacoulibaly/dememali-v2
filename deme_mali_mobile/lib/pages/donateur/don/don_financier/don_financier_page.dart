import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/styles/couleurs.dart';
import '/controllers/demande_aide_controller.dart';
import '/controllers/don_materiel_controller.dart';
import '/controllers/rapport_technique_controller.dart';

import '/models/demande_aide.dart';
import '/models/don_materiel.dart';
import '/models/rapport_technique.dart';

import 'mode_paiement_page.dart';

class DonFinancierPage extends ConsumerStatefulWidget {
  final int donateurId;
  final int? demandeAideId;
  final int? organisationPartenaireId;
  final String prenom;

  const DonFinancierPage({
    super.key,
    required this.donateurId,
    this.demandeAideId,
    this.organisationPartenaireId,
    required this.prenom,
  });

  @override
  ConsumerState<DonFinancierPage> createState() =>
      _DonFinancierPageState();
}

class _DonFinancierPageState extends ConsumerState<DonFinancierPage> {
  final TextEditingController _montantController =
  TextEditingController();

  bool _anonyme = false;

  final List<int> _montants = [200, 300, 400, 500, 600, 700];

  double? _montantRestant;
  bool _chargementMontant = false;
  String? _erreurCalcul;

  @override
  void initState() {
    super.initState();

    // Calculer le montant restant dès l'ouverture de la page.
    if (widget.demandeAideId != null) {
      Future.microtask(() => _calculerMontantRestant());
    }
  }

  @override
  void dispose() {
    _montantController.dispose();
    super.dispose();
  }

  void _selectionnerMontant(int montant) {
    setState(() {
      _montantController.text = montant.toString();
    });
  }

  // Normaliser le statut pour pouvoir comparer sa valeur.
  String _normaliserStatut(dynamic statut) {
    return statut.toString().split('.').last.toUpperCase();
  }

  // Créer une clé pour reconnaître un même article.
  String _creerCleArticle(String designation, String unite) {
    return '${designation.trim().toLowerCase()}|'
        '${unite.trim().toLowerCase()}';
  }

  // Calculer la valeur du matériel réellement reçu.
  double _calculerValeurMaterielleRecue(
      List<DonMateriel> dons,
      RapportTechnique rapport,
      ) {
    final Map<String, int> quantitesRecues = {};

    // Additionner uniquement les quantités réellement reçues.
    for (final don in dons) {
      final statut = _normaliserStatut(don.statutReception);

      if (statut != 'RECU' &&
          statut != 'PARTIELLEMENT_RECU') {
        continue;
      }

      final quantite = don.quantiteRecue ?? 0;

      if (quantite <= 0) {
        continue;
      }

      final cle = _creerCleArticle(
        don.designation,
        don.unite,
      );

      quantitesRecues[cle] =
          (quantitesRecues[cle] ?? 0) + quantite;
    }

    double valeurTotale = 0;

    // Comparer les quantités reçues avec les besoins du rapport.
    for (final detail in rapport.details) {
      if (detail.designation == null ||
          detail.unite == null ||
          detail.quantite == null ||
          detail.quantite <= 0 ||
          detail.prixUnitaire == null) {
        continue;
      }

      final prixUnitaire = detail.prixUnitaire.toDouble();

      if (!prixUnitaire.isFinite || prixUnitaire < 0) {
        continue;
      }

      final cle = _creerCleArticle(
        detail.designation,
        detail.unite,
      );

      final quantiteDisponible =
          quantitesRecues[cle] ?? 0;

      // Ne jamais compter plus que la quantité prévue.
      final quantiteACompter =
      quantiteDisponible < detail.quantite
          ? quantiteDisponible
          : detail.quantite;

      valeurTotale += quantiteACompter * prixUnitaire;

      // Éviter de compter deux fois la même quantité.
      quantitesRecues[cle] =
          quantiteDisponible - quantiteACompter;
    }

    return valeurTotale;
  }

  // Calculer le montant restant à collecter.
  Future<double?> _calculerMontantRestant() async {
    if (widget.demandeAideId == null) {
      return null;
    }

    setState(() {
      _chargementMontant = true;
      _erreurCalcul = null;
    });

    try {
      final demandeId = widget.demandeAideId!;

      // Récupérer la demande.
      final DemandeAide demande = await ref.read(
        demandeAideDetailProvider(demandeId).future,
      );

      // Récupérer le rapport technique.
      // Le rapport peut être null.
      final RapportTechnique? rapport = await ref.read(
        rapportTechniqueProvider(demandeId).future,
      );

      // Vérifier que le rapport technique existe.
      if (rapport == null) {
        throw Exception(
          'Aucun rapport technique trouvé pour cette demande.',
        );
      }

      final montantFinal = rapport.montantFinal;

      if (montantFinal == null ||
          !montantFinal.isFinite ||
          montantFinal <= 0) {
        throw Exception(
          'Le montant final du rapport technique est invalide.',
        );
      }

      final montantCollecte =
          demande.montantCollecte ?? 0.0;

      double valeurMaterielle = 0;

      // Les dons matériels sont pris en compte uniquement
      // pour les demandes matérielles.
      if (demande.estMaterielle) {
        final List<DonMateriel> dons = await ref.read(
          donMaterielControllerProvider(demandeId).future,
        );

        valeurMaterielle =
            _calculerValeurMaterielleRecue(dons, rapport);
      }

      final restant = (montantFinal -
          montantCollecte -
          valeurMaterielle)
          .clamp(0.0, double.infinity)
          .toDouble();

      if (!mounted) return restant;

      setState(() {
        _montantRestant = restant;
        _chargementMontant = false;
        _erreurCalcul = null;
      });

      return restant;
    } catch (e, stackTrace) {
      // Afficher la véritable erreur dans la console Flutter.
      debugPrint(
        'Erreur lors du calcul du montant restant : $e',
      );
      debugPrint('Détails : $stackTrace');

      if (!mounted) return null;

      // Afficher un message compréhensible au donateur.
      setState(() {
        _chargementMontant = false;
        _erreurCalcul =
        'Impossible de récupérer les informations de cette demande. '
            'Veuillez réessayer.';
      });

      return null;
    }
  }

  Future<void> _continuer() async {
    final texte = _montantController.text
        .trim()
        .replaceAll(' ', '')
        .replaceAll(',', '.');

    final montant = double.tryParse(texte);

    if (montant == null ||
        !montant.isFinite ||
        montant <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez saisir un montant supérieur à zéro.',
          ),
        ),
      );
      return;
    }

    // Pour un don lié à une demande, vérifier le montant restant.
    if (widget.demandeAideId != null) {
      final restant = await _calculerMontantRestant();

      if (!mounted) return;

      if (restant == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossible de vérifier le montant restant. '
                  'Veuillez réessayer.',
            ),
          ),
        );
        return;
      }

      if (restant <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cette demande a déjà atteint son montant nécessaire.',
            ),
          ),
        );
        return;
      }

      if (montant > restant) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Le montant saisi dépasse le montant restant : '
                  '${restant.toStringAsFixed(0)} FCFA.',
            ),
          ),
        );
        return;
      }
    }

    // Conserver la navigation et les paramètres existants.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModePaiementPage(
          montant: montant,
          anonyme: _anonyme,
          donateurId: widget.donateurId,
          demandeAideId: widget.demandeAideId,
          organisationPartenaireId:
          widget.organisationPartenaireId,
          prenom: widget.prenom,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, contraintes) {
            final largeur = contraintes.maxWidth;
            final petitEcran = contraintes.maxHeight < 700;
            final tresPetitEcran = largeur < 360;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                tresPetitEcran ? 12 : 20,
                petitEcran ? 6 : 12,
                tresPetitEcran ? 12 : 20,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // En-tête
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: CouleursApp.blanc,
                          foregroundColor: CouleursApp.noir,
                          side: BorderSide(
                            color: CouleursApp.noir.withValues(
                              alpha: 0.08,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Faire un don',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      color: CouleursApp.noir,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: petitEcran ? 12 : 20),

                  const Text(
                    'Choisissez ou saisissez un montant',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CouleursApp.noir,
                      fontSize: 14,
                    ),
                  ),

                  // La carte du montant restant a été supprimée.
                  // Le calcul et les vérifications sont conservés.

                  SizedBox(height: petitEcran ? 18 : 28),

                  // Saisie du montant
                  Container(
                    width: double.infinity,
                    height: petitEcran ? 82 : 100,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: CouleursApp.blanc,
                      border: Border.all(
                        color: CouleursApp.vert,
                        width: 1.4,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _montantController,
                      textAlign: TextAlign.center,
                      keyboardType:
                      const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        color: CouleursApp.vert,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: '0 FCFA',
                        hintStyle: TextStyle(
                          color: CouleursApp.vert,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),

                  SizedBox(height: petitEcran ? 20 : 30),

                  // Montants proposés
                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    itemCount: _montants.length,
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing:
                      tresPetitEcran ? 7 : 12,
                      mainAxisSpacing: 10,
                      childAspectRatio:
                      tresPetitEcran ? 1.55 : 1.8,
                    ),
                    itemBuilder: (context, index) {
                      final montant = _montants[index];

                      final selectionne =
                          _montantController.text.trim() ==
                              montant.toString();

                      return OutlinedButton(
                        onPressed: () =>
                            _selectionnerMontant(montant),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selectionne
                              ? CouleursApp.vert
                              : CouleursApp.fond,
                          foregroundColor: selectionne
                              ? CouleursApp.blanc
                              : CouleursApp.vert,
                          side: const BorderSide(
                            color: CouleursApp.vert,
                          ),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(14),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '$montant F',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: petitEcran ? 12 : 20),

                  // Choix du don anonyme
                  CheckboxListTile(
                    value: _anonyme,
                    onChanged: (value) {
                      setState(() {
                        _anonyme = value ?? false;
                      });
                    },
                    activeColor: CouleursApp.vert,
                    controlAffinity:
                    ListTileControlAffinity.leading,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 4),
                    dense: true,
                    title: const Text(
                      'Faire un don anonyme',
                      style: TextStyle(
                        color: CouleursApp.noir,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bouton Continuer
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _chargementMontant
                          ? null
                          : _continuer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CouleursApp.vert,
                        foregroundColor: CouleursApp.blanc,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Continuer',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
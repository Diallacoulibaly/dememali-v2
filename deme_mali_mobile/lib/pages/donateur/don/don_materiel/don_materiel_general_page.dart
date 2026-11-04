
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '/controllers/don_materiel_controller.dart';
import '/controllers/rapport_technique_controller.dart';
import '/models/don_materiel.dart';
import '/models/detail_rapport_technique.dart';
import '/styles/couleurs.dart';
import 'package:deme_mali_mobile/pages/navigation_donateur_page.dart';

class DonMaterielGeneralPage extends ConsumerStatefulWidget {
  final int donateurId;
  final String prenom;
  final int? demandeAideId;
  final int? organisationPartenaireId;

  const DonMaterielGeneralPage({
    super.key,
    required this.donateurId,
    required this.prenom,
    this.demandeAideId,
    this.organisationPartenaireId,
  });

  @override
  ConsumerState<DonMaterielGeneralPage> createState() =>
      _DonMaterielGeneralPageState();
}

class _DonMaterielGeneralPageState
    extends ConsumerState<DonMaterielGeneralPage> {
  final _formKey = GlobalKey<FormState>();
  final _designationController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _adresseController = TextEditingController();

  String _unite = 'Sac';
  String _etatMateriel = 'NEUF';
  bool _anonyme = false;
  bool _chargement = false;

  final List<String> _unites = [
    'Sac',
    'Kilogramme',
    'Carton',
    'Bidon',
    'Pièce',
    'Litre',
    'Paquet',
  ];

  final Map<String, String> _etats = {
    'NEUF': 'Neuf',
    'BON_ETAT': 'Bon état',
    'MAUVAIS_ETAT': 'Mauvais état',
  };

  @override
  void dispose() {
    _designationController.dispose();
    _quantiteController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  // Afficher un message d'erreur.
  void _afficherErreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Vérifier les informations du don avec le rapport technique.
  Future<String?> _verifierBesoinDemande() async {
    // Si le don n'est pas associé à une demande,
    // on conserve le fonctionnement actuel.
    if (widget.demandeAideId == null) {
      return null;
    }

    final designation = _designationController.text.trim();
    final unite = _unite.trim();
    final quantite = int.tryParse(_quantiteController.text.trim());

    // La quantité doit être positive.
    if (quantite == null || quantite <= 0) {
      return 'La quantité doit être supérieure à zéro.';
    }

    // Charger le rapport technique.
    final rapport = await ref.read(
      rapportTechniqueProvider(widget.demandeAideId!).future,
    );

    if (rapport == null || rapport.details.isEmpty) {
      return 'Aucun besoin disponible dans le rapport technique.';
    }

    // Rechercher la désignation et l'unité dans le rapport.
    DetailRapportTechnique? detailTrouve;

    for (final detail in rapport.details) {
      if (detail.designation.trim().toLowerCase() ==
          designation.toLowerCase() &&
          detail.unite.trim().toLowerCase() == unite.toLowerCase()) {
        detailTrouve = detail;
        break;
      }
    }

    // La désignation et l'unité doivent correspondre.
    if (detailTrouve == null) {
      return 'Cet article ne figure pas parmi les besoins de cette demande. '
          'Veuillez vérifier la désignation et l’unité.';
    }

    final detail = detailTrouve;

    // Récupérer les dons matériels associés à la demande.
    final dons = await ref.read(
      donMaterielControllerProvider(widget.demandeAideId!).future,
    );

    // Calculer les quantités déjà réellement reçues.
    final quantiteDejaRecue = dons
        .where((don) {
      final memeDesignation =
          don.designation.trim().toLowerCase() ==
              detail.designation.trim().toLowerCase();

      final memeUnite =
          don.unite.trim().toLowerCase() ==
              detail.unite.trim().toLowerCase();

      final statut = don.statutReception.trim().toUpperCase();

      return memeDesignation &&
          memeUnite &&
          (statut == 'RECU' || statut == 'PARTIELLEMENT_RECU');
    })
        .fold<int>(
      0,
          (total, don) => total + don.quantiteRecue,
    );

    // Calculer la quantité restante.
    final quantiteRestante = detail.quantite - quantiteDejaRecue;

    if (quantiteRestante <= 0) {
      return 'Ce besoin est déjà entièrement satisfait. '
          'Aucune quantité supplémentaire n’est nécessaire.';
    }

    // Vérifier que la quantité saisie ne dépasse pas le besoin restant.
    if (quantite > quantiteRestante) {
      return 'La quantité saisie dépasse le besoin restant. '
          'Vous pouvez encore donner $quantiteRestante ${detail.unite} maximum.';
    }

    return null;
  }

  Future<void> _envoyerDon() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _chargement = true);

    try {
      // Vérifications avant l'enregistrement.
      final erreurBesoin = await _verifierBesoinDemande();

      if (!mounted) return;

      if (erreurBesoin != null) {
        _afficherErreur(erreurBesoin);
        return;
      }

      // Logique initiale de création du don : conservée.
      final controller = ref.read(creationDonMaterielProvider);

      final DonMateriel don = await controller.creer(
        designation: _designationController.text.trim(),
        quantite: int.parse(_quantiteController.text.trim()),
        unite: _unite,
        etatMateriel: _etatMateriel,
        anonyme: _anonyme,
        donateurId: widget.donateurId,
        demandeAideId: widget.demandeAideId,
        adresseLivraison: _adresseController.text.trim(),
        organisationPartenaireId: widget.organisationPartenaireId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Don enregistré avec succès'),
          backgroundColor: CouleursApp.vert,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => NavigationDonateurPage(
            prenom: widget.prenom,
            donateurId: widget.donateurId,
          ),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      debugPrint('Erreur lors de la création du don matériel : $e');

      _afficherErreur(
        'Une erreur est survenue. Impossible de vérifier ou '
            'd’enregistrer votre don.',
      );
    } finally {
      if (mounted) {
        setState(() => _chargement = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête
                Row(
                  children: [
                    Material(
                      color: CouleursApp.blanc,
                      borderRadius: BorderRadius.circular(12),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: CouleursApp.noir,
                          size: 21,
                        ),
                        tooltip: 'Retour',
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Faire un don matériel',
                        style: TextStyle(
                          color: CouleursApp.noir,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Formulaire
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CouleursApp.blanc,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: CouleursApp.noir.withValues(alpha: 0.06),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.035),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Informations du don',
                        style: TextStyle(
                          color: CouleursApp.noir,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Les champs ci-dessous permettent de décrire '
                            'votre contribution.',
                        style: TextStyle(
                          color: CouleursApp.noir.withValues(alpha: 0.55),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Désignation
                      _label('Désignation du matériel'),

                      TextFormField(
                        controller: _designationController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: _decoration(
                          'Ex. : Sacs de riz, vêtements...',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Veuillez saisir le matériel à donner.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 19),

                      // Quantité
                      _label('Quantité'),

                      TextFormField(
                        controller: _quantiteController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: _decoration('Saisir la quantité'),
                        validator: (value) {
                          final quantite =
                          int.tryParse(value?.trim() ?? '');

                          if (quantite == null || quantite <= 0) {
                            return 'Saisissez une quantité entière supérieure à 0.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 19),

                      // Unité
                      _label('Unité'),

                      DropdownButtonFormField<String>(
                        initialValue: null,
                        isExpanded: true,
                        hint: const Text('Choisir une unité'),
                        dropdownColor: CouleursApp.blanc,
                        decoration: _decoration(''),
                        icon: const SizedBox.shrink(),
                        items: _unites.map((unite) {
                          return DropdownMenuItem<String>(
                            value: unite,
                            child: Text(unite),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _unite = value);
                          }
                        },
                      ),

                      const SizedBox(height: 19),

                      // État du matériel
                      _label('État du matériel'),

                      DropdownButtonFormField<String>(
                        initialValue: null,
                        isExpanded: true,
                        hint: const Text('Sélectionner l’état'),
                        dropdownColor: CouleursApp.blanc,
                        decoration: _decoration(''),
                        icon: const SizedBox.shrink(),
                        items: _etats.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _etatMateriel = value);
                          }
                        },
                      ),

                      const SizedBox(height: 19),

                      // Adresse de récupération
                      _label('Adresse de récupération'),

                      TextFormField(
                        controller: _adresseController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 3,
                        decoration: _decoration(
                          'Indiquer le lieu où le matériel peut être récupéré',
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Don anonyme
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: CouleursApp.fond,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _anonyme,
                              onChanged: (value) {
                                setState(() {
                                  _anonyme = value ?? false;
                                });
                              },
                              activeColor: CouleursApp.vert,
                              side: const BorderSide(
                                color: CouleursApp.vert,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),

                            const SizedBox(width: 8),

                            const Expanded(
                              child: Text(
                                'Faire un don anonyme',
                                softWrap: true,
                                style: TextStyle(
                                  color: CouleursApp.noir,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bouton confirmer
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _chargement ? null : _envoyerDon,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CouleursApp.vert,
                            foregroundColor: CouleursApp.blanc,
                            disabledBackgroundColor: CouleursApp.vert,
                            disabledForegroundColor: CouleursApp.blanc,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                          child: _chargement
                              ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: CouleursApp.blanc,
                            ),
                          )
                              : const Text(
                            'Confirmer mon don',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String texte) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texte,
        style: const TextStyle(
          color: CouleursApp.noir,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: CouleursApp.noir.withValues(alpha: 0.4),
        fontSize: 12,
      ),
      filled: true,
      fillColor: CouleursApp.fond.withValues(alpha: 0.45),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: CouleursApp.noir.withValues(alpha: 0.08),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: CouleursApp.noir.withValues(alpha: 0.10),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: CouleursApp.vert,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }
}

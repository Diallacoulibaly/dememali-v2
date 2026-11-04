import 'package:flutter/material.dart';

import '../../../models/donnees_structure.dart';
import '../../../styles/couleurs.dart';
import '../widgets/boutons_etapes.dart';
import '../widgets/champs_inscription.dart';
import '../widgets/entete_etapes.dart';
import 'informations_structure_etape2.dart';

class InformationsStructureEtape1Page extends StatefulWidget {
  final int organisationId;

  const InformationsStructureEtape1Page({
    super.key,
    required this.organisationId,
  });

  @override
  State<InformationsStructureEtape1Page> createState() =>
      _InformationsStructureEtape1PageState();
}

class _InformationsStructureEtape1PageState
    extends State<InformationsStructureEtape1Page> {
  final nomStructureController = TextEditingController();
  final nifController = TextEditingController();
  final villeController = TextEditingController();
  final adresseController = TextEditingController();

  String? typeStructure;

  static const List<String> typesStructure = [
    'Ecole',
    'Hôpital',
    'Mosquée',
    'Église',
    'Centre de santé',
    'Orphelinat',
    'Autre',
  ];

  @override
  void dispose() {
    nomStructureController.dispose();
    nifController.dispose();
    villeController.dispose();
    adresseController.dispose();
    super.dispose();
  }

  bool get formulaireValide {
    return nomStructureController.text.trim().isNotEmpty &&
        typeStructure != null &&
        nifController.text.trim().isNotEmpty &&
        villeController.text.trim().isNotEmpty &&
        adresseController.text.trim().isNotEmpty;
  }

  void _actualiser([String? _]) => setState(() {});

  void _suivant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InformationsStructureEtape2Page(
          organisationId: widget.organisationId,
          etape1: DonneesStructureEtape1(
            nomStructure: nomStructureController.text,
            typeStructure: typeStructure!,
            nif: nifController.text,
            ville: villeController.text,
            adresse: adresseController.text,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EnteteEtapes(
                      etape: 1,
                      total: 3,
                      titre: 'Informations de la stucture',
                      sousTitre: 'Renseignez les informations de votre structure.',
                    ),
                    const SizedBox(height: 18),

                    ChampInscription(
                      titre: 'Nom de la structure',
                      indication: 'Entrez le nom de votre structure',
                      controller: nomStructureController,
                      onChanged: _actualiser,
                    ),
                    const SizedBox(height: 14),

                    ChampListeInscription(
                      titre: 'Type de structure',
                      indication: 'Sélectionnez le type',
                      options: typesStructure,
                      valeur: typeStructure,
                      onChanged: (v) => setState(() => typeStructure = v),
                    ),
                    const SizedBox(height: 14),

                    ChampInscription(
                      titre: 'Numéro d’Identification Fiscale.',
                      indication: 'Entrez le numéro d’Identification Fiscale.',
                      controller: nifController,
                      onChanged: _actualiser,
                    ),
                    const SizedBox(height: 14),

                    ChampInscription(
                      titre: 'Ville',
                      indication: 'Entrez la ville',
                      controller: villeController,
                      onChanged: _actualiser,
                    ),
                    const SizedBox(height: 14),

                    ChampInscription(
                      titre: 'Adresse',
                      indication: 'Ex: Quartier du Fleuve, Rue 110',
                      controller: adresseController,
                      onChanged: _actualiser,
                    ),
                  ],
                ),
              ),
            ),

            // BOUTONS FIXES EN BAS
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              child: BoutonsEtapes(
                onRetour: () => Navigator.pop(context),
                onSuivant: formulaireValide ? _suivant : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

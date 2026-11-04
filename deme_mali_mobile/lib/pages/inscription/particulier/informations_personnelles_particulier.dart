
import 'package:flutter/material.dart';

import '../../../models/donnees_personnelles_particulier.dart';
import '../../../styles/couleurs.dart';
import '../widgets/boutons_etapes.dart';
import '../widgets/champs_inscription.dart';
import '../widgets/entete_etapes.dart';
import 'informations_beneficiaire.dart';

// Étape 1 sur 2 de l'inscription du particulier
class InformationsPersonnellesParticulierPage extends StatefulWidget {
  final int organisationId;

  const InformationsPersonnellesParticulierPage({
    super.key,
    required this.organisationId,
  });

  @override
  State<InformationsPersonnellesParticulierPage> createState() =>
      _InformationsPersonnellesParticulierPageState();
}

class _InformationsPersonnellesParticulierPageState
    extends State<InformationsPersonnellesParticulierPage> {
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final adresseController = TextEditingController();
  final villeController = TextEditingController();
  final telephoneController = TextEditingController();
  final motDePasseController = TextEditingController();
  String genre = 'Homme';

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    adresseController.dispose();
    villeController.dispose();
    telephoneController.dispose();
    motDePasseController.dispose();
    super.dispose();
  }

  bool get formulaireValide {
    return nomController.text.trim().isNotEmpty &&
        prenomController.text.trim().isNotEmpty &&
        adresseController.text.trim().isNotEmpty &&
        villeController.text.trim().isNotEmpty &&
        telephoneController.text.trim().isNotEmpty &&
        motDePasseController.text.length >= 6;
  }

  void _actualiser([String? _]) => setState(() {});

  void _suivant() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InformationsBeneficiairePage(
          organisationId: widget.organisationId,
          personnel: DonneesPersonnellesParticulier(
            nom: nomController.text,
            prenom: prenomController.text,
            adresse: adresseController.text,
            ville: villeController.text,
            telephone: telephoneController.text,
            motDePasse: motDePasseController.text,
            genre: genre,
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
                      total: 2,
                      titre: 'Informations personnelles',
                      sousTitre: 'Veuillez renseigner vos données de base '
                          "pour démarrer l'enregistrement.",
                    ),
                    const SizedBox(height: 18),

                    ChampInscription(
                      titre: 'Nom',
                      indication: 'Ex: Traoré',
                      controller: nomController,
                      onChanged: _actualiser,
                    ),
                    const SizedBox(height: 14),

                    ChampInscription(
                      titre: 'Prénom',
                      indication: 'Ex: Ousmane',
                      controller: prenomController,
                      onChanged: _actualiser,
                    ),
                    const SizedBox(height: 14),

                    ChampListeInscription(
                      titre: 'Genre',
                      indication: 'Sélectionnez votre genre',
                      options: const ['Homme', 'Femme'],
                      valeur: genre,
                      onChanged: (v) => setState(() => genre = v ?? 'Homme'),
                    ),
                    const SizedBox(height: 14),

                    ChampInscription(
                      titre: 'Adresse',
                      indication: 'Ex: Quartier du Fleuve, Rue 110',
                      controller: adresseController,
                      onChanged: _actualiser,
                    ),
                    const SizedBox(height: 14),

                    ChampInscription(
                      titre: 'Ville',
                      indication: 'Ex: Bamako',
                      controller: villeController,
                      onChanged: _actualiser,
                    ),
                    const SizedBox(height: 14),

                    ChampInscription(
                      titre: 'Numéro de téléphone',
                      indication: 'Ex: 67 89 09 78',
                      controller: telephoneController,
                      typeClavier: TextInputType.phone,
                      onChanged: _actualiser,
                    ),
                    const SizedBox(height: 14),

                    ChampInscription(
                      titre: 'Mot de passe',
                      indication: 'Entrez votre mot de passe',
                      controller: motDePasseController,
                      motDePasse: true,
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

import 'package:flutter/material.dart';

import '../../../controllers/inscription_structure_controller.dart';
import '../../../models/donnees_structure.dart';
import '../../../styles/couleurs.dart';
import '../redirection_connexion.dart';
import '../widgets/boutons_etapes.dart';
import '../widgets/champs_inscription.dart';
import '../widgets/entete_etapes.dart';

class InformationsStructureEtape3Page extends StatefulWidget {
  final int organisationId;
  final DonneesStructureEtape2 etape2;

  const InformationsStructureEtape3Page({
    super.key,
    required this.organisationId,
    required this.etape2,
  });

  @override
  State<InformationsStructureEtape3Page> createState() =>
      _InformationsStructureEtape3PageState();
}

class _InformationsStructureEtape3PageState
    extends State<InformationsStructureEtape3Page> {
  final InscriptionStructureController controller =
      InscriptionStructureController();

  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final telephoneController = TextEditingController();
  final motDePasseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.addListener(_actualiser);
  }

  @override
  void dispose() {
    controller.removeListener(_actualiser);
    controller.dispose();
    nomController.dispose();
    prenomController.dispose();
    telephoneController.dispose();
    motDePasseController.dispose();
    super.dispose();
  }

  void _actualiser([String? _]) {
    if (mounted) setState(() {});
  }

  bool get formulaireValide {
    return nomController.text.trim().isNotEmpty &&
        prenomController.text.trim().isNotEmpty &&
        telephoneController.text.trim().isNotEmpty &&
        motDePasseController.text.length >= 6;
  }

  Future<void> _enregistrer() async {
    final messenger = ScaffoldMessenger.of(context);

    final succes = await controller.inscrire(
      nom: nomController.text,
      prenom: prenomController.text,
      telephone: telephoneController.text,
      motDePasse: motDePasseController.text,
      ville: widget.etape2.etape1.ville,
      adresse: widget.etape2.etape1.adresse,
      organisationPartenaireId: widget.organisationId,
      nomStructure: widget.etape2.etape1.nomStructure,
      nif: widget.etape2.etape1.nif,
      email: widget.etape2.email,
      documentJustificatif: widget.etape2.nomDocument,
    );

    if (!mounted) return;

    if (!succes) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(controller.erreur ?? "Erreur lors de l'inscription."),
        ),
      );
      return;
    }

    redirigerVersConnexion(context, message: messageCompteStructureEnAttente);
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
                      etape: 3,
                      total: 3,
                      titre: 'Créer votre compte',
                      sousTitre: 'Créez vos identifiants pour accéder à '
                          'votre espace structure.',
                    ),
                    const SizedBox(height: 20),

                    ChampInscription(
                      titre: 'Nom',
                      indication: 'Entrez votre nom',
                      controller: nomController,
                      onChanged: _actualiser,
                    ),
                    const SizedBox(height: 14),

                    ChampInscription(
                      titre: 'Prenom',
                      indication: 'Entrez votre prenom',
                      controller: prenomController,
                      onChanged: _actualiser,
                    ),
                    const SizedBox(height: 14),

                    ChampInscription(
                      titre: 'Numéro de téléphone',
                      indication: 'Exemple : +223 70 00 00 00',
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
                onSuivant: formulaireValide ? _enregistrer : null,
                chargement: controller.chargement,
                texteSuivant: 'Enregistrer',
                afficherFleche: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

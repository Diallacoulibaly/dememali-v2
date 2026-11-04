
import 'package:flutter/material.dart';

import '../../controllers/inscription_donateur_controller.dart';
import '../../models/pays.dart';
import '../../styles/couleurs.dart';
import 'redirection_connexion.dart';
import 'widgets/bouton_continuer.dart';
import 'widgets/champs_inscription.dart';
import 'widgets/entete_inscription.dart';

class InformationsPersonnellesPage extends StatefulWidget {
  final String typeCompte;
  final Pays pays;

  // Identifiant du pays dans le backend (table pays)
  final int paysId;

  const InformationsPersonnellesPage({
    super.key,
    required this.typeCompte,
    required this.pays,
    required this.paysId,
  });

  @override
  State<InformationsPersonnellesPage> createState() =>
      _InformationsPersonnellesPageState();
}

class _InformationsPersonnellesPageState
    extends State<InformationsPersonnellesPage> {
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final telephoneController = TextEditingController();
  final motDePasseController = TextEditingController();

  final InscriptionDonateurController controller =
      InscriptionDonateurController();

  String? genre;
  String? ville;

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

  bool get formulaireValide {
    return nomController.text.trim().isNotEmpty &&
        prenomController.text.trim().isNotEmpty &&
        telephoneController.text.trim().isNotEmpty &&
        genre != null &&
        ville != null &&
        motDePasseController.text.isNotEmpty;
  }

  void _actualiser([String? _]) => setState(() {});

  Future<void> _continuer() async {
    final messenger = ScaffoldMessenger.of(context);

    if (motDePasseController.text.length < 6) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Le mot de passe doit contenir au moins 6 caractères.'),
        ),
      );
      return;
    }

    final succes = await controller.inscrire(
      nom: nomController.text,
      prenom: prenomController.text,
      telephone: telephoneController.text,
      motDePasse: motDePasseController.text,
      genre: genre!,
      paysId: widget.paysId,
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

    // Inscription réussie : on repart sur l'accueil puis on ouvre la connexion
    redirigerVersConnexion(context);
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const EnteteInscription(
                      titre: 'Information personnelles',
                      sousTitre: 'Veuillez renseigner vos données de '
                          "base pour démarrer l'enregistrement.",
                    ),
                    const SizedBox(height: 24),

                    ChampInscription(
                      titre: 'Nom',
                      indication: 'Entrez votre nom',
                      controller: nomController,
                      onChanged: _actualiser,
                    ),
                    const SizedBox(height: 18),

                    ChampInscription(
                      titre: 'Prenom',
                      indication: 'Entrez votre prenom',
                      controller: prenomController,
                      onChanged: _actualiser,
                    ),
                    const SizedBox(height: 18),

                    ChampInscription(
                      titre: 'Numéro de téléphone',
                      indication:
                      'Ex: ${widget.pays.indicatif} 76 00 00 00',
                      controller: telephoneController,
                      icone: Icons.phone_outlined,
                      typeClavier: TextInputType.phone,
                      onChanged: _actualiser,
                    ),
                    const SizedBox(height: 18),

                    ChampListeInscription(
                      titre: 'Genre',
                      indication: 'Sélectionnez votre genre',
                      options: const ['Homme', 'Femme'],
                      valeur: genre,
                      onChanged: (v) => setState(() => genre = v),
                    ),
                    const SizedBox(height: 18),

                    ChampListeInscription(
                      titre: 'Ville',
                      indication: 'Sélectionnez votre ville',
                      options: widget.pays.villes,
                      valeur: ville,
                      icone: Icons.location_on_outlined,
                      onChanged: (v) => setState(() => ville = v),
                    ),
                    const SizedBox(height: 18),

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

            // BOUTON FIXE EN BAS
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              child: BoutonContinuer(
                actif: formulaireValide && !controller.chargement,
                onPressed: _continuer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

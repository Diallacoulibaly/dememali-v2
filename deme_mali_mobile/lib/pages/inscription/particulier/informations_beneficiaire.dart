
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../controllers/inscription_particulier_controller.dart';
import '../../../models/donnees_personnelles_particulier.dart';
import '../../../styles/couleurs.dart';
import '../redirection_connexion.dart';
import '../widgets/boutons_etapes.dart';
import '../widgets/champs_inscription.dart';
import '../widgets/entete_etapes.dart';

// Étape 2 sur 2 de l'inscription du particulier
class InformationsBeneficiairePage extends StatefulWidget {
  final int organisationId;
  final DonneesPersonnellesParticulier personnel;

  const InformationsBeneficiairePage({
    super.key,
    required this.organisationId,
    required this.personnel,
  });

  @override
  State<InformationsBeneficiairePage> createState() =>
      _InformationsBeneficiairePageState();
}

class _InformationsBeneficiairePageState
    extends State<InformationsBeneficiairePage> {
  final InscriptionParticulierController controller =
  InscriptionParticulierController();

  final nombreEnfantsController = TextEditingController();
  final descriptionController = TextEditingController();

  String? situationMatrimoniale;
  String? handicap;
  DateTime? dateNaissance;

  @override
  void initState() {
    super.initState();
    controller.addListener(_actualiser);
  }

  @override
  void dispose() {
    controller.removeListener(_actualiser);
    controller.dispose();
    nombreEnfantsController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _actualiser([String? _]) {
    if (mounted) setState(() {});
  }

  // La description est facultative, tous les autres champs sont obligatoires
  bool get formulaireValide {
    return situationMatrimoniale != null &&
        nombreEnfantsController.text.trim().isNotEmpty &&
        handicap != null &&
        dateNaissance != null;
  }

  Future<void> _inscrire() async {
    final messenger = ScaffoldMessenger.of(context);

    final succes = await controller.inscrire(
      personnel: widget.personnel,
      organisationPartenaireId: widget.organisationId,
      situationMatrimoniale: situationMatrimoniale!,
      nombreEnfants: int.parse(nombreEnfantsController.text.trim()),
      handicap: handicap!,
      description: descriptionController.text,
      dateNaissance: dateNaissance!,
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

    redirigerVersConnexion(context, message: messageCompteParticulierEnAttente);
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
                      etape: 2,
                      total: 2,
                      titre: 'Informations bénéficiaire',
                      sousTitre: 'Ces critères nous permettent de mieux '
                          'cibler et prioriser nos interventions de soutien.',
                    ),
                    const SizedBox(height: 18),

                    ChampListeInscription(
                      titre: 'Situation matrimoniale',
                      indication: 'Sélectionnez votre situation',
                      options: InscriptionParticulierController
                          .situationsMatrimoniales.keys
                          .toList(),
                      valeur: situationMatrimoniale,
                      onChanged: (v) =>
                          setState(() => situationMatrimoniale = v),
                    ),
                    const SizedBox(height: 14),

                    ChampInscription(
                      titre: 'Nombre d’enfants',
                      indication: 'Ex: 2',
                      controller: nombreEnfantsController,
                      typeClavier: TextInputType.number,
                      formatteurs: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      onChanged: _actualiser,
                    ),
                    const SizedBox(height: 14),

                    ChampListeInscription(
                      titre: 'Type de handicap',
                      indication: 'Sélectionnez une option',
                      options: InscriptionParticulierController
                          .handicaps.keys
                          .toList(),
                      valeur: handicap,
                      onChanged: (v) => setState(() => handicap = v),
                    ),
                    const SizedBox(height: 14),

                    ChampInscription(
                      titre: 'Description de votre situation',
                      indication: 'Décrivez brièvement vos besoins '
                          'prioritaires actuels (santé, alimentation, '
                          'éducation...)',
                      controller: descriptionController,
                      lignes: 3,
                      typeClavier: TextInputType.multiline,
                    ),
                    const SizedBox(height: 14),

                    ChampDateInscription(
                      titre: 'Date de naissance',
                      valeur: dateNaissance,
                      onChoisie: (d) => setState(() => dateNaissance = d),
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
                onSuivant: formulaireValide ? _inscrire : null,
                chargement: controller.chargement,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

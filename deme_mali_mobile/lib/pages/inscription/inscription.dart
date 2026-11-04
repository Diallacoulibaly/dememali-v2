import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

import 'particulier/choix_organisation.dart';
import 'selection_pays.dart';
import 'widgets/choix_type_compte.dart';
import 'widgets/bouton_continuer.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  String typeSelectionne = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: Column(
          children: [
            // CONTENU DE LA PAGE
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // BOUTON RETOUR
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 17,
                          color: Color(0xFF1F1F1F),
                        ),
                      ),
                    ),

                    const SizedBox(height: 45),

                    // TITRE
                    const Text(
                      'Créer votre compte',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: CouleursApp.noir,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // DESCRIPTION
                    const Text(
                      'Choisissez le type de compte qui vous '
                          'correspond.',
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: Color(0xFF777777),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // CHOIX DU TYPE DE COMPTE
                    ChoixTypeCompte(
                      typeSelectionne: typeSelectionne,
                      onSelection: (type) {
                        setState(() {
                          typeSelectionne = type;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // BOUTON FIXE EN BAS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                12,
                12,
                12,
                18,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFECE8DF),
                  ),
                ),
              ),
              child: BoutonContinuer(
                actif: typeSelectionne.isNotEmpty,
                onPressed: () {
                  // Donateur : pays puis informations personnelles
                  if (typeSelectionne == 'DONATEUR') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectionPaysPage(
                          typeCompte: typeSelectionne,
                        ),
                      ),
                    );
                    return;
                  }

                  // Particulier : organisation, informations personnelles puis
                  // informations bénéficiaire
                  if (typeSelectionne == 'PARTICULIER') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChoixOrganisationPage(
                          typeCompte: 'PARTICULIER',
                        ),
                      ),
                    );
                    return;
                  }

                  // Structure : organisation, informations de la structure (1/3, 2/3)
                  // puis création du compte (3/3)
                  if (typeSelectionne == 'STRUCTURE') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChoixOrganisationPage(
                          typeCompte: 'STRUCTURE',
                        ),
                      ),
                    );
                    return;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

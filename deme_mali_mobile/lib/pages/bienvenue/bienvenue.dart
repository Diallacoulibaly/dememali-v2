import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';
import '../authentification/connexion.dart';
import 'widgets/contenue_bienvenu.dart';
import 'widgets/boutons_bienvenue.dart';
import '../inscription/inscription.dart';
class BienvenuePage extends StatelessWidget {
  const BienvenuePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // CONTENU PRINCIPAL centré et réajusté
              const Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: ContenuBienvenue(),
                  ),
                ),
              ),

              // BOUTONS EN BAS
              BoutonsBienvenue(
                onInscription: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InscriptionPage(),
                  ),
                );
              },onConnexion: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConnexionPage(),
                  ),
                );
              },
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}

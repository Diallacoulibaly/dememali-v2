
import 'package:flutter/material.dart';

import '../../styles/couleurs.dart';
import 'widgets/widget_logo.dart';
import 'widgets/widget_presentation.dart';
import '../presentation_don/presentation_don.dart';

class PresentationPage extends StatefulWidget {
  const PresentationPage({super.key});

  @override
  State<PresentationPage> createState() => _PresentationPageState();
}

class _PresentationPageState extends State<PresentationPage> {
  // Le deuxième point est actif au démarrage.
  int pageActive = 1;

  // Ouvrir la troisième page de présentation.
  void pageSuivante() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PresentationDonPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              // Logo et nom Dèmè Mali.
              const WidgetLogo(),

              const SizedBox(height: 16),

              // Contenu de la deuxième présentation centré et bien espacé
              const Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: WidgetPresentation(),
                  ),
                ),
              ),

              // Indicateurs juste au-dessus du bouton.
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 5,
                      ),
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == pageActive
                            ? CouleursApp.vert
                            : const Color(0xFFD8D8D8),
                      ),
                    );
                  }),
                ),
              ),

              // Bouton Suivant.
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: pageSuivante,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CouleursApp.vert,
                    foregroundColor: CouleursApp.blanc,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Suivant',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(width: 7),
                      Icon(
                        Icons.arrow_forward,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

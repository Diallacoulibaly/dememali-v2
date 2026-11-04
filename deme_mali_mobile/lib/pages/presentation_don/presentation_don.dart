import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';
import '../presentation/widgets/widget_logo.dart';
import '../bienvenue/bienvenue.dart';
import 'widgets/widget_message_aide.dart';
import 'widgets/widget_etapes_aide.dart';

class PresentationDonPage extends StatelessWidget {
  const PresentationDonPage({super.key});

  void _suivant(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const BienvenuePage(),
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
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
              child: Column(
                children: [
                  const Center(
                    child: WidgetLogo(),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: SizedBox(
                          width: contraintes.maxWidth,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WidgetMessageAide(),
                              SizedBox(height: 24),
                              WidgetEtapesAide(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Indicateur(actif: false),
                      _Indicateur(actif: false),
                      _Indicateur(actif: true),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => _suivant(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CouleursApp.vert,
                        foregroundColor: CouleursApp.blanc,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
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
                          Icon(Icons.arrow_forward, size: 14),
                        ],
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

class _Indicateur extends StatelessWidget {
  final bool actif;

  const _Indicateur({required this.actif});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: actif ? CouleursApp.vert : const Color(0xFFD8D8D8),
      ),
    );
  }
}
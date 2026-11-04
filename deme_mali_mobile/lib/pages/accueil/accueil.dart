
import 'package:flutter/material.dart';

import '../../styles/couleurs.dart';
import '../presentation/presentation.dart';
import 'widgets/panneau_message.dart';
import 'widgets/indicateurs_page.dart';

class AccueilPage extends StatelessWidget {
  final bool afficherLogo;

  const AccueilPage({
    super.key,
    this.afficherLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    final zoneSureHaut = MediaQuery.of(context).padding.top;
    final zoneSureBas = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PresentationPage(),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image de fond sur tout l'écran.
            Image.asset(
              'assets/images/accueil.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),

            // Logo de l'application.
            if (afficherLogo)
              Positioned(
                top: zoneSureHaut + 12,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/logo_acceuil.png',
                    width: 76,
                    height: 76,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/logo_accueil.png',
                      width: 76,
                      height: 76,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error2, stackTrace2) => Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: CouleursApp.vert.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.volunteer_activism,
                          color: CouleursApp.vert,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Panneau vert en bas de l'écran.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: 22,
                  bottom: zoneSureBas + 18,
                ),
                decoration: BoxDecoration(
                  color: CouleursApp.vert.withValues(alpha: 0.88),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: PanneauMessage(),
                    ),
                    SizedBox(height: 22),
                    IndicateursPage(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

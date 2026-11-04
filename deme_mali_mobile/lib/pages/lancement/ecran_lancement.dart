
import 'package:flutter/material.dart';

import '../../styles/couleurs.dart';
import '../accueil/accueil.dart';
import 'widgets/nom_anime.dart';

class EcranLancement extends StatefulWidget {
  const EcranLancement({super.key});

  @override
  State<EcranLancement> createState() => _EcranLancementState();
}

class _EcranLancementState extends State<EcranLancement>
    with TickerProviderStateMixin {
  final String nomApplication = 'Dèmè Mali';

  String nomAffiche = '';

  bool nomVisible = true;
  bool logoVisible = true;

  late final AnimationController controleurEntree;
  late final Animation<double> echelleLogo;

  late final AnimationController controleurPosition;
  late final Animation<double> positionLogo;
  late final Animation<double> tailleLogo;

  late final AnimationController controleurAccueil;
  late final Animation<double> opaciteAccueil;

  @override
  void initState() {
    super.initState();

    // 1. Entrée dynamique du logo dès l'ouverture du splash
    controleurEntree = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    echelleLogo = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controleurEntree,
        curve: Curves.easeOutBack,
      ),
    );

    // 2. Déplacement du logo vers le haut (et ajustement de 90px à 76px pour l'accueil)
    controleurPosition = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    positionLogo = CurvedAnimation(
      parent: controleurPosition,
      curve: Curves.easeInOutCubic,
    );

    tailleLogo = Tween<double>(
      begin: 90.0,
      end: 76.0,
    ).animate(
      CurvedAnimation(
        parent: controleurPosition,
        curve: Curves.easeInOutCubic,
      ),
    );

    // 3. Apparition progressive de la page d'accueil
    controleurAccueil = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    opaciteAccueil = CurvedAnimation(
      parent: controleurAccueil,
      curve: Curves.easeIn,
    );

    // Démarrer l'animation d'apparition du logo
    controleurEntree.forward();

    lancerAnimation();
  }

  Future<void> lancerAnimation() async {
    // 1. Écriture du nom lettre par lettre sous le logo
    for (int i = 1; i <= nomApplication.length; i++) {
      if (!mounted) return;

      setState(() {
        nomAffiche = nomApplication.substring(0, i);
      });

      await Future.delayed(
        const Duration(milliseconds: 110),
      );
    }

    if (!mounted) return;

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    // 2. Faire disparaître le nom
    setState(() {
      nomVisible = false;
    });

    // 3. Faire apparaître l'accueil
    controleurAccueil.forward();

    // 4. Déplacer le logo agrandi vers le haut (vers l'en-tête de l'accueil)
    await controleurPosition.forward();
  }

  @override
  void dispose() {
    controleurEntree.dispose();
    controleurPosition.dispose();
    controleurAccueil.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tailleEcran = MediaQuery.of(context).size;
    final zoneSureHaut = MediaQuery.of(context).padding.top;

    final double positionDepart = tailleEcran.height * 0.30;
    final double positionFinale = zoneSureHaut + 12;

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Page d'accueil sans deuxième logo
          FadeTransition(
            opacity: opaciteAccueil,
            child: const AccueilPage(
              afficherLogo: false,
            ),
          ),

          // Nom de l'application positionné juste sous le logo pour un ensemble cohérent
          if (nomVisible)
            Positioned(
              top: positionDepart + 96,
              left: 0,
              right: 0,
              child: Center(
                child: NomAnime(
                  texte: nomAffiche,
                ),
              ),
            ),

          // Logo animé : immédiatement visible dès le démarrage, avec entrée dynamique puis transition vers l'en-tête
          if (logoVisible)
            AnimatedBuilder(
              animation: Listenable.merge([
                controleurEntree,
                controleurPosition,
              ]),
              builder: (context, child) {
                final double taille = tailleLogo.value * echelleLogo.value;

                final double haut = positionDepart +
                    (positionFinale - positionDepart) *
                        positionLogo.value;

                return Positioned(
                  top: haut,
                  left: (tailleEcran.width - taille) / 2,
                  width: taille,
                  height: taille,
                  child: Image.asset(
                    'assets/images/logo_acceuil.png',
                    width: taille,
                    height: taille,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/logo_Acceuil.png',
                      width: taille,
                      height: taille,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error2, stackTrace2) => Image.asset(
                        'assets/images/logo_accueil.png',
                        width: taille,
                        height: taille,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error3, stackTrace3) => Icon(
                          Icons.volunteer_activism,
                          size: taille * 0.7,
                          color: CouleursApp.vert,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

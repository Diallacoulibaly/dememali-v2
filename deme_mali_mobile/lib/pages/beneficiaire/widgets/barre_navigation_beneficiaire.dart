import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/accueil_beneficiaire_controller.dart';
import '../../../styles/couleurs.dart';

/// Barre de navigation inférieure courbée uniforme pour l'espace bénéficiaire
class BarreNavigationBeneficiaire extends ConsumerWidget {
  const BarreNavigationBeneficiaire({super.key});

  static const Color vert = CouleursApp.vert;
  static const Color blanc = Colors.white;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(ongletActifBeneficiaireProvider);

    return CurvedNavigationBar(
      index: selectedIndex.clamp(0, 3),
      height: 65,
      color: vert,
      buttonBackgroundColor: blanc,
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      items: [
        CurvedNavigationBarItem(
          child: Icon(
            selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
            color: selectedIndex == 0 ? vert : blanc,
          ),
          label: 'Accueil',
          labelStyle: const TextStyle(
            color: blanc,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        CurvedNavigationBarItem(
          child: Icon(
            selectedIndex == 1
                ? Icons.description_rounded
                : Icons.description_outlined,
            color: selectedIndex == 1 ? vert : blanc,
          ),
          label: 'Mes demandes',
          labelStyle: const TextStyle(
            color: blanc,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        CurvedNavigationBarItem(
          child: Icon(
            selectedIndex == 2
                ? Icons.volunteer_activism_rounded
                : Icons.volunteer_activism_outlined,
            color: selectedIndex == 2 ? vert : blanc,
          ),
          label: 'Mes dons reçus',
          labelStyle: const TextStyle(
            color: blanc,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        CurvedNavigationBarItem(
          child: Icon(
            selectedIndex == 3
                ? Icons.person_rounded
                : Icons.person_outline_rounded,
            color: selectedIndex == 3 ? vert : blanc,
          ),
          label: 'Profil',
          labelStyle: const TextStyle(
            color: blanc,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
      onTap: (index) {
        ref.read(ongletActifBeneficiaireProvider.notifier).changerOnglet(index);
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}

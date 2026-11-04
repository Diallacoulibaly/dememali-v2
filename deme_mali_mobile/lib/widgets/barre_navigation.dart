import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';

class BarreNavigation extends StatelessWidget {
  final int indexSelectionne;
  final ValueChanged<int> onTap;

  const BarreNavigation({
    super.key,
    required this.indexSelectionne,
    required this.onTap,
  });

  static const Color vert = Color(0xFF0F7A4B);
  static const Color blanc = Colors.white;
  static const Color beige = Color(0xFFF7F3EA);


  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: indexSelectionne,
      height: 65,
      color: vert,
      buttonBackgroundColor: blanc,
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),

      items: [
        CurvedNavigationBarItem(
          child: Icon(
            indexSelectionne == 0 ? Icons.home_rounded : Icons.home_outlined,
            color: indexSelectionne == 0 ? vert : blanc,
          ),
          label: 'Home',
          labelStyle: const TextStyle(
            color: blanc,
            fontSize: 11,
          ),
        ),
        CurvedNavigationBarItem(
          child: Icon(
            indexSelectionne == 1
                ? Icons.account_balance_rounded
                : Icons.account_balance_outlined,
            color: indexSelectionne == 1 ? vert : blanc,
          ),
          label: 'Organisations',
          labelStyle: const TextStyle(
            color: blanc,
            fontSize: 11,
          ),
        ),
        CurvedNavigationBarItem(
          child: Icon(
            indexSelectionne == 2
                ? Icons.handshake_rounded
                : Icons.handshake_outlined,
            color: indexSelectionne == 2 ? vert : blanc,
          ),
          label: 'Mes dons',
          labelStyle: const TextStyle(
            color: blanc,
            fontSize: 11,
          ),
        ),
        CurvedNavigationBarItem(
          child: Icon(
            indexSelectionne == 3
                ? Icons.person_rounded
                : Icons.person_outline_rounded,
            color: indexSelectionne == 3 ? vert : blanc,
          ),
          label: 'Profil',
          labelStyle: const TextStyle(
            color: blanc,
            fontSize: 11,
          ),
        ),
      ],

      onTap: onTap,
    );
  }
}

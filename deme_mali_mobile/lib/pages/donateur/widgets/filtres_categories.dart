
import 'package:flutter/material.dart';

import '../../../models/categorie_demande.dart';

class FiltresCategories extends StatelessWidget {
  final List<CategorieDemande> categories;
  final int? categorieSelectionneeId;
  final ValueChanged<int?> onSelectionChanged;

  const FiltresCategories({
    super.key,
    required this.categories,
    required this.categorieSelectionneeId,
    required this.onSelectionChanged,
  });

  static const vert = Color(0xFF0F7A4B);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _construireFiltre(
            nom: 'Toutes',
            selectionne: categorieSelectionneeId == null,
            action: () => onSelectionChanged(null),
          ),
          ...categories.map((categorie) {
            return Padding(
              padding: const EdgeInsets.only(left: 9),
              child: _construireFiltre(
                nom: categorie.nom,
                selectionne: categorieSelectionneeId == categorie.id,
                action: () => onSelectionChanged(categorie.id),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _construireFiltre({
    required String nom,
    required bool selectionne,
    required VoidCallback action,
  }) {
    return Material(
      color: selectionne ? vert : const Color(0xFFF0F0F0),
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(25),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 19),
          child: Center(
            child: Text(
              nom,
              style: TextStyle(
                color: selectionne ? Colors.white : const Color(0xFF555555),
                fontSize: 14,
                fontWeight:
                selectionne ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

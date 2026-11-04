
import 'package:flutter/material.dart';
import 'package:deme_mali_mobile/styles/couleurs.dart';

enum FiltreMesDons {
  tous,
  financiers,
  materiels,
}

class FiltresMesDons extends StatelessWidget {
  final FiltreMesDons filtreSelectionne;
  final ValueChanged<FiltreMesDons> onFiltreChange;

  const FiltresMesDons({
    super.key,
    required this.filtreSelectionne,
    required this.onFiltreChange,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _construireFiltre('Tous', FiltreMesDons.tous),
          const SizedBox(width: 8),
          _construireFiltre(
            'Financiers',
            FiltreMesDons.financiers,
          ),
          const SizedBox(width: 8),
          _construireFiltre(
            'Matériels',
            FiltreMesDons.materiels,
          ),
        ],
      ),
    );
  }

  Widget _construireFiltre(
      String titre,
      FiltreMesDons filtre,
      ) {
    final selectionne = filtreSelectionne == filtre;

    return ChoiceChip(
      label: Text(titre),
      selected: selectionne,
      onSelected: (_) => onFiltreChange(filtre),
      showCheckmark: false,
      backgroundColor: CouleursApp.blanc,
      selectedColor: CouleursApp.vert,
      side: BorderSide(
        color: selectionne
            ? CouleursApp.vert
            : CouleursApp.jaune,
      ),
      labelStyle: TextStyle(
        color: selectionne
            ? CouleursApp.blanc
            : CouleursApp.noir,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}


import 'package:flutter/material.dart';

class FiltresUrgence extends StatelessWidget {
  final List<String> niveaux;
  final String selection;
  final ValueChanged<String> onSelectionChanged;

  const FiltresUrgence({
    super.key,
    required this.niveaux,
    required this.selection,
    required this.onSelectionChanged,
  });

  static const Color vert = Color(0xFF0F7A4B);
  static const Color fonce = Color(0xFF1F1F1F);
  static const Color bordure = Color(0xFFEAE6DF);

  @override
  Widget build(BuildContext context) {
    // Évite de construire une liste inutile si aucune valeur n'est disponible.
    if (niveaux.isEmpty) {
      return const SizedBox(height: 42);
    }

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        itemCount: niveaux.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final niveau = niveaux[index];

          final actif =
              niveau.trim().toLowerCase() ==
                  selection.trim().toLowerCase();

          return Material(
            color: actif ? vert : Colors.white,
            borderRadius: BorderRadius.circular(25),
            child: InkWell(
              onTap: () => onSelectionChanged(niveau),
              borderRadius: BorderRadius.circular(25),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: actif ? vert : bordure,
                  ),
                ),
                child: Text(
                  niveau,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: actif ? Colors.white : fonce,
                    fontSize: 12,
                    fontWeight: actif
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

class ChoixTypeCompte extends StatelessWidget {
  final String typeSelectionne;
  final Function(String) onSelection;

  const ChoixTypeCompte({
    super.key,
    required this.typeSelectionne,
    required this.onSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _creerCarte(
          'DONATEUR',
          'Je souhaite faire des dons et suivre leur utilisation.',
          Icons.volunteer_activism,
        ),
        const SizedBox(height: 20),

        _creerCarte(
          'PARTICULIER',
          'Je souhaite demander une aide.',
          Icons.person,
        ),
        const SizedBox(height: 20),

        _creerCarte(
          'STRUCTURE',
          'Je représente un hôpital, une école, une mosquée ou une église.',
          Icons.account_balance,
        ),
      ],
    );
  }

  Widget _creerCarte(
      String type,
      String description,
      IconData icone,
      ) {
    bool selectionne = typeSelectionne == type;

    return GestureDetector(
      onTap: () {
        onSelection(type);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selectionne
                ? CouleursApp.vert
                : const Color(0xFFF0F0F0),
          ),
        ),
        child: Row(
          children: [
            // ICONE
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE4F1E9),
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Icon(
                icone,
                color: CouleursApp.vert,
                size: 22,
              ),
            ),

            const SizedBox(width: 10),

            // TEXTE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type == 'DONATEUR'
                        ? 'Donateur'
                        : type == 'PARTICULIER'
                        ? 'Particulier'
                        : 'Structure',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.3,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // CERCLE DE SELECTION
            Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectionne
                      ? CouleursApp.vert
                      : const Color(0xFFDADADA),
                  width: 1,
                ),
                color: selectionne
                    ? CouleursApp.vert
                    : Colors.white,
              ),
              child: selectionne
                  ? const Icon(
                Icons.check,
                size: 12,
                color: Colors.white,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

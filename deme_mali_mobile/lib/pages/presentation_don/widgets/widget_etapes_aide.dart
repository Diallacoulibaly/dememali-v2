
import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

class WidgetEtapesAide extends StatelessWidget {
  const WidgetEtapesAide({super.key});

  Widget _etape({
    required IconData icone,
    required String titre,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFE2F0E7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icone,
              color: CouleursApp.vert,
              size: 25,
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                titre,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CouleursApp.vert,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _etape(
          icone: Icons.person,
          titre: 'Besoin',
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: Icon(
            Icons.arrow_forward,
            color: CouleursApp.vert,
            size: 19,
          ),
        ),

        _etape(
          icone: Icons.check_circle,
          titre: 'Vérification',
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 3),
          child: Icon(
            Icons.arrow_forward,
            color: CouleursApp.vert,
            size: 19,
          ),
        ),

        _etape(
          icone: Icons.volunteer_activism,
          titre: 'Aide',
        ),
      ],
    );
  }
}

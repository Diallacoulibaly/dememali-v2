
import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

class WidgetMessageAide extends StatelessWidget {
  const WidgetMessageAide({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Chaque personne\nmérite une aide',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: CouleursApp.vert,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            height: 1.12,
          ),
        ),

        SizedBox(height: 10),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            'Dèmè Mali met en relation les '
                'personnes en difficulté avec les aides '
                'dont elles ont réellement besoin.',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: CouleursApp.noir,
              fontSize: 13.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

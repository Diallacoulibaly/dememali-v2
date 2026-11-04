
import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

class IndicateursPage extends StatelessWidget {
  final int pageActive;

  const IndicateursPage({
    super.key,
    this.pageActive = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final bool actif = index == pageActive;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: actif
                ? CouleursApp.blanc
                : CouleursApp.blanc.withValues(alpha: 0.45),
          ),
        );
      }),
    );
  }
}

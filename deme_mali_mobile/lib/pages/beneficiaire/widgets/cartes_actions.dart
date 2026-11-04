import 'package:flutter/material.dart';
import '../../../styles/couleurs.dart';

class CartesActions extends StatelessWidget {
  const CartesActions({
    super.key,
    required this.onDemander,
    required this.onMesDemandes,
    required this.onSuivi,
    required this.onAidesRecues,
  });

  final VoidCallback onDemander;
  final VoidCallback onMesDemandes;
  final VoidCallback onSuivi;
  final VoidCallback onAidesRecues;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Demander une aide', Icons.volunteer_activism, onDemander),
      ('Mes demandes', Icons.description_outlined, onMesDemandes),
      ('Suivre mes aides', Icons.track_changes, onSuivi),
      ('Mes aides reçues', Icons.inventory_2_outlined, onAidesRecues),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 340 ? 1 : 2;
        final width =
            (constraints.maxWidth - (columns - 1) * 12) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) {
            return SizedBox(
              width: width,
              child: Material(
                color: CouleursApp.blanc,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: item.$3,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: CouleursApp.vert.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            item.$2,
                            color: CouleursApp.vert,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 13),
                        Text(
                          item.$1,
                          style: const TextStyle(
                            color: CouleursApp.noir,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Icon(
                          Icons.arrow_forward,
                          color: CouleursApp.jaune,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

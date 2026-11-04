
import 'package:flutter/material.dart';

// Drapeaux dessinés en Flutter (les emojis de drapeaux ne s'affichent
// pas sous Windows / Edge).
class DrapeauPays extends StatelessWidget {
  final String code;

  const DrapeauPays({super.key, required this.code});

  static const Color _rouge = Color(0xFFCE1126);
  static const Color _jaune = Color(0xFFFCD116);
  static const Color _vert = Color(0xFF14B53A);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        width: 26,
        height: 19,
        child: _construire(),
      ),
    );
  }

  Widget _construire() {
    switch (code) {
      case 'ML':
        return _bandesVerticales(const [_vert, _jaune, _rouge]);
      case 'SN':
        return Stack(
          alignment: Alignment.center,
          children: [
            _bandesVerticales(const [_vert, _jaune, _rouge]),
            const Icon(Icons.star, size: 9, color: _vert),
          ],
        );
      case 'CI':
        return _bandesVerticales(
          const [Color(0xFFF77F00), Colors.white, Color(0xFF009E60)],
        );
      case 'GN':
        return _bandesVerticales(
          const [_rouge, _jaune, Color(0xFF009460)],
        );
      case 'BF':
        return Stack(
          alignment: Alignment.center,
          children: [
            _bandesHorizontales(
              const [Color(0xFFEF2B2D), Color(0xFF009E49)],
            ),
            const Icon(Icons.star, size: 9, color: _jaune),
          ],
        );
      case 'NE':
        return Stack(
          alignment: Alignment.center,
          children: [
            _bandesHorizontales(
              const [Color(0xFFE05206), Colors.white, Color(0xFF0DB02B)],
            ),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFE05206),
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      default:
        return Container(color: const Color(0xFFDADADA));
    }
  }

  Widget _bandesVerticales(List<Color> couleurs) {
    return Row(
      children: couleurs
          .map((c) => Expanded(child: Container(color: c)))
          .toList(),
    );
  }

  Widget _bandesHorizontales(List<Color> couleurs) {
    return Column(
      children: couleurs
          .map((c) => Expanded(child: Container(color: c)))
          .toList(),
    );
  }
}

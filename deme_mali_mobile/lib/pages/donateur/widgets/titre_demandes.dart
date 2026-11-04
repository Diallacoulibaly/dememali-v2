
import 'package:flutter/material.dart';

class TitreDemandes extends StatelessWidget {
  final VoidCallback? onVoirTout;

  const TitreDemandes({
    super.key,
    this.onVoirTout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Des personnes ont besoin de votre aide',
              style: TextStyle(
                color: Color(0xFF1F1F1F),
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          InkWell(
            onTap: onVoirTout,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Text(
                    'Voir tout',
                    style: TextStyle(
                      color: Color(0xFF0F7A4B),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF0F7A4B),
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

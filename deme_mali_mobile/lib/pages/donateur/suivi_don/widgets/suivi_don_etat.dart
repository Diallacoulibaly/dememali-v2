
import 'package:flutter/material.dart';
import 'package:deme_mali_mobile/styles/couleurs.dart';

class SuiviDonEtat extends StatelessWidget {
  final String message;
  final String? detail;
  final VoidCallback onRetry;

  const SuiviDonEtat({
    super.key,
    required this.message,
    this.detail,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: CouleursApp.vert.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            color: CouleursApp.vert,
            size: 34,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: CouleursApp.noir,
            ),
          ),
          if (detail != null && detail!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              detail!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

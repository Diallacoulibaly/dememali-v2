import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/notification_controller.dart';
import '../../../styles/couleurs.dart';
import '../notifications/notifications_page.dart';

/// En-tête avec logo à gauche et cloche de notification dynamique à droite.
class EnteteBeneficiaire extends ConsumerWidget {
  const EnteteBeneficiaire({super.key, this.onNotificationTap});

  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nbNonLues = ref.watch(nombreNotificationsNonLuesProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo Dèmè Mali + Nom
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo_acceuil.png',
              width: 34,
              height: 34,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/logo_Acceuil.png',
                width: 34,
                height: 34,
                fit: BoxFit.contain,
                errorBuilder: (context, error2, stackTrace2) => Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: CouleursApp.vert.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volunteer_activism,
                    color: CouleursApp.vert,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Dèmè Mali',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: CouleursApp.noir,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),

        // Bouton cloche notification avec badge dynamique
        InkWell(
          onTap: onNotificationTap ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: CouleursApp.blanc,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: CouleursApp.noir,
                  size: 24,
                ),
                if (nbNonLues > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Center(
                        child: Text(
                          nbNonLues > 9 ? '9+' : '$nbNonLues',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

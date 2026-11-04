import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/notification_controller.dart';
import '../../../styles/couleurs.dart';
import '../notifications/notifications_donateur_page.dart';

class EnteteDonateur extends ConsumerWidget {
  final String prenom;
  final int? donateurId;
  final VoidCallback? onNotificationTap;

  const EnteteDonateur({
    super.key,
    required this.prenom,
    this.donateurId,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nbNonLues = ref.watch(nombreNotificationsNonLuesProvider);

    return Container(
      width: double.infinity,
      color: CouleursApp.fond,
      padding: const EdgeInsets.fromLTRB(22, 8, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo, nom de l'application et notifications.
          Row(
            children: [
              Image.asset(
                'assets/images/logo_acceuil.png',
                width: 32,
                height: 32,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: CouleursApp.vert,
                      size: 24,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),

              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Dèmè',
                        style: TextStyle(
                          color: CouleursApp.vert,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Mali',
                        style: TextStyle(
                          color: CouleursApp.jaune,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bouton de notification.
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: CouleursApp.blanc,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CouleursApp.noir.withValues(alpha: 0.06),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: onNotificationTap ??
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NotificationsDonateurPage(
                                  donateurId: donateurId ?? 0,
                                ),
                              ),
                            );
                          },
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: CouleursApp.noir,
                        size: 23,
                      ),
                    ),
                    if (nbNonLues > 0)
                      Positioned(
                        right: 4,
                        top: 4,
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
            ],
          ),

          const SizedBox(height: 16),

          // Message de bienvenue.
          Text(
            'Bonjour ${prenom.trim()} ',
            style: const TextStyle(
              color: CouleursApp.noir,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),

          Text(
            'Merci de contribuer à une solidarité plus forte au Mali.',
            style: TextStyle(
              color: CouleursApp.noir.withValues(alpha: 0.65),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

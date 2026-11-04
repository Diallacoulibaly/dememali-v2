import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/notification_controller.dart';
import '../../../styles/couleurs.dart';
import '../notifications/notifications_page.dart';

class EnteteAccueil extends ConsumerWidget {
  const EnteteAccueil({super.key, this.onNotificationTap});
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nbNonLues = ref.watch(nombreNotificationsNonLuesProvider);

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: CouleursApp.blanc,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.volunteer_activism,
            color: CouleursApp.vert,
            size: 27,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Dèmè ',
                  style: TextStyle(
                    color: CouleursApp.vert,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: 'Mali',
                  style: TextStyle(
                    color: CouleursApp.jaune,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        Material(
          color: CouleursApp.blanc,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onNotificationTap ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  );
                },
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: CouleursApp.vert,
                  ),
                  if (nbNonLues > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                        ),
                        child: Center(
                          child: Text(
                            nbNonLues > 9 ? '9+' : '$nbNonLues',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
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
        ),
      ],
    );
  }
}

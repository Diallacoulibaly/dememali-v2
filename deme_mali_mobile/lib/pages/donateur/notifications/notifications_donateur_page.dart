import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/notification_controller.dart';
import '../../../models/notification_item.dart';
import '../../../styles/couleurs.dart';
import '../mes_dons/mes_dons_page.dart';

class NotificationsDonateurPage extends ConsumerStatefulWidget {
  final int donateurId;

  const NotificationsDonateurPage({
    super.key,
    required this.donateurId,
  });

  @override
  ConsumerState<NotificationsDonateurPage> createState() =>
      _NotificationsDonateurPageState();
}

class _NotificationsDonateurPageState
    extends ConsumerState<NotificationsDonateurPage> {
  String filtreActif = 'Toutes';

  static const List<String> filtres = ['Toutes', 'Mes dons', 'Mises à jour'];

  List<NotificationItem> _filtrer(List<NotificationItem> liste) {
    if (filtreActif == 'Mes dons') {
      return liste
          .where((n) =>
              n.type == TypeNotification.donRecu ||
              n.type == TypeNotification.distributionEffectuee)
          .toList();
    }
    if (filtreActif == 'Mises à jour') {
      return liste
          .where((n) =>
              n.type == TypeNotification.demandeValidee ||
              n.type == TypeNotification.objectifAtteint ||
              n.type == TypeNotification.systeme ||
              n.type == TypeNotification.compteValide)
          .toList();
    }
    return liste;
  }

  void _actionNotification(NotificationItem notif) {
    ref.read(notificationsNotifierProvider.notifier).marquerCommeLue(notif.id);

    // Si la notification concerne un don, rediriger vers la page Mes Dons
    if (notif.type == TypeNotification.donRecu ||
        notif.type == TypeNotification.distributionEffectuee) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MesDonsPage(donateurId: widget.donateurId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsNotifierProvider);
    final notificationsFiltrees = _filtrer(state.notifications);

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: SafeArea(
        child: Column(
          children: [
            // 1. En-tête supérieur
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 19,
                        color: CouleursApp.noir,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: CouleursApp.noir,
                      ),
                    ),
                  ),
                  if (state.aDesNonLues)
                    TextButton(
                      onPressed: () {
                        ref
                            .read(notificationsNotifierProvider.notifier)
                            .toutMarquerCommeLu();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: CouleursApp.vert,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      child: const Text(
                        'Tout lire',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // 3. Onglets de filtrage
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: filtres.map((f) {
                  final actif = filtreActif == f;
                  int? compte;
                  if (f == 'Toutes') compte = state.notifications.length;
                  if (f == 'Mes dons') {
                    compte = state.notifications
                        .where((n) =>
                            n.type == TypeNotification.donRecu ||
                            n.type == TypeNotification.distributionEffectuee)
                        .length;
                  }
                  if (f == 'Mises à jour') {
                    compte = state.notifications
                        .where((n) =>
                            n.type == TypeNotification.demandeValidee ||
                            n.type == TypeNotification.objectifAtteint ||
                            n.type == TypeNotification.systeme ||
                            n.type == TypeNotification.compteValide)
                        .length;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => filtreActif = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: actif ? CouleursApp.vert : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: actif
                                ? CouleursApp.vert
                                : const Color(0xFFE5DECF),
                          ),
                          boxShadow: actif
                              ? [
                                  BoxShadow(
                                    color:
                                        CouleursApp.vert.withValues(alpha: 0.22),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          compte != null && compte > 0
                              ? '$f ($compte)'
                              : f,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight:
                                actif ? FontWeight.w700 : FontWeight.w600,
                            color: actif ? Colors.white : const Color(0xFF555555),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            // 4. Liste des notifications
            Expanded(
              child: RefreshIndicator(
                color: CouleursApp.vert,
                onRefresh: () async {
                  await ref
                      .read(notificationsNotifierProvider.notifier)
                      .charger();
                },
                child: state.chargement && state.notifications.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: CouleursApp.vert,
                        ),
                      )
                    : notificationsFiltrees.isEmpty
                        ? _vueVide()
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: notificationsFiltrees.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final notif = notificationsFiltrees[index];
                              return _carteNotification(
                                notif: notif,
                                onTap: () => _actionNotification(notif),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vueVide() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: CouleursApp.vert.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 38,
                color: CouleursApp.vert,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune notification pour le moment',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: CouleursApp.noir,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Vous recevrez ici les confirmations de vos dons, le suivi de distribution et les alertes en direct.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: CouleursApp.noir.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _carteNotification({
    required NotificationItem notif,
    required VoidCallback onTap,
  }) {
    final estLue = notif.lu;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: estLue ? Colors.white : const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: estLue
                  ? const Color(0xFFEAE5D9)
                  : CouleursApp.vert.withValues(alpha: 0.35),
              width: estLue ? 1 : 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icône avec fond
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: notif.couleur.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notif.icone,
                  color: notif.couleur,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Contenu textuel
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notif.titre,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  estLue ? FontWeight.w700 : FontWeight.w800,
                              color: CouleursApp.noir,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          notif.dateFormatee,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.message,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: CouleursApp.noir.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),

              // Indicateur non lu
              if (!estLue) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(
                    color: CouleursApp.vert,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


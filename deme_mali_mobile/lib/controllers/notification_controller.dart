import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_item.dart';
import '../repositories/notification_repository.dart';
import '../repositories/http_client_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) {
    final repo = NotificationRepository(client: ref.watch(httpClientProvider));
    ref.onDispose(() => repo.fermerStream());
    return repo;
  },
);

class NotificationState {
  final List<NotificationItem> notifications;
  final bool chargement;
  final String? erreur;

  const NotificationState({
    this.notifications = const [],
    this.chargement = false,
    this.erreur,
  });

  int get nombreNonLues => notifications.where((n) => !n.lu).length;
  bool get aDesNonLues => nombreNonLues > 0;

  NotificationState copyWith({
    List<NotificationItem>? notifications,
    bool? chargement,
    String? erreur,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      chargement: chargement ?? this.chargement,
      erreur: erreur,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  StreamSubscription<NotificationItem>? _sseSubscription;

  @override
  NotificationState build() {
    ref.onDispose(() {
      _sseSubscription?.cancel();
    });

    // Chargement asynchrone dès l'initialisation
    Future.microtask(() => charger());

    return const NotificationState(chargement: true);
  }

  NotificationRepository get repository => ref.read(notificationRepositoryProvider);

  Future<void> charger() async {
    state = state.copyWith(chargement: true, erreur: null);

    try {
      final telephone = await repository.stockage.read(key: 'userTelephone') ?? '';
      final userIdStr = await repository.stockage.read(key: 'userId');
      final role = (await repository.stockage.read(key: 'userRole') ?? '').toUpperCase();
      final userId = userIdStr != null ? int.tryParse(userIdStr) : null;

      final estDonateur = role == 'DONATEUR';

      final liste = await repository.chargerToutesNotifications(
        telephone: telephone,
        beneficiaireId: estDonateur ? null : userId,
        donateurId: estDonateur ? userId : null,
      );

      state = state.copyWith(notifications: liste, chargement: false);

      _connecterSse(telephone);
    } catch (e) {
      state = state.copyWith(
        chargement: false,
        erreur: 'Impossible de charger les notifications.',
      );
    }
  }

  void _connecterSse(String telephone) {
    if (telephone.isEmpty || _sseSubscription != null) return;

    _sseSubscription = repository.ecouterStream(telephone).listen((nouvelle) {
      if (!state.notifications.any((n) => n.id == nouvelle.id)) {
        state = state.copyWith(
          notifications: [nouvelle, ...state.notifications],
        );
      }
    });
  }

  Future<void> marquerCommeLue(String id) async {
    await repository.marquerCommeLue(id);
    final maj = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(lu: true);
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: maj);
  }

  Future<void> toutMarquerCommeLu() async {
    await repository.toutMarquerCommeLu(state.notifications);
    final maj = state.notifications.map((n) => n.copyWith(lu: true)).toList();
    state = state.copyWith(notifications: maj);
  }
}

final notificationsNotifierProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
  NotificationNotifier.new,
);

final nombreNotificationsNonLuesProvider = Provider<int>((ref) {
  return ref.watch(notificationsNotifierProvider).nombreNonLues;
});

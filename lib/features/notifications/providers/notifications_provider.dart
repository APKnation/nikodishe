import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/notification_model.dart';
import '../../../data/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

class NotificationsNotifier extends Notifier<List<AppNotificationModel>> {
  final ApiService _apiService = ApiService();

  @override
  List<AppNotificationModel> build() {
    ref.listen(currentUserProvider, (_, __) {
      Future.microtask(() => loadFromApi());
    });
    Future.microtask(() => loadFromApi());
    return const [];
  }

  Future<void> loadFromApi() async {
    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        state = const [];
        return;
      }
      final remote = await _apiService.fetchNotifications();
      state = remote;
    } catch (_) {
      // Backend offline or unauthenticated — keep current state
    }
  }

  void addNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? userId,
    String? relatedId,
  }) {
    final currentUserId = userId ?? ref.read(currentUserProvider)?.id ?? '';
    final notif = AppNotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      userId: currentUserId,
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
      isRead: false,
      relatedId: relatedId,
    );
    state = [notif, ...state];
  }

  Future<void> markAsRead(String id) async {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
    try {
      await _apiService.markNotificationAsRead(id);
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    state = [for (final n in state) n.copyWith(isRead: true)];
    try {
      await _apiService.markAllNotificationsAsRead();
    } catch (_) {}
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotificationModel>>(
      () => NotificationsNotifier(),
    );

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationsProvider);
  return notifs.where((n) => !n.isRead).length;
});

final userNotificationsProvider = Provider<List<AppNotificationModel>>((ref) {
  return ref.watch(notificationsProvider);
});

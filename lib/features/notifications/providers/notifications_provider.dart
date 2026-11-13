import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/mock/mock_data.dart';
import '../../../data/services/api_service.dart';
import '../../auth/providers/auth_provider.dart';

class NotificationsNotifier extends Notifier<List<AppNotificationModel>> {
  final ApiService _apiService = ApiService();

  @override
  List<AppNotificationModel> build() {
    final initial = List<AppNotificationModel>.from(mockNotifications);
    Future.microtask(() => loadFromApi());
    return initial;
  }

  Future<void> loadFromApi() async {
    try {
      final remote = await _apiService.fetchNotifications();
      if (remote.isNotEmpty) {
        state = remote;
      }
    } catch (_) {
      // Backend offline — retain mock notifications
    }
  }

  void addNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? userId,
    String? relatedId,
  }) {
    final currentUserId = userId ?? ref.read(currentUserProvider)?.id ?? 'user_001';
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

  void markAsRead(String id) {
    state = state.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
  }

  void markAllAsRead() {
    state = state.map((n) => n.copyWith(isRead: true)).toList();
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotificationModel>>(
        () => NotificationsNotifier());

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifs = ref.watch(notificationsProvider);
  return notifs.where((n) => !n.isRead).length;
});

final userNotificationsProvider = Provider<List<AppNotificationModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  final all = ref.watch(notificationsProvider);
  if (user == null) return all;
  return all.where((n) => n.userId == user.id || n.userId.isEmpty).toList();
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/notification_model.dart';
import '../../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newBooking:
        return Icons.calendar_month;
      case NotificationType.bookingConfirmed:
        return Icons.check_circle_outline;
      case NotificationType.bookingRejected:
        return Icons.cancel_outlined;
      case NotificationType.paymentReceived:
        return Icons.account_balance_wallet_outlined;
      case NotificationType.bookingReminder:
        return Icons.alarm;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newBooking:
        return Colors.blue;
      case NotificationType.bookingConfirmed:
        return AppColors.success;
      case NotificationType.bookingRejected:
        return AppColors.error;
      case NotificationType.paymentReceived:
        return AppColors.primary;
      case NotificationType.bookingReminder:
        return AppColors.warning;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) {
      return 'dakika ${diff.inMinutes} zilizopita';
    } else if (diff.inHours < 24) {
      return 'saa ${diff.inHours} yaliyopita';
    } else {
      return 'siku ${diff.inDays} zilizopita';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Arifa & Taarifa (Notifications)'),
        centerTitle: true,
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
              },
              child: const Text('Zote zimesomwa', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Huna arifa mpya kwa sasa',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final color = _getNotificationColor(notif.type);
                final icon = _getNotificationIcon(notif.type);

                return Dismissible(
                  key: Key(notif.id),
                  onDismissed: (_) {
                    ref.read(notificationsProvider.notifier).markAsRead(notif.id);
                  },
                  child: InkWell(
                    onTap: () {
                      ref.read(notificationsProvider.notifier).markAsRead(notif.id);
                      if (notif.type == NotificationType.newBooking ||
                          notif.type == NotificationType.bookingConfirmed ||
                          notif.type == NotificationType.bookingReminder) {
                        context.go('/home');
                      } else if (notif.type == NotificationType.paymentReceived) {
                        context.push('/payments/history');
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notif.isRead ? Colors.white : AppColors.primaryLight.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: notif.isRead ? AppColors.border : AppColors.primary.withOpacity(0.4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: color.withOpacity(0.12),
                            child: Icon(icon, color: color, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif.title,
                                        style: TextStyle(
                                          fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (!notif.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notif.body,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatTimeAgo(notif.createdAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}


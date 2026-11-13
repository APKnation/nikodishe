enum NotificationType {
  newBooking,       // == bookingNew  - Ombi jipya la booking
  bookingConfirmed, // Booking imethibitishwa
  bookingRejected,  // Booking imekataliwa
  paymentReceived,  // Malipo yamepokelewa
  bookingReminder,  // Kikumbusho cha booking (== reminder)
  system,           // Taarifa ya mfumo
}

// Convenience aliases used by api_service mapping
extension NotificationTypeExt on NotificationType {
  static NotificationType fromApiString(String s) {
    final upper = s.toUpperCase();
    if (upper.contains('BOOKING_NEW') || upper.contains('NEW')) {
      return NotificationType.newBooking;
    } else if (upper.contains('CONFIRMED')) {
      return NotificationType.bookingConfirmed;
    } else if (upper.contains('PAYMENT')) {
      return NotificationType.paymentReceived;
    } else if (upper.contains('REMINDER')) {
      return NotificationType.bookingReminder;
    }
    return NotificationType.system;
  }
}

class AppNotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? relatedId;

  const AppNotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.relatedId,
  });

  AppNotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    String? relatedId,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
    );
  }

  String get icon {
    switch (type) {
      case NotificationType.newBooking:
        return '📋';
      case NotificationType.bookingConfirmed:
        return '✅';
      case NotificationType.bookingRejected:
        return '❌';
      case NotificationType.paymentReceived:
        return '💰';
      case NotificationType.bookingReminder:
        return '⏰';
      case NotificationType.system:
        return '🔔';
    }
  }
}

// Keep old name as NotificationModel alias for api_service
typedef NotificationModel = AppNotificationModel;

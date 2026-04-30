enum NotificationType {
  rentalDue,
  rentalOverdue,
  system;

  static NotificationType fromValue(String value) {
    return switch (value) {
      'RENTAL_DUE' => NotificationType.rentalDue,
      'RENTAL_OVERDUE' => NotificationType.rentalOverdue,
      'SYSTEM' => NotificationType.system,
      _ => NotificationType.system,
    };
  }

  String get value => switch (this) {
        rentalDue => 'RENTAL_DUE',
        rentalOverdue => 'RENTAL_OVERDUE',
        system => 'SYSTEM',
      };
}

class NotificationItem {
  final int notificationId;
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final String channel;
  final int? referenceId;
  final DateTime sentAt;
  final DateTime? readAt;

  const NotificationItem({
    required this.notificationId,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.channel,
    this.referenceId,
    required this.sentAt,
    this.readAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      notificationId: json['notificationId'] as int,
      type: NotificationType.fromValue(json['type'] as String),
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool,
      channel: json['channel'] as String,
      referenceId: json['referenceId'] as int?,
      sentAt: DateTime.parse(json['sentAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
    );
  }

  NotificationItem copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationItem(
      notificationId: notificationId,
      type: type,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      channel: channel,
      referenceId: referenceId,
      sentAt: sentAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

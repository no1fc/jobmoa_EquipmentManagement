import '../../../shared/models/api_response.dart';
import '../data/models/notification_item.dart';

abstract interface class NotificationRepository {
  Future<PageResponse<NotificationItem>> getNotifications({
    bool? isRead,
    int page,
    int size,
  });

  Future<int> getUnreadCount();

  Future<void> markAsRead(int notificationId);

  Future<void> markAllAsRead();
}

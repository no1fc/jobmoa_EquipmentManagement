import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../data/notification_repository_impl.dart';
import '../domain/notification_repository.dart';
import 'notification_list_notifier.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final notificationListNotifierProvider =
    AsyncNotifierProvider<NotificationListNotifier, NotificationListState>(
  NotificationListNotifier.new,
);

final unreadCountProvider = FutureProvider<int>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return repo.getUnreadCount();
});

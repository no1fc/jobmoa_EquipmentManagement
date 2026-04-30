import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/notification_item.dart';
import '../domain/notification_repository.dart';
import 'notification_providers.dart';

class NotificationListState {
  final List<NotificationItem> notifications;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool? readFilter; // null=전체, true=읽음, false=읽지않음

  const NotificationListState({
    this.notifications = const [],
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.readFilter,
  });

  NotificationListState copyWith({
    List<NotificationItem>? notifications,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? Function()? readFilter,
  }) {
    return NotificationListState(
      notifications: notifications ?? this.notifications,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      readFilter: readFilter != null ? readFilter() : this.readFilter,
    );
  }
}

class NotificationListNotifier extends AsyncNotifier<NotificationListState> {
  late final NotificationRepository _repository;

  static const int _pageSize = 20;

  @override
  Future<NotificationListState> build() async {
    _repository = ref.watch(notificationRepositoryProvider);
    return _fetchPage(0);
  }

  Future<NotificationListState> _fetchPage(int page,
      {NotificationListState? current}) async {
    final pageResponse = await _repository.getNotifications(
      isRead: (current ?? state.valueOrNull)?.readFilter,
      page: page,
      size: _pageSize,
    );

    final existing = page > 0
        ? (current ?? state.valueOrNull)?.notifications ?? []
        : <NotificationItem>[];

    return NotificationListState(
      notifications: [...existing, ...pageResponse.content],
      currentPage: page,
      hasMore: !pageResponse.last,
      isLoadingMore: false,
      readFilter: (current ?? state.valueOrNull)?.readFilter,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.valueOrNull;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(isLoadingMore: true),
    );

    try {
      final newState = await _fetchPage(
        currentState.currentPage + 1,
        current: currentState,
      );
      state = AsyncValue.data(newState);
    } catch (e, st) {
      state = AsyncValue.data(
        currentState.copyWith(isLoadingMore: false),
      );
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(0));
    ref.invalidate(unreadCountProvider);
  }

  Future<void> setReadFilter(bool? isRead) async {
    final newState = NotificationListState(readFilter: isRead);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(0, current: newState));
  }

  Future<void> markAsRead(int notificationId) async {
    await _repository.markAsRead(notificationId);

    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(
        currentState.copyWith(
          notifications: currentState.notifications
              .map((n) => n.notificationId == notificationId
                  ? n.copyWith(isRead: true, readAt: DateTime.now())
                  : n)
              .toList(),
        ),
      );
    }
    ref.invalidate(unreadCountProvider);
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();

    final currentState = state.valueOrNull;
    if (currentState != null) {
      state = AsyncValue.data(
        currentState.copyWith(
          notifications: currentState.notifications
              .map((n) => n.isRead
                  ? n
                  : n.copyWith(isRead: true, readAt: DateTime.now()))
              .toList(),
        ),
      );
    }
    ref.invalidate(unreadCountProvider);
  }
}

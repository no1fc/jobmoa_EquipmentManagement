import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../data/models/notification_item.dart';
import 'notification_providers.dart';
import 'widgets/notification_card.dart';

class NotificationListScreen extends ConsumerStatefulWidget {
  const NotificationListScreen({super.key});

  @override
  ConsumerState<NotificationListScreen> createState() =>
      _NotificationListScreenState();
}

class _NotificationListScreenState
    extends ConsumerState<NotificationListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationListNotifierProvider.notifier).loadMore();
    }
  }

  void _onNotificationTap(NotificationItem notification) {
    if (!notification.isRead) {
      ref
          .read(notificationListNotifierProvider.notifier)
          .markAsRead(notification.notificationId);
    }

    if (notification.referenceId != null) {
      if (notification.type == NotificationType.rentalDue ||
          notification.type == NotificationType.rentalOverdue) {
        context.pushNamed(
          'rental-detail',
          pathParameters: {'id': notification.referenceId.toString()},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(notificationListNotifierProvider);
    final unreadAsync = ref.watch(unreadCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        actions: [
          unreadAsync.whenOrNull(
                data: (count) => count > 0
                    ? TextButton(
                        onPressed: () => ref
                            .read(notificationListNotifierProvider.notifier)
                            .markAllAsRead(),
                        child: const Text('모두 읽음'),
                      )
                    : null,
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: Column(
        children: [
          // 필터 칩
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: '전체',
                  selected: listAsync.valueOrNull?.readFilter == null,
                  onTap: () => ref
                      .read(notificationListNotifierProvider.notifier)
                      .setReadFilter(null),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '읽지 않음',
                  selected: listAsync.valueOrNull?.readFilter == false,
                  onTap: () => ref
                      .read(notificationListNotifierProvider.notifier)
                      .setReadFilter(false),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: '읽음',
                  selected: listAsync.valueOrNull?.readFilter == true,
                  onTap: () => ref
                      .read(notificationListNotifierProvider.notifier)
                      .setReadFilter(true),
                ),
              ],
            ),
          ),

          // 알림 목록
          Expanded(
            child: listAsync.when(
              data: (state) {
                if (state.notifications.isEmpty) {
                  return const EmptyState(
                    icon: Icons.notifications_off_outlined,
                    title: '알림이 없습니다',
                    description: '새로운 알림이 오면 여기에 표시됩니다',
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref
                      .read(notificationListNotifierProvider.notifier)
                      .refresh(),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: state.notifications.length +
                        (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.notifications.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }
                      final notification = state.notifications[index];
                      return NotificationCard(
                        notification: notification,
                        onTap: () => _onNotificationTap(notification),
                      );
                    },
                  ),
                );
              },
              loading: () => const LoadingIndicator(message: '알림을 불러오는 중...'),
              error: (error, _) => ErrorView(
                message: '알림을 불러올 수 없습니다',
                onRetry: () => ref
                    .read(notificationListNotifierProvider.notifier)
                    .refresh(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

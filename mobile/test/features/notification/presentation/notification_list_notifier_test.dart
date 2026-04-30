import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:equipment_management/features/notification/data/models/notification_item.dart';
import 'package:equipment_management/features/notification/domain/notification_repository.dart';
import 'package:equipment_management/features/notification/presentation/notification_providers.dart';
import 'package:equipment_management/shared/models/api_response.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

void main() {
  late MockNotificationRepository mockRepo;
  late ProviderContainer container;

  final sampleNotifications = [
    NotificationItem(
      notificationId: 1,
      type: NotificationType.rentalDue,
      title: '반납 예정 알림',
      message: '반납 기한이 3일 남았습니다.',
      isRead: false,
      channel: 'IN_APP',
      referenceId: 10,
      sentAt: DateTime(2026, 4, 30),
    ),
    NotificationItem(
      notificationId: 2,
      type: NotificationType.rentalOverdue,
      title: '연체 알림',
      message: '반납 기한이 지났습니다.',
      isRead: true,
      channel: 'IN_APP',
      referenceId: 11,
      sentAt: DateTime(2026, 4, 29),
    ),
  ];

  setUp(() {
    mockRepo = MockNotificationRepository();
    container = ProviderContainer(
      overrides: [
        notificationRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('NotificationListNotifier', () {
    test('build fetches first page', () async {
      when(() => mockRepo.getNotifications(
            isRead: any(named: 'isRead'),
            page: 0,
            size: 20,
          )).thenAnswer((_) async => PageResponse(
            content: sampleNotifications,
            page: 0,
            size: 20,
            totalElements: 2,
            totalPages: 1,
            last: true,
          ));

      final notifier =
          container.read(notificationListNotifierProvider.notifier);
      await container.read(notificationListNotifierProvider.future);

      final state = container.read(notificationListNotifierProvider).value!;
      expect(state.notifications.length, 2);
      expect(state.hasMore, false);
      expect(state.currentPage, 0);
      expect(notifier, isNotNull);
    });

    test('setReadFilter refetches with filter', () async {
      when(() => mockRepo.getNotifications(
            isRead: any(named: 'isRead'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          )).thenAnswer((_) async => PageResponse(
            content: sampleNotifications,
            page: 0,
            size: 20,
            totalElements: 2,
            totalPages: 1,
            last: true,
          ));

      await container.read(notificationListNotifierProvider.future);

      when(() => mockRepo.getNotifications(
            isRead: false,
            page: 0,
            size: 20,
          )).thenAnswer((_) async => PageResponse(
            content: [sampleNotifications[0]],
            page: 0,
            size: 20,
            totalElements: 1,
            totalPages: 1,
            last: true,
          ));

      await container
          .read(notificationListNotifierProvider.notifier)
          .setReadFilter(false);

      final state = container.read(notificationListNotifierProvider).value!;
      expect(state.readFilter, false);
      expect(state.notifications.length, 1);
    });

    test('markAsRead updates notification locally', () async {
      when(() => mockRepo.getNotifications(
            isRead: any(named: 'isRead'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          )).thenAnswer((_) async => PageResponse(
            content: sampleNotifications,
            page: 0,
            size: 20,
            totalElements: 2,
            totalPages: 1,
            last: true,
          ));
      when(() => mockRepo.markAsRead(1)).thenAnswer((_) async {});
      when(() => mockRepo.getUnreadCount()).thenAnswer((_) async => 0);

      await container.read(notificationListNotifierProvider.future);

      await container
          .read(notificationListNotifierProvider.notifier)
          .markAsRead(1);

      final state = container.read(notificationListNotifierProvider).value!;
      final updated =
          state.notifications.firstWhere((n) => n.notificationId == 1);
      expect(updated.isRead, true);
      expect(updated.readAt, isNotNull);
    });

    test('markAllAsRead updates all notifications locally', () async {
      when(() => mockRepo.getNotifications(
            isRead: any(named: 'isRead'),
            page: any(named: 'page'),
            size: any(named: 'size'),
          )).thenAnswer((_) async => PageResponse(
            content: sampleNotifications,
            page: 0,
            size: 20,
            totalElements: 2,
            totalPages: 1,
            last: true,
          ));
      when(() => mockRepo.markAllAsRead()).thenAnswer((_) async {});
      when(() => mockRepo.getUnreadCount()).thenAnswer((_) async => 0);

      await container.read(notificationListNotifierProvider.future);

      await container
          .read(notificationListNotifierProvider.notifier)
          .markAllAsRead();

      final state = container.read(notificationListNotifierProvider).value!;
      expect(state.notifications.every((n) => n.isRead), true);
    });

    test('loadMore appends next page', () async {
      when(() => mockRepo.getNotifications(
            isRead: any(named: 'isRead'),
            page: 0,
            size: 20,
          )).thenAnswer((_) async => PageResponse(
            content: sampleNotifications,
            page: 0,
            size: 20,
            totalElements: 4,
            totalPages: 2,
            last: false,
          ));

      await container.read(notificationListNotifierProvider.future);

      final moreNotifications = [
        NotificationItem(
          notificationId: 3,
          type: NotificationType.system,
          title: '시스템 알림',
          message: '시스템 점검 예정',
          isRead: false,
          channel: 'IN_APP',
          sentAt: DateTime(2026, 4, 28),
        ),
      ];

      when(() => mockRepo.getNotifications(
            isRead: any(named: 'isRead'),
            page: 1,
            size: 20,
          )).thenAnswer((_) async => PageResponse(
            content: moreNotifications,
            page: 1,
            size: 20,
            totalElements: 4,
            totalPages: 2,
            last: true,
          ));

      await container
          .read(notificationListNotifierProvider.notifier)
          .loadMore();

      final state = container.read(notificationListNotifierProvider).value!;
      expect(state.notifications.length, 3);
      expect(state.hasMore, false);
      expect(state.currentPage, 1);
    });
  });
}

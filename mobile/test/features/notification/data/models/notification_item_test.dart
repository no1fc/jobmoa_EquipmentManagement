import 'package:flutter_test/flutter_test.dart';
import 'package:equipment_management/features/notification/data/models/notification_item.dart';

void main() {
  group('NotificationType', () {
    test('fromValue returns correct type for RENTAL_DUE', () {
      expect(
        NotificationType.fromValue('RENTAL_DUE'),
        NotificationType.rentalDue,
      );
    });

    test('fromValue returns correct type for RENTAL_OVERDUE', () {
      expect(
        NotificationType.fromValue('RENTAL_OVERDUE'),
        NotificationType.rentalOverdue,
      );
    });

    test('fromValue returns correct type for SYSTEM', () {
      expect(
        NotificationType.fromValue('SYSTEM'),
        NotificationType.system,
      );
    });

    test('fromValue returns system for unknown value', () {
      expect(
        NotificationType.fromValue('UNKNOWN'),
        NotificationType.system,
      );
    });

    test('value returns correct string', () {
      expect(NotificationType.rentalDue.value, 'RENTAL_DUE');
      expect(NotificationType.rentalOverdue.value, 'RENTAL_OVERDUE');
      expect(NotificationType.system.value, 'SYSTEM');
    });
  });

  group('NotificationItem', () {
    final sampleJson = {
      'notificationId': 1,
      'type': 'RENTAL_DUE',
      'title': '반납 예정 알림',
      'message': '노트북의 반납 기한이 3일 남았습니다.',
      'isRead': false,
      'channel': 'IN_APP',
      'referenceId': 42,
      'sentAt': '2026-04-30T08:00:00',
      'readAt': null,
    };

    test('fromJson creates correct instance', () {
      final item = NotificationItem.fromJson(sampleJson);

      expect(item.notificationId, 1);
      expect(item.type, NotificationType.rentalDue);
      expect(item.title, '반납 예정 알림');
      expect(item.message, '노트북의 반납 기한이 3일 남았습니다.');
      expect(item.isRead, false);
      expect(item.channel, 'IN_APP');
      expect(item.referenceId, 42);
      expect(item.sentAt, DateTime(2026, 4, 30, 8, 0, 0));
      expect(item.readAt, isNull);
    });

    test('fromJson handles null referenceId', () {
      final json = {...sampleJson, 'referenceId': null};
      final item = NotificationItem.fromJson(json);

      expect(item.referenceId, isNull);
    });

    test('fromJson parses readAt when present', () {
      final json = {
        ...sampleJson,
        'isRead': true,
        'readAt': '2026-04-30T09:00:00',
      };
      final item = NotificationItem.fromJson(json);

      expect(item.isRead, true);
      expect(item.readAt, DateTime(2026, 4, 30, 9, 0, 0));
    });

    test('fromJson handles RENTAL_OVERDUE type', () {
      final json = {...sampleJson, 'type': 'RENTAL_OVERDUE'};
      final item = NotificationItem.fromJson(json);

      expect(item.type, NotificationType.rentalOverdue);
    });

    test('fromJson handles SYSTEM type', () {
      final json = {...sampleJson, 'type': 'SYSTEM'};
      final item = NotificationItem.fromJson(json);

      expect(item.type, NotificationType.system);
    });

    test('copyWith updates isRead', () {
      final item = NotificationItem.fromJson(sampleJson);
      final updated = item.copyWith(isRead: true, readAt: DateTime.now());

      expect(updated.isRead, true);
      expect(updated.readAt, isNotNull);
      expect(updated.title, item.title);
      expect(updated.notificationId, item.notificationId);
    });

    test('copyWith preserves original values when not specified', () {
      final item = NotificationItem.fromJson(sampleJson);
      final updated = item.copyWith();

      expect(updated.notificationId, item.notificationId);
      expect(updated.type, item.type);
      expect(updated.title, item.title);
      expect(updated.isRead, item.isRead);
    });
  });
}

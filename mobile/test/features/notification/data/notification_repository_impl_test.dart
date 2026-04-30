import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:equipment_management/core/network/api_client.dart';
import 'package:equipment_management/features/notification/data/notification_repository_impl.dart';
import 'package:equipment_management/features/notification/data/models/notification_item.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late MockApiClient mockApiClient;
  late MockDio mockDio;
  late NotificationRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    repository = NotificationRepositoryImpl(apiClient: mockApiClient);
  });

  group('getNotifications', () {
    test('returns PageResponse on success', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'success': true,
              'data': {
                'content': [
                  {
                    'notificationId': 1,
                    'type': 'RENTAL_DUE',
                    'title': '반납 예정',
                    'message': '반납 기한이 다가옵니다.',
                    'isRead': false,
                    'channel': 'IN_APP',
                    'referenceId': 10,
                    'sentAt': '2026-04-30T08:00:00',
                    'readAt': null,
                  }
                ],
                'page': 0,
                'size': 20,
                'totalElements': 1,
                'totalPages': 1,
                'last': true,
              },
              'message': null,
              'timestamp': '2026-04-30T08:00:00',
            },
          ));

      final result = await repository.getNotifications();

      expect(result.content.length, 1);
      expect(result.content.first.title, '반납 예정');
      expect(result.content.first.type, NotificationType.rentalDue);
      expect(result.last, true);
    });

    test('passes isRead filter parameter', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {
              'success': true,
              'data': {
                'content': [],
                'page': 0,
                'size': 20,
                'totalElements': 0,
                'totalPages': 0,
                'last': true,
              },
            },
          ));

      await repository.getNotifications(isRead: false);

      verify(() => mockDio.get(
            any(),
            queryParameters: {'page': 0, 'size': 20, 'isRead': false},
          )).called(1);
    });

    test('throws ApiException on DioException', () async {
      when(() => mockDio.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionError,
          ));

      expect(
        () => repository.getNotifications(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getUnreadCount', () {
    test('returns count on success', () async {
      when(() => mockDio.get(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'success': true, 'data': 5},
          ));

      final count = await repository.getUnreadCount();

      expect(count, 5);
    });
  });

  group('markAsRead', () {
    test('calls PUT with correct endpoint', () async {
      when(() => mockDio.put(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'success': true},
          ));

      await repository.markAsRead(1);

      verify(() => mockDio.put('/api/v1/notifications/1/read')).called(1);
    });
  });

  group('markAllAsRead', () {
    test('calls PUT with correct endpoint', () async {
      when(() => mockDio.put(any())).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {'success': true},
          ));

      await repository.markAllAsRead();

      verify(() => mockDio.put('/api/v1/notifications/read-all')).called(1);
    });
  });
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:equipment_management/core/network/api_client.dart';
import 'package:equipment_management/core/network/api_exception.dart';
import 'package:equipment_management/features/rental/data/rental_repository_impl.dart';
import 'package:equipment_management/features/rental/data/models/rental.dart';
import 'package:equipment_management/features/rental/data/models/rental_create_request.dart';
import 'package:equipment_management/features/rental/data/models/rental_dashboard.dart';
import 'package:equipment_management/features/rental/data/models/rental_extend_request.dart';
import 'package:equipment_management/features/rental/data/models/rental_return_request.dart';
import 'package:equipment_management/features/rental/data/models/rental_status.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late RentalRepositoryImpl repository;
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  final testRentalJson = {
    'rentalId': 1,
    'assetId': 10,
    'assetName': '노트북',
    'assetCode': 'AST-202601-0001',
    'borrowerId': 2,
    'borrowerEmail': 'user@jobmoa.kr',
    'borrowerName': '홍길동',
    'rentalReason': '업무용',
    'rentalDate': '2026-04-20T10:00:00',
    'dueDate': '2026-04-30T10:00:00',
    'status': 'RENTED',
    'extensionCount': 0,
  };

  final testPageResponse = {
    'success': true,
    'data': {
      'content': [testRentalJson],
      'page': 0,
      'size': 20,
      'totalElements': 1,
      'totalPages': 1,
      'last': true,
    },
  };

  setUp(() {
    mockApiClient = MockApiClient();
    mockDio = MockDio();
    when(() => mockApiClient.dio).thenReturn(mockDio);
    repository = RentalRepositoryImpl(apiClient: mockApiClient);
  });

  group('RentalRepositoryImpl', () {
    group('getRentals', () {
      test('returns PageResponse<Rental> on success', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: testPageResponse,
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

        final result = await repository.getRentals();

        expect(result.content, hasLength(1));
        expect(result.content[0], isA<Rental>());
        expect(result.content[0].assetName, '노트북');
        expect(result.totalElements, 1);
      });

      test('passes filter parameters correctly', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: testPageResponse,
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

        await repository.getRentals(
          status: 'RENTED',
          search: '노트북',
          page: 1,
          size: 10,
        );

        final captured = verify(() => mockDio.get(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            )).captured.single as Map<String, dynamic>;

        expect(captured['status'], 'RENTED');
        expect(captured['search'], '노트북');
        expect(captured['page'], 1);
        expect(captured['size'], 10);
      });

      test('throws ApiException on DioException', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(),
        ));

        expect(
          () => repository.getRentals(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getRental', () {
      test('returns Rental on success', () async {
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {'success': true, 'data': testRentalJson},
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

        final result = await repository.getRental(1);

        expect(result, isA<Rental>());
        expect(result.assetName, '노트북');
        expect(result.status, RentalStatus.rented);
      });
    });

    group('createRental', () {
      test('sends POST and returns Rental', () async {
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  data: {'success': true, 'data': testRentalJson},
                  statusCode: 201,
                  requestOptions: RequestOptions(),
                ));

        const request = RentalCreateRequest(
          assetId: 10,
          dueDays: 7,
        );

        final result = await repository.createRental(request);

        expect(result, isA<Rental>());
        expect(result.assetName, '노트북');
        verify(() => mockDio.post(any(), data: any(named: 'data'))).called(1);
      });
    });

    group('returnRental', () {
      test('sends PUT and returns updated Rental', () async {
        final returnedJson = {
          ...testRentalJson,
          'status': 'RETURNED',
          'returnDate': '2026-04-28T15:00:00',
        };
        when(() => mockDio.put(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  data: {'success': true, 'data': returnedJson},
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        const request = RentalReturnRequest(returnCondition: '양호');
        final result = await repository.returnRental(1, request);

        expect(result.status, RentalStatus.returned);
        expect(result.returnDate, isNotNull);
      });
    });

    group('extendRental', () {
      test('sends PUT and returns extended Rental', () async {
        final extendedJson = {
          ...testRentalJson,
          'dueDate': '2026-05-07T10:00:00',
          'extensionCount': 1,
        };
        when(() => mockDio.put(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  data: {'success': true, 'data': extendedJson},
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        const request = RentalExtendRequest(extensionDays: 7);
        final result = await repository.extendRental(1, request);

        expect(result.extensionCount, 1);
      });
    });

    group('cancelRental', () {
      test('sends PUT and returns cancelled Rental', () async {
        final cancelledJson = {...testRentalJson, 'status': 'CANCELLED'};
        when(() => mockDio.put(any())).thenAnswer((_) async => Response(
              data: {'success': true, 'data': cancelledJson},
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

        final result = await repository.cancelRental(1);

        expect(result.status, RentalStatus.cancelled);
      });
    });

    group('getDashboard', () {
      test('returns RentalDashboard on success', () async {
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {
                'success': true,
                'data': {
                  'totalActive': 15,
                  'overdueCount': 3,
                  'dueSoon': 5,
                  'returnedToday': 2,
                },
              },
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

        final result = await repository.getDashboard();

        expect(result, isA<RentalDashboard>());
        expect(result.totalActive, 15);
        expect(result.overdueCount, 3);
      });
    });

    group('getOverdueRentals', () {
      test('returns List<Rental> on success', () async {
        final overdueJson = {...testRentalJson, 'status': 'OVERDUE'};
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {
                'success': true,
                'data': [overdueJson],
              },
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

        final result = await repository.getOverdueRentals();

        expect(result, hasLength(1));
        expect(result[0].status, RentalStatus.overdue);
      });
    });

    group('getRentalHistory', () {
      test('returns List<Rental> for asset', () async {
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {
                'success': true,
                'data': [testRentalJson],
              },
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

        final result = await repository.getRentalHistory(10);

        expect(result, hasLength(1));
        expect(result[0].assetId, 10);
      });
    });
  });
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:equipment_management/core/network/api_client.dart';
import 'package:equipment_management/core/network/api_exception.dart';
import 'package:equipment_management/features/asset/data/asset_repository_impl.dart';
import 'package:equipment_management/features/asset/data/models/asset.dart';
import 'package:equipment_management/features/asset/data/models/asset_create_request.dart';
import 'package:equipment_management/features/asset/data/models/asset_detail.dart';
import 'package:equipment_management/features/asset/data/models/asset_status.dart';
import 'package:equipment_management/features/asset/data/models/asset_status_request.dart';
import 'package:equipment_management/features/asset/data/models/asset_summary.dart';
import 'package:equipment_management/features/asset/data/models/asset_update_request.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}

void main() {
  late AssetRepositoryImpl repository;
  late MockApiClient mockApiClient;
  late MockDio mockDio;

  final testAssetJson = {
    'assetId': 1,
    'assetCode': 'AST-202601-0001',
    'assetName': '노트북',
    'status': 'IN_USE',
    'categoryName': '노트북',
    'categoryId': 5,
    'location': '본사 1층',
    'aiClassified': false,
    'createdAt': '2026-01-15T10:30:45',
  };

  final testAssetDetailJson = {
    ...testAssetJson,
    'categoryPath': ['IT장비', '컴퓨터', '노트북'],
    'serialNumber': 'SN-12345',
    'conditionRating': 4,
    'registeredByName': '관리자',
    'updatedAt': '2026-01-20T14:00:00',
  };

  final testPageResponse = {
    'success': true,
    'data': {
      'content': [testAssetJson],
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
    repository = AssetRepositoryImpl(apiClient: mockApiClient);
  });

  setUpAll(() {
    registerFallbackValue(FormData());
  });

  group('AssetRepositoryImpl', () {
    group('getAssets', () {
      test('returns PageResponse<Asset> on success', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: testPageResponse,
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

        final result = await repository.getAssets();

        expect(result.content, hasLength(1));
        expect(result.content[0], isA<Asset>());
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

        await repository.getAssets(
          status: 'IN_USE',
          categoryId: 5,
          search: '노트북',
          page: 1,
          size: 10,
        );

        final captured = verify(() => mockDio.get(
              any(),
              queryParameters: captureAny(named: 'queryParameters'),
            )).captured.single as Map<String, dynamic>;

        expect(captured['status'], 'IN_USE');
        expect(captured['categoryId'], 5);
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
          () => repository.getAssets(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getAsset', () {
      test('returns AssetDetail on success', () async {
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {'success': true, 'data': testAssetDetailJson},
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

        final result = await repository.getAsset(1);

        expect(result, isA<AssetDetail>());
        expect(result.assetName, '노트북');
        expect(result.categoryPath, ['IT장비', '컴퓨터', '노트북']);
        expect(result.conditionRating, 4);
      });
    });

    group('createAsset', () {
      test('sends FormData and returns Asset', () async {
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  data: {'success': true, 'data': testAssetJson},
                  statusCode: 201,
                  requestOptions: RequestOptions(),
                ));

        const request = AssetCreateRequest(
          categoryId: 5,
          assetName: '노트북',
        );

        final result = await repository.createAsset(request);

        expect(result, isA<Asset>());
        expect(result.assetName, '노트북');
        verify(() => mockDio.post(any(), data: any(named: 'data'))).called(1);
      });
    });

    group('updateAsset', () {
      test('sends FormData with PUT and returns Asset', () async {
        when(() => mockDio.put(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  data: {'success': true, 'data': testAssetJson},
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        const request = AssetUpdateRequest(
          categoryId: 5,
          assetName: '노트북 (수정)',
        );

        final result = await repository.updateAsset(1, request);

        expect(result, isA<Asset>());
        verify(() => mockDio.put(any(), data: any(named: 'data'))).called(1);
      });
    });

    group('deleteAsset', () {
      test('calls DELETE endpoint', () async {
        when(() => mockDio.delete(any())).thenAnswer((_) async => Response(
              data: {'success': true, 'data': null, 'message': '장비가 삭제되었습니다.'},
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

        await repository.deleteAsset(1);

        verify(() => mockDio.delete(any())).called(1);
      });

      test('throws ApiException when asset is rented', () async {
        when(() => mockDio.delete(any())).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            data: {'message': '대여 중인 장비는 삭제할 수 없습니다.'},
            statusCode: 400,
            requestOptions: RequestOptions(),
          ),
          requestOptions: RequestOptions(),
        ));

        expect(
          () => repository.deleteAsset(1),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('updateAssetStatus', () {
      test('sends PATCH and returns updated Asset', () async {
        final updatedJson = {...testAssetJson, 'status': 'BROKEN'};
        when(() => mockDio.patch(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  data: {'success': true, 'data': updatedJson},
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        const request = AssetStatusRequest(status: 'BROKEN');
        final result = await repository.updateAssetStatus(1, request);

        expect(result.status, AssetStatus.broken);
      });
    });

    group('getAssetSummary', () {
      test('returns AssetSummary on success', () async {
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {
                'success': true,
                'data': {
                  'total': 100,
                  'inUse': 50,
                  'rented': 20,
                  'broken': 5,
                  'inStorage': 20,
                  'disposed': 5,
                },
              },
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

        final result = await repository.getAssetSummary();

        expect(result, isA<AssetSummary>());
        expect(result.total, 100);
        expect(result.inUse, 50);
      });
    });

    group('getCategoryTree', () {
      test('returns List<CategoryTree> on success', () async {
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: {
                'success': true,
                'data': [
                  {
                    'categoryId': 1,
                    'categoryName': 'IT장비',
                    'categoryLevel': 1,
                    'children': [
                      {
                        'categoryId': 2,
                        'categoryName': '컴퓨터',
                        'categoryLevel': 2,
                        'children': [],
                      },
                    ],
                  },
                ],
              },
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

        final result = await repository.getCategoryTree();

        expect(result, hasLength(1));
        expect(result[0].categoryName, 'IT장비');
        expect(result[0].children, hasLength(1));
      });
    });

    group('getCategories', () {
      test('returns List<Category> with level filter', () async {
        when(() => mockDio.get(
              any(),
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              data: {
                'success': true,
                'data': [
                  {
                    'categoryId': 1,
                    'categoryName': 'IT장비',
                    'categoryLevel': 1,
                    'createdAt': '2026-01-01T00:00:00',
                  },
                ],
              },
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

        final result = await repository.getCategories(level: 1);

        expect(result, hasLength(1));
        expect(result[0].categoryName, 'IT장비');
      });
    });
  });
}

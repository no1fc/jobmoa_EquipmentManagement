import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:equipment_management/core/network/api_client.dart';
import 'package:equipment_management/core/network/api_exception.dart';
import 'package:equipment_management/core/storage/token_storage.dart';
import 'package:equipment_management/features/auth/data/auth_repository_impl.dart';
import 'package:equipment_management/shared/models/user.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockTokenStorage extends Mock implements TokenStorage {}

class MockDio extends Mock implements Dio {}

void main() {
  late AuthRepositoryImpl repository;
  late MockApiClient mockApiClient;
  late MockTokenStorage mockTokenStorage;
  late MockDio mockDio;

  final testUserJson = {
    'userId': 1,
    'email': 'test@jobmoa.kr',
    'name': '홍길동',
    'role': 'COUNSELOR',
    'branchName': '서울지점',
    'phone': '010-1234-5678',
    'isActive': true,
  };

  final testLoginResponseData = {
    'success': true,
    'data': {
      'accessToken': 'test-access-token',
      'refreshToken': 'test-refresh-token',
      'user': testUserJson,
    },
  };

  final testProfileResponseData = {
    'success': true,
    'data': testUserJson,
  };

  setUp(() {
    mockApiClient = MockApiClient();
    mockTokenStorage = MockTokenStorage();
    mockDio = MockDio();

    when(() => mockApiClient.dio).thenReturn(mockDio);

    repository = AuthRepositoryImpl(
      apiClient: mockApiClient,
      tokenStorage: mockTokenStorage,
    );
  });

  group('AuthRepositoryImpl', () {
    group('login', () {
      test('saves tokens and returns User on success', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  data: testLoginResponseData,
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));
        when(() => mockTokenStorage.saveTokens(
              accessToken: any(named: 'accessToken'),
              refreshToken: any(named: 'refreshToken'),
            )).thenAnswer((_) async {});

        // Act
        final user = await repository.login(
          email: 'test@jobmoa.kr',
          password: 'password123',
        );

        // Assert
        expect(user, isA<User>());
        expect(user.email, 'test@jobmoa.kr');
        expect(user.name, '홍길동');
        verify(() => mockTokenStorage.saveTokens(
              accessToken: 'test-access-token',
              refreshToken: 'test-refresh-token',
            )).called(1);
      });

      test('throws ApiException on DioException', () async {
        // Arrange
        when(() => mockDio.post(any(), data: any(named: 'data')))
            .thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            data: {'message': '이메일 또는 비밀번호가 올바르지 않습니다.'},
            statusCode: 401,
            requestOptions: RequestOptions(),
          ),
          requestOptions: RequestOptions(),
        ));

        // Act & Assert
        expect(
          () => repository.login(
            email: 'test@jobmoa.kr',
            password: 'wrong',
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('logout', () {
      test('clears tokens even if API call fails', () async {
        // Arrange
        when(() => mockDio.post(any())).thenThrow(DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(),
        ));
        when(() => mockTokenStorage.clearTokens())
            .thenAnswer((_) async {});

        // Act
        await repository.logout();

        // Assert
        verify(() => mockTokenStorage.clearTokens()).called(1);
      });

      test('calls logout API and clears tokens on success', () async {
        // Arrange
        when(() => mockDio.post(any())).thenAnswer((_) async => Response(
              data: {'success': true, 'data': null},
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));
        when(() => mockTokenStorage.clearTokens())
            .thenAnswer((_) async {});

        // Act
        await repository.logout();

        // Assert
        verify(() => mockDio.post(any())).called(1);
        verify(() => mockTokenStorage.clearTokens()).called(1);
      });
    });

    group('getMyProfile', () {
      test('returns User from API response', () async {
        // Arrange
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: testProfileResponseData,
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

        // Act
        final user = await repository.getMyProfile();

        // Assert
        expect(user.email, 'test@jobmoa.kr');
        expect(user.name, '홍길동');
        expect(user.role, UserRole.counselor);
      });
    });

    group('updateProfile', () {
      test('sends correct request and returns updated User', () async {
        // Arrange
        final updatedUserJson = {...testUserJson, 'name': '김철수'};
        when(() => mockDio.put(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  data: {'success': true, 'data': updatedUserJson},
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        // Act
        final user = await repository.updateProfile(
          name: '김철수',
          phone: '010-9876-5432',
        );

        // Assert
        expect(user.name, '김철수');
      });
    });

    group('changePassword', () {
      test('completes successfully on valid request', () async {
        // Arrange
        when(() => mockDio.put(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
                  data: {'success': true, 'data': null},
                  statusCode: 200,
                  requestOptions: RequestOptions(),
                ));

        // Act & Assert
        await expectLater(
          repository.changePassword(
            currentPassword: 'oldPass123',
            newPassword: 'newPass123',
            confirmPassword: 'newPass123',
          ),
          completes,
        );
      });

      test('throws ApiException on wrong current password', () async {
        // Arrange
        when(() => mockDio.put(any(), data: any(named: 'data')))
            .thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            data: {'message': '현재 비밀번호가 올바르지 않습니다.'},
            statusCode: 400,
            requestOptions: RequestOptions(),
          ),
          requestOptions: RequestOptions(),
        ));

        // Act & Assert
        expect(
          () => repository.changePassword(
            currentPassword: 'wrongPass',
            newPassword: 'newPass123',
            confirmPassword: 'newPass123',
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('hasValidSession', () {
      test('returns true when tokens exist and profile fetch succeeds',
          () async {
        // Arrange
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => true);
        when(() => mockDio.get(any())).thenAnswer((_) async => Response(
              data: testProfileResponseData,
              statusCode: 200,
              requestOptions: RequestOptions(),
            ));

        // Act
        final result = await repository.hasValidSession();

        // Assert
        expect(result, true);
      });

      test('returns false when no tokens exist', () async {
        // Arrange
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.hasValidSession();

        // Assert
        expect(result, false);
      });

      test('returns false when tokens exist but profile fetch fails',
          () async {
        // Arrange
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => true);
        when(() => mockDio.get(any())).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(),
          ),
          requestOptions: RequestOptions(),
        ));

        // Act
        final result = await repository.hasValidSession();

        // Assert
        expect(result, false);
      });
    });
  });
}

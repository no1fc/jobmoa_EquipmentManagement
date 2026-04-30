import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:equipment_management/core/config/providers.dart';
import 'package:equipment_management/core/network/api_exception.dart';
import 'package:equipment_management/core/storage/token_storage.dart';
import 'package:equipment_management/features/auth/domain/auth_repository.dart';
import 'package:equipment_management/features/auth/presentation/auth_providers.dart';
import 'package:equipment_management/shared/models/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockAuthRepository mockRepository;
  late MockTokenStorage mockTokenStorage;

  const testUser = User(
    userId: 1,
    email: 'test@jobmoa.kr',
    name: '홍길동',
    role: UserRole.counselor,
    branchName: '서울지점',
    isActive: true,
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    mockTokenStorage = MockTokenStorage();
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepository),
        tokenStorageProvider.overrideWithValue(mockTokenStorage),
      ],
    );
  }

  group('AuthNotifier', () {
    group('build', () {
      test('returns null when no tokens exist', () async {
        // Arrange
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => false);
        final container = createContainer();

        // Act
        final result = await container.read(authNotifierProvider.future);

        // Assert
        expect(result, isNull);
        container.dispose();
      });

      test('returns User when valid tokens exist', () async {
        // Arrange
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => true);
        when(() => mockRepository.getMyProfile())
            .thenAnswer((_) async => testUser);
        final container = createContainer();

        // Act
        final result = await container.read(authNotifierProvider.future);

        // Assert
        expect(result, isNotNull);
        expect(result!.email, 'test@jobmoa.kr');
        container.dispose();
      });

      test('clears tokens and returns null when tokens are invalid', () async {
        // Arrange
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => true);
        when(() => mockRepository.getMyProfile())
            .thenThrow(const ApiException(message: 'Unauthorized'));
        when(() => mockTokenStorage.clearTokens())
            .thenAnswer((_) async {});
        final container = createContainer();

        // Act
        final result = await container.read(authNotifierProvider.future);

        // Assert
        expect(result, isNull);
        verify(() => mockTokenStorage.clearTokens()).called(1);
        container.dispose();
      });
    });

    group('login', () {
      test('sets User state on successful login', () async {
        // Arrange
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => false);
        when(() => mockRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => testUser);
        final container = createContainer();

        // Wait for initial build
        await container.read(authNotifierProvider.future);

        // Act
        await container
            .read(authNotifierProvider.notifier)
            .login(email: 'test@jobmoa.kr', password: 'password123');

        // Assert
        final state = container.read(authNotifierProvider);
        expect(state.valueOrNull, isNotNull);
        expect(state.valueOrNull!.email, 'test@jobmoa.kr');
        container.dispose();
      });

      test('sets error state on failed login', () async {
        // Arrange
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => false);
        when(() => mockRepository.login(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(
          const ApiException(message: '이메일 또는 비밀번호가 올바르지 않습니다.'),
        );
        final container = createContainer();
        await container.read(authNotifierProvider.future);

        // Act
        await container
            .read(authNotifierProvider.notifier)
            .login(email: 'test@jobmoa.kr', password: 'wrong');

        // Assert
        final state = container.read(authNotifierProvider);
        expect(state.hasError, true);
        container.dispose();
      });
    });

    group('logout', () {
      test('sets state to null after logout', () async {
        // Arrange
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => true);
        when(() => mockRepository.getMyProfile())
            .thenAnswer((_) async => testUser);
        when(() => mockRepository.logout()).thenAnswer((_) async {});
        final container = createContainer();
        await container.read(authNotifierProvider.future);

        // Act
        await container.read(authNotifierProvider.notifier).logout();

        // Assert
        final state = container.read(authNotifierProvider);
        expect(state.valueOrNull, isNull);
        container.dispose();
      });
    });

    group('updateProfile', () {
      test('updates User in state', () async {
        // Arrange
        const updatedUser = User(
          userId: 1,
          email: 'test@jobmoa.kr',
          name: '김철수',
          role: UserRole.counselor,
          branchName: '서울지점',
          phone: '010-9876-5432',
          isActive: true,
        );
        when(() => mockTokenStorage.hasTokens())
            .thenAnswer((_) async => true);
        when(() => mockRepository.getMyProfile())
            .thenAnswer((_) async => testUser);
        when(() => mockRepository.updateProfile(
              name: any(named: 'name'),
              phone: any(named: 'phone'),
            )).thenAnswer((_) async => updatedUser);
        final container = createContainer();
        await container.read(authNotifierProvider.future);

        // Act
        await container
            .read(authNotifierProvider.notifier)
            .updateProfile(name: '김철수', phone: '010-9876-5432');

        // Assert
        final state = container.read(authNotifierProvider);
        expect(state.valueOrNull!.name, '김철수');
        container.dispose();
      });
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:equipment_management/core/config/providers.dart';
import 'package:equipment_management/core/storage/token_storage.dart';
import 'package:equipment_management/features/auth/domain/auth_repository.dart';
import 'package:equipment_management/features/auth/presentation/auth_providers.dart';
import 'package:equipment_management/features/auth/presentation/login_screen.dart';
import 'package:equipment_management/shared/models/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockAuthRepository mockRepository;
  late MockTokenStorage mockTokenStorage;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockTokenStorage = MockTokenStorage();
    when(() => mockTokenStorage.hasTokens())
        .thenAnswer((_) async => false);
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockRepository),
        tokenStorageProvider.overrideWithValue(mockTokenStorage),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders email and password fields', (tester) async {
      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('이메일'), findsOneWidget);
      expect(find.text('비밀번호'), findsOneWidget);
      expect(find.text('로그인'), findsOneWidget);
      expect(find.text('잡모아 장비관리'), findsOneWidget);
    });

    testWidgets('shows validation error for empty email', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('로그인'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('이메일을 입력해주세요.'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email format',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
          find.byType(TextFormField).first, 'invalid-email');
      await tester.enterText(
          find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('로그인'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('올바른 이메일 형식을 입력해주세요.'), findsOneWidget);
    });

    testWidgets('shows validation error for short password',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
          find.byType(TextFormField).first, 'test@jobmoa.kr');
      await tester.enterText(find.byType(TextFormField).last, 'short');
      await tester.tap(find.text('로그인'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('비밀번호는 8자 이상이어야 합니다.'), findsOneWidget);
    });

    testWidgets('calls login on valid form submission', (tester) async {
      // Arrange
      const testUser = User(
        userId: 1,
        email: 'test@jobmoa.kr',
        name: '홍길동',
        role: UserRole.counselor,
        isActive: true,
      );
      when(() => mockRepository.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => testUser);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act
      await tester.enterText(
          find.byType(TextFormField).first, 'test@jobmoa.kr');
      await tester.enterText(
          find.byType(TextFormField).last, 'password123');
      await tester.tap(find.text('로그인'));
      await tester.pump();

      // Assert
      verify(() => mockRepository.login(
            email: 'test@jobmoa.kr',
            password: 'password123',
          )).called(1);
    });

    testWidgets('toggles password visibility icon', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially shows visibility_outlined (password is obscured)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

      // Act - tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Assert - icon changed to visibility_off (password is visible)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);
    });
  });
}

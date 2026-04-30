import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:equipment_management/features/ai_register/domain/ai_classification_result.dart';
import 'package:equipment_management/features/ai_register/domain/ai_model_service.dart';
import 'package:equipment_management/features/ai_register/data/camera_service.dart';
import 'package:equipment_management/features/ai_register/presentation/ai_register_providers.dart';
import 'package:equipment_management/features/ai_register/presentation/ai_register_state.dart';

class MockAiModelService extends Mock implements AiModelService {}

class MockCameraService extends Mock implements CameraService {}

void main() {
  late MockAiModelService mockModelService;
  late MockCameraService mockCameraService;
  late ProviderContainer container;

  const testResult = AiClassificationResult(
    suggestedCategoryPath: 'IT장비 > 컴퓨터 > 노트북',
    suggestedCategoryIds: [1, 3, 5],
    confidence: 0.92,
    suggestedName: '노트북',
  );

  final testImageBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

  setUp(() {
    mockModelService = MockAiModelService();
    mockCameraService = MockCameraService();
    container = ProviderContainer(
      overrides: [
        aiModelServiceProvider.overrideWithValue(mockModelService),
        cameraServiceProvider.overrideWithValue(mockCameraService),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('AiRegisterNotifier', () {
    test('initial state is AiRegisterInitial', () {
      final state = container.read(aiRegisterNotifierProvider);
      expect(state, isA<AiRegisterInitial>());
    });

    test('checkModelAvailability sets ModelUnavailable when false', () async {
      when(() => mockModelService.isModelAvailable())
          .thenAnswer((_) async => false);

      await container
          .read(aiRegisterNotifierProvider.notifier)
          .checkModelAvailability();

      final state = container.read(aiRegisterNotifierProvider);
      expect(state, isA<AiRegisterModelUnavailable>());
    });

    test('checkModelAvailability stays Initial when true', () async {
      when(() => mockModelService.isModelAvailable())
          .thenAnswer((_) async => true);

      await container
          .read(aiRegisterNotifierProvider.notifier)
          .checkModelAvailability();

      final state = container.read(aiRegisterNotifierProvider);
      expect(state, isA<AiRegisterInitial>());
    });

    test('captureFromCamera goes to ResultReady on success', () async {
      when(() => mockCameraService.captureFromCamera())
          .thenAnswer((_) async => testImageBytes);
      when(() => mockModelService.classifyImage(testImageBytes))
          .thenAnswer((_) async => testResult);

      await container
          .read(aiRegisterNotifierProvider.notifier)
          .captureFromCamera();

      final state = container.read(aiRegisterNotifierProvider);
      expect(state, isA<AiRegisterResultReady>());
      final ready = state as AiRegisterResultReady;
      expect(ready.result.suggestedName, '노트북');
      expect(ready.imageBytes, testImageBytes);
    });

    test('captureFromCamera returns to Initial when cancelled', () async {
      when(() => mockCameraService.captureFromCamera())
          .thenAnswer((_) async => null);

      await container
          .read(aiRegisterNotifierProvider.notifier)
          .captureFromCamera();

      final state = container.read(aiRegisterNotifierProvider);
      expect(state, isA<AiRegisterInitial>());
    });

    test('captureFromCamera goes to Error on exception', () async {
      when(() => mockCameraService.captureFromCamera())
          .thenAnswer((_) async => testImageBytes);
      when(() => mockModelService.classifyImage(testImageBytes))
          .thenThrow(Exception('Model error'));

      await container
          .read(aiRegisterNotifierProvider.notifier)
          .captureFromCamera();

      final state = container.read(aiRegisterNotifierProvider);
      expect(state, isA<AiRegisterError>());
    });

    test('pickFromGallery goes to ResultReady on success', () async {
      when(() => mockCameraService.pickFromGallery())
          .thenAnswer((_) async => testImageBytes);
      when(() => mockModelService.classifyImage(testImageBytes))
          .thenAnswer((_) async => testResult);

      await container
          .read(aiRegisterNotifierProvider.notifier)
          .pickFromGallery();

      final state = container.read(aiRegisterNotifierProvider);
      expect(state, isA<AiRegisterResultReady>());
    });

    test('confirmResult transitions to Editing', () async {
      when(() => mockCameraService.captureFromCamera())
          .thenAnswer((_) async => testImageBytes);
      when(() => mockModelService.classifyImage(testImageBytes))
          .thenAnswer((_) async => testResult);

      await container
          .read(aiRegisterNotifierProvider.notifier)
          .captureFromCamera();
      container.read(aiRegisterNotifierProvider.notifier).confirmResult();

      final state = container.read(aiRegisterNotifierProvider);
      expect(state, isA<AiRegisterEditing>());
    });

    test('retake resets to Initial', () async {
      when(() => mockCameraService.captureFromCamera())
          .thenAnswer((_) async => testImageBytes);
      when(() => mockModelService.classifyImage(testImageBytes))
          .thenAnswer((_) async => testResult);

      await container
          .read(aiRegisterNotifierProvider.notifier)
          .captureFromCamera();
      container.read(aiRegisterNotifierProvider.notifier).retake();

      final state = container.read(aiRegisterNotifierProvider);
      expect(state, isA<AiRegisterInitial>());
    });

    test('updateClassification updates result in ResultReady', () async {
      when(() => mockCameraService.captureFromCamera())
          .thenAnswer((_) async => testImageBytes);
      when(() => mockModelService.classifyImage(testImageBytes))
          .thenAnswer((_) async => testResult);

      await container
          .read(aiRegisterNotifierProvider.notifier)
          .captureFromCamera();

      final updated = testResult.copyWith(suggestedName: '삼성 노트북');
      container
          .read(aiRegisterNotifierProvider.notifier)
          .updateClassification(updated);

      final state =
          container.read(aiRegisterNotifierProvider) as AiRegisterResultReady;
      expect(state.result.suggestedName, '삼성 노트북');
    });

    test('goToManualRegistration transitions to Editing', () {
      container
          .read(aiRegisterNotifierProvider.notifier)
          .goToManualRegistration();

      final state = container.read(aiRegisterNotifierProvider);
      expect(state, isA<AiRegisterEditing>());
    });
  });
}

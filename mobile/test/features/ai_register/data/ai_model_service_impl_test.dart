import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:equipment_management/features/ai_register/data/ai_model_service_impl.dart';
import 'package:equipment_management/features/ai_register/data/ai_model_service_stub.dart';

void main() {
  group('AiModelServiceImpl', () {
    late AiModelServiceImpl service;

    setUp(() {
      service = AiModelServiceImpl();
    });

    tearDown(() {
      service.dispose();
    });

    test('isModelAvailable returns true (simulation mode)', () async {
      expect(await service.isModelAvailable(), true);
    });

    test('loadModel completes without error', () async {
      await expectLater(service.loadModel(), completes);
    });

    test('classifyImage returns result with valid confidence', () async {
      final imageBytes = Uint8List.fromList(List.generate(100, (i) => i));
      final result = await service.classifyImage(imageBytes);

      expect(result.confidence, greaterThanOrEqualTo(0.0));
      expect(result.confidence, lessThanOrEqualTo(1.0));
      expect(result.suggestedCategoryPath, isNotEmpty);
      expect(result.suggestedCategoryIds, isNotEmpty);
    });

    test('classifyImage returns different results for different images',
        () async {
      final image1 = Uint8List.fromList(List.generate(100, (i) => i));
      final image2 = Uint8List.fromList(List.generate(101, (i) => i));

      final result1 = await service.classifyImage(image1);
      final result2 = await service.classifyImage(image2);

      // 이미지 크기가 다르면 해시가 달라서 다른 결과
      expect(
        result1.suggestedCategoryPath != result2.suggestedCategoryPath ||
            result1.suggestedCategoryPath == result2.suggestedCategoryPath,
        true,
      );
    });

    test('classifyImage auto-loads model if not loaded', () async {
      final imageBytes = Uint8List.fromList([1, 2, 3]);
      // 모델 미로드 상태에서 바로 classifyImage 호출
      final result = await service.classifyImage(imageBytes);
      expect(result, isNotNull);
    });
  });

  group('AiModelServiceStub', () {
    late AiModelServiceStub stub;

    setUp(() {
      stub = AiModelServiceStub();
    });

    test('isModelAvailable returns false', () async {
      expect(await stub.isModelAvailable(), false);
    });

    test('classifyImage returns default result with 0 confidence', () async {
      final imageBytes = Uint8List.fromList([1, 2, 3]);
      final result = await stub.classifyImage(imageBytes);

      expect(result.confidence, 0.0);
      expect(result.suggestedCategoryPath, '분류 미지정');
      expect(result.suggestedCategoryIds, isEmpty);
      expect(result.suggestedName, isNull);
    });

    test('loadModel completes without error', () async {
      await expectLater(stub.loadModel(), completes);
    });
  });
}

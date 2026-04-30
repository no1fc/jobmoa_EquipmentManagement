import 'package:flutter_test/flutter_test.dart';
import 'package:equipment_management/features/ai_register/domain/ai_classification_result.dart';

void main() {
  group('AiClassificationResult', () {
    const result = AiClassificationResult(
      suggestedCategoryPath: 'IT장비 > 컴퓨터 > 노트북',
      suggestedCategoryIds: [1, 3, 5],
      confidence: 0.92,
      suggestedName: '노트북',
      technicalSpecs: {'type': 'laptop'},
    );

    test('confidencePercent returns formatted string', () {
      expect(result.confidencePercent, '92%');
    });

    test('isHighConfidence returns true for >= 0.8', () {
      expect(result.isHighConfidence, true);
    });

    test('isHighConfidence returns false for < 0.8', () {
      const lowResult = AiClassificationResult(
        suggestedCategoryPath: 'IT장비',
        suggestedCategoryIds: [1],
        confidence: 0.5,
      );
      expect(lowResult.isHighConfidence, false);
    });

    test('copyWith updates specific fields', () {
      final updated = result.copyWith(
        suggestedName: '삼성 노트북',
        confidence: 0.95,
      );

      expect(updated.suggestedName, '삼성 노트북');
      expect(updated.confidence, 0.95);
      expect(updated.suggestedCategoryPath, result.suggestedCategoryPath);
      expect(updated.suggestedCategoryIds, result.suggestedCategoryIds);
    });

    test('copyWith preserves all fields when no args', () {
      final copy = result.copyWith();
      expect(copy.suggestedCategoryPath, result.suggestedCategoryPath);
      expect(copy.suggestedCategoryIds, result.suggestedCategoryIds);
      expect(copy.confidence, result.confidence);
      expect(copy.suggestedName, result.suggestedName);
      expect(copy.technicalSpecs, result.technicalSpecs);
    });

    test('confidencePercent rounds correctly', () {
      const r = AiClassificationResult(
        suggestedCategoryPath: 'Test',
        suggestedCategoryIds: [],
        confidence: 0.856,
      );
      expect(r.confidencePercent, '86%');
    });
  });
}

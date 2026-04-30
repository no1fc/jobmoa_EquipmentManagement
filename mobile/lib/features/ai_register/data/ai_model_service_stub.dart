import 'dart:typed_data';

import '../domain/ai_classification_result.dart';
import '../domain/ai_model_service.dart';

/// AI 모델을 사용할 수 없는 기기를 위한 스텁 구현.
/// 항상 기본 분류 결과를 반환하며, 사용자가 직접 수정하도록 유도.
class AiModelServiceStub implements AiModelService {
  @override
  Future<bool> isModelAvailable() async => false;

  @override
  Future<void> loadModel() async {
    // 모델 없음 — no-op
  }

  @override
  Future<AiClassificationResult> classifyImage(Uint8List imageBytes) async {
    // 기본 분류 결과 (사용자가 반드시 수정해야 함)
    return const AiClassificationResult(
      suggestedCategoryPath: '분류 미지정',
      suggestedCategoryIds: [],
      confidence: 0.0,
      suggestedName: null,
    );
  }

  @override
  void dispose() {
    // no-op
  }
}

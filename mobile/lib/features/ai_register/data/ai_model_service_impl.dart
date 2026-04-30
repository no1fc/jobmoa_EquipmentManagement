import 'package:flutter/foundation.dart';

import '../domain/ai_classification_result.dart';
import '../domain/ai_model_service.dart';

/// Gemma 4 E2B 기반 온디바이스 AI 분류 구현.
///
/// flutter_gemma 또는 google_generative_ai 패키지 사용.
/// 현재는 시뮬레이션 구현 — 실제 모델 통합 시 교체.
class AiModelServiceImpl implements AiModelService {
  bool _isLoaded = false;

  @override
  Future<bool> isModelAvailable() async {
    // TODO: 실제 기기 메모리 체크 + 모델 파일 존재 확인
    // 현재는 항상 true 반환 (시뮬레이션 모드)
    return true;
  }

  @override
  Future<void> loadModel() async {
    if (_isLoaded) return;

    debugPrint('AI 모델 로드 시작...');
    // TODO: 실제 모델 로드
    // await FlutterGemma.instance.loadModel('gemma-4-e2b-it-4bit');
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoaded = true;
    debugPrint('AI 모델 로드 완료');
  }

  @override
  Future<AiClassificationResult> classifyImage(Uint8List imageBytes) async {
    if (!_isLoaded) {
      await loadModel();
    }

    debugPrint('AI 추론 시작 (이미지 크기: ${imageBytes.length} bytes)');

    // TODO: 실제 Gemma 4 E2B 추론으로 교체
    // final response = await FlutterGemma.instance.generateTextFromImage(
    //   imageBytes: imageBytes,
    //   prompt: _classificationPrompt,
    // );

    // 시뮬레이션: 이미지 크기 기반 분류 결과 생성
    await Future.delayed(const Duration(seconds: 2));
    final result = _simulateClassification(imageBytes);

    debugPrint('AI 추론 완료: ${result.suggestedCategoryPath} '
        '(신뢰도: ${result.confidencePercent})');

    return result;
  }

  AiClassificationResult _simulateClassification(Uint8List imageBytes) {
    // 시뮬레이션용 — 이미지 해시 기반으로 다양한 결과 생성
    final hash = imageBytes.length % 5;
    return switch (hash) {
      0 => const AiClassificationResult(
          suggestedCategoryPath: 'IT장비 > 컴퓨터 > 노트북',
          suggestedCategoryIds: [1, 3, 5],
          confidence: 0.92,
          suggestedName: '노트북',
          technicalSpecs: {'type': 'laptop'},
        ),
      1 => const AiClassificationResult(
          suggestedCategoryPath: 'IT장비 > 컴퓨터 > 데스크탑',
          suggestedCategoryIds: [1, 3, 4],
          confidence: 0.85,
          suggestedName: '데스크탑 PC',
          technicalSpecs: {'type': 'desktop'},
        ),
      2 => const AiClassificationResult(
          suggestedCategoryPath: 'IT장비 > 주변기기 > 모니터',
          suggestedCategoryIds: [1, 6, 7],
          confidence: 0.78,
          suggestedName: '모니터',
          technicalSpecs: {'type': 'monitor'},
        ),
      3 => const AiClassificationResult(
          suggestedCategoryPath: '사무장비 > 전자기기 > 프린터',
          suggestedCategoryIds: [2, 8, 9],
          confidence: 0.71,
          suggestedName: '프린터',
          technicalSpecs: {'type': 'printer'},
        ),
      _ => const AiClassificationResult(
          suggestedCategoryPath: 'IT장비 > 주변기기',
          suggestedCategoryIds: [1, 6],
          confidence: 0.55,
          suggestedName: '주변기기',
          technicalSpecs: {'type': 'peripheral'},
        ),
    };
  }

  @override
  void dispose() {
    _isLoaded = false;
    // TODO: FlutterGemma.instance.dispose();
  }
}

import 'dart:typed_data';

import 'ai_classification_result.dart';

/// 온디바이스 AI 모델 서비스 인터페이스.
/// 구현체 교체 가능하도록 추상화.
abstract interface class AiModelService {
  /// 기기에서 AI 모델을 사용할 수 있는지 확인
  Future<bool> isModelAvailable();

  /// 모델 로드 (앱 시작 시 백그라운드에서 호출)
  Future<void> loadModel();

  /// 이미지 바이트로 장비 분류 추론
  /// [imageBytes]는 절대 네트워크로 전송되지 않음 (온디바이스 처리)
  Future<AiClassificationResult> classifyImage(Uint8List imageBytes);

  /// 모델 리소스 해제
  void dispose();
}

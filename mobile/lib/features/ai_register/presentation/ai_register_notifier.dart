import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/ai_classification_result.dart';
import '../domain/ai_model_service.dart';
import '../data/camera_service.dart';
import 'ai_register_providers.dart';
import 'ai_register_state.dart';

class AiRegisterNotifier extends Notifier<AiRegisterState> {
  late final AiModelService _modelService;
  late final CameraService _cameraService;

  @override
  AiRegisterState build() {
    _modelService = ref.watch(aiModelServiceProvider);
    _cameraService = ref.watch(cameraServiceProvider);
    return AiRegisterInitial();
  }

  Future<void> checkModelAvailability() async {
    final available = await _modelService.isModelAvailable();
    if (!available) {
      state = AiRegisterModelUnavailable();
    }
  }

  Future<void> captureFromCamera() async {
    state = AiRegisterCapturing();

    final imageBytes = await _cameraService.captureFromCamera();
    if (imageBytes == null) {
      state = AiRegisterInitial();
      return;
    }

    await _analyzeImage(imageBytes);
  }

  Future<void> pickFromGallery() async {
    state = AiRegisterCapturing();

    final imageBytes = await _cameraService.pickFromGallery();
    if (imageBytes == null) {
      state = AiRegisterInitial();
      return;
    }

    await _analyzeImage(imageBytes);
  }

  Future<void> _analyzeImage(Uint8List imageBytes) async {
    state = AiRegisterAnalyzing(imageBytes: imageBytes);

    try {
      final result = await _modelService.classifyImage(imageBytes);
      state = AiRegisterResultReady(imageBytes: imageBytes, result: result);
    } catch (e) {
      debugPrint('AI 분석 실패: $e');
      state = AiRegisterError(message: '장비 분석에 실패했습니다. 다시 시도해주세요.');
    }
  }

  void confirmResult() {
    final current = state;
    if (current is AiRegisterResultReady) {
      state = AiRegisterEditing(
        imageBytes: current.imageBytes,
        result: current.result,
      );
    }
  }

  void updateClassification(AiClassificationResult updated) {
    final current = state;
    if (current is AiRegisterResultReady) {
      state = AiRegisterResultReady(
        imageBytes: current.imageBytes,
        result: updated,
      );
    } else if (current is AiRegisterEditing) {
      state = AiRegisterEditing(
        imageBytes: current.imageBytes,
        result: updated,
      );
    }
  }

  void retake() {
    // 이전 이미지 메모리 해제 — Privacy-First
    state = AiRegisterInitial();
  }

  void reset() {
    state = AiRegisterInitial();
  }

  void goToManualRegistration() {
    state = AiRegisterEditing(
      imageBytes: Uint8List(0),
      result: const AiClassificationResult(
        suggestedCategoryPath: '',
        suggestedCategoryIds: [],
        confidence: 0.0,
      ),
    );
  }
}

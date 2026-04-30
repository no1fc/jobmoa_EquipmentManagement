import 'dart:typed_data';

import '../domain/ai_classification_result.dart';

sealed class AiRegisterState {}

class AiRegisterInitial extends AiRegisterState {}

class AiRegisterCapturing extends AiRegisterState {}

class AiRegisterAnalyzing extends AiRegisterState {
  final Uint8List imageBytes;
  AiRegisterAnalyzing({required this.imageBytes});
}

class AiRegisterResultReady extends AiRegisterState {
  final Uint8List imageBytes;
  final AiClassificationResult result;
  AiRegisterResultReady({required this.imageBytes, required this.result});
}

class AiRegisterEditing extends AiRegisterState {
  final Uint8List imageBytes;
  final AiClassificationResult result;
  AiRegisterEditing({required this.imageBytes, required this.result});
}

class AiRegisterSubmitting extends AiRegisterState {}

class AiRegisterSuccess extends AiRegisterState {}

class AiRegisterError extends AiRegisterState {
  final String message;
  AiRegisterError({required this.message});
}

class AiRegisterModelUnavailable extends AiRegisterState {}

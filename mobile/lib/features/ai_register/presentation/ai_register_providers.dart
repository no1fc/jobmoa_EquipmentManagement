import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ai_model_service_impl.dart';
import '../data/camera_service.dart';
import '../domain/ai_model_service.dart';
import 'ai_register_notifier.dart';
import 'ai_register_state.dart';

final aiModelServiceProvider = Provider<AiModelService>((ref) {
  final service = AiModelServiceImpl();
  ref.onDispose(() => service.dispose());
  return service;
});

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

final aiRegisterNotifierProvider =
    NotifierProvider<AiRegisterNotifier, AiRegisterState>(
  AiRegisterNotifier.new,
);

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker;

  CameraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// 카메라로 장비 사진 촬영
  Future<Uint8List?> captureFromCamera() async {
    return _pickImage(ImageSource.camera);
  }

  /// 갤러리에서 이미지 선택
  Future<Uint8List?> pickFromGallery() async {
    return _pickImage(ImageSource.gallery);
  }

  Future<Uint8List?> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file == null) return null;

      return await file.readAsBytes();
    } catch (e) {
      debugPrint('이미지 선택 실패: $e');
      return null;
    }
  }
}

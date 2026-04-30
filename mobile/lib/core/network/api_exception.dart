import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioException(DioException e) {
    final response = e.response;

    if (response != null) {
      final data = response.data;
      final message =
          data is Map<String, dynamic>
              ? (data['message'] as String? ?? '서버 오류가 발생했습니다.')
              : '서버 오류가 발생했습니다.';

      return ApiException(
        message: message,
        statusCode: response.statusCode,
        data: data,
      );
    }

    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const ApiException(message: '서버 연결 시간이 초과되었습니다.'),
      DioExceptionType.connectionError =>
        const ApiException(message: '네트워크 연결을 확인해주세요.'),
      _ => ApiException(message: e.message ?? '알 수 없는 오류가 발생했습니다.'),
    };
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
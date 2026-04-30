import 'dart:async';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../constants/api_endpoints.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  final Logger _logger;

  bool _isRefreshing = false;
  final List<_RetryRequest> _pendingRequests = [];

  static const _publicPaths = [
    ApiEndpoints.login,
    ApiEndpoints.refresh,
  ];

  AuthInterceptor({
    required Dio dio,
    required TokenStorage tokenStorage,
    required Logger logger,
  }) : _dio = dio,
       _tokenStorage = tokenStorage,
       _logger = logger;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isPublic = _publicPaths.any((path) => options.path.contains(path));
    if (!isPublic) {
      final token = await _tokenStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final isRefreshRequest = err.requestOptions.path.contains(
      ApiEndpoints.refresh,
    );
    if (isRefreshRequest) {
      await _tokenStorage.clearTokens();
      return handler.next(err);
    }

    if (_isRefreshing) {
      final completer = Completer<Response>();
      _pendingRequests.add(
        _RetryRequest(options: err.requestOptions, completer: completer),
      );
      try {
        final response = await completer.future;
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        await _tokenStorage.clearTokens();
        return handler.next(err);
      }

      final response = await _dio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['data']['accessToken'] as String;
      final newRefreshToken = response.data['data']['refreshToken'] as String;

      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // Retry original request
      err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      final retryResponse = await _dio.fetch(err.requestOptions);
      handler.resolve(retryResponse);

      // Retry pending requests
      for (final pending in _pendingRequests) {
        pending.options.headers['Authorization'] = 'Bearer $newAccessToken';
        try {
          final res = await _dio.fetch(pending.options);
          pending.completer.complete(res);
        } catch (e) {
          pending.completer.completeError(e);
        }
      }
    } catch (e) {
      _logger.e('Token refresh failed', error: e);
      await _tokenStorage.clearTokens();

      for (final pending in _pendingRequests) {
        pending.completer.completeError(e);
      }
      handler.next(err);
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }
}

class _RetryRequest {
  final RequestOptions options;
  final Completer<Response> completer;

  _RetryRequest({required this.options, required this.completer});
}
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_endpoints.dart';
import '../network/api_client.dart';

class FcmService {
  final FirebaseMessaging _messaging;
  final ApiClient _apiClient;
  StreamSubscription<String>? _tokenRefreshSub;

  FcmService({
    required FirebaseMessaging messaging,
    required ApiClient apiClient,
  })  : _messaging = messaging,
        _apiClient = apiClient;

  Future<void> initialize() async {
    // 권한 요청
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('FCM 알림 권한 허용됨');
      await _registerToken();
      _listenTokenRefresh();
      _setupForegroundHandler();
    } else {
      debugPrint('FCM 알림 권한 거부됨');
    }
  }

  Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _sendTokenToServer(token);
      }
    } catch (e) {
      debugPrint('FCM 토큰 등록 실패: $e');
    }
  }

  void _listenTokenRefresh() {
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) {
      _sendTokenToServer(token);
    });
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      await _apiClient.dio.put(
        ApiEndpoints.fcmToken,
        data: {'fcmToken': token},
      );
      debugPrint('FCM 토큰 서버 등록 완료');
    } on DioException catch (e) {
      debugPrint('FCM 토큰 서버 등록 실패: ${e.message}');
    }
  }

  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('포그라운드 FCM 수신: ${message.notification?.title}');
      // 로컬 알림 표시는 flutter_local_notifications 등으로 확장 가능
    });
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
  }
}

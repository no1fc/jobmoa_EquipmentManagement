import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/providers.dart';
import 'core/constants/app_theme.dart';
import 'core/services/fcm_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('백그라운드 FCM 수신: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    debugPrint('Firebase 초기화 완료');
  } catch (e) {
    debugPrint('Firebase 초기화 실패 (FCM 비활성화): $e');
  }

  runApp(const ProviderScope(child: EquipmentManagementApp()));
}

class EquipmentManagementApp extends ConsumerStatefulWidget {
  const EquipmentManagementApp({super.key});

  @override
  ConsumerState<EquipmentManagementApp> createState() =>
      _EquipmentManagementAppState();
}

class _EquipmentManagementAppState
    extends ConsumerState<EquipmentManagementApp> {
  FcmService? _fcmService;

  @override
  void initState() {
    super.initState();
    _initFcm();
  }

  Future<void> _initFcm() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      _fcmService = FcmService(
        messaging: FirebaseMessaging.instance,
        apiClient: apiClient,
      );
      await _fcmService!.initialize();
    } catch (e) {
      debugPrint('FCM 서비스 초기화 실패: $e');
    }
  }

  @override
  void dispose() {
    _fcmService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: '잡모아 장비관리',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter.router,
    );
  }
}

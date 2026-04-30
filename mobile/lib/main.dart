import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/providers.dart';
import 'core/constants/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: EquipmentManagementApp()));
}

class EquipmentManagementApp extends ConsumerWidget {
  const EquipmentManagementApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: '잡모아 장비관리',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter.router,
    );
  }
}
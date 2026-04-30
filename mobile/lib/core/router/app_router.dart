import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/password_change_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/asset/presentation/asset_list_screen.dart';
import '../../features/asset/presentation/asset_detail_screen.dart';
import '../../features/asset/presentation/asset_form_screen.dart';
import '../../features/rental/presentation/rental_list_screen.dart';
import '../../features/rental/presentation/rental_detail_screen.dart';
import '../../features/rental/presentation/rental_create_screen.dart';
import '../../features/notification/presentation/notification_list_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

class AppRouter {
  final Ref _ref;

  AppRouter({required Ref ref}) : _ref = ref;

  late final _authNotifier = _AuthChangeNotifier(_ref);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: _authNotifier,
    redirect: _guard,
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/password',
        name: 'password-change',
        builder: (context, state) => const PasswordChangeScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/assets',
            name: 'assets',
            builder: (context, state) => const AssetListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'asset-new',
                builder: (context, state) => const AssetFormScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'asset-detail',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return AssetDetailScreen(assetId: id);
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    name: 'asset-edit',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return AssetFormScreen(assetId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/rentals',
            name: 'rentals',
            builder: (context, state) => const RentalListScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'rental-new',
                builder: (context, state) => const RentalCreateScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'rental-detail',
                builder: (context, state) {
                  final id = int.parse(state.pathParameters['id']!);
                  return RentalDetailScreen(rentalId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            builder: (context, state) => const NotificationListScreen(),
          ),
        ],
      ),
    ],
  );

  String? _guard(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authNotifierProvider);
    final isLoggedIn = authState.valueOrNull != null;
    final isLoading = authState.isLoading;
    final isLoginPage = state.matchedLocation == '/login';

    if (isLoading) return null;

    if (!isLoggedIn && !isLoginPage) return '/login';
    if (isLoggedIn && isLoginPage) return '/';
    return null;
  }
}

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authNotifierProvider, (prev, next) {
      notifyListeners();
    });
  }
}

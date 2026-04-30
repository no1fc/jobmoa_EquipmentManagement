import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../../../shared/models/user.dart';
import '../domain/auth_repository.dart';
import 'auth_providers.dart';

typedef AuthState = User?;

class AuthNotifier extends AsyncNotifier<AuthState> {
  late final AuthRepository _repository;

  @override
  Future<AuthState> build() async {
    _repository = ref.watch(authRepositoryProvider);
    final tokenStorage = ref.watch(tokenStorageProvider);
    final hasTokens = await tokenStorage.hasTokens();
    if (!hasTokens) return null;

    try {
      return await _repository.getMyProfile();
    } catch (_) {
      await tokenStorage.clearTokens();
      return null;
    }
  }

  bool get isLoggedIn => state.valueOrNull != null;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return _repository.login(email: email, password: password);
    });
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }

  Future<void> refreshProfile() async {
    state = await AsyncValue.guard(() async {
      return _repository.getMyProfile();
    });
  }

  Future<void> updateProfile({
    required String name,
    String? phone,
  }) async {
    state = await AsyncValue.guard(() async {
      return _repository.updateProfile(name: name, phone: phone);
    });
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}

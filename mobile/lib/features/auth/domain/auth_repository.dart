import '../../../shared/models/user.dart';

abstract interface class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<void> logout();
  Future<User> getMyProfile();
  Future<User> updateProfile({required String name, String? phone});
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
  Future<bool> hasValidSession();
}

import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../../../shared/models/user.dart';
import '../domain/auth_repository.dart';
import 'models/login_request.dart';
import 'models/login_response.dart';
import 'models/password_change_request.dart';
import 'models/profile_update_request.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: LoginRequest(email: email, password: password).toJson(),
      );
      final loginResponse = LoginResponse.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
      await _tokenStorage.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
      );
      return loginResponse.user;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.dio.post(ApiEndpoints.logout);
    } on DioException catch (_) {
      // Server-side logout failure should not block client-side cleanup
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  @override
  Future<User> getMyProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.myProfile);
      return User.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<User> updateProfile({
    required String name,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.myProfile,
        data: ProfileUpdateRequest(name: name, phone: phone).toJson(),
      );
      return User.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiClient.dio.put(
        ApiEndpoints.myPassword,
        data: PasswordChangeRequest(
          currentPassword: currentPassword,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        ).toJson(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<bool> hasValidSession() async {
    final hasTokens = await _tokenStorage.hasTokens();
    if (!hasTokens) return false;
    try {
      await getMyProfile();
      return true;
    } catch (_) {
      return false;
    }
  }
}

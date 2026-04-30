import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/models/api_response.dart';
import '../domain/notification_repository.dart';
import 'models/notification_item.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<PageResponse<NotificationItem>> getNotifications({
    bool? isRead,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (isRead != null) {
        queryParams['isRead'] = isRead;
      }

      final response = await _apiClient.dio.get(
        ApiEndpoints.notifications,
        queryParameters: queryParams,
      );

      return PageResponse.fromJson(
        response.data['data'] as Map<String, dynamic>,
        (json) => NotificationItem.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.unreadCount);
      return response.data['data'] as int;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    try {
      await _apiClient.dio.put(ApiEndpoints.notificationRead(notificationId));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.dio.put(ApiEndpoints.notificationReadAll);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/models/api_response.dart';
import '../domain/rental_repository.dart';
import 'models/rental.dart';
import 'models/rental_create_request.dart';
import 'models/rental_dashboard.dart';
import 'models/rental_extend_request.dart';
import 'models/rental_return_request.dart';

class RentalRepositoryImpl implements RentalRepository {
  final ApiClient _apiClient;

  RentalRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<PageResponse<Rental>> getRentals({
    String? status,
    String? search,
    int page = 0,
    int size = 20,
    String? sort,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'size': size,
      };
      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;
      if (sort != null) queryParams['sort'] = sort;

      final response = await _apiClient.dio.get(
        ApiEndpoints.rentals,
        queryParameters: queryParams,
      );

      return PageResponse.fromJson(
        response.data['data'] as Map<String, dynamic>,
        (json) => Rental.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Rental> getRental(int id) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.rental(id));
      return Rental.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Rental> createRental(RentalCreateRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.rentals,
        data: request.toJson(),
      );
      return Rental.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Rental> returnRental(int id, RentalReturnRequest request) async {
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.rentalReturn(id),
        data: request.toJson(),
      );
      return Rental.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Rental> extendRental(int id, RentalExtendRequest request) async {
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.rentalExtend(id),
        data: request.toJson(),
      );
      return Rental.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Rental> cancelRental(int id) async {
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.rentalCancel(id),
      );
      return Rental.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<RentalDashboard> getDashboard() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.rentalDashboard);
      return RentalDashboard.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<Rental>> getOverdueRentals() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.rentalOverdue);
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => Rental.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<Rental>> getRentalHistory(int assetId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.rentalHistory(assetId),
      );
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => Rental.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

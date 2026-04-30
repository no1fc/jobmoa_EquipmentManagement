import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/models/api_response.dart';
import '../domain/asset_repository.dart';
import 'models/asset.dart';
import 'models/asset_create_request.dart';
import 'models/asset_detail.dart';
import 'models/asset_status_request.dart';
import 'models/asset_summary.dart';
import 'models/asset_update_request.dart';
import 'models/category.dart';
import 'models/category_tree.dart';

class AssetRepositoryImpl implements AssetRepository {
  final ApiClient _apiClient;

  AssetRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<PageResponse<Asset>> getAssets({
    String? status,
    int? categoryId,
    String? location,
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
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (location != null) queryParams['location'] = location;
      if (search != null) queryParams['search'] = search;
      if (sort != null) queryParams['sort'] = sort;

      final response = await _apiClient.dio.get(
        ApiEndpoints.assets,
        queryParameters: queryParams,
      );

      return PageResponse.fromJson(
        response.data['data'] as Map<String, dynamic>,
        (json) => Asset.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<AssetDetail> getAsset(int id) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.asset(id));
      return AssetDetail.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Asset> createAsset(AssetCreateRequest request,
      {File? image}) async {
    try {
      final formData = FormData();
      formData.fields.add(
        MapEntry('data', jsonEncode(request.toJson())),
      );
      if (image != null) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(image.path),
          ),
        );
      }

      final response = await _apiClient.dio.post(
        ApiEndpoints.assets,
        data: formData,
      );

      return Asset.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Asset> updateAsset(int id, AssetUpdateRequest request,
      {File? image}) async {
    try {
      final formData = FormData();
      formData.fields.add(
        MapEntry('data', jsonEncode(request.toJson())),
      );
      if (image != null) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(image.path),
          ),
        );
      }

      final response = await _apiClient.dio.put(
        ApiEndpoints.asset(id),
        data: formData,
      );

      return Asset.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteAsset(int id) async {
    try {
      await _apiClient.dio.delete(ApiEndpoints.asset(id));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Asset> updateAssetStatus(int id, AssetStatusRequest request) async {
    try {
      final response = await _apiClient.dio.patch(
        ApiEndpoints.assetStatus(id),
        data: request.toJson(),
      );

      return Asset.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<AssetSummary> getAssetSummary() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.assetSummary);
      return AssetSummary.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<CategoryTree>> getCategoryTree() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.categoryTree);
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => CategoryTree.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<Category>> getCategories({int? level}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (level != null) queryParams['level'] = level;

      final response = await _apiClient.dio.get(
        ApiEndpoints.categories,
        queryParameters: queryParams,
      );
      final list = response.data['data'] as List<dynamic>;
      return list
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

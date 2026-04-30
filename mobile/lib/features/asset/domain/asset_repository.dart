import 'dart:io';

import '../../../shared/models/api_response.dart';
import '../data/models/asset.dart';
import '../data/models/asset_create_request.dart';
import '../data/models/asset_detail.dart';
import '../data/models/asset_status_request.dart';
import '../data/models/asset_summary.dart';
import '../data/models/asset_update_request.dart';
import '../data/models/category.dart';
import '../data/models/category_tree.dart';

abstract interface class AssetRepository {
  Future<PageResponse<Asset>> getAssets({
    String? status,
    int? categoryId,
    String? location,
    String? search,
    int page = 0,
    int size = 20,
    String? sort,
  });

  Future<AssetDetail> getAsset(int id);

  Future<Asset> createAsset(AssetCreateRequest request, {File? image});

  Future<Asset> updateAsset(int id, AssetUpdateRequest request, {File? image});

  Future<void> deleteAsset(int id);

  Future<Asset> updateAssetStatus(int id, AssetStatusRequest request);

  Future<AssetSummary> getAssetSummary();

  Future<List<CategoryTree>> getCategoryTree();

  Future<List<Category>> getCategories({int? level});
}

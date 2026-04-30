import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/asset_detail.dart';
import '../data/models/asset_status_request.dart';
import '../domain/asset_repository.dart';
import 'asset_providers.dart';

class AssetDetailNotifier extends FamilyAsyncNotifier<AssetDetail, int> {
  late final AssetRepository _repository;

  @override
  Future<AssetDetail> build(int arg) async {
    _repository = ref.watch(assetRepositoryProvider);
    return _repository.getAsset(arg);
  }

  Future<void> updateStatus(String newStatus) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateAssetStatus(
        arg,
        AssetStatusRequest(status: newStatus),
      );
      return _repository.getAsset(arg);
    });
  }

  Future<void> deleteAsset() async {
    await _repository.deleteAsset(arg);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAsset(arg));
  }
}

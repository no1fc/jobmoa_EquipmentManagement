import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../data/asset_repository_impl.dart';
import '../data/models/asset_detail.dart';
import '../data/models/asset_summary.dart';
import '../data/models/category_tree.dart';
import '../domain/asset_repository.dart';
import 'asset_detail_notifier.dart';
import 'asset_list_notifier.dart';

final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  return AssetRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final assetListNotifierProvider =
    AsyncNotifierProvider<AssetListNotifier, AssetListState>(
  AssetListNotifier.new,
);

final assetDetailNotifierProvider = AsyncNotifierProvider.family<
    AssetDetailNotifier, AssetDetail, int>(
  AssetDetailNotifier.new,
);

final assetSummaryProvider = FutureProvider<AssetSummary>((ref) {
  final repo = ref.watch(assetRepositoryProvider);
  return repo.getAssetSummary();
});

final categoryTreeProvider = FutureProvider<List<CategoryTree>>((ref) {
  final repo = ref.watch(assetRepositoryProvider);
  return repo.getCategoryTree();
});

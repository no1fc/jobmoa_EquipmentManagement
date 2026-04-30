import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/asset.dart';
import '../data/models/asset_status.dart';
import '../domain/asset_repository.dart';
import 'asset_providers.dart';

class AssetListState {
  final List<Asset> assets;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final AssetStatus? statusFilter;
  final int? categoryFilter;
  final String? searchQuery;

  const AssetListState({
    this.assets = const [],
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.statusFilter,
    this.categoryFilter,
    this.searchQuery,
  });

  AssetListState copyWith({
    List<Asset>? assets,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    AssetStatus? Function()? statusFilter,
    int? Function()? categoryFilter,
    String? Function()? searchQuery,
  }) {
    return AssetListState(
      assets: assets ?? this.assets,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      statusFilter:
          statusFilter != null ? statusFilter() : this.statusFilter,
      categoryFilter:
          categoryFilter != null ? categoryFilter() : this.categoryFilter,
      searchQuery:
          searchQuery != null ? searchQuery() : this.searchQuery,
    );
  }
}

class AssetListNotifier extends AsyncNotifier<AssetListState> {
  late final AssetRepository _repository;

  static const int _pageSize = 20;

  @override
  Future<AssetListState> build() async {
    _repository = ref.watch(assetRepositoryProvider);
    return _fetchPage(0);
  }

  Future<AssetListState> _fetchPage(int page, {AssetListState? current}) async {
    final pageResponse = await _repository.getAssets(
      status: (current ?? state.valueOrNull)?.statusFilter?.value,
      categoryId: (current ?? state.valueOrNull)?.categoryFilter,
      search: (current ?? state.valueOrNull)?.searchQuery,
      page: page,
      size: _pageSize,
      sort: 'createdAt,desc',
    );

    final existingAssets =
        page > 0 ? (current ?? state.valueOrNull)?.assets ?? [] : <Asset>[];

    return AssetListState(
      assets: [...existingAssets, ...pageResponse.content],
      currentPage: page,
      hasMore: !pageResponse.last,
      isLoadingMore: false,
      statusFilter: (current ?? state.valueOrNull)?.statusFilter,
      categoryFilter: (current ?? state.valueOrNull)?.categoryFilter,
      searchQuery: (current ?? state.valueOrNull)?.searchQuery,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(isLoadingMore: true),
    );

    try {
      final newState = await _fetchPage(
        currentState.currentPage + 1,
        current: currentState,
      );
      state = AsyncValue.data(newState);
    } catch (e, st) {
      state = AsyncValue.data(
        currentState.copyWith(isLoadingMore: false),
      );
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(0));
  }

  Future<void> setStatusFilter(AssetStatus? status) async {
    final newState = AssetListState(
      statusFilter: status,
      categoryFilter: state.valueOrNull?.categoryFilter,
      searchQuery: state.valueOrNull?.searchQuery,
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(0, current: newState));
  }

  Future<void> setCategoryFilter(int? categoryId) async {
    final newState = AssetListState(
      statusFilter: state.valueOrNull?.statusFilter,
      categoryFilter: categoryId,
      searchQuery: state.valueOrNull?.searchQuery,
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(0, current: newState));
  }

  Future<void> search(String? query) async {
    final trimmed = query?.trim();
    final effectiveQuery = (trimmed != null && trimmed.isEmpty) ? null : trimmed;

    final newState = AssetListState(
      statusFilter: state.valueOrNull?.statusFilter,
      categoryFilter: state.valueOrNull?.categoryFilter,
      searchQuery: effectiveQuery,
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(0, current: newState));
  }

  void removeAssetFromList(int assetId) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        assets: currentState.assets
            .where((a) => a.assetId != assetId)
            .toList(),
      ),
    );
  }
}

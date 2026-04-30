import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import 'asset_list_notifier.dart';
import 'asset_providers.dart';
import 'widgets/asset_card.dart';
import 'widgets/asset_filter_sheet.dart';

class AssetListScreen extends ConsumerStatefulWidget {
  const AssetListScreen({super.key});

  @override
  ConsumerState<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends ConsumerState<AssetListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(assetListNotifierProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(assetListNotifierProvider.notifier).search(query);
    });
  }

  void _showFilterSheet() {
    final currentState = ref.read(assetListNotifierProvider).valueOrNull;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AssetFilterSheet(
        currentStatus: currentState?.statusFilter,
        currentCategoryId: currentState?.categoryFilter,
        onApply: (status, categoryId) {
          ref.read(assetListNotifierProvider.notifier).setStatusFilter(status);
          if (categoryId != currentState?.categoryFilter) {
            ref
                .read(assetListNotifierProvider.notifier)
                .setCategoryFilter(categoryId);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(assetListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '장비명, 코드 검색...',
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
              )
            : const Text('장비 관리'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(assetListNotifierProvider.notifier).search(null);
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: asyncState.when(
        data: (state) => _buildList(state),
        loading: () => const LoadingIndicator(message: '장비 목록을 불러오는 중...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.read(assetListNotifierProvider.notifier).refresh(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/assets/new'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildList(AssetListState state) {
    if (state.assets.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        title: '등록된 장비가 없습니다',
        description: '새 장비를 등록해보세요.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(assetListNotifierProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.assets.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.assets.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final asset = state.assets[index];
          return AssetCard(
            asset: asset,
            onTap: () => context.push('/assets/${asset.assetId}'),
          );
        },
      ),
    );
  }
}

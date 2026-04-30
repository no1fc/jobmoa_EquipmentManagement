import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import 'rental_list_notifier.dart';
import 'rental_providers.dart';
import 'widgets/rental_card.dart';
import 'widgets/rental_filter_sheet.dart';

class RentalListScreen extends ConsumerStatefulWidget {
  const RentalListScreen({super.key});

  @override
  ConsumerState<RentalListScreen> createState() => _RentalListScreenState();
}

class _RentalListScreenState extends ConsumerState<RentalListScreen> {
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
      ref.read(rentalListNotifierProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(rentalListNotifierProvider.notifier).search(query);
    });
  }

  void _showFilterSheet() {
    final currentState = ref.read(rentalListNotifierProvider).valueOrNull;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => RentalFilterSheet(
        currentStatus: currentState?.statusFilter,
        onApply: (status) {
          ref.read(rentalListNotifierProvider.notifier).setStatusFilter(status);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(rentalListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '장비명, 대여자 검색...',
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
              )
            : const Text('대여 관리'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(rentalListNotifierProvider.notifier).search(null);
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
        loading: () => const LoadingIndicator(message: '대여 목록을 불러오는 중...'),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () =>
              ref.read(rentalListNotifierProvider.notifier).refresh(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/rentals/new'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildList(RentalListState state) {
    if (state.rentals.isEmpty) {
      return const EmptyState(
        icon: Icons.swap_horiz_outlined,
        title: '대여 기록이 없습니다',
        description: '새 대여를 등록해보세요.',
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(rentalListNotifierProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.rentals.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.rentals.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final rental = state.rentals[index];
          return RentalCard(
            rental: rental,
            onTap: () => context.push('/rentals/${rental.rentalId}'),
          );
        },
      ),
    );
  }
}

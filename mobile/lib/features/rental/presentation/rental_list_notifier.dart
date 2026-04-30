import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/rental.dart';
import '../data/models/rental_status.dart';
import '../domain/rental_repository.dart';
import 'rental_providers.dart';

class RentalListState {
  final List<Rental> rentals;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final RentalStatus? statusFilter;
  final String? searchQuery;

  const RentalListState({
    this.rentals = const [],
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.statusFilter,
    this.searchQuery,
  });

  RentalListState copyWith({
    List<Rental>? rentals,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    RentalStatus? Function()? statusFilter,
    String? Function()? searchQuery,
  }) {
    return RentalListState(
      rentals: rentals ?? this.rentals,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      statusFilter:
          statusFilter != null ? statusFilter() : this.statusFilter,
      searchQuery:
          searchQuery != null ? searchQuery() : this.searchQuery,
    );
  }
}

class RentalListNotifier extends AsyncNotifier<RentalListState> {
  late final RentalRepository _repository;

  static const int _pageSize = 20;

  @override
  Future<RentalListState> build() async {
    _repository = ref.watch(rentalRepositoryProvider);
    return _fetchPage(0);
  }

  Future<RentalListState> _fetchPage(int page,
      {RentalListState? current}) async {
    final pageResponse = await _repository.getRentals(
      status: (current ?? state.valueOrNull)?.statusFilter?.value,
      search: (current ?? state.valueOrNull)?.searchQuery,
      page: page,
      size: _pageSize,
      sort: 'rentalDate,desc',
    );

    final existingRentals =
        page > 0 ? (current ?? state.valueOrNull)?.rentals ?? [] : <Rental>[];

    return RentalListState(
      rentals: [...existingRentals, ...pageResponse.content],
      currentPage: page,
      hasMore: !pageResponse.last,
      isLoadingMore: false,
      statusFilter: (current ?? state.valueOrNull)?.statusFilter,
      searchQuery: (current ?? state.valueOrNull)?.searchQuery,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.valueOrNull;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
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

  Future<void> setStatusFilter(RentalStatus? status) async {
    final newState = RentalListState(
      statusFilter: status,
      searchQuery: state.valueOrNull?.searchQuery,
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(0, current: newState));
  }

  Future<void> search(String? query) async {
    final trimmed = query?.trim();
    final effectiveQuery =
        (trimmed != null && trimmed.isEmpty) ? null : trimmed;

    final newState = RentalListState(
      statusFilter: state.valueOrNull?.statusFilter,
      searchQuery: effectiveQuery,
    );
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPage(0, current: newState));
  }

  void removeRentalFromList(int rentalId) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        rentals: currentState.rentals
            .where((r) => r.rentalId != rentalId)
            .toList(),
      ),
    );
  }

  void updateRentalInList(Rental updated) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(
        rentals: currentState.rentals
            .map((r) => r.rentalId == updated.rentalId ? updated : r)
            .toList(),
      ),
    );
  }
}

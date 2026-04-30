import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/providers.dart';
import '../data/models/rental.dart';
import '../data/models/rental_dashboard.dart';
import '../data/rental_repository_impl.dart';
import '../domain/rental_repository.dart';
import 'rental_detail_notifier.dart';
import 'rental_list_notifier.dart';

final rentalRepositoryProvider = Provider<RentalRepository>((ref) {
  return RentalRepositoryImpl(apiClient: ref.watch(apiClientProvider));
});

final rentalListNotifierProvider =
    AsyncNotifierProvider<RentalListNotifier, RentalListState>(
  RentalListNotifier.new,
);

final rentalDetailNotifierProvider =
    AsyncNotifierProvider.family<RentalDetailNotifier, Rental, int>(
  RentalDetailNotifier.new,
);

final rentalDashboardProvider = FutureProvider<RentalDashboard>((ref) {
  final repo = ref.watch(rentalRepositoryProvider);
  return repo.getDashboard();
});

final overdueRentalsProvider = FutureProvider<List<Rental>>((ref) {
  final repo = ref.watch(rentalRepositoryProvider);
  return repo.getOverdueRentals();
});

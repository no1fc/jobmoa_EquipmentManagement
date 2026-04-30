import '../../../shared/models/api_response.dart';
import '../data/models/rental.dart';
import '../data/models/rental_create_request.dart';
import '../data/models/rental_dashboard.dart';
import '../data/models/rental_extend_request.dart';
import '../data/models/rental_return_request.dart';

abstract interface class RentalRepository {
  Future<PageResponse<Rental>> getRentals({
    String? status,
    String? search,
    int page = 0,
    int size = 20,
    String? sort,
  });

  Future<Rental> getRental(int id);

  Future<Rental> createRental(RentalCreateRequest request);

  Future<Rental> returnRental(int id, RentalReturnRequest request);

  Future<Rental> extendRental(int id, RentalExtendRequest request);

  Future<Rental> cancelRental(int id);

  Future<RentalDashboard> getDashboard();

  Future<List<Rental>> getOverdueRentals();

  Future<List<Rental>> getRentalHistory(int assetId);
}

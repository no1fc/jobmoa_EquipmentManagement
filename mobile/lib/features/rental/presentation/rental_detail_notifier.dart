import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/rental.dart';
import '../data/models/rental_extend_request.dart';
import '../data/models/rental_return_request.dart';
import '../domain/rental_repository.dart';
import 'rental_providers.dart';

class RentalDetailNotifier extends FamilyAsyncNotifier<Rental, int> {
  late final RentalRepository _repository;

  @override
  Future<Rental> build(int arg) async {
    _repository = ref.watch(rentalRepositoryProvider);
    return _repository.getRental(arg);
  }

  Future<Rental> returnRental({String? returnCondition}) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await _repository.returnRental(
        arg,
        RentalReturnRequest(returnCondition: returnCondition),
      );
      return _repository.getRental(arg);
    });
    state = result;
    return result.requireValue;
  }

  Future<Rental> extendRental(int extensionDays) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await _repository.extendRental(
        arg,
        RentalExtendRequest(extensionDays: extensionDays),
      );
      return _repository.getRental(arg);
    });
    state = result;
    return result.requireValue;
  }

  Future<Rental> cancelRental() async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      await _repository.cancelRental(arg);
      return _repository.getRental(arg);
    });
    state = result;
    return result.requireValue;
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getRental(arg));
  }
}

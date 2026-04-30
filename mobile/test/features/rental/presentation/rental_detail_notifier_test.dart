import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:equipment_management/features/rental/data/models/rental.dart';
import 'package:equipment_management/features/rental/data/models/rental_extend_request.dart';
import 'package:equipment_management/features/rental/data/models/rental_return_request.dart';
import 'package:equipment_management/features/rental/data/models/rental_status.dart';
import 'package:equipment_management/features/rental/domain/rental_repository.dart';
import 'package:equipment_management/features/rental/presentation/rental_providers.dart';

class MockRentalRepository extends Mock implements RentalRepository {}

void main() {
  late MockRentalRepository mockRepository;
  late ProviderContainer container;

  final now = DateTime.now();
  final testRental = Rental(
    rentalId: 1,
    assetId: 10,
    assetName: '노트북',
    assetCode: 'AST-202601-0001',
    borrowerId: 2,
    borrowerEmail: 'user@jobmoa.kr',
    borrowerName: '홍길동',
    rentalDate: now.subtract(const Duration(days: 5)),
    dueDate: now.add(const Duration(days: 5)),
    status: RentalStatus.rented,
    extensionCount: 0,
  );

  setUp(() {
    mockRepository = MockRentalRepository();
    container = ProviderContainer(
      overrides: [
        rentalRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );

    registerFallbackValue(const RentalReturnRequest());
    registerFallbackValue(const RentalExtendRequest(extensionDays: 7));
  });

  tearDown(() {
    container.dispose();
  });

  group('RentalDetailNotifier', () {
    test('build loads rental by id', () async {
      when(() => mockRepository.getRental(1))
          .thenAnswer((_) async => testRental);

      final result =
          await container.read(rentalDetailNotifierProvider(1).future);

      expect(result.rentalId, 1);
      expect(result.assetName, '노트북');
      expect(result.status, RentalStatus.rented);
    });

    test('returnRental updates status to returned', () async {
      when(() => mockRepository.getRental(1))
          .thenAnswer((_) async => testRental);

      await container.read(rentalDetailNotifierProvider(1).future);

      final returnedRental = Rental(
        rentalId: 1,
        assetId: 10,
        assetName: '노트북',
        assetCode: 'AST-202601-0001',
        borrowerId: 2,
        borrowerEmail: 'user@jobmoa.kr',
        borrowerName: '홍길동',
        rentalDate: now.subtract(const Duration(days: 5)),
        dueDate: now.add(const Duration(days: 5)),
        returnDate: now,
        status: RentalStatus.returned,
        extensionCount: 0,
        returnCondition: '양호',
      );

      when(() => mockRepository.returnRental(1, any()))
          .thenAnswer((_) async => returnedRental);
      when(() => mockRepository.getRental(1))
          .thenAnswer((_) async => returnedRental);

      final result = await container
          .read(rentalDetailNotifierProvider(1).notifier)
          .returnRental(returnCondition: '양호');

      expect(result.status, RentalStatus.returned);
      expect(result.returnCondition, '양호');
    });

    test('extendRental updates due date', () async {
      when(() => mockRepository.getRental(1))
          .thenAnswer((_) async => testRental);

      await container.read(rentalDetailNotifierProvider(1).future);

      final extendedRental = Rental(
        rentalId: 1,
        assetId: 10,
        assetName: '노트북',
        assetCode: 'AST-202601-0001',
        borrowerId: 2,
        borrowerEmail: 'user@jobmoa.kr',
        borrowerName: '홍길동',
        rentalDate: now.subtract(const Duration(days: 5)),
        dueDate: now.add(const Duration(days: 12)),
        status: RentalStatus.rented,
        extensionCount: 1,
      );

      when(() => mockRepository.extendRental(1, any()))
          .thenAnswer((_) async => extendedRental);
      when(() => mockRepository.getRental(1))
          .thenAnswer((_) async => extendedRental);

      final result = await container
          .read(rentalDetailNotifierProvider(1).notifier)
          .extendRental(7);

      expect(result.extensionCount, 1);
    });
  });
}

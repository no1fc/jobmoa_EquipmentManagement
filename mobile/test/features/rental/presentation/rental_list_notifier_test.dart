import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:equipment_management/features/rental/data/models/rental.dart';
import 'package:equipment_management/features/rental/data/models/rental_status.dart';
import 'package:equipment_management/features/rental/domain/rental_repository.dart';
import 'package:equipment_management/features/rental/presentation/rental_providers.dart';
import 'package:equipment_management/shared/models/api_response.dart';

class MockRentalRepository extends Mock implements RentalRepository {}

void main() {
  late MockRentalRepository mockRepository;
  late ProviderContainer container;

  final now = DateTime.now();
  final testRentals = List.generate(
    3,
    (i) => Rental(
      rentalId: i + 1,
      assetId: i + 10,
      assetName: '장비 ${i + 1}',
      assetCode: 'AST-202601-000${i + 1}',
      borrowerId: i + 2,
      borrowerEmail: 'user${i + 1}@jobmoa.kr',
      borrowerName: '사용자 ${i + 1}',
      rentalDate: now.subtract(const Duration(days: 5)),
      dueDate: now.add(const Duration(days: 5)),
      status: RentalStatus.rented,
      extensionCount: 0,
    ),
  );

  PageResponse<Rental> createPageResponse({
    List<Rental>? content,
    bool last = true,
    int page = 0,
  }) {
    return PageResponse(
      content: content ?? testRentals,
      page: page,
      size: 20,
      totalElements: content?.length ?? testRentals.length,
      totalPages: 1,
      last: last,
    );
  }

  setUp(() {
    mockRepository = MockRentalRepository();
    container = ProviderContainer(
      overrides: [
        rentalRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('RentalListNotifier', () {
    test('initial build loads first page of rentals', () async {
      when(() => mockRepository.getRentals(
            status: any(named: 'status'),
            search: any(named: 'search'),
            page: 0,
            size: 20,
            sort: 'rentalDate,desc',
          )).thenAnswer((_) async => createPageResponse());

      final state = await container.read(rentalListNotifierProvider.future);

      expect(state.rentals, hasLength(3));
      expect(state.currentPage, 0);
      expect(state.hasMore, false);
      expect(state.isLoadingMore, false);
    });

    test('loadMore appends next page', () async {
      when(() => mockRepository.getRentals(
            status: any(named: 'status'),
            search: any(named: 'search'),
            page: 0,
            size: 20,
            sort: 'rentalDate,desc',
          )).thenAnswer((_) async => createPageResponse(last: false));

      await container.read(rentalListNotifierProvider.future);

      final moreRentals = [
        Rental(
          rentalId: 4,
          assetId: 14,
          assetName: '장비 4',
          assetCode: 'AST-202601-0004',
          borrowerId: 5,
          borrowerEmail: 'user4@jobmoa.kr',
          borrowerName: '사용자 4',
          rentalDate: now,
          dueDate: now.add(const Duration(days: 14)),
          status: RentalStatus.rented,
          extensionCount: 0,
        ),
      ];

      when(() => mockRepository.getRentals(
            status: any(named: 'status'),
            search: any(named: 'search'),
            page: 1,
            size: 20,
            sort: 'rentalDate,desc',
          )).thenAnswer((_) async => createPageResponse(
            content: moreRentals,
            page: 1,
            last: true,
          ));

      await container
          .read(rentalListNotifierProvider.notifier)
          .loadMore();

      final state = container.read(rentalListNotifierProvider).value!;
      expect(state.rentals, hasLength(4));
      expect(state.currentPage, 1);
      expect(state.hasMore, false);
    });

    test('setStatusFilter reloads with filter', () async {
      when(() => mockRepository.getRentals(
            status: any(named: 'status'),
            search: any(named: 'search'),
            page: 0,
            size: 20,
            sort: 'rentalDate,desc',
          )).thenAnswer((_) async => createPageResponse());

      await container.read(rentalListNotifierProvider.future);

      when(() => mockRepository.getRentals(
            status: 'OVERDUE',
            search: any(named: 'search'),
            page: 0,
            size: 20,
            sort: 'rentalDate,desc',
          )).thenAnswer(
        (_) async => createPageResponse(content: [testRentals[0]]),
      );

      await container
          .read(rentalListNotifierProvider.notifier)
          .setStatusFilter(RentalStatus.overdue);

      final state = container.read(rentalListNotifierProvider).value!;
      expect(state.rentals, hasLength(1));
      expect(state.statusFilter, RentalStatus.overdue);
    });

    test('search reloads with search query', () async {
      when(() => mockRepository.getRentals(
            status: any(named: 'status'),
            search: any(named: 'search'),
            page: 0,
            size: 20,
            sort: 'rentalDate,desc',
          )).thenAnswer((_) async => createPageResponse());

      await container.read(rentalListNotifierProvider.future);

      when(() => mockRepository.getRentals(
            status: any(named: 'status'),
            search: '노트북',
            page: 0,
            size: 20,
            sort: 'rentalDate,desc',
          )).thenAnswer(
        (_) async => createPageResponse(content: [testRentals[0]]),
      );

      await container
          .read(rentalListNotifierProvider.notifier)
          .search('노트북');

      final state = container.read(rentalListNotifierProvider).value!;
      expect(state.searchQuery, '노트북');
    });

    test('removeRentalFromList removes rental locally', () async {
      when(() => mockRepository.getRentals(
            status: any(named: 'status'),
            search: any(named: 'search'),
            page: 0,
            size: 20,
            sort: 'rentalDate,desc',
          )).thenAnswer((_) async => createPageResponse());

      await container.read(rentalListNotifierProvider.future);

      container
          .read(rentalListNotifierProvider.notifier)
          .removeRentalFromList(1);

      final state = container.read(rentalListNotifierProvider).value!;
      expect(state.rentals, hasLength(2));
      expect(state.rentals.any((r) => r.rentalId == 1), false);
    });

    test('updateRentalInList updates rental locally', () async {
      when(() => mockRepository.getRentals(
            status: any(named: 'status'),
            search: any(named: 'search'),
            page: 0,
            size: 20,
            sort: 'rentalDate,desc',
          )).thenAnswer((_) async => createPageResponse());

      await container.read(rentalListNotifierProvider.future);

      final updatedRental = Rental(
        rentalId: 1,
        assetId: 10,
        assetName: '장비 1',
        assetCode: 'AST-202601-0001',
        borrowerId: 2,
        borrowerEmail: 'user1@jobmoa.kr',
        borrowerName: '사용자 1',
        rentalDate: now.subtract(const Duration(days: 5)),
        dueDate: now.add(const Duration(days: 5)),
        returnDate: now,
        status: RentalStatus.returned,
        extensionCount: 0,
      );

      container
          .read(rentalListNotifierProvider.notifier)
          .updateRentalInList(updatedRental);

      final state = container.read(rentalListNotifierProvider).value!;
      final rental = state.rentals.firstWhere((r) => r.rentalId == 1);
      expect(rental.status, RentalStatus.returned);
    });

    test('refresh reloads from page 0', () async {
      var callCount = 0;
      when(() => mockRepository.getRentals(
            status: any(named: 'status'),
            search: any(named: 'search'),
            page: 0,
            size: 20,
            sort: 'rentalDate,desc',
          )).thenAnswer((_) async {
        callCount++;
        return createPageResponse();
      });

      await container.read(rentalListNotifierProvider.future);
      await container
          .read(rentalListNotifierProvider.notifier)
          .refresh();

      expect(callCount, 2);
    });
  });
}

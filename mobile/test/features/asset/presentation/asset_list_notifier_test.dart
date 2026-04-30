import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:equipment_management/features/asset/data/models/asset.dart';
import 'package:equipment_management/features/asset/data/models/asset_status.dart';
import 'package:equipment_management/features/asset/domain/asset_repository.dart';
import 'package:equipment_management/features/asset/presentation/asset_providers.dart';
import 'package:equipment_management/shared/models/api_response.dart';

class MockAssetRepository extends Mock implements AssetRepository {}

void main() {
  late MockAssetRepository mockRepository;
  late ProviderContainer container;

  final testAssets = List.generate(
    3,
    (i) => Asset(
      assetId: i + 1,
      assetCode: 'AST-202601-000${i + 1}',
      assetName: '장비 ${i + 1}',
      status: AssetStatus.inUse,
      categoryName: '노트북',
      categoryId: 5,
      aiClassified: false,
      createdAt: DateTime(2026, 1, 15),
    ),
  );

  PageResponse<Asset> createPageResponse({
    List<Asset>? content,
    bool last = true,
    int page = 0,
  }) {
    return PageResponse(
      content: content ?? testAssets,
      page: page,
      size: 20,
      totalElements: content?.length ?? testAssets.length,
      totalPages: 1,
      last: last,
    );
  }

  setUp(() {
    mockRepository = MockAssetRepository();
    container = ProviderContainer(
      overrides: [
        assetRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AssetListNotifier', () {
    test('initial build loads first page of assets', () async {
      when(() => mockRepository.getAssets(
            status: any(named: 'status'),
            categoryId: any(named: 'categoryId'),
            search: any(named: 'search'),
            page: 0,
            size: 20,
            sort: 'createdAt,desc',
          )).thenAnswer((_) async => createPageResponse());

      final state = await container.read(assetListNotifierProvider.future);

      expect(state.assets, hasLength(3));
      expect(state.currentPage, 0);
      expect(state.hasMore, false);
      expect(state.isLoadingMore, false);
    });

    test('loadMore appends next page', () async {
      when(() => mockRepository.getAssets(
            status: any(named: 'status'),
            categoryId: any(named: 'categoryId'),
            search: any(named: 'search'),
            page: 0,
            size: 20,
            sort: 'createdAt,desc',
          )).thenAnswer((_) async => createPageResponse(last: false));

      await container.read(assetListNotifierProvider.future);

      final moreAssets = [
        Asset(
          assetId: 4,
          assetCode: 'AST-202601-0004',
          assetName: '장비 4',
          status: AssetStatus.rented,
          categoryName: '모니터',
          categoryId: 6,
          aiClassified: false,
          createdAt: DateTime(2026, 2, 1),
        ),
      ];

      when(() => mockRepository.getAssets(
            status: any(named: 'status'),
            categoryId: any(named: 'categoryId'),
            search: any(named: 'search'),
            page: 1,
            size: 20,
            sort: 'createdAt,desc',
          )).thenAnswer((_) async => createPageResponse(
            content: moreAssets,
            page: 1,
            last: true,
          ));

      await container
          .read(assetListNotifierProvider.notifier)
          .loadMore();

      final state = container.read(assetListNotifierProvider).value!;
      expect(state.assets, hasLength(4));
      expect(state.currentPage, 1);
      expect(state.hasMore, false);
    });

    test('setStatusFilter reloads with filter', () async {
      when(() => mockRepository.getAssets(
            status: any(named: 'status'),
            categoryId: any(named: 'categoryId'),
            search: any(named: 'search'),
            page: 0,
            size: 20,
            sort: 'createdAt,desc',
          )).thenAnswer((_) async => createPageResponse());

      await container.read(assetListNotifierProvider.future);

      final filteredAssets = [testAssets[0]];
      when(() => mockRepository.getAssets(
            status: 'IN_USE',
            categoryId: any(named: 'categoryId'),
            search: any(named: 'search'),
            page: 0,
            size: 20,
            sort: 'createdAt,desc',
          )).thenAnswer(
        (_) async => createPageResponse(content: filteredAssets),
      );

      await container
          .read(assetListNotifierProvider.notifier)
          .setStatusFilter(AssetStatus.inUse);

      final state = container.read(assetListNotifierProvider).value!;
      expect(state.assets, hasLength(1));
      expect(state.statusFilter, AssetStatus.inUse);
    });

    test('search reloads with search query', () async {
      when(() => mockRepository.getAssets(
            status: any(named: 'status'),
            categoryId: any(named: 'categoryId'),
            search: any(named: 'search'),
            page: 0,
            size: 20,
            sort: 'createdAt,desc',
          )).thenAnswer((_) async => createPageResponse());

      await container.read(assetListNotifierProvider.future);

      when(() => mockRepository.getAssets(
            status: any(named: 'status'),
            categoryId: any(named: 'categoryId'),
            search: '노트북',
            page: 0,
            size: 20,
            sort: 'createdAt,desc',
          )).thenAnswer(
        (_) async => createPageResponse(content: [testAssets[0]]),
      );

      await container
          .read(assetListNotifierProvider.notifier)
          .search('노트북');

      final state = container.read(assetListNotifierProvider).value!;
      expect(state.searchQuery, '노트북');
    });

    test('removeAssetFromList removes asset locally', () async {
      when(() => mockRepository.getAssets(
            status: any(named: 'status'),
            categoryId: any(named: 'categoryId'),
            search: any(named: 'search'),
            page: 0,
            size: 20,
            sort: 'createdAt,desc',
          )).thenAnswer((_) async => createPageResponse());

      await container.read(assetListNotifierProvider.future);

      container
          .read(assetListNotifierProvider.notifier)
          .removeAssetFromList(1);

      final state = container.read(assetListNotifierProvider).value!;
      expect(state.assets, hasLength(2));
      expect(state.assets.any((a) => a.assetId == 1), false);
    });

    test('refresh reloads from page 0', () async {
      var callCount = 0;
      when(() => mockRepository.getAssets(
            status: any(named: 'status'),
            categoryId: any(named: 'categoryId'),
            search: any(named: 'search'),
            page: 0,
            size: 20,
            sort: 'createdAt,desc',
          )).thenAnswer((_) async {
        callCount++;
        return createPageResponse();
      });

      await container.read(assetListNotifierProvider.future);
      await container
          .read(assetListNotifierProvider.notifier)
          .refresh();

      expect(callCount, 2);
    });
  });
}

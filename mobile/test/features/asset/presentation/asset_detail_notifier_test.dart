import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:equipment_management/features/asset/data/models/asset.dart';
import 'package:equipment_management/features/asset/data/models/asset_detail.dart';
import 'package:equipment_management/features/asset/data/models/asset_status.dart';
import 'package:equipment_management/features/asset/data/models/asset_status_request.dart';
import 'package:equipment_management/features/asset/domain/asset_repository.dart';
import 'package:equipment_management/features/asset/presentation/asset_providers.dart';

class MockAssetRepository extends Mock implements AssetRepository {}

void main() {
  late MockAssetRepository mockRepository;
  late ProviderContainer container;

  final testDetail = AssetDetail(
    assetId: 1,
    assetCode: 'AST-202601-0001',
    assetName: '노트북',
    status: AssetStatus.inUse,
    categoryId: 5,
    categoryName: '노트북',
    categoryPath: const ['IT장비', '컴퓨터', '노트북'],
    registeredByName: '관리자',
    aiClassified: false,
    createdAt: DateTime(2026, 1, 15),
    updatedAt: DateTime(2026, 1, 20),
  );

  setUp(() {
    mockRepository = MockAssetRepository();
    container = ProviderContainer(
      overrides: [
        assetRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  setUpAll(() {
    registerFallbackValue(const AssetStatusRequest(status: 'IN_USE'));
  });

  tearDown(() {
    container.dispose();
  });

  group('AssetDetailNotifier', () {
    test('build fetches asset detail by id', () async {
      when(() => mockRepository.getAsset(1))
          .thenAnswer((_) async => testDetail);

      final result = await container
          .read(assetDetailNotifierProvider(1).future);

      expect(result.assetId, 1);
      expect(result.assetName, '노트북');
      expect(result.categoryPath, ['IT장비', '컴퓨터', '노트북']);
    });

    test('updateStatus changes status and refreshes', () async {
      when(() => mockRepository.getAsset(1))
          .thenAnswer((_) async => testDetail);

      await container.read(assetDetailNotifierProvider(1).future);

      final updatedDetail = AssetDetail(
        assetId: 1,
        assetCode: 'AST-202601-0001',
        assetName: '노트북',
        status: AssetStatus.broken,
        categoryId: 5,
        categoryName: '노트북',
        categoryPath: const ['IT장비', '컴퓨터', '노트북'],
        registeredByName: '관리자',
        aiClassified: false,
        createdAt: DateTime(2026, 1, 15),
        updatedAt: DateTime(2026, 1, 25),
      );

      when(() => mockRepository.updateAssetStatus(1, any()))
          .thenAnswer((_) async => Asset(
                assetId: 1,
                assetCode: 'AST-202601-0001',
                assetName: '노트북',
                status: AssetStatus.broken,
                categoryName: '노트북',
                categoryId: 5,
                aiClassified: false,
                createdAt: DateTime(2026, 1, 15),
              ));
      when(() => mockRepository.getAsset(1))
          .thenAnswer((_) async => updatedDetail);

      await container
          .read(assetDetailNotifierProvider(1).notifier)
          .updateStatus('BROKEN');

      final state = container.read(assetDetailNotifierProvider(1)).value!;
      expect(state.status, AssetStatus.broken);
    });

    test('deleteAsset calls repository delete', () async {
      when(() => mockRepository.getAsset(1))
          .thenAnswer((_) async => testDetail);
      when(() => mockRepository.deleteAsset(1))
          .thenAnswer((_) async {});

      await container.read(assetDetailNotifierProvider(1).future);

      await container
          .read(assetDetailNotifierProvider(1).notifier)
          .deleteAsset();

      verify(() => mockRepository.deleteAsset(1)).called(1);
    });
  });
}

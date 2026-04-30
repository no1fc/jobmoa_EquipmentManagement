import 'package:flutter_test/flutter_test.dart';
import 'package:equipment_management/features/asset/data/models/asset.dart';
import 'package:equipment_management/features/asset/data/models/asset_status.dart';

void main() {
  group('AssetStatus', () {
    test('fromValue returns correct enum for valid values', () {
      expect(AssetStatus.fromValue('IN_USE'), AssetStatus.inUse);
      expect(AssetStatus.fromValue('RENTED'), AssetStatus.rented);
      expect(AssetStatus.fromValue('BROKEN'), AssetStatus.broken);
      expect(AssetStatus.fromValue('IN_STORAGE'), AssetStatus.inStorage);
      expect(AssetStatus.fromValue('DISPOSED'), AssetStatus.disposed);
    });

    test('fromValue returns inUse for unknown value', () {
      expect(AssetStatus.fromValue('UNKNOWN'), AssetStatus.inUse);
    });

    test('each status has correct label', () {
      expect(AssetStatus.inUse.label, '사용중');
      expect(AssetStatus.rented.label, '대여중');
      expect(AssetStatus.broken.label, '고장');
      expect(AssetStatus.inStorage.label, '보관중');
      expect(AssetStatus.disposed.label, '폐기');
    });
  });

  group('Asset', () {
    test('fromJson parses complete JSON correctly', () {
      final json = {
        'assetId': 1,
        'assetCode': 'AST-202601-0001',
        'assetName': '노트북',
        'status': 'IN_USE',
        'categoryName': '노트북',
        'categoryId': 5,
        'location': '본사 1층',
        'managingDepartment': 'IT팀',
        'usingDepartment': '상담팀',
        'manufacturer': 'Samsung',
        'modelNumber': 'NT950XCR',
        'purchaseDate': '2026-01-15',
        'imagePath': '/uploads/assets/img.jpg',
        'aiClassified': true,
        'createdAt': '2026-01-15T10:30:45',
      };

      final asset = Asset.fromJson(json);

      expect(asset.assetId, 1);
      expect(asset.assetCode, 'AST-202601-0001');
      expect(asset.assetName, '노트북');
      expect(asset.status, AssetStatus.inUse);
      expect(asset.categoryName, '노트북');
      expect(asset.categoryId, 5);
      expect(asset.location, '본사 1층');
      expect(asset.managingDepartment, 'IT팀');
      expect(asset.usingDepartment, '상담팀');
      expect(asset.manufacturer, 'Samsung');
      expect(asset.modelNumber, 'NT950XCR');
      expect(asset.purchaseDate, DateTime(2026, 1, 15));
      expect(asset.imagePath, '/uploads/assets/img.jpg');
      expect(asset.aiClassified, true);
      expect(asset.createdAt, DateTime(2026, 1, 15, 10, 30, 45));
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'assetId': 2,
        'assetCode': 'AST-202601-0002',
        'assetName': '모니터',
        'status': 'RENTED',
        'categoryName': '모니터',
        'categoryId': 6,
        'aiClassified': false,
        'createdAt': '2026-02-01T09:00:00',
      };

      final asset = Asset.fromJson(json);

      expect(asset.assetId, 2);
      expect(asset.status, AssetStatus.rented);
      expect(asset.location, isNull);
      expect(asset.managingDepartment, isNull);
      expect(asset.manufacturer, isNull);
      expect(asset.purchaseDate, isNull);
      expect(asset.imagePath, isNull);
    });

    test('fromJson defaults aiClassified to false when null', () {
      final json = {
        'assetId': 3,
        'assetCode': 'AST-202601-0003',
        'assetName': '키보드',
        'status': 'IN_STORAGE',
        'categoryName': '주변기기',
        'categoryId': 7,
        'createdAt': '2026-03-01T12:00:00',
      };

      final asset = Asset.fromJson(json);
      expect(asset.aiClassified, false);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:equipment_management/features/asset/data/models/asset_detail.dart';
import 'package:equipment_management/features/asset/data/models/asset_status.dart';

void main() {
  group('AssetDetail', () {
    test('fromJson parses complete JSON correctly', () {
      final json = {
        'assetId': 1,
        'assetCode': 'AST-202601-0001',
        'assetName': '노트북',
        'status': 'IN_USE',
        'categoryId': 5,
        'categoryName': '노트북',
        'categoryPath': ['IT장비', '컴퓨터', '노트북'],
        'serialNumber': 'SN-12345',
        'manufacturer': 'Samsung',
        'modelNumber': 'NT950XCR',
        'purchaseDate': '2026-01-15',
        'location': '본사 1층',
        'managingDepartment': 'IT팀',
        'usingDepartment': '상담팀',
        'conditionRating': 4,
        'technicalSpecs': '{"cpu":"i7","ram":"16GB"}',
        'imagePath': '/uploads/assets/img.jpg',
        'aiClassified': true,
        'notes': '테스트 장비',
        'registeredByName': '관리자',
        'createdAt': '2026-01-15T10:30:45',
        'updatedAt': '2026-01-20T14:00:00',
      };

      final detail = AssetDetail.fromJson(json);

      expect(detail.assetId, 1);
      expect(detail.assetCode, 'AST-202601-0001');
      expect(detail.status, AssetStatus.inUse);
      expect(detail.categoryPath, ['IT장비', '컴퓨터', '노트북']);
      expect(detail.serialNumber, 'SN-12345');
      expect(detail.conditionRating, 4);
      expect(detail.technicalSpecs, '{"cpu":"i7","ram":"16GB"}');
      expect(detail.notes, '테스트 장비');
      expect(detail.registeredByName, '관리자');
      expect(detail.updatedAt, DateTime(2026, 1, 20, 14, 0, 0));
    });

    test('fromJson handles null categoryPath', () {
      final json = {
        'assetId': 2,
        'assetCode': 'AST-202601-0002',
        'assetName': '모니터',
        'status': 'RENTED',
        'categoryId': 6,
        'categoryName': '모니터',
        'registeredByName': '관리자',
        'createdAt': '2026-02-01T09:00:00',
        'updatedAt': '2026-02-01T09:00:00',
      };

      final detail = AssetDetail.fromJson(json);
      expect(detail.categoryPath, isEmpty);
      expect(detail.serialNumber, isNull);
      expect(detail.conditionRating, isNull);
    });
  });
}

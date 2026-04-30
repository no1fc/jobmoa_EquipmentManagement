import 'package:flutter_test/flutter_test.dart';
import 'package:equipment_management/features/asset/data/models/asset_create_request.dart';
import 'package:equipment_management/features/asset/data/models/asset_status_request.dart';
import 'package:equipment_management/features/asset/data/models/asset_summary.dart';
import 'package:equipment_management/features/asset/data/models/asset_update_request.dart';

void main() {
  group('AssetCreateRequest', () {
    test('toJson includes only non-null fields', () {
      const request = AssetCreateRequest(
        categoryId: 5,
        assetName: '노트북',
        manufacturer: 'Samsung',
      );

      final json = request.toJson();

      expect(json['categoryId'], 5);
      expect(json['assetName'], '노트북');
      expect(json['manufacturer'], 'Samsung');
      expect(json.containsKey('serialNumber'), false);
      expect(json.containsKey('location'), false);
    });

    test('toJson includes all fields when provided', () {
      const request = AssetCreateRequest(
        categoryId: 5,
        assetName: '노트북',
        serialNumber: 'SN-123',
        manufacturer: 'Samsung',
        modelNumber: 'NT950',
        purchaseDate: '2026-01-15',
        location: '본사',
        managingDepartment: 'IT팀',
        usingDepartment: '상담팀',
        conditionRating: 4,
        technicalSpecs: 'specs',
        aiClassified: true,
        notes: '메모',
      );

      final json = request.toJson();
      expect(json, hasLength(13));
    });
  });

  group('AssetUpdateRequest', () {
    test('toJson excludes aiClassified', () {
      const request = AssetUpdateRequest(
        categoryId: 5,
        assetName: '노트북',
      );

      final json = request.toJson();
      expect(json.containsKey('aiClassified'), false);
    });
  });

  group('AssetStatusRequest', () {
    test('toJson returns status', () {
      const request = AssetStatusRequest(status: 'IN_USE');
      expect(request.toJson(), {'status': 'IN_USE'});
    });
  });

  group('AssetSummary', () {
    test('fromJson parses correctly', () {
      final json = {
        'total': 100,
        'inUse': 50,
        'rented': 20,
        'broken': 5,
        'inStorage': 20,
        'disposed': 5,
      };

      final summary = AssetSummary.fromJson(json);

      expect(summary.total, 100);
      expect(summary.inUse, 50);
      expect(summary.rented, 20);
      expect(summary.broken, 5);
      expect(summary.inStorage, 20);
      expect(summary.disposed, 5);
    });
  });
}

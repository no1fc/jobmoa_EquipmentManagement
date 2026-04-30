import 'package:flutter_test/flutter_test.dart';
import 'package:equipment_management/features/rental/data/models/rental_create_request.dart';
import 'package:equipment_management/features/rental/data/models/rental_return_request.dart';
import 'package:equipment_management/features/rental/data/models/rental_extend_request.dart';
import 'package:equipment_management/features/rental/data/models/rental_dashboard.dart';

void main() {
  group('RentalCreateRequest', () {
    test('toJson includes all fields when set', () {
      const request = RentalCreateRequest(
        assetId: 10,
        borrowerId: 2,
        borrowerName: '홍길동',
        rentalReason: '업무용',
        dueDays: 14,
      );

      final json = request.toJson();

      expect(json['assetId'], 10);
      expect(json['borrowerId'], 2);
      expect(json['borrowerName'], '홍길동');
      expect(json['rentalReason'], '업무용');
      expect(json['dueDays'], 14);
    });

    test('toJson excludes null optional fields', () {
      const request = RentalCreateRequest(
        assetId: 10,
        dueDays: 7,
      );

      final json = request.toJson();

      expect(json['assetId'], 10);
      expect(json['dueDays'], 7);
      expect(json.containsKey('borrowerId'), isFalse);
      expect(json.containsKey('borrowerName'), isFalse);
      expect(json.containsKey('rentalReason'), isFalse);
    });
  });

  group('RentalReturnRequest', () {
    test('toJson includes returnCondition when set', () {
      const request = RentalReturnRequest(returnCondition: '양호');
      final json = request.toJson();
      expect(json['returnCondition'], '양호');
    });

    test('toJson returns empty map when null', () {
      const request = RentalReturnRequest();
      final json = request.toJson();
      expect(json, isEmpty);
    });
  });

  group('RentalExtendRequest', () {
    test('toJson includes extensionDays', () {
      const request = RentalExtendRequest(extensionDays: 7);
      final json = request.toJson();
      expect(json['extensionDays'], 7);
    });
  });

  group('RentalDashboard', () {
    test('fromJson parses correctly', () {
      final json = {
        'totalActive': 15,
        'overdueCount': 3,
        'dueSoon': 5,
        'returnedToday': 2,
      };

      final dashboard = RentalDashboard.fromJson(json);

      expect(dashboard.totalActive, 15);
      expect(dashboard.overdueCount, 3);
      expect(dashboard.dueSoon, 5);
      expect(dashboard.returnedToday, 2);
    });
  });
}

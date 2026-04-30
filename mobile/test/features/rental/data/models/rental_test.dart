import 'package:flutter_test/flutter_test.dart';
import 'package:equipment_management/features/rental/data/models/rental.dart';
import 'package:equipment_management/features/rental/data/models/rental_status.dart';

void main() {
  group('RentalStatus', () {
    test('fromValue returns correct enum for valid values', () {
      expect(RentalStatus.fromValue('RENTED'), RentalStatus.rented);
      expect(RentalStatus.fromValue('RETURNED'), RentalStatus.returned);
      expect(RentalStatus.fromValue('OVERDUE'), RentalStatus.overdue);
      expect(RentalStatus.fromValue('CANCELLED'), RentalStatus.cancelled);
    });

    test('fromValue returns rented for unknown value', () {
      expect(RentalStatus.fromValue('UNKNOWN'), RentalStatus.rented);
    });

    test('each status has correct label', () {
      expect(RentalStatus.rented.label, '대여중');
      expect(RentalStatus.returned.label, '반납완료');
      expect(RentalStatus.overdue.label, '연체');
      expect(RentalStatus.cancelled.label, '취소');
    });
  });

  group('Rental', () {
    final now = DateTime.now();
    final pastDue = now.subtract(const Duration(days: 3));
    final futureDue = now.add(const Duration(days: 7));

    test('fromJson parses complete JSON correctly', () {
      final json = {
        'rentalId': 1,
        'assetId': 10,
        'assetName': '노트북',
        'assetCode': 'AST-202601-0001',
        'borrowerId': 2,
        'borrowerEmail': 'user@jobmoa.kr',
        'borrowerName': '홍길동',
        'rentalReason': '업무용',
        'rentalDate': '2026-04-20T10:00:00',
        'dueDate': '2026-04-30T10:00:00',
        'returnDate': '2026-04-28T15:00:00',
        'status': 'RETURNED',
        'extensionCount': 1,
        'returnCondition': '양호',
      };

      final rental = Rental.fromJson(json);

      expect(rental.rentalId, 1);
      expect(rental.assetId, 10);
      expect(rental.assetName, '노트북');
      expect(rental.assetCode, 'AST-202601-0001');
      expect(rental.borrowerId, 2);
      expect(rental.borrowerEmail, 'user@jobmoa.kr');
      expect(rental.borrowerName, '홍길동');
      expect(rental.rentalReason, '업무용');
      expect(rental.status, RentalStatus.returned);
      expect(rental.extensionCount, 1);
      expect(rental.returnCondition, '양호');
      expect(rental.returnDate, isNotNull);
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'rentalId': 2,
        'assetId': 11,
        'assetName': '모니터',
        'assetCode': 'AST-202601-0002',
        'borrowerId': 3,
        'borrowerEmail': 'test@jobmoa.kr',
        'borrowerName': '김철수',
        'rentalDate': '2026-04-25T09:00:00',
        'dueDate': '2026-05-05T09:00:00',
        'status': 'RENTED',
      };

      final rental = Rental.fromJson(json);

      expect(rental.rentalReason, isNull);
      expect(rental.returnDate, isNull);
      expect(rental.extensionCount, 0);
      expect(rental.returnCondition, isNull);
    });

    test('isOverdue returns true when past due and RENTED', () {
      final rental = Rental(
        rentalId: 1,
        assetId: 1,
        assetName: 'test',
        assetCode: 'test',
        borrowerId: 1,
        borrowerEmail: 'test@test.com',
        borrowerName: 'test',
        rentalDate: pastDue.subtract(const Duration(days: 7)),
        dueDate: pastDue,
        status: RentalStatus.rented,
        extensionCount: 0,
      );

      expect(rental.isOverdue, isTrue);
    });

    test('isOverdue returns false when due date is future', () {
      final rental = Rental(
        rentalId: 1,
        assetId: 1,
        assetName: 'test',
        assetCode: 'test',
        borrowerId: 1,
        borrowerEmail: 'test@test.com',
        borrowerName: 'test',
        rentalDate: now,
        dueDate: futureDue,
        status: RentalStatus.rented,
        extensionCount: 0,
      );

      expect(rental.isOverdue, isFalse);
    });

    test('canExtend returns true when rented and no extensions', () {
      final rental = Rental(
        rentalId: 1,
        assetId: 1,
        assetName: 'test',
        assetCode: 'test',
        borrowerId: 1,
        borrowerEmail: 'test@test.com',
        borrowerName: 'test',
        rentalDate: now,
        dueDate: futureDue,
        status: RentalStatus.rented,
        extensionCount: 0,
      );

      expect(rental.canExtend, isTrue);
    });

    test('canExtend returns false when already extended', () {
      final rental = Rental(
        rentalId: 1,
        assetId: 1,
        assetName: 'test',
        assetCode: 'test',
        borrowerId: 1,
        borrowerEmail: 'test@test.com',
        borrowerName: 'test',
        rentalDate: now,
        dueDate: futureDue,
        status: RentalStatus.rented,
        extensionCount: 1,
      );

      expect(rental.canExtend, isFalse);
    });

    test('canReturn returns true when rented or overdue', () {
      final rentedRental = Rental(
        rentalId: 1,
        assetId: 1,
        assetName: 'test',
        assetCode: 'test',
        borrowerId: 1,
        borrowerEmail: 'test@test.com',
        borrowerName: 'test',
        rentalDate: now,
        dueDate: futureDue,
        status: RentalStatus.rented,
        extensionCount: 0,
      );

      final overdueRental = Rental(
        rentalId: 2,
        assetId: 1,
        assetName: 'test',
        assetCode: 'test',
        borrowerId: 1,
        borrowerEmail: 'test@test.com',
        borrowerName: 'test',
        rentalDate: pastDue.subtract(const Duration(days: 7)),
        dueDate: pastDue,
        status: RentalStatus.overdue,
        extensionCount: 0,
      );

      expect(rentedRental.canReturn, isTrue);
      expect(overdueRental.canReturn, isTrue);
    });

    test('canReturn returns false when returned or cancelled', () {
      final returnedRental = Rental(
        rentalId: 1,
        assetId: 1,
        assetName: 'test',
        assetCode: 'test',
        borrowerId: 1,
        borrowerEmail: 'test@test.com',
        borrowerName: 'test',
        rentalDate: now,
        dueDate: futureDue,
        status: RentalStatus.returned,
        extensionCount: 0,
      );

      expect(returnedRental.canReturn, isFalse);
    });

    test('canCancel returns true only when rented', () {
      final rented = Rental(
        rentalId: 1,
        assetId: 1,
        assetName: 'test',
        assetCode: 'test',
        borrowerId: 1,
        borrowerEmail: 'test@test.com',
        borrowerName: 'test',
        rentalDate: now,
        dueDate: futureDue,
        status: RentalStatus.rented,
        extensionCount: 0,
      );

      final overdue = Rental(
        rentalId: 2,
        assetId: 1,
        assetName: 'test',
        assetCode: 'test',
        borrowerId: 1,
        borrowerEmail: 'test@test.com',
        borrowerName: 'test',
        rentalDate: now,
        dueDate: pastDue,
        status: RentalStatus.overdue,
        extensionCount: 0,
      );

      expect(rented.canCancel, isTrue);
      expect(overdue.canCancel, isFalse);
    });
  });
}

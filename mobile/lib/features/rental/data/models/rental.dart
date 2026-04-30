import 'rental_status.dart';

class Rental {
  final int rentalId;
  final int assetId;
  final String assetName;
  final String assetCode;
  final int borrowerId;
  final String borrowerEmail;
  final String borrowerName;
  final String? rentalReason;
  final DateTime rentalDate;
  final DateTime dueDate;
  final DateTime? returnDate;
  final RentalStatus status;
  final int extensionCount;
  final String? returnCondition;

  const Rental({
    required this.rentalId,
    required this.assetId,
    required this.assetName,
    required this.assetCode,
    required this.borrowerId,
    required this.borrowerEmail,
    required this.borrowerName,
    this.rentalReason,
    required this.rentalDate,
    required this.dueDate,
    this.returnDate,
    required this.status,
    required this.extensionCount,
    this.returnCondition,
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      rentalId: json['rentalId'] as int,
      assetId: json['assetId'] as int,
      assetName: json['assetName'] as String,
      assetCode: json['assetCode'] as String,
      borrowerId: json['borrowerId'] as int,
      borrowerEmail: json['borrowerEmail'] as String,
      borrowerName: json['borrowerName'] as String,
      rentalReason: json['rentalReason'] as String?,
      rentalDate: DateTime.parse(json['rentalDate'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      returnDate: json['returnDate'] != null
          ? DateTime.parse(json['returnDate'] as String)
          : null,
      status: RentalStatus.fromValue(json['status'] as String),
      extensionCount: json['extensionCount'] as int? ?? 0,
      returnCondition: json['returnCondition'] as String?,
    );
  }

  bool get isOverdue =>
      status == RentalStatus.rented &&
      DateTime.now().isAfter(dueDate);

  int get overdueDays {
    if (!isOverdue && status != RentalStatus.overdue) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }

  bool get canExtend =>
      (status == RentalStatus.rented || status == RentalStatus.overdue) &&
      extensionCount < 1;

  bool get canReturn =>
      status == RentalStatus.rented || status == RentalStatus.overdue;

  bool get canCancel => status == RentalStatus.rented;
}

class RentalCreateRequest {
  final int assetId;
  final int? borrowerId;
  final String? borrowerName;
  final String? rentalReason;
  final int dueDays;

  const RentalCreateRequest({
    required this.assetId,
    this.borrowerId,
    this.borrowerName,
    this.rentalReason,
    required this.dueDays,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'assetId': assetId,
      'dueDays': dueDays,
    };
    if (borrowerId != null) json['borrowerId'] = borrowerId;
    if (borrowerName != null) json['borrowerName'] = borrowerName;
    if (rentalReason != null) json['rentalReason'] = rentalReason;
    return json;
  }
}

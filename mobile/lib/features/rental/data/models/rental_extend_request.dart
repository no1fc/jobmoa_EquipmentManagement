class RentalExtendRequest {
  final int extensionDays;

  const RentalExtendRequest({required this.extensionDays});

  Map<String, dynamic> toJson() {
    return {'extensionDays': extensionDays};
  }
}

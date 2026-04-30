class AssetCreateRequest {
  final int categoryId;
  final String assetName;
  final String? serialNumber;
  final String? manufacturer;
  final String? modelNumber;
  final String? purchaseDate;
  final String? location;
  final String? managingDepartment;
  final String? usingDepartment;
  final int? conditionRating;
  final String? technicalSpecs;
  final bool? aiClassified;
  final String? notes;

  const AssetCreateRequest({
    required this.categoryId,
    required this.assetName,
    this.serialNumber,
    this.manufacturer,
    this.modelNumber,
    this.purchaseDate,
    this.location,
    this.managingDepartment,
    this.usingDepartment,
    this.conditionRating,
    this.technicalSpecs,
    this.aiClassified,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'categoryId': categoryId,
      'assetName': assetName,
    };
    if (serialNumber != null) json['serialNumber'] = serialNumber;
    if (manufacturer != null) json['manufacturer'] = manufacturer;
    if (modelNumber != null) json['modelNumber'] = modelNumber;
    if (purchaseDate != null) json['purchaseDate'] = purchaseDate;
    if (location != null) json['location'] = location;
    if (managingDepartment != null) {
      json['managingDepartment'] = managingDepartment;
    }
    if (usingDepartment != null) json['usingDepartment'] = usingDepartment;
    if (conditionRating != null) json['conditionRating'] = conditionRating;
    if (technicalSpecs != null) json['technicalSpecs'] = technicalSpecs;
    if (aiClassified != null) json['aiClassified'] = aiClassified;
    if (notes != null) json['notes'] = notes;
    return json;
  }
}

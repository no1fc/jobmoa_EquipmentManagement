import 'asset_status.dart';

class AssetDetail {
  final int assetId;
  final String assetCode;
  final String assetName;
  final AssetStatus status;
  final int categoryId;
  final String categoryName;
  final List<String> categoryPath;
  final String? serialNumber;
  final String? manufacturer;
  final String? modelNumber;
  final DateTime? purchaseDate;
  final String? location;
  final String? managingDepartment;
  final String? usingDepartment;
  final int? conditionRating;
  final String? technicalSpecs;
  final String? imagePath;
  final bool aiClassified;
  final String? notes;
  final String registeredByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AssetDetail({
    required this.assetId,
    required this.assetCode,
    required this.assetName,
    required this.status,
    required this.categoryId,
    required this.categoryName,
    required this.categoryPath,
    this.serialNumber,
    this.manufacturer,
    this.modelNumber,
    this.purchaseDate,
    this.location,
    this.managingDepartment,
    this.usingDepartment,
    this.conditionRating,
    this.technicalSpecs,
    this.imagePath,
    required this.aiClassified,
    this.notes,
    required this.registeredByName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AssetDetail.fromJson(Map<String, dynamic> json) {
    return AssetDetail(
      assetId: json['assetId'] as int,
      assetCode: json['assetCode'] as String,
      assetName: json['assetName'] as String,
      status: AssetStatus.fromValue(json['status'] as String),
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String,
      categoryPath: (json['categoryPath'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      serialNumber: json['serialNumber'] as String?,
      manufacturer: json['manufacturer'] as String?,
      modelNumber: json['modelNumber'] as String?,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : null,
      location: json['location'] as String?,
      managingDepartment: json['managingDepartment'] as String?,
      usingDepartment: json['usingDepartment'] as String?,
      conditionRating: json['conditionRating'] as int?,
      technicalSpecs: json['technicalSpecs'] as String?,
      imagePath: json['imagePath'] as String?,
      aiClassified: json['aiClassified'] as bool? ?? false,
      notes: json['notes'] as String?,
      registeredByName: json['registeredByName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

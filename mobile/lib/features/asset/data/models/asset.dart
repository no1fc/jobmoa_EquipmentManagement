import 'asset_status.dart';

class Asset {
  final int assetId;
  final String assetCode;
  final String assetName;
  final AssetStatus status;
  final String categoryName;
  final int categoryId;
  final String? location;
  final String? managingDepartment;
  final String? usingDepartment;
  final String? manufacturer;
  final String? modelNumber;
  final DateTime? purchaseDate;
  final String? imagePath;
  final bool aiClassified;
  final DateTime createdAt;

  const Asset({
    required this.assetId,
    required this.assetCode,
    required this.assetName,
    required this.status,
    required this.categoryName,
    required this.categoryId,
    this.location,
    this.managingDepartment,
    this.usingDepartment,
    this.manufacturer,
    this.modelNumber,
    this.purchaseDate,
    this.imagePath,
    required this.aiClassified,
    required this.createdAt,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      assetId: json['assetId'] as int,
      assetCode: json['assetCode'] as String,
      assetName: json['assetName'] as String,
      status: AssetStatus.fromValue(json['status'] as String),
      categoryName: json['categoryName'] as String,
      categoryId: json['categoryId'] as int,
      location: json['location'] as String?,
      managingDepartment: json['managingDepartment'] as String?,
      usingDepartment: json['usingDepartment'] as String?,
      manufacturer: json['manufacturer'] as String?,
      modelNumber: json['modelNumber'] as String?,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : null,
      imagePath: json['imagePath'] as String?,
      aiClassified: json['aiClassified'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

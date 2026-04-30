class AssetSummary {
  final int total;
  final int inUse;
  final int rented;
  final int broken;
  final int inStorage;
  final int disposed;

  const AssetSummary({
    required this.total,
    required this.inUse,
    required this.rented,
    required this.broken,
    required this.inStorage,
    required this.disposed,
  });

  factory AssetSummary.fromJson(Map<String, dynamic> json) {
    return AssetSummary(
      total: json['total'] as int,
      inUse: json['inUse'] as int,
      rented: json['rented'] as int,
      broken: json['broken'] as int,
      inStorage: json['inStorage'] as int,
      disposed: json['disposed'] as int,
    );
  }
}

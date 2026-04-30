class Category {
  final int categoryId;
  final int? parentId;
  final String categoryName;
  final int categoryLevel;
  final String? description;
  final DateTime createdAt;

  const Category({
    required this.categoryId,
    this.parentId,
    required this.categoryName,
    required this.categoryLevel,
    this.description,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'] as int,
      parentId: json['parentId'] as int?,
      categoryName: json['categoryName'] as String,
      categoryLevel: json['categoryLevel'] as int,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

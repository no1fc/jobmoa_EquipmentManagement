class CategoryTree {
  final int categoryId;
  final String categoryName;
  final int categoryLevel;
  final String? description;
  final List<CategoryTree> children;

  const CategoryTree({
    required this.categoryId,
    required this.categoryName,
    required this.categoryLevel,
    this.description,
    required this.children,
  });

  factory CategoryTree.fromJson(Map<String, dynamic> json) {
    return CategoryTree(
      categoryId: json['categoryId'] as int,
      categoryName: json['categoryName'] as String,
      categoryLevel: json['categoryLevel'] as int,
      description: json['description'] as String?,
      children: (json['children'] as List<dynamic>?)
              ?.map(
                (e) => CategoryTree.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class AiClassificationResult {
  final String suggestedCategoryPath; // "IT장비 > 컴퓨터 > 노트북"
  final List<int> suggestedCategoryIds; // [대분류ID, 중분류ID, 소분류ID]
  final double confidence; // 0.0 ~ 1.0
  final String? suggestedName;
  final Map<String, String>? technicalSpecs;

  const AiClassificationResult({
    required this.suggestedCategoryPath,
    required this.suggestedCategoryIds,
    required this.confidence,
    this.suggestedName,
    this.technicalSpecs,
  });

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(0)}%';

  bool get isHighConfidence => confidence >= 0.8;

  AiClassificationResult copyWith({
    String? suggestedCategoryPath,
    List<int>? suggestedCategoryIds,
    double? confidence,
    String? suggestedName,
    Map<String, String>? technicalSpecs,
  }) {
    return AiClassificationResult(
      suggestedCategoryPath:
          suggestedCategoryPath ?? this.suggestedCategoryPath,
      suggestedCategoryIds:
          suggestedCategoryIds ?? this.suggestedCategoryIds,
      confidence: confidence ?? this.confidence,
      suggestedName: suggestedName ?? this.suggestedName,
      technicalSpecs: technicalSpecs ?? this.technicalSpecs,
    );
  }
}

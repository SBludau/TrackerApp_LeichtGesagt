import 'category.dart';

/// The result of running the NLP stub over a spoken/typed transcript.
class ExtractionResult {
  /// Successfully extracted values, keyed by [CategoryType.key].
  final Map<String, double> values;

  /// Keywords detected in the transcript (e.g. "Kaffee", "Sport").
  final List<String> tags;

  /// Categories that were active but for which no value was found.
  final List<CategoryType> missingCategories;

  const ExtractionResult({
    required this.values,
    required this.tags,
    required this.missingCategories,
  });

  /// An empty result with all categories missing.
  factory ExtractionResult.empty(List<CategoryType> activeCategories) {
    return ExtractionResult(
      values: const {},
      tags: const [],
      missingCategories: List<CategoryType>.from(activeCategories),
    );
  }
}

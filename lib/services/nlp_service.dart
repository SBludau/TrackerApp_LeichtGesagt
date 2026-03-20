import '../models/category.dart';
import '../models/extraction_result.dart';

/// Stub NLP service that extracts category values and tags from a transcript.
///
/// In production this would use a local LLM (e.g. llama.cpp).
/// For development it uses simple regex heuristics.
class NlpService {
  /// Known lifestyle tags to detect in transcripts.
  static const _knownTags = [
    'Kaffee',
    'Sport',
    'Kopfschmerz',
    'Müde',
    'Erschöpft',
    'Meditation',
    'Alkohol',
    'Schlechter Schlaf',
    'Guter Schlaf',
    'Spaziergang',
    'Yoga',
    'Arbeit',
    'Meeting',
    'Stress',
  ];

  /// Keyword variants (lowercase) that map to each [CategoryType].
  static const _keywords = <CategoryType, List<String>>{
    CategoryType.stress: ['stress', 'stresslevel', 'gestresst', 'anspannung'],
    CategoryType.energie: ['energie', 'energielevel', 'energetisch', 'müde', 'erschöpft'],
    CategoryType.schlaf: ['schlaf', 'geschlafen', 'schlafqualität', 'nacht'],
    CategoryType.ernaehrung: ['ernährung', 'gegessen', 'essen', 'mahlzeit', 'kalorien'],
  };

  /// Analyses [transcript] and returns extracted values for the
  /// [activeCategories]. Categories with no match appear in
  /// [ExtractionResult.missingCategories].
  ExtractionResult extractValues(
      String transcript, List<CategoryType> activeCategories) {
    final lower = transcript.toLowerCase();
    final extracted = <String, double>{};

    for (final cat in activeCategories) {
      final keywords = _keywords[cat] ?? [];
      for (final kw in keywords) {
        final value = _findValueNearKeyword(lower, kw);
        if (value != null) {
          extracted[cat.key] = value;
          break;
        }
      }
    }

    final missing = activeCategories
        .where((c) => !extracted.containsKey(c.key))
        .toList();

    final tags = _extractTags(transcript);

    return ExtractionResult(
      values: extracted,
      tags: tags,
      missingCategories: missing,
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  /// Looks for a digit 1–10 within ±30 characters of [keyword].
  double? _findValueNearKeyword(String lower, String keyword) {
    final idx = lower.indexOf(keyword);
    if (idx == -1) return null;

    final start = (idx - 5).clamp(0, lower.length);
    final end = (idx + keyword.length + 30).clamp(0, lower.length);
    final window = lower.substring(start, end);

    // Match "10" before single digits so it takes precedence
    final match = RegExp(r'\b(10|[1-9])\b').firstMatch(window);
    if (match == null) return null;
    return double.tryParse(match.group(1) ?? '');
  }

  /// Returns known tags that appear in [transcript] (case-insensitive).
  List<String> _extractTags(String transcript) {
    final lower = transcript.toLowerCase();
    return _knownTags
        .where((tag) => lower.contains(tag.toLowerCase()))
        .toList();
  }
}

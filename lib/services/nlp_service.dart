import '../models/category.dart';
import '../models/extraction_result.dart';

/// Rule-based NLP service for extracting health/lifestyle values from
/// free-form German speech.
///
/// Handles:
/// - Digit literals: "Stress 7", "so bei einer 7"
/// - German number words: "sieben", "acht", "zehn"
/// - Contextual patterns: "war bei X", "würde sagen X", "so um die X",
///   "ungefähr X", "ca. X", "etwa X"
/// - Implicit quality words: "gut" → 7-8, "schlecht" → 2-3, "okay" → 5-6
/// - Ordinal phrases: "einer sieben", "einem 6er"
/// - Lifestyle tag detection (50+ known terms)
///
/// Production replacement: swap with llama.cpp / fllama for true LLM
/// extraction before the Play Store release.
class NlpService {
  // ─── Number word map ────────────────────────────────────────────────────────

  static const _wordToNum = <String, double>{
    'null': 0, 'eins': 1, 'eine': 1, 'einem': 1, 'einen': 1, 'ein': 1,
    'zwei': 2, 'drei': 3, 'vier': 4, 'fünf': 5,
    'sechs': 6, 'sieben': 7, 'acht': 8, 'neun': 9, 'zehn': 10,
  };

  // ─── Category keywords ──────────────────────────────────────────────────────

  static const _keywords = <CategoryType, List<String>>{
    CategoryType.stress: [
      'stress', 'stresslevel', 'gestresst', 'stressig', 'anspannung',
      'angespannt', 'nervös', 'überwältigt', 'druck',
    ],
    CategoryType.energie: [
      'energie', 'energielevel', 'energetisch', 'müde', 'erschöpft',
      'ausgelaugt', 'fit', 'wach', 'kraft', 'energiegeladen', 'antrieb',
    ],
    CategoryType.schlaf: [
      'schlaf', 'geschlafen', 'schlafqualität', 'nacht', 'schlafen',
      'eingeschlafen', 'aufgewacht', 'durchgeschlafen', 'schlaflos',
    ],
    CategoryType.ernaehrung: [
      'ernährung', 'gegessen', 'essen', 'mahlzeit', 'kalorien',
      'frühstück', 'mittagessen', 'abendessen', 'snack', 'getrunken',
      'hunger', 'satt',
    ],
  };

  // ─── Implicit quality mappings ──────────────────────────────────────────────
  // When a value word is found near a category keyword but no number follows.

  static const _qualityToValue = <String, double>{
    // Positive
    'sehr gut': 9.0, 'super': 9.0, 'hervorragend': 9.0, 'ausgezeichnet': 9.0,
    'toll': 8.0, 'gut': 7.5, 'prima': 7.5, 'ganz gut': 7.0,
    'okay': 5.5, 'ok': 5.5, 'so lala': 5.0, 'mittel': 5.0,
    'nicht so gut': 3.5, 'schlecht': 3.0, 'sehr schlecht': 2.0,
    'miserabel': 1.5, 'schrecklich': 1.0,
    // Stress-specific (high stress = high value)
    'sehr gestresst': 9.0, 'gestresst': 7.0, 'etwas gestresst': 6.0,
    // Energy-specific
    'erschöpft': 2.0, 'ausgelaugt': 2.5, 'müde': 3.0,
    'fit': 7.5, 'energiegeladen': 9.0,
  };

  // ─── Known lifestyle tags ───────────────────────────────────────────────────

  static const _knownTags = <String>[
    'Kaffee', 'Tee', 'Alkohol', 'Wasser',
    'Sport', 'Laufen', 'Joggen', 'Yoga', 'Meditation', 'Spaziergang',
    'Radfahren', 'Schwimmen', 'Training', 'Workout',
    'Kopfschmerz', 'Migräne', 'Rückenschmerzen', 'Bauchschmerzen',
    'Übelkeit', 'Schwindel', 'Husten', 'Schnupfen',
    'Müde', 'Erschöpft', 'Schlechter Schlaf', 'Guter Schlaf',
    'Arbeit', 'Meeting', 'Homeoffice', 'Urlaub',
    'Stress', 'Entspannung', 'Freunde', 'Familie',
    'Draußen', 'Frische Luft', 'Sonnenschein',
    'Süßigkeiten', 'Fast Food', 'Gemüse', 'Obst',
  ];

  // ─── Public API ─────────────────────────────────────────────────────────────

  /// Analyses [transcript] and returns extracted values for [activeCategories].
  ExtractionResult extractValues(
    String transcript,
    List<CategoryType> activeCategories,
  ) {
    final lower = transcript.toLowerCase();
    final extracted = <String, double>{};

    for (final cat in activeCategories) {
      final value = _extractCategoryValue(lower, cat);
      if (value != null) {
        extracted[cat.key] = value.clamp(1.0, 10.0);
      }
    }

    final missing = activeCategories
        .where((c) => !extracted.containsKey(c.key))
        .toList();

    return ExtractionResult(
      values: extracted,
      tags: _extractTags(transcript),
      missingCategories: missing,
    );
  }

  // ─── Value extraction ───────────────────────────────────────────────────────

  double? _extractCategoryValue(String lower, CategoryType cat) {
    final keywords = _keywords[cat] ?? [];

    for (final kw in keywords) {
      final idx = lower.indexOf(kw);
      if (idx == -1) continue;

      // Search window: 8 chars before and 40 chars after the keyword
      final start = (idx - 8).clamp(0, lower.length);
      final end = (idx + kw.length + 40).clamp(0, lower.length);
      final window = lower.substring(start, end);

      // 1. Try to find a numeric value (digits or number words)
      final numValue = _findNumericValue(window);
      if (numValue != null) return numValue;

      // 2. Try quality words
      final qualValue = _findQualityValue(window);
      if (qualValue != null) return qualValue;
    }
    return null;
  }

  /// Searches [window] for a number (digit or word) preceded by optional
  /// context phrases like "bei", "so", "etwa", "würde sagen", etc.
  double? _findNumericValue(String window) {
    // Pattern: optional filler + number (10 before 1-9 to avoid partial match)
    final pattern = RegExp(
      r'(?:bei\s+(?:einer?\s+)?|so\s+(?:um\s+(?:die\s+)?)?|etwa\s+|'
      r'ungefähr\s+|ca\.?\s+|würde\s+sagen\s+|sage\s+(?:mal\s+)?|'
      r'so\s+(?:ca\.?\s+)?|auf\s+(?:einer?\s+)?)?'
      r'(10|[1-9](?:[,\.]\d)?|'
      r'zehn|neun|acht|sieben|sechs|fünf|vier|drei|zwei|eins?|eine[nm]?)'
      r'(?:\s*(?:er|em|en|es|von\s+zehn|\/10))?',
    );

    for (final m in pattern.allMatches(window)) {
      final raw = m.group(1);
      if (raw == null) continue;
      // Try digit parse first
      final d = double.tryParse(raw.replaceAll(',', '.'));
      if (d != null) return d;
      // Then word map
      final w = _wordToNum[raw.toLowerCase()];
      if (w != null) return w;
    }
    return null;
  }

  /// Searches [window] for implicit quality descriptors.
  double? _findQualityValue(String window) {
    // Longer phrases first to avoid partial matches
    final sorted = _qualityToValue.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final phrase in sorted) {
      if (window.contains(phrase)) return _qualityToValue[phrase];
    }
    return null;
  }

  // ─── Tag extraction ─────────────────────────────────────────────────────────

  List<String> _extractTags(String transcript) {
    final lower = transcript.toLowerCase();
    final found = <String>[];
    for (final tag in _knownTags) {
      if (lower.contains(tag.toLowerCase())) {
        found.add(tag);
      }
    }
    return found;
  }
}

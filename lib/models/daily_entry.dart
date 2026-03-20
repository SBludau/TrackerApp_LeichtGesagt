/// A single day's tracking record in LeichtGesagt.
class DailyEntry {
  final int? id;
  final DateTime date;

  /// Map from [CategoryType.key] → value (1.0–10.0).
  final Map<String, double> values;

  /// User-mentioned tags (e.g. "Kaffee", "Sport", "Kopfschmerz").
  final List<String> tags;

  /// Spoken or typed transcript that was analysed to produce [values].
  final String? transcript;

  /// True when the entry was created via the "Standard-Tag" shortcut.
  final bool isStandardTag;

  /// True when the user explicitly skipped this day.
  final bool isSkipped;

  const DailyEntry({
    this.id,
    required this.date,
    this.values = const {},
    this.tags = const [],
    this.transcript,
    this.isStandardTag = false,
    this.isSkipped = false,
  });

  /// Returns an ISO-8601 date-only string (YYYY-MM-DD) for the entry date.
  String get dateKey =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  DailyEntry copyWith({
    int? id,
    DateTime? date,
    Map<String, double>? values,
    List<String>? tags,
    String? transcript,
    bool? isStandardTag,
    bool? isSkipped,
  }) {
    return DailyEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      values: values ?? this.values,
      tags: tags ?? this.tags,
      transcript: transcript ?? this.transcript,
      isStandardTag: isStandardTag ?? this.isStandardTag,
      isSkipped: isSkipped ?? this.isSkipped,
    );
  }

  /// Normalises a [DateTime] to midnight (removes time components).
  static DateTime normaliseDate(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// Returns true when there is at least one recorded value.
  bool get hasValues => values.isNotEmpty;
}

import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/daily_entry.dart';
import '../services/database_service.dart';
import '../services/preferences_service.dart';

/// Central application state, exposed via [ChangeNotifier] / Provider.
///
/// All screens read from and write to this single object; it coordinates
/// both the SQLite database and shared-preferences layer.
class AppState extends ChangeNotifier {
  final DatabaseService _db;
  final PreferencesService _prefs;

  AppState({
    DatabaseService? db,
    PreferencesService? prefs,
  })  : _db = db ?? DatabaseService(),
        _prefs = prefs ?? PreferencesService();

  // ─── State fields ────────────────────────────────────────────────────────────

  List<Category> _activeCategories = [];
  DailyEntry? _todayEntry;
  int _streak = 0;
  List<DailyEntry> _allEntries = [];
  bool _isLoading = false;

  // ─── Getters ─────────────────────────────────────────────────────────────────

  List<Category> get activeCategories => _activeCategories;
  DailyEntry? get todayEntry => _todayEntry;
  int get streak => _streak;
  List<DailyEntry> get allEntries => _allEntries;
  bool get isLoading => _isLoading;

  /// Whether the user has already recorded an entry for today.
  bool get hasEntryToday =>
      _todayEntry != null &&
      (_todayEntry!.hasValues || _todayEntry!.isSkipped);

  // ─── Initialisation ──────────────────────────────────────────────────────────

  /// Loads all persisted data. Should be called once on app start.
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final activeCategoryTypes = await _prefs.getActiveCategories();
    final defaultValues = await _prefs.getAllDefaultValues();

    _activeCategories = activeCategoryTypes.map((t) {
      return Category(
        type: t,
        defaultValue: defaultValues[t.key] ?? 5.0,
        isActive: true,
      );
    }).toList();

    _streak = await _prefs.getStreak();
    _allEntries = await _db.getAllEntries();
    _todayEntry = await _db.getEntry(DateTime.now());

    _isLoading = false;
    notifyListeners();
  }

  // ─── Saving ──────────────────────────────────────────────────────────────────

  /// Saves a [DailyEntry] for today, recalculates streak, and notifies.
  Future<void> saveEntry(DailyEntry entry) async {
    await _db.saveEntry(entry);
    _todayEntry = entry;

    // Re-load all entries so trend data stays fresh
    _allEntries = await _db.getAllEntries();

    await _recalculateStreak();
    await _prefs.setLastEntryDate(DateTime.now());

    notifyListeners();
  }

  /// Saves default values for all active categories as today's entry.
  Future<void> applyStandardTag() async {
    final values = {
      for (final cat in _activeCategories) cat.key: cat.defaultValue
    };
    final entry = DailyEntry(
      date: DailyEntry.normaliseDate(DateTime.now()),
      values: values,
      isStandardTag: true,
    );
    await saveEntry(entry);
  }

  /// Marks today as skipped (no tracking data is recorded).
  Future<void> skipDay() async {
    final entry = DailyEntry(
      date: DailyEntry.normaliseDate(DateTime.now()),
      isSkipped: true,
    );
    await _db.saveEntry(entry);
    _todayEntry = entry;
    _allEntries = await _db.getAllEntries();
    notifyListeners();
  }

  // ─── Debug helpers ────────────────────────────────────────────────────────────

  /// Löscht den heutigen Eintrag aus der Datenbank.
  /// Nur für Debug-Zwecke – vor Play-Store-Release entfernen.
  Future<void> resetTodayEntry() async {
    await _db.deleteEntry(DateTime.now());
    _todayEntry = null;
    _allEntries = await _db.getAllEntries();
    await _recalculateStreak();
    notifyListeners();
  }

  // ─── Category management ─────────────────────────────────────────────────────

  /// Persists a new set of active categories and reloads state.
  Future<void> setActiveCategories(List<CategoryType> types) async {
    await _prefs.setActiveCategories(types);
    await loadData();
  }

  /// Updates the default value for one category.
  Future<void> setDefaultValue(CategoryType type, double value) async {
    await _prefs.setDefaultValue(type, value);
    _activeCategories = _activeCategories.map((c) {
      if (c.type == type) return c.copyWith(defaultValue: value);
      return c;
    }).toList();
    notifyListeners();
  }

  // ─── Analytics helpers ────────────────────────────────────────────────────────

  /// Returns entries for the last [days] calendar days (including today).
  List<DailyEntry> recentEntries(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days - 1));
    final cutoffNorm = DailyEntry.normaliseDate(cutoff);
    return _allEntries
        .where((e) =>
            !e.date.isBefore(cutoffNorm) && !e.isSkipped)
        .toList();
  }

  /// Average value for [categoryKey] across [entries].
  double? averageValue(String categoryKey, List<DailyEntry> entries) {
    final vals = entries
        .where((e) => e.values.containsKey(categoryKey))
        .map((e) => e.values[categoryKey]!)
        .toList();
    if (vals.isEmpty) return null;
    return vals.reduce((a, b) => a + b) / vals.length;
  }

  // ─── Streak ──────────────────────────────────────────────────────────────────

  Future<void> _recalculateStreak() async {
    int streak = 0;
    DateTime day = DailyEntry.normaliseDate(DateTime.now());

    while (true) {
      final entry = _allEntries.firstWhere(
        (e) => e.date == day && !e.isSkipped && e.hasValues,
        orElse: () => DailyEntry(date: DateTime(0)),
      );
      if (entry.date.year == 0) break;
      streak++;
      day = day.subtract(const Duration(days: 1));
    }

    _streak = streak;
    await _prefs.setStreak(streak);
  }
}

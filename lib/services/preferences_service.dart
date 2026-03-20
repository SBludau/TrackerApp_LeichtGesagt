import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';

/// Thin wrapper around [SharedPreferences] for all persistent app settings.
class PreferencesService {
  static const _keyOnboarding = 'onboardingCompleted';
  static const _keyActiveCategories = 'activeCategories';
  static const _keyDefaultValues = 'defaultValues_';
  static const _keyStreak = 'currentStreak';
  static const _keyLastEntry = 'lastEntryDate';

  // ─── Onboarding ─────────────────────────────────────────────────────────────

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarding) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarding, value);
  }

  // ─── Active Categories ───────────────────────────────────────────────────────

  /// Returns the list of active [CategoryType]s.
  /// Falls back to all four categories if nothing has been saved yet.
  Future<List<CategoryType>> getActiveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getStringList(_keyActiveCategories);
    if (keys == null || keys.isEmpty) {
      return CategoryType.values.toList();
    }
    return keys.map(CategoryTypeExtension.fromKey).toList();
  }

  Future<void> setActiveCategories(List<CategoryType> types) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _keyActiveCategories, types.map((t) => t.key).toList());
  }

  // ─── Default Values ──────────────────────────────────────────────────────────

  Future<double> getDefaultValue(CategoryType type) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('$_keyDefaultValues${type.key}') ?? 5.0;
  }

  Future<void> setDefaultValue(CategoryType type, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_keyDefaultValues${type.key}', value);
  }

  /// Returns a map of all default values.
  Future<Map<String, double>> getAllDefaultValues() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final t in CategoryType.values)
        t.key: prefs.getDouble('$_keyDefaultValues${t.key}') ?? 5.0
    };
  }

  // ─── Streak ──────────────────────────────────────────────────────────────────

  Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStreak) ?? 0;
  }

  Future<void> setStreak(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStreak, value);
  }

  // ─── Last Entry Date ─────────────────────────────────────────────────────────

  Future<DateTime?> getLastEntryDate() async {
    final prefs = await SharedPreferences.getInstance();
    final iso = prefs.getString(_keyLastEntry);
    if (iso == null) return null;
    return DateTime.tryParse(iso);
  }

  Future<void> setLastEntryDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastEntry, date.toIso8601String());
  }
}

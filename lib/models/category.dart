import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The four trackable categories in LeichtGesagt.
enum CategoryType { stress, energie, schlaf, ernaehrung }

/// Extension on [CategoryType] providing display name, color and icon.
extension CategoryTypeExtension on CategoryType {
  /// Human-readable display name in German.
  String get displayName {
    switch (this) {
      case CategoryType.stress:
        return 'Stress';
      case CategoryType.energie:
        return 'Energie';
      case CategoryType.schlaf:
        return 'Schlaf';
      case CategoryType.ernaehrung:
        return 'Ernährung';
    }
  }

  /// Key used for persistence (stable identifier).
  String get key {
    switch (this) {
      case CategoryType.stress:
        return 'stress';
      case CategoryType.energie:
        return 'energie';
      case CategoryType.schlaf:
        return 'schlaf';
      case CategoryType.ernaehrung:
        return 'ernaehrung';
    }
  }

  Color get color {
    switch (this) {
      case CategoryType.stress:
        return AppColors.stress;
      case CategoryType.energie:
        return AppColors.energy;
      case CategoryType.schlaf:
        return AppColors.sleep;
      case CategoryType.ernaehrung:
        return AppColors.nutrition;
    }
  }

  String get icon {
    switch (this) {
      case CategoryType.stress:
        return '🧠';
      case CategoryType.energie:
        return '⚡';
      case CategoryType.schlaf:
        return '🌙';
      case CategoryType.ernaehrung:
        return '🥗';
    }
  }

  String get description {
    switch (this) {
      case CategoryType.stress:
        return 'Skala 1–10';
      case CategoryType.energie:
        return 'Skala 1–10';
      case CategoryType.schlaf:
        return 'Skala 1–10';
      case CategoryType.ernaehrung:
        return 'Skala 1–10';
    }
  }

  /// Reconstruct from persistence key.
  static CategoryType fromKey(String key) {
    return CategoryType.values.firstWhere(
      (e) => e.key == key,
      orElse: () => CategoryType.stress,
    );
  }
}

/// A tracked category with its current active state and default value.
class Category {
  final CategoryType type;
  final double defaultValue;
  final bool isActive;

  const Category({
    required this.type,
    this.defaultValue = 5.0,
    this.isActive = true,
  });

  String get name => type.displayName;
  Color get color => type.color;
  String get icon => type.icon;
  String get key => type.key;

  Category copyWith({
    double? defaultValue,
    bool? isActive,
  }) {
    return Category(
      type: type,
      defaultValue: defaultValue ?? this.defaultValue,
      isActive: isActive ?? this.isActive,
    );
  }

  /// All four categories with default settings.
  static List<Category> defaults() {
    return CategoryType.values
        .map((t) => Category(type: t))
        .toList();
  }
}

import 'package:flutter/material.dart';

/// Design tokens for LeichtGesagt.
/// Single source of truth — derived directly from the design specification.
/// Use these constants everywhere; never hardcode hex values in widgets.
abstract class AppColors {
  // ── Backgrounds & Surfaces ──────────────────────────────────────────────────
  static const Color appBackground  = Color(0xFF111318);
  static const Color surface        = Color(0xFF1A1D26);
  static const Color elevatedSurface= Color(0xFF1E2132);
  static const Color border         = Color(0xFF2A2D35);

  // ── Text ────────────────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFFE8E9EC);
  static const Color textSecondary  = Color(0xFF9CA3AF);
  static const Color textMuted      = Color(0xFF6B7280);
  static const Color textDisabled   = Color(0xFF4B5563);

  // ── Accent & Category colours ───────────────────────────────────────────────
  static const Color indigo         = Color(0xFF6366F1); // primary CTA, mic button
  static const Color stress         = Color(0xFFA78BFA); // Stress category
  static const Color energy         = Color(0xFF34D399); // Energie category
  static const Color sleep          = Color(0xFF60A5FA); // Schlaf category
  static const Color nutrition      = Color(0xFFFB923C); // Ernährung category
  static const Color warning        = Color(0xFFF87171); // negative trends

  // ── Semantic ────────────────────────────────────────────────────────────────
  static const Color insightBg      = Color(0xFF0D1A14);
  static const Color insightBorder  = Color(0xFF1A3A28);
  static const Color missingBg      = Color(0xFF1F1A2E);
  static const Color missingBorder  = Color(0xFF3B2F6E);
}

abstract class AppSpacing {
  static const double screenH        = 20.0; // horizontal screen padding
  static const double screenV        = 28.0; // vertical screen padding
  static const double cardPadding    = 14.0;
  static const double gap            = 14.0; // standard component gap
  static const double gapTight       = 8.0;  // tightly related elements

  static const double radiusLarge    = 14.0; // large cards
  static const double radiusMedium   = 12.0; // buttons, medium cards
  static const double radiusPill     = 20.0; // pills / tags
  static const double radiusMic      = 32.0; // mic button (half of 64px)
}

abstract class AppTextStyles {
  static const String _fontFamily =
      '-apple-system, BlinkMacSystemFont, Segoe UI, Arial';

  static const TextStyle screenTitle = TextStyle(
    fontSize: 21,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle label = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    letterSpacing: 0.3,
  );

  static const TextStyle metricValue = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonPrimary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );
}

/// Returns the ThemeData to pass into MaterialApp.
ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.appBackground,
    colorScheme: const ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.indigo,
      onPrimary: Colors.white,
      onSurface: AppColors.textPrimary,
    ),
    cardColor: AppColors.surface,
    dividerColor: AppColors.border,
    splashColor: AppColors.indigo.withOpacity(0.12),
    highlightColor: Colors.transparent,
    useMaterial3: true,
  );
}

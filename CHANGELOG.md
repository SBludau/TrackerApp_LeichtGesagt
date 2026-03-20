# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] – 2026-03-20

### Added
- Complete app implementation: Onboarding, Home, Review, Trends, Settings screens
- `provider` package for state management via `AppState` ChangeNotifier
- `fl_chart` package for dark-styled line charts on the Trends dashboard
- SQLite persistence (`sqflite`) with `daily_entries`, `entry_values`, `entry_tags` tables
- `DatabaseService`: upsert-based save, single-day lookup, range and full-history queries
- `PreferencesService`: active categories, per-category default values, streak, last entry date
- `SttService` stub: simulates 3-second recording and returns a hardcoded German transcript
- `NlpService` stub: regex-based extraction of category values (1–10) and lifestyle tags
- `AppState`: loadData, saveEntry, applyStandardTag, skipDay, setActiveCategories, setDefaultValue, streak recalculation
- Onboarding screen with category card selection (min. 2), quick-select presets, animated CTA
- Home screen: streak badge, context prompt, category pills (active/inactive), pulsing transcript box, mic/standard/skip actions
- Review screen: transcript card, per-category sliders, missing-category cards with default/skip actions, tag chips, save/re-record buttons
- Trends screen: date-range selector (Week/Month/All), 2×2 metric cards, per-category line charts, frequent tags, insight card with mock pattern detection
- Settings screen: data export stub, re-onboarding link, per-category default sliders, app info
- `MainShell` with Material 3 `NavigationBar` (Heute / Trends / Einstellungen)
- Reusable widgets: `CategoryPill`, `ValueSlider`, `TagPill`, `InsightCard`, `MissingCategoryCard`, `StreakBadge`, `MetricCard`, `TrendChart`, `AppLogo`

### Changed
- `pubspec.yaml`: added `provider ^6.1.2`, `fl_chart ^0.69.0`, updated `sqflite` to `^2.3.3+1`, `shared_preferences` to `^2.3.3`, `flutter_lints` to `^5.0.0`
- `lib/main.dart`: full Provider + routing setup with onboarding-gate
- `lib/theme/app_theme.dart`: added `sectionHeading` text style, Navigation Bar and SnackBar theme

## [Unreleased]

### Added
- Initial project setup with Flutter
- App icon and wordmark (SVG + PNG variants)
- Design token system (`app_theme.dart`)
- Home screen (daily entry) with category pills, mic button, and standard-tag button
- GitHub Actions CI/CD workflow for Android APK builds

### Changed
- `android/gradle.properties`: `org.gradle.java.home` auf Microsoft OpenJDK 17
  gesetzt, damit der Gradle-Daemon die AGP-8.x-Mindestanforderung (Java 17)
  erfüllt; Gradle-Client läuft weiterhin mit Java 11 (`JAVA_HOME`), um den
  Windows-spezifischen `WEPollSelectorImpl`-UDS-Loopback-Fehler zu umgehen
- `android/gradle.properties`: überflüssiges `-Djava.io.tmpdir`-Flag aus
  `org.gradle.jvmargs` entfernt (Workaround funktioniert nur via
  `TEMP`/`TMP`-Umgebungsvariable, nicht als JVM-Property)
- `pubspec.yaml`: `in_app_update ^4.2.3` temporär auskommentiert (verursacht
  Kotlin-Incremental-Cache-Fehler beim Build; wird vor Play-Store-Release
  reaktiviert)
- README: Abschnitt „Lokale Entwicklung starten" mit vollständigen
  Windows-Voraussetzungen, Umgebungsvariablen-Tabelle und Fehler-/
  Lösungstabelle erweitert

### Fixed
- Build schlägt nicht mehr mit `Unable to establish loopback connection` fehl,
  wenn `TEMP` und `TMP` auf `C:\Tmp` gesetzt sind und `JAVA_HOME` auf JDK 11
  zeigt

### Known Issues
- `in_app_update` ist deaktiviert — In-App-Updates stehen erst nach
  Play-Store-Veröffentlichung zur Verfügung
- Kotlin-Incremental-Cache-Warnungen für `shared_preferences_android`
  (`PersistentMapImpl`) beim ersten Build nicht-kritisch; beeinflussen
  Laufzeitverhalten nicht

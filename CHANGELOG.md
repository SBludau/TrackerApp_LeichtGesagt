# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

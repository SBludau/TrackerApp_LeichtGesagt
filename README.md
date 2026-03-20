# LeichtGesagt

Voice-first health & habit tracker for Android. Speak your daily observations — the app transcribes and structures them into trackable data.

---

## Lokale Entwicklung starten

### Voraussetzungen (einmalig)
- Flutter SDK unter `F:\portable_tools\flutter\bin` im PATH
- Android Studio installiert mit Emulator `Medium_Phone_API_36.1`

### App im Emulator starten

**1. Emulator starten** — in Android Studio über den AVD Manager, oder:
```powershell
flutter emulators --launch Medium_Phone_API_36.1
```

**2. Warten** bis der Android-Homescreen im Emulator sichtbar ist (~30 Sek.)

**3. App starten** (im Projektordner):
```powershell
cd F:\GitHub\TrackerApp_LeichtGesagt
flutter run
```

> Erster Build dauert 2–4 Min. (Gradle). Danach öffnet sich die App automatisch.
> Änderungen am Code → `r` im Terminal drücken → Hot Reload (sofort sichtbar).

### Fehler: „cannot access engine.stamp"
Ein vorheriger Flutter-Prozess ist noch aktiv. Kurz warten und Befehl wiederholen.
Oder alle Flutter-Prozesse beenden:
```powershell
taskkill /f /im dart.exe 2>$null; taskkill /f /im flutter.bat 2>$null
```

---

## Architecture

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Local database | SQLite via `sqflite` |
| Speech-to-Text | Vosk API (`vosk_flutter`) — fully offline |
| NLP / extraction | Llama 3.2 1B/3B or Qwen 2.5 1.5B via `llama.cpp` — fully offline |
| Distribution | Google Play Store |

All processing runs on-device. No backend, no cloud, no registration required.

## Requirements

- Flutter SDK ≥ 3.19
- Dart SDK ≥ 3.3
- Android SDK ≥ 21 (Android 5.0)
- NDK (required for llama.cpp native compilation)

## Setup

```bash
# 1. Clone
git clone https://github.com/<your-org>/leichtgesagt.git
cd leichtgesagt

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run
```

## Build

```bash
# Debug APK
flutter build apk --debug

# Release APK (requires signing config in android/key.properties)
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

## Signing

Create `android/key.properties` (excluded from git):

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=<your-key-alias>
storeFile=<path-to-keystore.jks>
```

## Project Structure

```
lib/
  main.dart               # Entry point
  theme/
    app_theme.dart        # Design tokens (colors, spacing, typography)
  screens/
    home_screen.dart      # Daily entry screen (Screen 1)
    review_screen.dart    # Validation screen (Screen 2)
    trends_screen.dart    # Dashboard / trends (Screen 3)
  widgets/                # Reusable UI components
  models/                 # Data models
  services/               # STT, NLP, database services
assets/
  logo/                   # App icon and wordmark
```

## CI/CD

GitHub Actions builds a debug APK on every push to `main`. See `.github/workflows/build.yml`.

## License

MIT

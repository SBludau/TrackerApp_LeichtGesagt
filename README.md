# LeichtGesagt

Voice-first health & habit tracker for Android. Speak your daily observations — the app transcribes and structures them into trackable data.

---

## Lokale Entwicklung starten

### Voraussetzungen (einmalig)

| Tool | Version / Pfad | Zweck |
|---|---|---|
| Flutter SDK | `F:\portable_tools\flutter\bin` im PATH | Framework |
| Microsoft OpenJDK **11** | `C:\Program Files\Microsoft\jdk-11.0.30.7-hotspot` | Gradle-Client (kein UDS-Problem) |
| Microsoft OpenJDK **17** | `C:\Program Files\Microsoft\jdk-17.0.18.8-hotspot` | Gradle-Daemon (AGP 8.x-Pflicht) |
| Android Studio | mit AVD `Medium_Phone_API_36.1` | Emulator |

> **Warum zwei Java-Versionen?**
> Android Gradle Plugin ≥ 8.x erfordert Java 17 für den Gradle-*Daemon*.
> Java 17+ nutzt unter Windows `WEPollSelectorImpl`, das Unix-Domain-Sockets
> in `%TEMP%` anlegt. Liegt `%TEMP%` unter `C:\Users\…`, schlägt der
> Socket-Connect() mit „Invalid argument" fehl (Windows-Sicherheitsrichtlinie).
> Lösung: Java 11 als *Client* (`JAVA_HOME`) vermeidet das Problem; Java 17
> als *Daemon* (`org.gradle.java.home` in `gradle.properties`) erfüllt AGP.

### Umgebungsvariablen setzen (Windows, einmalig als Benutzervariablen)

```
JAVA_HOME   = C:\Program Files\Microsoft\jdk-11.0.30.7-hotspot
PUB_CACHE   = C:\PubCache
TEMP        = C:\Tmp
TMP         = C:\Tmp
```

> `PUB_CACHE` muss auf einen Pfad **ohne Leerzeichen** zeigen — der Standard
> `C:\Users\<Name>\AppData\Local\Pub\Cache` enthält Leerzeichen und bricht
> die Dart-Kompilierung ab.
> `TEMP`/`TMP` müssen auf einen kurzen Pfad **außerhalb** von `C:\Users\`
> zeigen, damit Java 17 seine UDS-Sockets anlegen kann.

### App im Emulator starten

**1. Emulator starten** — in Android Studio über den AVD Manager, oder:
```powershell
flutter emulators --launch Medium_Phone_API_36.1
```

**2. Warten** bis der Android-Homescreen im Emulator sichtbar ist (~30 Sek.)

**3. App starten** (im Projektordner, nachdem die o.g. Umgebungsvariablen gesetzt sind):
```powershell
cd F:\GitHub\TrackerApp_LeichtGesagt
flutter run
```

> Erster Build dauert 2–4 Min. (Gradle). Danach öffnet sich die App automatisch.
> Änderungen am Code → `r` im Terminal drücken → Hot Reload (sofort sichtbar).

### Bekannte Fehler & Lösungen

| Fehler | Ursache | Lösung |
|---|---|---|
| `Unable to establish loopback connection` | `TEMP`/`TMP` zeigen auf `C:\Users\…` | `TEMP=C:\Tmp` und `TMP=C:\Tmp` setzen |
| `pub get` schlägt fehl / Kompilierungsfehler | `PUB_CACHE` enthält Leerzeichen | `PUB_CACHE=C:\PubCache` setzen |
| `AGP requires Java 17` | Gradle-Daemon läuft mit Java 11 | `org.gradle.java.home` in `gradle.properties` prüfen |
| `cannot access engine.stamp` | Flutter-Prozess noch aktiv | `taskkill /f /im dart.exe` ausführen oder kurz warten |

```powershell
# Flutter-Prozesse beenden (Notfall-Reset):
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
  services/               # STT stub, NLP stub, SQLite, SharedPreferences
  state/
    app_state.dart        # ChangeNotifier – single source of truth
assets/
  logo/                   # App icon and wordmark
```

## CI/CD

GitHub Actions builds a debug APK on every push to `main`. See `.github/workflows/build.yml`.

## License

MIT

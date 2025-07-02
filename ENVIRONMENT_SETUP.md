# Konfiguracja środowiska dla projektu Saper - Tauri
# Instrukcje odtworzenia środowiska na nowym komputerze

## 📋 Wymagania systemowe

### Zainstalowane oprogramowanie:
1. **Node.js** (v18+)
2. **Rust** (latest stable)
3. **Android Studio** z Android SDK
4. **Java JDK** (Amazon Corretto 21.0.2_13)

### Zmienne środowiskowe:
```bash
ANDROID_HOME=/c/Users/dawid/AppData/Local/Android/Sdk
ANDROID_SDK_ROOT=/c/Users/dawid/AppData/Local/Android/Sdk
NDK_HOME=/c/Users/dawid/AppData/Local/Android/Sdk/ndk/29.0.13599879
JAVA_HOME=/c/Program Files/Amazon Corretto/jdk21.0.2_13
```

### PATH:
Dodać do PATH:
- %ANDROID_HOME%\platform-tools
- %ANDROID_HOME%\tools
- %ANDROID_HOME%\tools\bin

## 🚀 Instrukcje szybkiego uruchomienia

### 1. Klonowanie i instalacja:
```bash
cd /d/projekty/tauri/moja-aplikacja-tauri
npm install
```

### 2. Konfiguracja środowiska:
```bash
# Linux/macOS/Git Bash:
source setup-android-env.sh

# PowerShell:
.\setup-android-env.ps1
```

### 3. Pierwsze uruchomienie:
```bash
# Inicjalizacja Android (jeśli potrzebne):
npx tauri android init

# Budowanie dla Windows:
npx tauri dev

# Budowanie dla Android:
npx tauri android build
```

## 📦 Zainstalowane komponenty Android SDK:

### Platforms:
- android-36 (API Level 36)

### Build Tools:
- 36.0.0

### NDK:
- 29.0.13599879

### Platform Tools:
- Najnowsza wersja (zawiera adb, fastboot)

## 🔧 Komponenty Tauri:

### package.json:
- @tauri-apps/cli: 2.6.2
- @tauri-apps/api: 2.0 (w przyszłości)

### Cargo.toml:
- tauri: 2.0
- tauri-build: 2.0
- tauri-plugin-shell: 2.0

## 📱 Struktura projektu:

```
moja-aplikacja-tauri/
├── public/                 # Frontend (HTML, CSS, JS)
├── src-tauri/             # Backend Rust
│   ├── src/
│   │   ├── main.rs        # Entry point desktop
│   │   └── lib.rs         # Entry point mobile
│   ├── gen/android/       # Wygenerowany projekt Android
│   └── Cargo.toml         # Konfiguracja Rust
├── setup-android-env.sh   # Skrypt środowiska (Bash)
├── setup-android-env.ps1  # Skrypt środowiska (PowerShell)
└── README.md              # Dokumentacja
```

## 🎯 Komendy budowania:

### Development:
```bash
npx tauri dev              # Windows (dev)
npx tauri android dev      # Android (dev + emulator)
```

### Production:
```bash
npx tauri build            # Windows (MSI/NSIS)
npx tauri android build    # Android (APK)
```

## 🐛 Rozwiązywanie problemów:

### "no library targets found":
- Sprawdź czy istnieje `src-tauri/src/lib.rs`
- Sprawdź konfigurację `[lib]` w `Cargo.toml`

### "Android SDK not found":
- Uruchom skrypt środowiska
- Sprawdź ścieżki w `setup-android-env.sh`

### "NDK not found":
- Zainstaluj NDK przez Android Studio
- Zaktualizuj ścieżkę w skrypcie środowiska

## 📄 Backupy:

### Lista zainstalowanych pakietów:
```bash
# Node.js pakiety:
npm list --depth=0

# Rust targets:
rustup target list --installed

# Android SDK komponenty:
sdkmanager --list_installed
```

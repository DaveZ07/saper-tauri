# 🎮 Saper - Tauri App

Klasyczna gra w Sapera zbudowana z wykorzystaniem Tauri (Rust + Web Technologies).

Aplikacja obsługuje zarówno desktop (Windows, macOS, Linux) jak i mobile (Android) dzięki uniwersalnej architekturze Tauri.

## ✨ Funkcje

- 🎯 Trzy poziomy trudności (Łatwy, Średni, Trudny)
- ⏱️ Timer i licznik pozostałych min
- 🚩 Flagowanie min prawym przyciskiem myszy
- 💥 Automatyczne odkrywanie pustych obszarów
- 📱 Responsywny design (działa na telefonach)
- 🖥️ Natywna aplikacja desktopowa (Windows, macOS, Linux)
- 📲 Natywna aplikacja mobilna (Android)
- 🌐 Progressive Web App (PWA) dla przeglądarek
- ⚡ Wysoką wydajność dzięki Rust backend

## 🚀 Instalacja

### Desktop (Windows, macOS, Linux)

#### Windows
Pobierz i uruchom jeden z instalatorów:
- `Saper - Tauri_0.1.0_x64_en-US.msi` - Windows Installer
- `Saper - Tauri_0.1.0_x64-setup.exe` - Setup Executable

Pliki znajdują się w `src-tauri/target/release/bundle/`

#### macOS
```bash
# Budowanie dla macOS
make build-windows  # lub npx tauri build
```

#### Linux
```bash
# Budowanie dla Linux
make build-windows  # lub npx tauri build
```

### Android

#### Wymagania
- Android SDK (API 26+) - obsługuje Android 8.0 i nowsze
- Android NDK
- Java JDK 21

#### Instalacja APK
1. Zbuduj APK:
   ```bash
   make build-android
   # lub
   npx tauri android build
   ```
2. Zainstaluj na urządzeniu:
   ```bash
   adb install src-tauri/gen/android/app/build/outputs/apk/debug/app-debug.apk
   ```

### PWA (Progressive Web App)

#### Opcja A: Lokalnie
1. Upewnij się, że masz zainstalowany Python
2. W folderze głównym projektu uruchom:
   ```bash
   cd public
   python -m http.server 8000
   ```
3. Na telefonie otwórz: `http://192.168.1.140:8000`
4. W Chrome Android kliknij menu (⋮) → "Dodaj do ekranu głównego"

#### Opcja B: GitHub Pages (zalecane)
1. Stwórz nowe repozytorium na GitHub
2. Wrzuć wszystkie pliki z folderu `public/`
3. Włącz GitHub Pages w ustawieniach repozytorium
4. Otwórz stronę na telefonie i zainstaluj jako PWA

## 🛠️ Rozwój

### Wymagania
- **Rust** (1.70+)
- **Node.js** (18+)
- **NPM** lub Yarn
- **Android SDK** (dla Android builds)
- **Android NDK** (dla Android builds)
- **Java JDK** 21 (dla Android builds)

### Quick Start
```bash
# Klonowanie repozytorium
git clone <repository-url>
cd moja-aplikacja-tauri

# Instalacja zależności
npm install

# Konfiguracja środowiska (dla Android)
make setup
```

### Uruchomienie w trybie deweloperskim

#### Desktop (Windows/macOS/Linux)
```bash
make dev
# lub
npm run tauri:dev
```

#### Android
```bash
make dev-android
# lub
npx tauri android dev
```

### Budowanie

#### Windows/Desktop
```bash
make build-windows
# lub
npx tauri build
```

#### Android
```bash
make build-android
# lub  
npx tauri android build
```

#### Wszystkie platformy
```bash
make build-all
```

### Dostępne komendy Make
```bash
make help           # Wyświetl wszystkie dostępne komendy
make setup          # Konfiguracja środowiska Android
make dev            # Tryb development (desktop)
make dev-android    # Tryb development (Android) 
make build-windows  # Build aplikacji Windows
make build-android  # Build aplikacji Android
make build-all      # Build wszystkich platform
make clean          # Wyczyść pliki build
make install-deps   # Zainstaluj zależności npm
```

## 🎮 Jak grać

1. **Odkrywanie pól**: Kliknij lewym przyciskiem myszy
2. **Flagowanie min**: Kliknij prawym przyciskiem myszy
3. **Cel**: Odkryj wszystkie pola bez min
4. **Liczby**: Pokazują ile min jest w sąsiedztwie
5. **Nowa gra**: Kliknij przycisk "Nowa Gra"

## 📁 Struktura projektu

```
moja-aplikacja-tauri/
├── public/                 # PWA files (HTML, CSS, JS)
│   ├── index.html         # Główny plik HTML
│   ├── main.js           # Logika gry JavaScript
│   ├── style.css         # Style CSS
│   ├── manifest.json     # Web App Manifest (PWA)
│   ├── sw.js            # Service Worker (PWA)
│   └── icon-*.png       # Ikony PWA
├── src-tauri/             # Rust backend
│   ├── src/
│   │   ├── lib.rs        # Główna biblioteka Rust
│   │   └── main.rs       # Entry point aplikacji
│   ├── gen/              # Wygenerowane pliki (Android, etc.)
│   ├── target/           # Skompilowane binaria
│   ├── icons/            # Ikony aplikacji
│   ├── Cargo.toml        # Konfiguracja Rust
│   └── tauri.conf.json   # Konfiguracja Tauri
├── src-frontend/          # Frontend development files
│   ├── main.js
│   └── style.css
├── Makefile              # Automatyzacja buildów
├── package.json          # Konfiguracja Node.js
├── build-all.sh         # Skrypt buildowania wszystkich platform
├── setup-android-env.sh  # Konfiguracja środowiska Android
├── .gitignore           # Git ignore rules
└── README.md            # Ta dokumentacja
```

## 🔧 Technologie

- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Backend**: Rust + Tauri Framework
- **Build System**: Tauri CLI, Cargo, Make
- **Mobile**: Android SDK/NDK (API 26+)
- **PWA**: Service Worker, Web App Manifest
- **Packaging**: MSI, NSIS (Windows), APK (Android)

## 📱 Obsługiwane platformy

| Platforma | Status | Wersja | Notatki |
|-----------|--------|---------|---------|
| Windows   | ✅ Pełne wsparcie | 10+ | MSI, EXE installers |
| macOS     | ✅ Pełne wsparcie | 10.15+ | DMG package |
| Linux     | ✅ Pełne wsparcie | Ubuntu 18+ | AppImage, DEB |
| Android   | ✅ Pełne wsparcie | 8.0+ (API 26+) | APK package |
| iOS       | ⏳ W planach | - | Przyszła wersja |
| PWA       | ✅ Pełne wsparcie | Wszystkie | Uniwersalne |

## 🎯 Konfiguracja SDK Android

Projekt jest skonfigurowany dla:
- **Minimum SDK**: API 26 (Android 8.0)
- **Target SDK**: API 35 (Android 15)
- **Compile SDK**: API 35 (najnowsze narzędzia)

To zapewnia kompatybilność z ~95% aktywnych urządzeń Android.

## 📱 PWA Status

PWA jest w pełni funkcjonalna i zawiera:
- ✅ Web App Manifest
- ✅ Service Worker (offline support)
- ✅ Responsywny design
- ✅ Ikony dla instalacji
- ✅ Standalone display mode

## 🤝 Wkład

To jest projekt szkoleniowy demonstrujący możliwości Tauri. Feel free to fork i eksperymentować!

### Rozwój
1. Fork repository
2. Stwórz feature branch (`git checkout -b feature/amazing-feature`)
3. Commit zmiany (`git commit -m 'Add amazing feature'`)
4. Push do branch (`git push origin feature/amazing-feature`)
5. Otwórz Pull Request

## 🐛 Troubleshooting

### Android Build Issues
```bash
# Sprawdź zmienne środowiskowe
echo $ANDROID_HOME
echo $NDK_HOME

# Ponowna konfiguracja
make setup
make clean
make build-android
```

### Windows Build Issues
```bash
# Sprawdź Rust toolchain
rustup show
rustup target add x86_64-pc-windows-msvc

# Rebuild
make clean
make build-windows
```

## 📄 Licencja

MIT License

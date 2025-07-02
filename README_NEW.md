# 🎮 Saper - Tauri App

Klasyczna gra w Sapera zbudowana z wykorzystaniem Tauri (Rust + Web Technologies).

## ✨ Funkcje

- 🎯 Trzy poziomy trudności (Łatwy, Średni, Trudny)
- ⏱️ Timer i licznik pozostałych min
- 🚩 Flagowanie min prawym przyciskiem myszy
- 💥 Automatyczne odkrywanie pustych obszarów
- 📱 Responsywny design (działa na telefonach)
- 🖥️ Natywna aplikacja desktopowa
- 📲 Progressive Web App (PWA) dla mobile

## 🚀 Instalacja

### Windows (Desktop)
Pobierz i uruchom jeden z instalatorów:
- `Saper - Tauri_0.1.0_x64_en-US.msi`
- `Saper - Tauri_0.1.0_x64-setup.exe`

Pliki znajdują się w `src-tauri/target/release/bundle/`

### Android/iOS (PWA)

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
- Rust (1.60+)
- Node.js (16+)
- NPM lub Yarn

### Uruchomienie w trybie deweloperskim
```bash
npm install
npm run tauri:dev
```

### Budowanie
```bash
npm run tauri:build
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
├── public/              # PWA files (HTML, CSS, JS)
│   ├── index.html
│   ├── main.js
│   ├── style.css
│   ├── manifest.json
│   └── sw.js
├── src-tauri/          # Rust backend
│   ├── src/
│   ├── Cargo.toml
│   └── tauri.conf.json
├── package.json
└── README.md
```

## 🔧 Technologie

- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **Backend**: Rust + Tauri
- **Build**: Tauri CLI, Cargo
- **PWA**: Service Worker, Web App Manifest

## 📱 PWA Status

PWA jest w pełni funkcjonalna i zawiera:
- ✅ Web App Manifest
- ✅ Service Worker (offline support)
- ✅ Responsywny design
- ✅ Ikony dla instalacji
- ✅ Standalone display mode

## 🤝 Wkład

To jest projekt szkoleniowy demonstrujący możliwości Tauri. Feel free to fork i eksperymentować!

## 📄 Licencja

MIT License

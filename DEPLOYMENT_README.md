# 🎮 Saper Tauri - Skrypty Deployment

Zestaw skryptów do automatycznego budowania i deployowania aplikacji Saper na Xiaomi 12.

## 📁 Dostępne skrypty

### 🔨 `build-and-deploy.sh` - GŁÓWNY SKRYPT
**Kompletny proces budowania i deployowania**
```bash
bash build-and-deploy.sh
```

**Co robi:**
- ✅ Konfiguruje środowisko Android/Java
- ✅ Buduje aplikację w trybie release
- ✅ Generuje keystore (pierwszym razem)
- ✅ Podpisuje APK dla Xiaomi
- ✅ Weryfikuje podpis
- ✅ Opcjonalnie instaluje na telefonie

---

### ⚡ `quick-deploy.sh` - SZYBKI DEPLOYMENT
**Gdy APK już jest zbudowany**
```bash
bash quick-deploy.sh
```

**Co robi:**
- ✅ Łączy się z Xiaomi 12
- ✅ Instaluje istniejący APK
- ✅ Opcjonalnie uruchamia aplikację

---

### 📱 `manage-app.sh` - ZARZĄDZANIE APLIKACJĄ
**Zarządzanie zainstalowaną aplikacją**
```bash
bash manage-app.sh
```

**Opcje:**
1. Zainstaluj aplikację
2. Odinstaluj aplikację
3. Uruchom aplikację
4. Zatrzymaj aplikację
5. Sprawdź czy jest zainstalowana
6. Pokaż logi aplikacji
7. Wyczyść dane aplikacji
8. Restart aplikacji

---

## 🔧 Pierwsza konfiguracja

### 1. Przygotowanie telefonu Xiaomi 12:
```
1. Ustawienia → O telefonie → 7x kliknij "Numer kompilacji"
2. Ustawienia → Dodatkowe → Opcje dewelopera:
   - Włącz "Debugowanie USB"
   - Wyłącz "MIUI optimization"
   - Włącz "Debugowanie bezprzewodowe"
3. Połącz telefon i PC z tą samą siecią WiFi
```

### 2. Environment (zmienne środowiskowe):
**✅ AUTOMATYCZNE** - Nie musisz nic konfigurować!

Każdy skrypt automatycznie ustawia potrzebne zmienne:
- `ANDROID_HOME` → Android SDK
- `JAVA_HOME` → Java JDK 17
- `NDK_HOME` → Android NDK
- `PATH` → Narzędzia Android

**Opcjonalnie** (dla ręcznego użycia narzędzi):
```bash
source setup-android-env.sh  # Ustawia environment globalnie
```

### 3. Pierwsze uruchomienie:
```bash
bash build-and-deploy.sh
```

### 4. Kolejne deploymenty (gdy już masz APK):
```bash
bash quick-deploy.sh
```

---

## 📋 Wymagania systemowe

- **Windows z Git Bash**
- **Android SDK** (ścieżka: `/c/Users/dawid/AppData/Local/Android/Sdk`)
- **Java JDK 17** (ścieżka: `/c/Program Files/Java/jdk-17`)
- **Tauri CLI**: `npm install -g @tauri-apps/cli`
- **Rust**: Zainstalowany z cargo

### 🧪 Test środowiska:
```bash
# Sprawdź czy wszystko jest poprawnie skonfigurowane:
echo "ANDROID_HOME: $ANDROID_HOME"
echo "JAVA_HOME: $JAVA_HOME"
adb --version
npx tauri --version
rustc --version
```

---

## 🔍 Troubleshooting

### Problem: "APK nie może być zainstalowany"
```bash
# Sprawdź czy MIUI optimization jest wyłączone
# Spróbuj ręcznej instalacji:
adb install -r -d saper-xiaomi-compatible.apk
```

### Problem: "Urządzenie nie wykryte"
```bash
# Sprawdź IP telefonu w ustawieniach debugowania bezprzewodowego
# Zmień IP w skrypcie build-and-deploy.sh w linii:
XIAOMI_IP="192.168.1.247:42133"  # <- zmień na swoje IP
```

### Problem: "Build failed"
```bash
# Sprawdź czy wszystkie tools są zainstalowane:
npx tauri info
```

### Problem: "Environment/narzędzia nie znalezione"
```bash
# Sprawdź czy environment jest poprawnie ustawiony:
echo "ANDROID_HOME: $ANDROID_HOME"
echo "JAVA_HOME: $JAVA_HOME"

# Jeśli puste, uruchom ręcznie:
source setup-android-env.sh

# Sprawdź czy narzędzia istnieją:
ls -la "$ANDROID_HOME/platform-tools/adb.exe"
ls -la "$JAVA_HOME/bin/keytool.exe"
```

---

## 📝 Pliki generowane

- `saper-xiaomi-compatible.apk` - Podpisany APK gotowy do instalacji
- `saper-xiaomi.keystore` - Keystore do podpisywania (ZACHOWAJ!)
- Hasło keystore: `xiaomi123`

---

## 🎯 Szybki workflow

1. **Rozwój aplikacji** → Edytuj kod w `public/` i `src-tauri/`
2. **Test lokalny** → `npm run dev` 
3. **Build i deploy** → `bash build-and-deploy.sh`
4. **Szybkie updaty** → `bash quick-deploy.sh`
5. **Zarządzanie** → `bash manage-app.sh`

---

## 🆘 Pomoc

Jeśli coś nie działa:
1. **Environment**: Sprawdź `echo $ANDROID_HOME` i `echo $JAVA_HOME`
2. **Połączenie**: Sprawdź WiFi telefonu i PC (ta sama sieć)
3. **Debugowanie**: Zrestartuj debugowanie bezprzewodowe na telefonie  
4. **Aplikacja**: Uruchom `bash manage-app.sh` opcja 5 (sprawdź instalację)
5. **Diagnostyka**: W razie problemów użyj `adb devices` do diagnozy

**Szybki test wszystkiego:**
```bash
source setup-android-env.sh  # Ustaw environment
adb devices                   # Sprawdź połączenie
npx tauri info               # Sprawdź Tauri
```

**Powodzenia! 🚀**

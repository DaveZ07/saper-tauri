# 🎮 Saper Tauri - Skrypty Deployment

Zestaw skryptów do automatycznego budowania i deployowania aplikacji Saper na Xiaomi 12.

## 📁 Dostępne skrypty

### 🔨 `build-and-deploy.sh` - GŁÓWNY SKRYPT
**Kompletny proces budowania i deployowania z wyborem trybu**
```bash
bash build-and-deploy.sh
```

**Co robi:**
- 🎯 **NOWE: Wybór trybu budowania (release/debug)**
- ✅ Konfiguruje środowisko Android/Java
- ✅ Buduje aplikację w wybranym trybie
- ✅ Generuje keystore (pierwszym razem)
- ✅ Podpisuje APK dla Xiaomi
- ✅ Weryfikuje podpis
- ✅ **NOWE: Automatyczna aktualizacja portu ADB**
- ✅ Opcjonalnie instaluje na telefonie

**Różnice między trybami:**
- **Release**: ~38MB, zoptymalizowany, wolniejszy build
- **Debug**: ~558MB, szybszy build, informacje debug

---

### ⚡ `quick-deploy.sh` - SZYBKI DEPLOYMENT
**Gdy APK już jest zbudowany - automatyczne wykrywanie typu**
```bash
bash quick-deploy.sh
```

**Co robi:**
- 🎯 **NOWE: Automatyczne wykrywanie dostępnych APK (release/debug)**
- ✅ **NOWE: Automatyczna aktualizacja portu ADB**
- ✅ Łączy się z Xiaomi 12
- ✅ Instaluje najlepszy dostępny APK
- ✅ Opcjonalnie uruchamia aplikację

---

### � `switch-apk.sh` - PRZEŁĄCZNIK APK
**NOWY: Wybór domyślnego APK**
```bash
bash switch-apk.sh
```

**Co robi:**
- �📱 Pokazuje dostępne APK (release/debug) i ich rozmiary
- 🔄 Pozwala wybrać który APK ma być domyślny
- 🔗 Tworzy symlink saper-xiaomi-compatible.apk
- ⚡ Umożliwia szybkie przełączanie między wersjami

---

### 📱 `manage-app.sh` - ZARZĄDZANIE APLIKACJĄ
**Zarządzanie zainstalowaną aplikacją z automatyczną aktualizacją portu**
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

---

## 🚀 Workflow - Najlepsze praktyki

### 🎯 **NOWY: Wybór trybu budowania**

#### Dla rozwoju (szybsze iteracje):
```bash
bash build-and-deploy.sh
# Wybierz: 2) DEBUG
# - Szybszy build (~2-3 min vs 5-8 min)
# - Większy rozmiar (~558MB)
# - Debug informacje
```

#### Dla produkcji/testów:
```bash
bash build-and-deploy.sh  
# Wybierz: 1) RELEASE
# - Wolniejszy build (5-8 min)
# - Mały rozmiar (~38MB)
# - Zoptymalizowany kod
```

### 🔄 **NOWY: Przełączanie między wersjami**

```bash
# Zbuduj oba typy
bash build-and-deploy.sh  # release
bash build-and-deploy.sh  # debug

# Przełączaj między nimi:
bash switch-apk.sh
# Wybierz który ma być domyślny

# Szybko deployuj wybrany:
bash quick-deploy.sh
```

### ⚡ **Typowy workflow**

1. **Pierwsze użycie:**
   ```bash
   bash build-and-deploy.sh  # Wybierz tryb i zainstaluj
   ```

2. **Szybkie iteracje (bez rebuildu):**
   ```bash
   bash quick-deploy.sh  # Używa ostatnio zbudowanego APK
   ```

3. **Zmiana trybu:**
   ```bash
   bash switch-apk.sh  # Przełącz release <-> debug
   bash quick-deploy.sh
   ```

4. **Zarządzanie aplikacją:**
   ```bash
   bash manage-app.sh  # Uninstall, logs, restart itp.
   ```

### 📁 **Generowane pliki:**
```
saper-xiaomi-compatible-release.apk  # Release (~38MB)
saper-xiaomi-compatible-debug.apk    # Debug (~558MB)  
saper-xiaomi-compatible.apk          # Symlink do wybranego
saper-xiaomi.keystore                # Keystore (zachowaj!)
```

---

## 🔧 Automatyczne funkcje

### 🔌 **NOWE: Automatyczna aktualizacja portu ADB**
Wszystkie skrypty automatycznie:
- 🔍 Wykrywają najnowszy port ADB urządzenia
- 🔄 Aktualizują port we wszystkich skryptach
- 📝 Synchronizują ustawienia między skryptami

**Działa w:**
- `build-and-deploy.sh` - podczas instalacji
- `quick-deploy.sh` - podczas szybkiego deployu  
- `manage-app.sh` - podczas każdego połączenia

**Nie musisz ręcznie edytować IP/portu!**

### 🎯 **Automatyczna konfiguracja środowiska**
Każdy skrypt automatycznie ustawia:
- `ANDROID_HOME` → Android SDK
- `JAVA_HOME` → Java JDK 17  
- `NDK_HOME` → Android NDK
- `PATH` → Narzędzia Android

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

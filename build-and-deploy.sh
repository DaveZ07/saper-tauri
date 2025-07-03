#!/bin/bash
# build-and-deploy.sh - Kompletny skrypt do budowania i deployowania APK na Xiaomi
# Autor: GitHub Copilot & Dawid
# Data: 3 lipca 2025

echo "🚀 === AUTOMATYCZNE BUDOWANIE I DEPLOYMENT APK SAPER === 🚀"
echo ""

# Kolory dla lepszej czytelności
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funkcja do wyświetlania kolorowych komunikatów
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# 1. KONFIGURACJA ŚRODOWISKA
log_info "Konfiguracja zmiennych środowiskowych..."
export ANDROID_HOME="/c/Users/dawid/AppData/Local/Android/Sdk"
export ANDROID_SDK_ROOT="/c/Users/dawid/AppData/Local/Android/Sdk"
export NDK_HOME="/c/Users/dawid/AppData/Local/Android/Sdk/ndk/29.0.13599879"
export JAVA_HOME="/c/Program Files/Java/jdk-17"
export PATH="$HOME/.cargo/bin:$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin"

log_success "Zmienne środowiskowe ustawione"
echo "   ANDROID_HOME: $ANDROID_HOME"
echo "   JAVA_HOME: $JAVA_HOME"
echo ""

# 2. SPRAWDZENIE NARZĘDZI
log_info "Sprawdzanie dostępności narzędzi..."

# Sprawdź ADB
if [ -f "$ANDROID_HOME/platform-tools/adb.exe" ]; then
    log_success "ADB: OK"
    ADB_PATH="$ANDROID_HOME/platform-tools/adb.exe"
else
    log_error "ADB nie znalezione"
    exit 1
fi

# Sprawdź apksigner
APKSIGNER="$ANDROID_HOME/build-tools/$(ls "$ANDROID_HOME/build-tools" | tail -1)/apksigner.bat"
if [ -f "$APKSIGNER" ]; then
    log_success "apksigner: OK"
else
    log_error "apksigner nie znalezione"
    exit 1
fi

# Sprawdź keytool
if [ -f "$JAVA_HOME/bin/keytool.exe" ]; then
    log_success "keytool: OK"
else
    log_error "keytool nie znalezione"
    exit 1
fi

echo ""

# 3. CZYSZCZENIE POPRZEDNICH BUILDÓW
log_info "Czyszczenie poprzednich buildów..."
rm -f saper-xiaomi-compatible.apk
rm -f xiaomi-temp.apk

# 4. BUDOWANIE APK
echo ""
log_info "🔨 Budowanie aplikacji Tauri w trybie release..."
echo "To może potrwać kilka minut..."

if npx tauri android build --release; then
    log_success "Build zakończony pomyślnie!"
else
    log_error "Błąd podczas budowania aplikacji"
    exit 1
fi

# 5. SPRAWDZENIE PLIKU APK
APK_RELEASE="src-tauri/gen/android/app/build/outputs/apk/universal/release/app-universal-release-unsigned.apk"

if [ -f "$APK_RELEASE" ]; then
    APK_SIZE=$(stat -c%s "$APK_RELEASE" 2>/dev/null || stat -f%z "$APK_RELEASE" 2>/dev/null || echo "unknown")
    log_success "APK release znaleziony (rozmiar: $APK_SIZE bajtów)"
    APK_SOURCE="$APK_RELEASE"
else
    log_error "Nie znaleziono APK release!"
    exit 1
fi

# 6. GENEROWANIE KEYSTORE (jeśli nie istnieje)
echo ""
log_info "🔐 Przygotowanie keystore do podpisywania..."

if [ ! -f "saper-xiaomi.keystore" ]; then
    log_info "Generowanie nowego keystore dla Xiaomi..."
    "$JAVA_HOME/bin/keytool.exe" -genkey -v -keystore saper-xiaomi.keystore \
        -alias xiaomi-key -keyalg RSA -keysize 2048 -validity 25000 \
        -storepass "xiaomi123" -keypass "xiaomi123" \
        -dname "CN=Saper, OU=Game, O=App, L=PL, ST=PL, C=PL"
    
    if [ $? -eq 0 ]; then
        log_success "Keystore wygenerowany pomyślnie"
    else
        log_error "Błąd generowania keystore"
        exit 1
    fi
else
    log_success "Keystore już istnieje"
fi

# 7. PODPISYWANIE APK
echo ""
log_info "✍️  Podpisywanie APK dla Xiaomi..."

# Kopiuj APK do tymczasowego pliku
cp "$APK_SOURCE" xiaomi-temp.apk

# Podpisz APK
"$APKSIGNER" sign \
    --ks saper-xiaomi.keystore \
    --ks-key-alias xiaomi-key \
    --ks-pass pass:xiaomi123 \
    --key-pass pass:xiaomi123 \
    --out saper-xiaomi-compatible.apk \
    xiaomi-temp.apk

if [ $? -eq 0 ]; then
    log_success "APK podpisany pomyślnie!"
else
    log_error "Błąd podpisywania APK"
    rm -f xiaomi-temp.apk
    exit 1
fi

# 8. WERYFIKACJA PODPISU
log_info "Weryfikacja podpisu APK..."
"$APKSIGNER" verify saper-xiaomi-compatible.apk

if [ $? -eq 0 ]; then
    log_success "Podpis APK zweryfikowany pomyślnie!"
else
    log_warning "Ostrzeżenie: Problem z weryfikacją podpisu"
fi

# Cleanup
rm -f xiaomi-temp.apk

# 9. INFORMACJE O PLIKU
echo ""
FINAL_SIZE=$(stat -c%s "saper-xiaomi-compatible.apk" 2>/dev/null || stat -f%z "saper-xiaomi-compatible.apk" 2>/dev/null || echo "unknown")
log_success "📱 APK gotowy do instalacji!"
echo "   Nazwa pliku: saper-xiaomi-compatible.apk"
echo "   Rozmiar: $FINAL_SIZE bajtów"
echo ""

# 10. OPCJA AUTOMATYCZNEJ INSTALACJI
echo ""
log_info "🔌 Sprawdzanie połączenia z urządzeniem..."

read -p "Czy chcesz spróbować automatycznej instalacji na Xiaomi? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    log_info "Próba połączenia z Xiaomi 12..."
    
    # Sprawdź czy urządzenie jest połączone
    "$ADB_PATH" devices
    
    # Spróbuj połączyć się z urządzeniem (zmień IP jeśli potrzeba)
    XIAOMI_IP="192.168.1.247:42133"
    log_info "Łączenie z $XIAOMI_IP..."
    "$ADB_PATH" connect $XIAOMI_IP
    
    # Sprawdź status urządzenia
    DEVICE_STATUS=$("$ADB_PATH" devices | grep "$XIAOMI_IP" | awk '{print $2}')
    
    if [ "$DEVICE_STATUS" = "device" ]; then
        log_success "Urządzenie gotowe do instalacji!"
        
        log_info "Instalowanie APK na Xiaomi..."
        "$ADB_PATH" install -r saper-xiaomi-compatible.apk
        
        if [ $? -eq 0 ]; then
            log_success "🎉 APK zainstalowany pomyślnie na Xiaomi 12!"
            echo ""
            log_info "Możesz teraz uruchomić aplikację 'Saper Game' na telefonie"
        else
            log_error "Błąd instalacji. Spróbuj ręcznie:"
            echo "   $ADB_PATH install -r saper-xiaomi-compatible.apk"
        fi
    elif [ "$DEVICE_STATUS" = "unauthorized" ]; then
        log_warning "Urządzenie nieautoryzowane!"
        echo "   1. Sprawdź popup na telefonie"
        echo "   2. Zaakceptuj debugowanie USB"
        echo "   3. Uruchom skrypt ponownie"
    else
        log_warning "Nie można wykryć urządzenia!"
        echo ""
        echo "📋 Instrukcja ręcznej instalacji:"
        echo "   1. Włącz opcje dewelopera (7x kliknij numer kompilacji)"
        echo "   2. Włącz 'Debugowanie USB'"
        echo "   3. Wyłącz 'MIUI optimization'"
        echo "   4. Podłącz telefon przez WiFi ADB"
        echo "   5. Uruchom: $ADB_PATH install -r saper-xiaomi-compatible.apk"
    fi
else
    echo ""
    log_info "📋 Instrukcja ręcznej instalacji:"
    echo "   1. Skopiuj plik 'saper-xiaomi-compatible.apk' na telefon"
    echo "   2. Włącz 'Nieznane źródła' w ustawieniach"
    echo "   3. Zainstaluj APK bezpośrednio z telefonu"
    echo ""
    echo "   LUB użyj ADB:"
    echo "   $ADB_PATH connect [IP_TELEFONU]:5555"
    echo "   $ADB_PATH install -r saper-xiaomi-compatible.apk"
fi

echo ""
log_success "🏁 Proces zakończony!"
echo "   APK: saper-xiaomi-compatible.apk"
echo "   Keystore: saper-xiaomi.keystore (zachowaj na przyszłość!)"

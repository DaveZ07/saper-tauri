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

# Funkcja do aktualizacji portu ADB
update_adb_port() {
    log_info "Sprawdzanie najnowszego portu ADB..."
    
    # Sprawdź dostępne urządzenia
    local devices_output
    devices_output=$("$ADB_PATH" devices 2>/dev/null) || return 1
    local new_ip_port
    new_ip_port=$(echo "$devices_output" | grep "192.168.1" | grep "device" | head -1 | awk '{print $1}') || return 1
    
    if [ -n "$new_ip_port" ] && [ "$new_ip_port" != "$XIAOMI_IP" ]; then
        log_info "Znaleziono nowy port: $new_ip_port"
        # Aktualizuj w tym skrypcie
        sed -i "s/XIAOMI_IP=\"[^\"]*\"/XIAOMI_IP=\"$new_ip_port\"/g" "$0"
        # Aktualizuj w quick-deploy.sh
        if [ -f "quick-deploy.sh" ]; then
            sed -i "s/XIAOMI_IP=\"[^\"]*\"/XIAOMI_IP=\"$new_ip_port\"/g" "quick-deploy.sh"
        fi
        # Aktualizuj w manage-app.sh
        if [ -f "manage-app.sh" ]; then
            sed -i "s/XIAOMI_IP=\"[^\"]*\"/XIAOMI_IP=\"$new_ip_port\"/g" "manage-app.sh"
        fi
        XIAOMI_IP="192.168.1.247:41497"
        log_success "Port ADB zaktualizowany we wszystkich skryptach"
    fi
}

# WYBÓR TRYBU BUDOWANIA
echo ""
log_info "🎯 WYBIERZ TRYB BUDOWANIA:"
echo "   1) RELEASE - Optymalizowany, mały rozmiar (~38MB), wolniejszy build"
echo "   2) DEBUG   - Większy rozmiar (~558MB), szybszy build, debug info"
echo ""

while true; do
    read -p "Wybierz tryb (1=release, 2=debug): " -n 1 -r
    echo ""
    case $REPLY in
        1)
            BUILD_MODE="release"
            log_success "Wybrano tryb: RELEASE"
            break
            ;;
        2)
            BUILD_MODE="debug"
            log_success "Wybrano tryb: DEBUG"
            break
            ;;
        *)
            log_warning "Wybierz 1 lub 2"
            ;;
    esac
done

echo ""

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
rm -f saper-xiaomi-compatible-*.apk
rm -f xiaomi-temp.apk

# 4. BUDOWANIE APK
echo ""
log_info "🔨 Budowanie aplikacji Tauri w trybie $BUILD_MODE..."
echo "To może potrwać kilka minut..."

if [ "$BUILD_MODE" = "release" ]; then
    if npx tauri android build; then
        log_success "Build RELEASE zakończony pomyślnie!"
        APK_SOURCE="src-tauri/gen/android/app/build/outputs/apk/universal/release/app-universal-release-unsigned.apk"
    else
        log_error "Błąd podczas budowania aplikacji w trybie release"
        exit 1
    fi
else
    if npx tauri android build --debug; then
        log_success "Build DEBUG zakończony pomyślnie!"
        APK_SOURCE="src-tauri/gen/android/app/build/outputs/apk/universal/debug/app-universal-debug.apk"
    else
        log_error "Błąd podczas budowania aplikacji w trybie debug"
        exit 1
    fi
fi

# 5. SPRAWDZENIE PLIKU APK
if [ ! -f "$APK_SOURCE" ]; then
    log_error "Nie znaleziono zbudowanego APK: $APK_SOURCE"
    log_error "Sprawdź czy build się powiódł"
    exit 1
fi

APK_SIZE=$(stat -c%s "$APK_SOURCE" 2>/dev/null || stat -f%z "$APK_SOURCE" 2>/dev/null || echo "unknown")
log_success "Znaleziono APK $BUILD_MODE (rozmiar: $APK_SIZE bajtów)"

# Określ nazwę finalnego APK na podstawie trybu
if [ "$BUILD_MODE" = "release" ]; then
    FINAL_APK_NAME="saper-xiaomi-compatible-release.apk"
else
    FINAL_APK_NAME="saper-xiaomi-compatible-debug.apk"
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
log_info "✍️  Podpisywanie APK $BUILD_MODE dla Xiaomi..."

# Kopiuj APK do tymczasowego pliku
cp "$APK_SOURCE" xiaomi-temp.apk

# Podpisz APK
"$APKSIGNER" sign \
    --ks saper-xiaomi.keystore \
    --ks-key-alias xiaomi-key \
    --ks-pass pass:xiaomi123 \
    --key-pass pass:xiaomi123 \
    --out "$FINAL_APK_NAME" \
    xiaomi-temp.apk

if [ $? -eq 0 ]; then
    log_success "APK $BUILD_MODE podpisany pomyślnie!"
else
    log_error "Błąd podpisywania APK"
    rm -f xiaomi-temp.apk
    exit 1
fi

# 8. WERYFIKACJA PODPISU
log_info "Weryfikacja podpisu APK..."
"$APKSIGNER" verify "$FINAL_APK_NAME"

if [ $? -eq 0 ]; then
    log_success "Podpis APK zweryfikowany pomyślnie!"
else
    log_warning "Ostrzeżenie: Problem z weryfikacją podpisu"
fi

# Cleanup
rm -f xiaomi-temp.apk

# Stwórz symlink dla kompatybilności wstecznej
ln -sf "$FINAL_APK_NAME" "saper-xiaomi-compatible.apk"

# 9. INFORMACJE O PLIKU
echo ""
FINAL_SIZE=$(stat -c%s "$FINAL_APK_NAME" 2>/dev/null || stat -f%z "$FINAL_APK_NAME" 2>/dev/null || echo "unknown")
log_success "📱 APK $BUILD_MODE gotowy do instalacji!"
echo "   Nazwa pliku: $FINAL_APK_NAME"
echo "   Rozmiar: $FINAL_SIZE bajtów"
echo "   Symlink: saper-xiaomi-compatible.apk -> $FINAL_APK_NAME"
echo ""

# 10. OPCJA AUTOMATYCZNEJ INSTALACJI
echo ""
log_info "🔌 Sprawdzanie połączenia z urządzeniem..."

# Aktualizuj port ADB przed instalacją
update_adb_port

read -p "Czy chcesz spróbować automatycznej instalacji na Xiaomi? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    log_info "Próba połączenia z Xiaomi 12..."
    
    # Sprawdź czy urządzenie jest połączone
    "$ADB_PATH" devices
    
    # Spróbuj połączyć się z urządzeniem (aktualizowany automatycznie)
    XIAOMI_IP="192.168.1.247:41497"
    log_info "Łączenie z $XIAOMI_IP..."
    "$ADB_PATH" connect $XIAOMI_IP
    
    # Sprawdź status urządzenia
    DEVICE_STATUS=$("$ADB_PATH" devices | grep "$XIAOMI_IP" | awk '{print $2}')
    
    if [ "$DEVICE_STATUS" = "device" ]; then
        log_success "Urządzenie gotowe do instalacji!"
        
        log_info "Instalowanie APK $BUILD_MODE na Xiaomi..."
        "$ADB_PATH" install -r "$FINAL_APK_NAME"
        
        if [ $? -eq 0 ]; then
            log_success "🎉 APK $BUILD_MODE zainstalowany pomyślnie na Xiaomi 12!"
            echo ""
            log_info "Możesz teraz uruchomić aplikację 'Saper Game' na telefonie"
            
            # Opcja uruchomienia aplikacji
            read -p "Czy uruchomić aplikację na telefonie? (y/n): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                log_info "Uruchamianie aplikacji..."
                "$ADB_PATH" shell am start -n com.tauri.saper/.MainActivity
            fi
        else
            log_error "Błąd instalacji. Spróbuj ręcznie:"
            echo "   $ADB_PATH install -r $FINAL_APK_NAME"
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
        echo "   5. Uruchom: $ADB_PATH install -r $FINAL_APK_NAME"
    fi
else
    echo ""
    log_info "📋 Instrukcja ręcznej instalacji:"
    echo "   1. Skopiuj plik '$FINAL_APK_NAME' na telefon"
    echo "   2. Włącz 'Nieznane źródła' w ustawieniach"
    echo "   3. Zainstaluj APK bezpośrednio z telefonu"
    echo ""
    echo "   LUB użyj ADB:"
    echo "   $ADB_PATH connect [IP_TELEFONU]:5555"
    echo "   $ADB_PATH install -r $FINAL_APK_NAME"
fi

echo ""
log_success "🏁 Proces zakończony!"
echo "   APK $BUILD_MODE: $FINAL_APK_NAME"
echo "   Symlink: saper-xiaomi-compatible.apk"
echo "   Keystore: saper-xiaomi.keystore (zachowaj na przyszłość!)"

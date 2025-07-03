#!/bin/bash
# quick-deploy.sh - Szybki deployment istniejącego APK na Xiaomi
# Użyj tego skryptu gdy APK już jest zbudowany i chcesz tylko go zainstalować

echo "🚀 === SZYBKI DEPLOYMENT APK === 🚀"

# Kolory
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Sprawdź czy APK istnieje
if [ ! -f "saper-xiaomi-compatible.apk" ]; then
    log_error "Nie znaleziono pliku saper-xiaomi-compatible.apk"
    echo "Uruchom najpierw: bash build-and-deploy.sh"
    exit 1
fi

# Konfiguracja ADB
export ANDROID_HOME="/c/Users/dawid/AppData/Local/Android/Sdk"
ADB_PATH="$ANDROID_HOME/platform-tools/adb.exe"

if [ ! -f "$ADB_PATH" ]; then
    log_error "ADB nie znalezione!"
    exit 1
fi

log_success "APK znaleziony: saper-xiaomi-compatible.apk"

# Połącz i zainstaluj
XIAOMI_IP="192.168.1.247:42133"

log_info "Łączenie z Xiaomi 12 ($XIAOMI_IP)..."
"$ADB_PATH" connect $XIAOMI_IP

# Sprawdź status
DEVICE_STATUS=$("$ADB_PATH" devices | grep "$XIAOMI_IP" | awk '{print $2}')

if [ "$DEVICE_STATUS" = "device" ]; then
    log_success "Urządzenie połączone!"
    
    log_info "Instalowanie APK..."
    "$ADB_PATH" install -r saper-xiaomi-compatible.apk
    
    if [ $? -eq 0 ]; then
        log_success "🎉 APK zainstalowany pomyślnie!"
        
        # Opcja uruchomienia aplikacji
        read -p "Czy uruchomić aplikację na telefonie? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Uruchamianie aplikacji..."
            "$ADB_PATH" shell am start -n com.tauri.saper/.MainActivity
        fi
    else
        log_error "Błąd instalacji!"
    fi
else
    log_warning "Problem z połączeniem urządzenia (status: $DEVICE_STATUS)"
    echo "Sprawdź:"
    echo "  - Czy telefon jest w tej samej sieci WiFi"
    echo "  - Czy debugowanie bezprzewodowe jest włączone"
    echo "  - Spróbuj sparować ponownie urządzenia"
fi

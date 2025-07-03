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

# Funkcja do aktualizacji portu ADB
update_adb_port() {
    log_info "Sprawdzanie najnowszego portu ADB..."
    
    # Sprawdź dostępne urządzenia
    local devices_output
    devices_output=$("$ADB_PATH" devices 2>/dev/null)
    local new_ip_port
    new_ip_port=$(echo "$devices_output" | grep "192.168.1" | grep "device" | head -1 | awk '{print $1}')
    
    if [ -n "$new_ip_port" ] && [ "$new_ip_port" != "$XIAOMI_IP" ]; then
        log_info "Znaleziono nowy port: $new_ip_port"
        # Aktualizuj w tym skrypcie
        sed -i "s/XIAOMI_IP=\"[^\"]*\"/XIAOMI_IP=\"$new_ip_port\"/g" "$0"
        # Aktualizuj w innych skryptach
        if [ -f "build-and-deploy.sh" ]; then
            sed -i "s/XIAOMI_IP=\"[^\"]*\"/XIAOMI_IP=\"$new_ip_port\"/g" "build-and-deploy.sh"
        fi
        if [ -f "manage-app.sh" ]; then
            sed -i "s/XIAOMI_IP=\"[^\"]*\"/XIAOMI_IP=\"$new_ip_port\"/g" "manage-app.sh"
        fi
        XIAOMI_IP="192.168.1.247:41497"
        log_success "Port ADB zaktualizowany we wszystkich skryptach"
    fi
}

# Konfiguracja ADB
export ANDROID_HOME="/c/Users/dawid/AppData/Local/Android/Sdk"
ADB_PATH="$ANDROID_HOME/platform-tools/adb.exe"

if [ ! -f "$ADB_PATH" ]; then
    log_error "ADB nie znalezione!"
    exit 1
fi

# Sprawdź dostępne APK i wybierz najlepszy
APK_FILE=""
APK_TYPE=""

# Najpierw sprawdź czy jest symlink (domyślny)
if [ -f "saper-xiaomi-compatible.apk" ] && [ -L "saper-xiaomi-compatible.apk" ]; then
    APK_FILE="saper-xiaomi-compatible.apk"
    APK_TYPE="domyślny (symlink)"
# Potem sprawdź release
elif [ -f "saper-xiaomi-compatible-release.apk" ]; then
    APK_FILE="saper-xiaomi-compatible-release.apk"
    APK_TYPE="release"
# Potem debug
elif [ -f "saper-xiaomi-compatible-debug.apk" ]; then
    APK_FILE="saper-xiaomi-compatible-debug.apk"
    APK_TYPE="debug"
# Fallback na stary plik
elif [ -f "saper-xiaomi-compatible.apk" ]; then
    APK_FILE="saper-xiaomi-compatible.apk"
    APK_TYPE="legacy"
else
    log_error "Nie znaleziono żadnego podpisanego APK!"
    echo "Dostępne opcje:"
    echo "  - saper-xiaomi-compatible-release.apk"
    echo "  - saper-xiaomi-compatible-debug.apk"
    echo "  - saper-xiaomi-compatible.apk"
    echo ""
    echo "Uruchom najpierw: bash build-and-deploy.sh"
    exit 1
fi

log_success "APK znaleziony: $APK_FILE ($APK_TYPE)"

# Aktualizuj port ADB
update_adb_port

# Połącz i zainstaluj
XIAOMI_IP="192.168.1.247:41497"

log_info "Łączenie z Xiaomi 12 ($XIAOMI_IP)..."
"$ADB_PATH" connect $XIAOMI_IP

# Sprawdź status
DEVICE_STATUS=$("$ADB_PATH" devices | grep "$XIAOMI_IP" | awk '{print $2}')

if [ "$DEVICE_STATUS" = "device" ]; then
    log_success "Urządzenie połączone!"
    
    log_info "Instalowanie APK $APK_TYPE..."
    "$ADB_PATH" install -r "$APK_FILE"
    
    if [ $? -eq 0 ]; then
        log_success "🎉 APK $APK_TYPE zainstalowany pomyślnie!"
        
        # Opcja uruchomienia aplikacji
        read -p "Czy uruchomić aplikację na telefonie? (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Uruchamianie aplikacji..."
            "$ADB_PATH" shell am start -n com.tauri.saper/.MainActivity
            
            if [ $? -eq 0 ]; then
                log_success "Aplikacja uruchomiona!"
            else
                log_warning "Problem z uruchomieniem aplikacji"
            fi
        fi
    else
        log_error "Błąd instalacji!"
        echo "Spróbuj ręcznie: $ADB_PATH install -r $APK_FILE"
    fi
else
    log_warning "Problem z połączeniem urządzenia (status: $DEVICE_STATUS)"
    echo ""
    echo "Sprawdź:"
    echo "  - Czy telefon jest w tej samej sieci WiFi"
    echo "  - Czy debugowanie bezprzewodowe jest włączone"
    echo "  - Spróbuj sparować ponownie urządzenia"
    echo ""
    echo "Instrukcja ręczna:"
    echo "  1. Włącz WiFi ADB na telefonie"
    echo "  2. $ADB_PATH connect [IP_TELEFONU]:5555"
    echo "  3. $ADB_PATH install -r $APK_FILE"
fi

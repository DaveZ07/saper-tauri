#!/bin/bash
# manage-app.sh - Zarządzanie aplikacją Saper na Xiaomi
# Opcje: uninstall, install, launch, logs

echo "📱 === ZARZĄDZANIE APLIKACJĄ SAPER === 📱"

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

# Konfiguracja
export ANDROID_HOME="/c/Users/dawid/AppData/Local/Android/Sdk"
ADB_PATH="$ANDROID_HOME/platform-tools/adb.exe"
PACKAGE_NAME="com.tauri.saper"
XIAOMI_IP="192.168.1.247:42133"

# Sprawdź ADB
if [ ! -f "$ADB_PATH" ]; then
    log_error "ADB nie znalezione!"
    exit 1
fi

# Funkcja połączenia
connect_device() {
    log_info "Łączenie z urządzeniem..."
    "$ADB_PATH" connect $XIAOMI_IP
    
    DEVICE_STATUS=$("$ADB_PATH" devices | grep "$XIAOMI_IP" | awk '{print $2}')
    if [ "$DEVICE_STATUS" != "device" ]; then
        log_error "Nie można połączyć z urządzeniem!"
        exit 1
    fi
    log_success "Urządzenie połączone"
}

# Menu opcji
echo "Wybierz akcję:"
echo "1. Zainstaluj aplikację"
echo "2. Odinstaluj aplikację" 
echo "3. Uruchom aplikację"
echo "4. Zatrzymaj aplikację"
echo "5. Sprawdź czy jest zainstalowana"
echo "6. Pokaż logi aplikacji"
echo "7. Wyczyść dane aplikacji"
echo "8. Restart aplikacji"

read -p "Wybierz opcję (1-8): " choice

connect_device

case $choice in
    1)
        if [ -f "saper-xiaomi-compatible.apk" ]; then
            log_info "Instalowanie aplikacji..."
            "$ADB_PATH" install -r saper-xiaomi-compatible.apk
        else
            log_error "Nie znaleziono pliku APK!"
            echo "Uruchom najpierw: bash build-and-deploy.sh"
        fi
        ;;
    2)
        log_info "Odinstalowywanie aplikacji..."
        "$ADB_PATH" uninstall $PACKAGE_NAME
        ;;
    3)
        log_info "Uruchamianie aplikacji..."
        "$ADB_PATH" shell am start -n $PACKAGE_NAME/.MainActivity
        ;;
    4)
        log_info "Zatrzymywanie aplikacji..."
        "$ADB_PATH" shell am force-stop $PACKAGE_NAME
        ;;
    5)
        log_info "Sprawdzanie instalacji..."
        if "$ADB_PATH" shell pm list packages | grep -q $PACKAGE_NAME; then
            log_success "Aplikacja jest zainstalowana"
            # Pokaż szczegóły
            "$ADB_PATH" shell dumpsys package $PACKAGE_NAME | head -20
        else
            log_warning "Aplikacja nie jest zainstalowana"
        fi
        ;;
    6)
        log_info "Pokazywanie logów aplikacji..."
        echo "Naciśnij Ctrl+C aby zatrzymać..."
        "$ADB_PATH" logcat | grep $PACKAGE_NAME
        ;;
    7)
        log_info "Czyszczenie danych aplikacji..."
        "$ADB_PATH" shell pm clear $PACKAGE_NAME
        ;;
    8)
        log_info "Restart aplikacji..."
        "$ADB_PATH" shell am force-stop $PACKAGE_NAME
        sleep 2
        "$ADB_PATH" shell am start -n $PACKAGE_NAME/.MainActivity
        ;;
    *)
        log_error "Nieprawidłowa opcja!"
        ;;
esac

log_success "Operacja zakończona!"

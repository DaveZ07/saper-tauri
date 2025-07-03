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
XIAOMI_IP="192.168.1.247:41497"

# Sprawdź ADB
if [ ! -f "$ADB_PATH" ]; then
    log_error "ADB nie znalezione!"
    exit 1
fi

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
        if [ -f "quick-deploy.sh" ]; then
            sed -i "s/XIAOMI_IP=\"[^\"]*\"/XIAOMI_IP=\"$new_ip_port\"/g" "quick-deploy.sh"
        fi
        XIAOMI_IP="192.168.1.247:41497"
        log_success "Port ADB zaktualizowany we wszystkich skryptach"
    fi
}

# Funkcja połączenia
connect_device() {
    log_info "Łączenie z urządzeniem..."
    update_adb_port  # Aktualizuj port przed połączeniem
    
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
echo "9. Sprawdź ustawienia MIUI/Xiaomi"

read -p "Wybierz opcję (1-9): " choice

connect_device

case $choice in
    1)
        if [ -f "saper-xiaomi-compatible.apk" ]; then
            log_info "Instalowanie aplikacji na MIUI/Xiaomi..."
            log_warning "WAŻNE: Sprawdź telefon - może pojawić się popup!"
            echo "   1. Jeśli pojawi się pytanie o instalację - zaakceptuj"
            echo "   2. Jeśli pojawi się 'Zainstalować tę aplikację?' - kliknij OK"
            echo "   3. Poczekaj na komunikat o instalacji..."
            echo ""
            
            # Próba 1: Standardowa instalacja z replace
            log_info "Próba 1: Standardowa instalacja..."
            if "$ADB_PATH" install -r saper-xiaomi-compatible.apk; then
                log_success "Instalacja zakończona pomyślnie!"
            else
                log_warning "Próba 1 nieudana. Próba 2 z dodatkowymi flagami..."
                
                # Próba 2: Z flagami dla MIUI
                if "$ADB_PATH" install -r -t -d saper-xiaomi-compatible.apk; then
                    log_success "Instalacja zakończona pomyślnie!"
                else
                    log_warning "Próba 2 nieudana. Próba 3: Push i install..."
                    
                    # Próba 3: Push pliku i install przez shell
                    "$ADB_PATH" push saper-xiaomi-compatible.apk /data/local/tmp/
                    "$ADB_PATH" shell pm install -r -t /data/local/tmp/saper-xiaomi-compatible.apk
                    "$ADB_PATH" shell rm /data/local/tmp/saper-xiaomi-compatible.apk
                fi
            fi
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
    9)
        log_info "Sprawdzanie ustawień MIUI/Xiaomi..."
        echo ""
        echo "📋 WYMAGANE USTAWIENIA MIUI:"
        echo "   1. Ustawienia → O telefonie → 7x kliknij 'Numer kompilacji'"
        echo "   2. Ustawienia → Dodatkowe → Opcje dewelopera:"
        echo "      - ✅ Debugowanie USB"
        echo "      - ❌ MIUI optimization (WYŁĄCZ!)"
        echo "      - ✅ Instaluj przez USB"
        echo "      - ✅ Weryfikacja aplikacji przez USB (może być wyłączone)"
        echo ""
        echo "🔍 SPRAWDZANIE USTAWIEŃ:"
        
        # Sprawdź czy opcje dewelopera są włączone
        DEV_OPTIONS=$("$ADB_PATH" shell settings get global development_settings_enabled 2>/dev/null)
        if [ "$DEV_OPTIONS" = "1" ]; then
            log_success "Opcje dewelopera: WŁĄCZONE"
        else
            log_error "Opcje dewelopera: WYŁĄCZONE"
        fi
        
        # Sprawdź debugowanie USB
        USB_DEBUG=$("$ADB_PATH" shell settings get global adb_enabled 2>/dev/null)
        if [ "$USB_DEBUG" = "1" ]; then
            log_success "Debugowanie USB: WŁĄCZONE"
        else
            log_error "Debugowanie USB: WYŁĄCZONE"
        fi
        
        # Sprawdź weryfikację aplikacji
        VERIFY_APPS=$("$ADB_PATH" shell settings get global package_verifier_enable 2>/dev/null)
        if [ "$VERIFY_APPS" = "1" ]; then
            log_warning "Weryfikacja aplikacji: WŁĄCZONA (może blokować instalację)"
        else
            log_success "Weryfikacja aplikacji: WYŁĄCZONA"
        fi
        
        echo ""
        log_info "Jeśli instalacja nadal nie działa:"
        echo "   1. Wyłącz 'MIUI optimization' w opcjach dewelopera"
        echo "   2. Zrestartuj telefon"
        echo "   3. Włącz ponownie debugowanie bezprzewodowe"
        echo "   4. Spróbuj instalacji ponownie"
        ;;
    *)
        log_error "Nieprawidłowa opcja!"
        ;;
esac

log_success "Operacja zakończona!"

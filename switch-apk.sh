#!/bin/bash
# switch-apk.sh - Przełącznik między różnymi typami APK
# Pozwala wybrać który APK ma być używany jako domyślny (symlink)

echo "🔄 === PRZEŁĄCZNIK APK === 🔄"

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

# Sprawdź dostępne APK
echo ""
log_info "Sprawdzanie dostępnych APK..."

available_apks=()
if [ -f "saper-xiaomi-compatible-release.apk" ]; then
    available_apks+=("release")
    RELEASE_SIZE=$(stat -c%s "saper-xiaomi-compatible-release.apk" 2>/dev/null || stat -f%z "saper-xiaomi-compatible-release.apk" 2>/dev/null || echo "unknown")
    echo "   📱 Release APK: $(echo "$RELEASE_SIZE" | awk '{print int($1/1024/1024)}')MB"
fi

if [ -f "saper-xiaomi-compatible-debug.apk" ]; then
    available_apks+=("debug")
    DEBUG_SIZE=$(stat -c%s "saper-xiaomi-compatible-debug.apk" 2>/dev/null || stat -f%z "saper-xiaomi-compatible-debug.apk" 2>/dev/null || echo "unknown")
    echo "   🐛 Debug APK: $(echo "$DEBUG_SIZE" | awk '{print int($1/1024/1024)}')MB"
fi

if [ ${#available_apks[@]} -eq 0 ]; then
    log_error "Nie znaleziono żadnych APK!"
    echo "Uruchom najpierw: bash build-and-deploy.sh"
    exit 1
fi

# Sprawdź obecny symlink
echo ""
if [ -L "saper-xiaomi-compatible.apk" ]; then
    CURRENT_TARGET=$(readlink "saper-xiaomi-compatible.apk")
    log_info "Obecny domyślny APK: $CURRENT_TARGET"
else
    log_warning "Brak symlinka domyślnego APK"
fi

# Menu wyboru
echo ""
log_info "Wybierz APK jako domyślny:"

counter=1
for apk in "${available_apks[@]}"; do
    echo "   $counter) $apk"
    ((counter++))
done

echo ""
read -p "Wybierz opcję (1-${#available_apks[@]}): " -n 1 -r
echo ""

# Walidacja wyboru
if [[ ! $REPLY =~ ^[1-9]$ ]] || [ "$REPLY" -gt "${#available_apks[@]}" ]; then
    log_error "Nieprawidłowy wybór!"
    exit 1
fi

# Pobierz wybrany typ
selected_index=$((REPLY - 1))
selected_type="${available_apks[$selected_index]}"
selected_file="saper-xiaomi-compatible-${selected_type}.apk"

# Usuń istniejący symlink i utwórz nowy
if [ -L "saper-xiaomi-compatible.apk" ] || [ -f "saper-xiaomi-compatible.apk" ]; then
    rm -f "saper-xiaomi-compatible.apk"
fi

ln -sf "$selected_file" "saper-xiaomi-compatible.apk"

if [ $? -eq 0 ]; then
    log_success "Domyślny APK ustawiony na: $selected_type"
    echo "   Symlink: saper-xiaomi-compatible.apk -> $selected_file"
    echo ""
    log_info "Teraz możesz użyć: bash quick-deploy.sh"
else
    log_error "Błąd tworzenia symlinka!"
    exit 1
fi

#!/bin/bash
# setup-android-env.sh
# Skrypt do konfiguracji środowiska Android dla Tauri

echo "🔧 Konfiguracja środowiska Android dla Tauri..."

# Ścieżki do Android SDK i NDK
export ANDROID_HOME="/c/Users/dawid/AppData/Local/Android/Sdk"
export ANDROID_SDK_ROOT="/c/Users/dawid/AppData/Local/Android/Sdk"
export NDK_HOME="/c/Users/dawid/AppData/Local/Android/Sdk/ndk/29.0.13599879"

# Dodanie narzędzi Android do PATH
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin"

# Java (już skonfigurowane)
export JAVA_HOME="/c/Program Files/Amazon Corretto/jdk21.0.2_13"

echo "✅ Zmienne środowiskowe ustawione:"
echo "   ANDROID_HOME: $ANDROID_HOME"
echo "   ANDROID_SDK_ROOT: $ANDROID_SDK_ROOT"
echo "   NDK_HOME: $NDK_HOME"
echo "   JAVA_HOME: $JAVA_HOME"

# Sprawdzenie dostępności narzędzi
echo ""
echo "🔍 Sprawdzanie dostępności narzędzi..."

if command -v adb &> /dev/null; then
    echo "✅ ADB: $(which adb)"
else
    echo "❌ ADB nie znalezione"
fi

if [ -f "$ANDROID_HOME/platform-tools/adb.exe" ]; then
    echo "✅ Android Platform Tools: OK"
else
    echo "❌ Android Platform Tools nie znalezione"
fi

if [ -d "$NDK_HOME" ]; then
    echo "✅ Android NDK: OK"
else
    echo "❌ Android NDK nie znalezione"
fi

echo ""
echo "🚀 Środowisko gotowe! Możesz teraz uruchomić:"
echo "   npx tauri android dev     # Tryb developerski"
echo "   npx tauri android build   # Budowanie APK"

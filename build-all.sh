#!/bin/bash
# build-all.sh
# Skrypt do budowania aplikacji na wszystkich platformach

echo "🚀 Budowanie aplikacji Saper - Tauri na wszystkich platformach..."

# Źródło środowiska
source setup-android-env.sh

echo ""
echo "📦 1. Budowanie dla Windows..."
npx tauri build

if [ $? -eq 0 ]; then
    echo "✅ Windows build: SUKCES"
else
    echo "❌ Windows build: BŁĄD"
    exit 1
fi

echo ""
echo "📱 2. Budowanie dla Android..."
npx tauri android build

if [ $? -eq 0 ]; then
    echo "✅ Android build: SUKCES"
    echo ""
    echo "📍 Pliki wynikowe:"
    echo "   Windows: src-tauri/target/release/bundle/"
    echo "   Android: src-tauri/gen/android/app/build/outputs/apk/"
else
    echo "❌ Android build: BŁĄD"
    exit 1
fi

echo ""
echo "🎉 Wszystkie buildy zakończone pomyślnie!"

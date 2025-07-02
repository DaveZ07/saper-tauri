# Makefile dla projektu Saper - Tauri
# Użycie: make [target]

.PHONY: help setup dev build-windows build-android build-all clean

help: ## Wyświetl dostępne komendy
	@echo "Dostępne komendy:"
	@echo "  setup          - Konfiguracja środowiska"
	@echo "  dev            - Uruchom w trybie development (Windows)"
	@echo "  dev-android    - Uruchom w trybie development (Android)"
	@echo "  build-windows  - Zbuduj aplikację Windows"
	@echo "  build-android  - Zbuduj aplikację Android"
	@echo "  build-all      - Zbuduj na wszystkich platformach"
	@echo "  clean          - Wyczyść pliki build"

setup: ## Konfiguruj środowisko
	@echo "🔧 Konfiguracja środowiska..."
	@bash setup-android-env.sh

dev: ## Uruchom tryb development (Windows)
	@echo "🚀 Uruchamianie trybu development (Windows)..."
	@bash setup-android-env.sh && npx tauri dev

dev-android: ## Uruchom tryb development (Android)
	@echo "📱 Uruchamianie trybu development (Android)..."
	@ANDROID_HOME="/c/Users/dawid/AppData/Local/Android/Sdk" ANDROID_SDK_ROOT="/c/Users/dawid/AppData/Local/Android/Sdk" NDK_HOME="/c/Users/dawid/AppData/Local/Android/Sdk/ndk/29.0.13599879" JAVA_HOME="/c/Program Files/Amazon Corretto/jdk21.0.2_13" PATH="$$PATH:/c/Users/dawid/AppData/Local/Android/Sdk/platform-tools:/c/Users/dawid/AppData/Local/Android/Sdk/tools:/c/Users/dawid/AppData/Local/Android/Sdk/tools/bin" npx tauri android dev

build-windows: ## Zbuduj aplikację Windows
	@echo "📦 Budowanie aplikacji Windows..."
	@bash setup-android-env.sh && npx tauri build

build-android: ## Zbuduj aplikację Android
	@echo "📱 Budowanie aplikacji Android..."
	@ANDROID_HOME="/c/Users/dawid/AppData/Local/Android/Sdk" ANDROID_SDK_ROOT="/c/Users/dawid/AppData/Local/Android/Sdk" NDK_HOME="/c/Users/dawid/AppData/Local/Android/Sdk/ndk/29.0.13599879" JAVA_HOME="/c/Program Files/Amazon Corretto/jdk21.0.2_13" PATH="$$PATH:/c/Users/dawid/AppData/Local/Android/Sdk/platform-tools:/c/Users/dawid/AppData/Local/Android/Sdk/tools:/c/Users/dawid/AppData/Local/Android/Sdk/tools/bin" npx tauri android build

build-all: ## Zbuduj na wszystkich platformach
	@echo "🚀 Budowanie na wszystkich platformach..."
	@bash build-all.sh

clean: ## Wyczyść pliki build
	@echo "🧹 Czyszczenie plików build..."
	@rm -rf src-tauri/target/
	@rm -rf src-tauri/gen/android/app/build/
	@echo "✅ Czyszczenie zakończone"

install-deps: ## Zainstaluj zależności
	@echo "📦 Instalowanie zależności..."
	@npm install
	@echo "✅ Zależności zainstalowane"

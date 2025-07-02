# setup-android-env.ps1
# Skrypt PowerShell do konfiguracji środowiska Android dla Tauri

Write-Host "🔧 Konfiguracja środowiska Android dla Tauri..." -ForegroundColor Cyan

# Ścieżki do Android SDK i NDK
$env:ANDROID_HOME = "C:\Users\dawid\AppData\Local\Android\Sdk"
$env:ANDROID_SDK_ROOT = "C:\Users\dawid\AppData\Local\Android\Sdk"
$env:NDK_HOME = "C:\Users\dawid\AppData\Local\Android\Sdk\ndk\29.0.13599879"

# Dodanie narzędzi Android do PATH
$env:PATH = "$env:PATH;$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\tools;$env:ANDROID_HOME\tools\bin"

# Java (już skonfigurowane)
$env:JAVA_HOME = "C:\Program Files\Amazon Corretto\jdk21.0.2_13"

Write-Host "✅ Zmienne środowiskowe ustawione:" -ForegroundColor Green
Write-Host "   ANDROID_HOME: $env:ANDROID_HOME"
Write-Host "   ANDROID_SDK_ROOT: $env:ANDROID_SDK_ROOT"
Write-Host "   NDK_HOME: $env:NDK_HOME"
Write-Host "   JAVA_HOME: $env:JAVA_HOME"

Write-Host ""
Write-Host "🔍 Sprawdzanie dostępności narzędzi..." -ForegroundColor Yellow

# Sprawdzenie ADB
if (Test-Path "$env:ANDROID_HOME\platform-tools\adb.exe") {
    Write-Host "✅ ADB: OK" -ForegroundColor Green
} else {
    Write-Host "❌ ADB nie znalezione" -ForegroundColor Red
}

# Sprawdzenie Android Platform Tools
if (Test-Path "$env:ANDROID_HOME\platform-tools") {
    Write-Host "✅ Android Platform Tools: OK" -ForegroundColor Green
} else {
    Write-Host "❌ Android Platform Tools nie znalezione" -ForegroundColor Red
}

# Sprawdzenie NDK
if (Test-Path $env:NDK_HOME) {
    Write-Host "✅ Android NDK: OK" -ForegroundColor Green
} else {
    Write-Host "❌ Android NDK nie znalezione" -ForegroundColor Red
}

Write-Host ""
Write-Host "🚀 Środowisko gotowe! Możesz teraz uruchomić:" -ForegroundColor Cyan
Write-Host "   npx tauri android dev     # Tryb developerski"
Write-Host "   npx tauri android build   # Budowanie APK"

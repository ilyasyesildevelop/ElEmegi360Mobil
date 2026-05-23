# Windows: Proje D: sürücüsündeyken Pub önbelleği de D: olmalı (Gradle "different roots" hatası).
# Kalıcı çözüm: Sistem ortam değişkeni PUB_CACHE = D:\AndroidSDK\PubCache

$ErrorActionPreference = "Stop"
$pubCache = if ($env:PUB_CACHE) { $env:PUB_CACHE } else { "D:\AndroidSDK\PubCache" }
$env:PUB_CACHE = $pubCache
New-Item -ItemType Directory -Force -Path $pubCache | Out-Null

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$flutter = "D:\AndroidSDK\FlutterSDK\bin\flutter.bat"
if (-not (Test-Path $flutter)) {
    $flutter = "flutter"
}

$deps = Join-Path $root ".flutter-plugins-dependencies"
if ((Test-Path $deps) -and (Select-String -Path $deps -Pattern "AppData\\Local\\Pub\\Cache" -Quiet)) {
    Write-Host "C: Pub Cache yolu tespit edildi — fix-pub-cache çalıştırılıyor..."
    & (Join-Path $PSScriptRoot "fix-pub-cache.ps1")
} else {
    & $flutter pub get
}
& $flutter run @args

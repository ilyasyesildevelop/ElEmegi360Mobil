# Gradle "different roots" (D: proje + C: Pub Cache) — plugin yollarını D: önbelleğe yeniler.
# Android Studio / Cursor: kullanıcı ortam değişkeni PUB_CACHE = D:\AndroidSDK\PubCache (IDE yeniden başlat).

$ErrorActionPreference = "Stop"
$pubCache = "D:\AndroidSDK\PubCache"
$env:PUB_CACHE = $pubCache
New-Item -ItemType Directory -Force -Path $pubCache | Out-Null

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

$flutter = "D:\AndroidSDK\FlutterSDK\bin\flutter.bat"
if (-not (Test-Path $flutter)) { $flutter = "flutter" }

Write-Host "PUB_CACHE=$pubCache"
Write-Host "Temizleniyor..."
& $flutter clean
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue `
    build, .dart_tool, .flutter-plugins, .flutter-plugins-dependencies

Write-Host "pub get..."
& $flutter pub get

$deps = Join-Path $root ".flutter-plugins-dependencies"
if (Select-String -Path $deps -Pattern "AppData\\Local\\Pub\\Cache" -Quiet) {
    Write-Error "Hâlâ C: Pub Cache yolu var. PUB_CACHE bu oturumda uygulanmamış olabilir."
}
Write-Host "Tamam — plugin yolları D: önbelleğe işlendi."
Write-Host ""
Write-Host "Masaustu kisayolu icin: scripts\Masaustu-Kisayol-Olustur.bat (bir kez)"

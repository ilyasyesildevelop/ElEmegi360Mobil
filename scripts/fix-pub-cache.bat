@echo off
chcp 65001 >nul
title El Emeği 360 — Pub Cache düzelt (D: sürücü)
cd /d "%~dp0"

echo.
echo  Fabrika360 / El Emeği 360
echo  Gradle "different roots" onarimi (PUB_CACHE = D:\AndroidSDK\PubCache)
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0fix-pub-cache.ps1"
set ERR=%ERRORLEVEL%

echo.
if %ERR% NEQ 0 (
    echo  HATA: Islem basarisiz (kod %ERR%).
) else (
    echo  Bitti. Simdi Android Studio''yu kapatip acin, sonra Run.
)
echo.
pause
exit /b %ERR%

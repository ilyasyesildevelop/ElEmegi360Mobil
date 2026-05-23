@echo off
chcp 65001 >nul
title El Emeği 360 — Release APK
cd /d "%~dp0\.."

set PUB_CACHE=D:\AndroidSDK\PubCache
set PATH=D:\AndroidSDK\FlutterSDK\bin;%PATH%

echo Release APK derleniyor...
call flutter build apk --release
if errorlevel 1 (
    echo Derleme basarisiz.
    pause
    exit /b 1
)

echo.
echo Cikti klasoru:
echo   build\app\outputs\flutter-apk\
echo   build\app\outputs\apk\release\
echo.
echo GitHub: fabrika360-updates / elemegi360 / version.json ile versionCode uyumlu olmali.
echo.
pause

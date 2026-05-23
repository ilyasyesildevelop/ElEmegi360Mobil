@echo off
chcp 65001 >nul
set "TARGET=%~dp0fix-pub-cache.bat"
set "DESKTOP=%USERPROFILE%\Desktop"
set "LINK=%DESKTOP%\El Emeği 360 - Pub Cache Düzelt.lnk"

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$ws = New-Object -ComObject WScript.Shell; ^
   $s = $ws.CreateShortcut('%LINK%'); ^
   $s.TargetPath = '%TARGET%'; ^
   $s.WorkingDirectory = '%~dp0'; ^
   $s.WindowStyle = 1; ^
   $s.Description = 'Flutter pub get D: onbellek - Gradle different roots'; ^
   $s.Save()"

if exist "%LINK%" (
    echo Masaustu kisayolu olusturuldu:
    echo   %LINK%
) else (
    echo Kisayol olusturulamadi.
)
pause

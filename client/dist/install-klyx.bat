@echo off
title Klyx Tunnel Installer
color 0B
cls

echo.
echo ===============================================
echo    KLYX TUNNEL INSTALLER
echo    Fast tunneling for local services
echo ===============================================
echo.
echo Downloading installer...
echo.

powershell -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/klyxAgency/tunnel/main/klyx-installer-dark.ps1' -OutFile '%TEMP%\klyx-install.ps1'; Write-Host 'Download complete!' -ForegroundColor Green; Start-Process powershell -Verb RunAs -ArgumentList '-NoExit -ExecutionPolicy Bypass -File %TEMP%\klyx-install.ps1' } catch { Write-Host 'ERROR:' $_.Exception.Message -ForegroundColor Red; Read-Host 'Press Enter to exit' }"

echo.
echo Check the new window that opened.
echo If no window opened, there was an error above.
echo.
pause

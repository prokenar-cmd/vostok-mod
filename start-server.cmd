@echo off
title VOSTOK PERFECT LOCAL SERVER
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start_server.ps1"

echo.
pause

@echo off
powershell.exe -NoProfile -Command "Get-Process omp-server -ErrorAction SilentlyContinue | Stop-Process -Force"
echo open.mp stopped. MariaDB was left running for the next start.
pause

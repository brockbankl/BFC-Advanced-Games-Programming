@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Setup-Assessment1.ps1"
exit /b %ERRORLEVEL%

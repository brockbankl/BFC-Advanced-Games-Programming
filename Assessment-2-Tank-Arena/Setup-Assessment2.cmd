@echo off
setlocal
echo [INFO] Starting Tank Arena setup through PowerShell...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Setup-Assessment2.ps1"
set "exitCode=%ERRORLEVEL%"
if not "%exitCode%"=="0" (
  echo [FAIL] Setup stopped with exit code %exitCode%. Read the messages above before closing this window.
  pause
)
exit /b %exitCode%

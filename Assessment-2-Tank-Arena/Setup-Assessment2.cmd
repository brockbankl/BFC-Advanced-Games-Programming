@echo off
setlocal
rem Beginner-friendly launcher for File Explorer. The policy override is only
rem for this PowerShell process; it does not change Windows security settings.
echo.
echo BFC Advanced Games Programming - Assessment 2 Tank Arena setup
echo Starting the checked setup script. Please read this window until it finishes.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Setup-Assessment2.ps1"
set "BFC_SETUP_EXIT=%ERRORLEVEL%"
echo.
if "%BFC_SETUP_EXIT%"=="0" (
    echo Setup finished successfully. Open this folder in VS Code, then use Terminal -^> Run Task -^> BFC: Run Tank Arena.
    echo You can also run: powershell -NoProfile -ExecutionPolicy Bypass -File .\Run-Assessment2.ps1 start
) else (
    echo Setup stopped with exit code %BFC_SETUP_EXIT%. Keep this window open and show the message to your lecturer or IT.
)
rem Double-clicking normally starts cmd.exe with /c. Keep that window open so
rem beginners can read the result; /NoPause is useful from a terminal.
echo %CMDCMDLINE% | findstr /i /c:"/c" >nul
if not errorlevel 1 if /i not "%~1"=="/NoPause" pause
exit /b %BFC_SETUP_EXIT%

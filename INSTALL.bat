@echo off
REM ============================================================================
REM Unicode Monitor System - One-Click Installer
REM Auto-elevates to Administrator and runs PowerShell setup
REM ============================================================================

title Unicode Monitor System - Installation

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with Administrator privileges...
    echo.
    goto :RunSetup
) else (
    echo.
    echo ============================================================================
    echo ELEVATION REQUIRED
    echo ============================================================================
    echo.
    echo This installer needs Administrator privileges.
    echo Requesting elevation...
    echo.

    REM Request elevation and re-run this script
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:RunSetup
echo ============================================================================
echo Unicode Monitor System - Complete Setup
echo ============================================================================
echo.
echo This will install:
echo   - Optimized batch replacer (1.94x faster)
echo   - Real-time monitoring Windows Service
echo   - Interactive log viewer
echo   - Public desktop shortcut (all users)
echo   - Auto-start on boot
echo.
echo ============================================================================
echo.

pause

REM Get script directory
set SCRIPT_DIR=%~dp0

REM Run PowerShell setup
echo.
echo Running setup...
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%Setup-UnicodeMonitorSystem.ps1"

if %errorLevel% == 0 (
    echo.
    echo ============================================================================
    echo INSTALLATION COMPLETE
    echo ============================================================================
    echo.
    echo The Unicode Monitor System is now installed and running!
    echo.
    echo Next steps:
    echo   1. Check desktop for "Unicode Monitor Logs" shortcut
    echo   2. Double-click to view real-time monitoring
    echo   3. Service auto-starts on boot
    echo.
    echo ============================================================================
) else (
    echo.
    echo ============================================================================
    echo INSTALLATION FAILED
    echo ============================================================================
    echo.
    echo Please check the error messages above.
    echo.
    echo For help, see: README.md
    echo.
    echo ============================================================================
)

echo.
pause

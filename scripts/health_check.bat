@echo off
REM Automation Health Check Script for Windows
REM This script runs a comprehensive health check of the automation system

echo ================================
echo AshTrail Automation Health Check
echo ================================

REM Change to project directory
cd /d "%~dp0\.."

echo.
echo [*] Running comprehensive automation check...
echo.

python scripts\automation_monitor.py check

echo.
echo [*] Quick Commands:
echo   Monitor a feature:     python scripts\automation_monitor.py monitor --feature-id ui.app_shell
echo   View metrics:          python scripts\automation_monitor.py metrics
echo   Full automation:       python scripts\auto_implement_feature.py ui.app_shell
echo.
echo [*] For help: python scripts\automation_monitor.py --help

pause

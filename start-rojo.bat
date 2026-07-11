@echo off
title Rojo - PartyObbyGame

echo ================================
echo Starting PartyObbyGame Rojo
echo ================================
echo.

cd /d "%~dp0"

echo Current folder:
cd
echo.

if not exist "default.project.json" (
    echo ERROR: default.project.json not found.
    pause
    exit /b 1
)

if not exist "C:\Tools\Rojo\rojo.exe" (
    echo ERROR: Rojo not found at:
    echo C:\Tools\Rojo\rojo.exe
    pause
    exit /b 1
)

echo Starting Rojo on port 34873...
echo Studio address: localhost:34873
echo.

"C:\Tools\Rojo\rojo.exe" serve "default.project.json" --port 34873

echo.
echo Rojo stopped or failed to start.
pause
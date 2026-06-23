@echo off
setlocal
title Territorial USER BUILD
cd /d "%~dp0"
set "GAME_URL=https://kevin-lozada-santos.github.io/territorial-multiplayer/index.html?build=user"

echo ============================================================
echo Territorial - USER BUILD
echo Build: STABLE-LOCALHOST-8000-USER-TEXT-CLEANUP
echo ============================================================
echo.
echo Opening the public HTTPS build.
echo No local server, Python, or install step is required.
echo.

if not exist "index.html" (
  echo NOTE: index.html is not next to this launcher.
  echo The hosted build will still open in your browser.
  echo.
)

start "" "%GAME_URL%"

echo.
echo If the browser did not open, paste this URL:
echo %GAME_URL%
pause

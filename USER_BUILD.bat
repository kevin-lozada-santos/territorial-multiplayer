@echo off
setlocal
title Territorial USER BUILD
cd /d "%~dp0"

echo ============================================================
echo Territorial - USER BUILD
echo Build: STABLE-LOCALHOST-8000-USER-TEXT-CLEANUP
echo ============================================================
echo.
echo This version uses localhost:8000 and does NOT require Python.
echo Keep this black window open while playing.
echo.

if not exist "index.html" (
  echo ERROR: index.html is missing.
  echo Extract the ZIP first, then run this BAT from the extracted folder.
  echo.
  pause
  exit /b 1
)

if not exist "serve_localhost_8000.ps1" (
  echo ERROR: serve_localhost_8000.ps1 is missing.
  echo Re-extract the ZIP so all files are together.
  echo.
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0serve_localhost_8000.ps1" -Mode user

echo.
echo Launcher stopped or failed.
pause

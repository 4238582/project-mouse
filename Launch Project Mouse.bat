@echo off
title Project Mouse Launcher
echo.
echo  ==========================================
echo   Project Mouse - Starting...
echo  ==========================================
echo.

set FOLDER=%~dp0

:: Open as standalone app in Chrome with custom icon
start "" "chrome.exe" --app="file:///%FOLDER%index.html" --window-size=430,900

if errorlevel 1 (
  start "" "%FOLDER%index.html"
)

timeout /t 2 >nul
exit

@echo off
setlocal enabledelayedexpansion
title Project Mouse Installer
color 0A
cls

echo.
echo  ============================================================
echo.
echo         PROJECT MOUSE - Windows Installer
echo         Car Photo Manager - Hull Hyundai
echo.
echo  ============================================================
echo.
echo  Installing Project Mouse on your computer...
echo.

set INSTALL_DIR=%LOCALAPPDATA%\ProjectMouse

echo  [1/5] Creating installation folder...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
echo        Done!
echo.

echo  [2/5] Copying application files...
xcopy /E /I /Y "%~dp0*.*" "%INSTALL_DIR%\" >nul 2>&1
echo        Done!
echo.

echo  [3/5] Creating Desktop shortcut with icon...
powershell -NoProfile -Command ^
  "$ico = '%INSTALL_DIR%\ProjectMouse.ico';" ^
  "$ws = New-Object -ComObject WScript.Shell;" ^
  "$s = $ws.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\Project Mouse.lnk');" ^
  "$s.TargetPath = (Get-Command chrome.exe -ErrorAction SilentlyContinue).Source;" ^
  "if (-not $s.TargetPath) { $s.TargetPath = 'C:\Program Files\Google\Chrome\Application\chrome.exe' };" ^
  "$s.Arguments = '--app=""file:///%INSTALL_DIR:\=/%/index.html"" --window-size=430,900';" ^
  "$s.IconLocation = $ico + ',0';" ^
  "$s.WorkingDirectory = '%INSTALL_DIR%';" ^
  "$s.Description = 'Project Mouse - Car Photo Manager';" ^
  "$s.Save();" ^
  "Write-Host 'Shortcut created with icon'"
echo        Desktop shortcut created with chibi mouse icon!
echo.

echo  [4/5] Adding to Start Menu...
powershell -NoProfile -Command ^
  "$smDir = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Project Mouse';" ^
  "New-Item -ItemType Directory -Force -Path $smDir | Out-Null;" ^
  "$ico = '%INSTALL_DIR%\ProjectMouse.ico';" ^
  "$ws = New-Object -ComObject WScript.Shell;" ^
  "$s = $ws.CreateShortcut((Join-Path $smDir 'Project Mouse.lnk'));" ^
  "$s.TargetPath = (Get-Command chrome.exe -ErrorAction SilentlyContinue).Source;" ^
  "if (-not $s.TargetPath) { $s.TargetPath = 'C:\Program Files\Google\Chrome\Application\chrome.exe' };" ^
  "$s.Arguments = '--app=""file:///%INSTALL_DIR:\=/%/index.html"" --window-size=430,900';" ^
  "$s.IconLocation = $ico + ',0';" ^
  "$s.Description = 'Project Mouse - Car Photo Manager';" ^
  "$s.Save()"
if exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Project Mouse\Project Mouse.lnk" (
  echo        Start Menu entry added!
) else (
  echo        WARNING: Start Menu shortcut failed - Desktop icon still works fine.
)
echo.

echo  [5/5] Finalizing...
:: Rebuild icon cache so Windows shows it immediately
ie4uinit.exe -show >nul 2>&1
taskkill /IM explorer.exe /F >nul 2>&1
start explorer.exe >nul 2>&1
echo        Icon cache refreshed!
echo.

echo  ============================================================
echo.
echo    Project Mouse installed successfully!
echo.
echo    - Chibi mouse icon on your Desktop
echo    - Added to Start Menu
echo    - Double-click the desktop icon to launch!
echo.
echo  ============================================================
echo.
pause

start "" "C:\Program Files\Google\Chrome\Application\chrome.exe" --app="file:///%INSTALL_DIR:\=/%/index.html" --window-size=430,900

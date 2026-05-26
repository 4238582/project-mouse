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

:: Set install location
set INSTALL_DIR=%LOCALAPPDATA%\ProjectMouse

:: Create install folder
echo  [1/5] Creating installation folder...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
echo        Done! Installed to: %INSTALL_DIR%
echo.

:: Copy all files
echo  [2/5] Copying application files...
xcopy /E /I /Y "%~dp0*.*" "%INSTALL_DIR%\" >nul 2>&1
echo        Done!
echo.

:: Create Desktop Shortcut using PowerShell
echo  [3/5] Creating Desktop shortcut...
powershell -Command ^
  "$ws = New-Object -ComObject WScript.Shell; ^
   $s = $ws.CreateShortcut('%USERPROFILE%\Desktop\Project Mouse.lnk'); ^
   $s.TargetPath = 'chrome.exe'; ^
   $s.Arguments = '--app=\"file:///%INSTALL_DIR:\=/%/index.html\" --window-size=430,900'; ^
   $s.IconLocation = '%INSTALL_DIR%\ProjectMouse.ico'; ^
   $s.Description = 'Project Mouse - Car Photo Manager'; ^
   $s.Save()"
echo        Desktop shortcut created!
echo.

:: Create Start Menu shortcut
echo  [4/5] Adding to Start Menu...
if not exist "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Project Mouse" ^
  mkdir "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Project Mouse"
powershell -Command ^
  "$ws = New-Object -ComObject WScript.Shell; ^
   $s = $ws.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\Project Mouse\Project Mouse.lnk'); ^
   $s.TargetPath = 'chrome.exe'; ^
   $s.Arguments = '--app=\"file:///%INSTALL_DIR:\=/%/index.html\" --window-size=430,900'; ^
   $s.IconLocation = '%INSTALL_DIR%\ProjectMouse.ico'; ^
   $s.Description = 'Project Mouse - Car Photo Manager'; ^
   $s.Save()"
echo        Start Menu entry added!
echo.

:: Create uninstaller
echo  [5/5] Creating uninstaller...
echo @echo off > "%INSTALL_DIR%\Uninstall Project Mouse.bat"
echo title Uninstall Project Mouse >> "%INSTALL_DIR%\Uninstall Project Mouse.bat"
echo echo Uninstalling Project Mouse... >> "%INSTALL_DIR%\Uninstall Project Mouse.bat"
echo del "%USERPROFILE%\Desktop\Project Mouse.lnk" >> "%INSTALL_DIR%\Uninstall Project Mouse.bat"
echo rmdir /S /Q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Project Mouse" >> "%INSTALL_DIR%\Uninstall Project Mouse.bat"
echo rmdir /S /Q "%INSTALL_DIR%" >> "%INSTALL_DIR%\Uninstall Project Mouse.bat"
echo echo Done! Project Mouse has been uninstalled. >> "%INSTALL_DIR%\Uninstall Project Mouse.bat"
echo pause >> "%INSTALL_DIR%\Uninstall Project Mouse.bat"
echo        Uninstaller created!
echo.

echo  ============================================================
echo.
echo    Project Mouse installed successfully!
echo.
echo    - Desktop shortcut created
echo    - Start Menu entry added  
echo    - Double-click the icon on your Desktop to launch
echo.
echo  ============================================================
echo.
pause

:: Launch the app after install
start "" "chrome.exe" --app="file:///%INSTALL_DIR:\=/%/index.html" --window-size=430,900

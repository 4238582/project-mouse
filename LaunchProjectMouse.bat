@echo off
rem Starts the local dev server (harmless no-op if one's already running on
rem this port) then opens Snake's Hustle as an app window. Runs from the
rem live repo folder so it always reflects your latest local edits.
set REPO_DIR=C:\Users\jeepe\OneDrive\Documents\GitHub\project-mouse
set PORT=5501

start "ProjectMouseServer" /min cmd /c "cd /d "%REPO_DIR%" && npx --yes serve -l %PORT% ."
timeout /t 2 /nobreak >nul

set CHROME=C:\Program Files\Google\Chrome\Application\chrome.exe
if not exist "%CHROME%" set CHROME=C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
start "" "%CHROME%" --app="http://localhost:%PORT%" --window-size=430,900

@echo off
title 🐭 Project Mouse - Auto Deployer
color 0A
cls

echo.
echo  ============================================================
echo.
echo         PROJECT MOUSE - Auto Deployer
echo         One click deploy to Netlify!
echo.
echo  ============================================================
echo.

:: Check if Node.js is installed
node --version >nul 2>&1
if errorlevel 1 (
    echo  [!] Node.js not found. Installing now...
    echo  [!] Please download Node.js from https://nodejs.org
    echo  [!] Install it, then run this script again!
    pause
    start https://nodejs.org
    exit
)

echo  [1/4] Checking Netlify CLI...
call netlify --version >nul 2>&1
if errorlevel 1 (
    echo  Installing Netlify CLI... ^(one time only^)
    call npm install -g netlify-cli
    echo  Done!
)
echo        Netlify CLI ready!
echo.

echo  [2/4] Logging into Netlify...
echo        ^(A browser window will open - sign in once^)
call netlify login
echo.

echo  [3/4] Deploying Project Mouse...
echo        Uploading files to Netlify...
cd /d "%~dp0"
call netlify deploy --prod --dir . --site majestic-elf-6ab83b
echo.

echo  [4/4] Done!
echo.
echo  ============================================================
echo.
echo    Project Mouse is LIVE! 
echo    https://majestic-elf-6ab83b.netlify.app
echo.
echo    Your app updated everywhere automatically!
echo    Phone + PC + everywhere! 
echo.
echo  ============================================================
echo.
pause
start https://majestic-elf-6ab83b.netlify.app

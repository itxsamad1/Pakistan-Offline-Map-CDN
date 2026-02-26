@echo off
title S4 Map Server
color 0B
echo.
echo  ============================================
echo   S4 OFFLINE MAP SERVER — STARTING
echo  ============================================
echo.

REM Check node is installed
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERROR] Node.js not found! Install from nodejs.org
    pause
    exit /b 1
)

REM Install dependencies if node_modules missing
if not exist "server\node_modules" (
    echo  Installing server dependencies (first run only)...
    cd server
    npm install
    cd ..
    echo.
)

REM Check if tiles exist
set TILES_FOUND=0
for %%f in (*.mbtiles) do set TILES_FOUND=1
if "%TILES_FOUND%"=="0" (
    echo  [WARNING] No .mbtiles file found!
    echo  Run GENERATE-TILES.bat first to generate tiles.
    echo  Server will start but map will be empty.
    echo.
)

REM Get LAN IP
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /r "IPv4"') do (
    set LAN_IP=%%a
    goto :gotip
)
:gotip
set LAN_IP=%LAN_IP: =%

echo  Starting server...
echo.
echo  Your teammates should open:
echo.
echo      http://%LAN_IP%:3000
echo.
echo  (Make sure you are on the same WiFi / LAN)
echo.
echo  Press Ctrl+C to stop the server.
echo  ============================================
echo.

cd server
node server.js

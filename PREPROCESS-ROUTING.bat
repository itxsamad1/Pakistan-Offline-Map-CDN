@echo off
title OSRM Route Preprocessor for Pakistan
color 0A
echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║    OSRM Offline Routing — Preprocessing Pakistan    ║
echo ╚══════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

REM ── Find the OSM PBF file ──────────────────────────────────────────────────
set OSM_FILE=
for %%f in (*.osm.pbf) do set OSM_FILE=%%f

if "%OSM_FILE%"=="" (
    echo ❌ ERROR: No .osm.pbf file found in %CD%
    echo    Download the Pakistan PBF from geofabrik.de and place it here.
    pause
    exit /b 1
)

echo   Found: %OSM_FILE%
echo.

REM ── Install osrm npm package in the server directory ─────────────────────
echo [1/4] Installing osrm npm package...
cd server
call npm install osrm --save 2>nul
if %errorlevel% neq 0 (
    echo ❌ Failed to install osrm. Check your Node.js version.
    cd ..
    pause
    exit /b 1
)
cd ..
echo ✅ osrm installed.
echo.

REM ── Paths ──────────────────────────────────────────────────────────────────
set NODE_EXE=node
set OSRM_EXTRACT=node_modules\.bin\osrm-extract
set OSRM_PARTITION=node_modules\.bin\osrm-partition
set OSRM_CUSTOMIZE=node_modules\.bin\osrm-customize
set PROFILE=server\node_modules\osrm\profiles\car.lua

cd server

echo [2/4] Extracting road network from %OSM_FILE%...
echo       (This may take 5-15 minutes depending on your hardware)
call npx osrm-extract -p node_modules\osrm\profiles\car.lua ..\%OSM_FILE%
if %errorlevel% neq 0 (
    echo ❌ osrm-extract failed.
    cd ..
    pause
    exit /b 1
)
echo ✅ Extraction complete.
echo.

echo [3/4] Partitioning...
call npx osrm-partition ..\pakistan.osrm
if %errorlevel% neq 0 (
    echo ❌ osrm-partition failed.
    cd ..
    pause
    exit /b 1
)
echo ✅ Partition complete.
echo.

echo [4/4] Customizing...
call npx osrm-customize ..\pakistan.osrm
if %errorlevel% neq 0 (
    echo ❌ osrm-customize failed.
    cd ..
    pause
    exit /b 1
)
echo ✅ Customization complete.
cd ..
echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║  ✅ Offline routing ready! Restart START-SERVER.bat ║
echo ╚══════════════════════════════════════════════════════╝
echo.
pause

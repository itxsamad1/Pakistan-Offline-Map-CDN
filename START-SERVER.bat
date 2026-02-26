@echo off
title S4 Map - Server
color 0A
echo.
echo  ============================================
echo   S4 OFFLINE MAP SERVER
echo  ============================================
echo.

cd /d "%~dp0"

REM Install dependencies if needed
if not exist "server\node_modules" (
    echo  Installing server dependencies...
    cd server
    npm install
    cd ..
    echo.
)

REM Check for .mbtiles file
set TILES_FOUND=0
for %%f in (*.mbtiles) do set TILES_FOUND=1
if "%TILES_FOUND%"=="0" (
    echo  [ERROR] No .mbtiles file found!
    echo  Run GENERATE-TILES.bat first.
    pause
    exit /b 1
)

REM Download fonts if missing
if not exist "server\fonts\Open Sans Bold\0-255.pbf" (
    echo  Downloading offline font pack ^(70MB, one-time^)...
    echo.
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/openmaptiles/fonts/releases/download/v2.0/v2.0.zip' -OutFile 'fonts_v2.0.zip'"
    
    echo  Extracting fonts for map labels...
    powershell -Command "Add-Type -AssemblyName System.IO.Compression.FileSystem; $zip = [System.IO.Compression.ZipFile]::OpenRead('fonts_v2.0.zip'); $target = 'server\fonts'; foreach ($entry in $zip.Entries) { if ($entry.FullName -like 'Open Sans Bold/*' -or $entry.FullName -like 'Open Sans Regular/*') { $destPath = Join-Path $target $entry.FullName; $destDir = Split-Path $destPath -Parent; if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Force $destDir | Out-Null }; if ($entry.Name -ne '') { [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $destPath, $true) } } }; $zip.Dispose()"
    
    echo  Cleaning up font zip file...
    del fonts_v2.0.zip
    echo  Fonts ready for offline use.
    echo.
)

REM Start server
echo  Starting map server...
echo.
cd server
node server.js

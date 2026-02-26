@echo off
title S4 Map - Tile Generator
color 0A
echo.
echo  ============================================
echo   S4 OFFLINE MAP - TILE GENERATOR
echo  ============================================
echo.

REM Set Java 21 path (required for Planetiler)
set JAVA_HOME=C:\Program Files\Java\jdk-21
set PATH=%JAVA_HOME%\bin;%PATH%

REM Verify Java 21
java -version 2>&1 | findstr /i "21" >nul
if %errorlevel% neq 0 (
    echo  [ERROR] Java 21 not found at %JAVA_HOME%
    echo  Make sure JDK 21 is installed.
    pause
    exit /b 1
)

REM Find .osm.pbf file
set OSM_FILE=
for %%f in (*.osm.pbf) do set OSM_FILE=%%f

if "%OSM_FILE%"=="" (
    echo  [ERROR] No .osm.pbf file found!
    pause
    exit /b 1
)

echo  Java 21  : OK
echo  OSM file : %OSM_FILE%
echo  Output   : pakistan.mbtiles
echo.

if not exist "planetiler.jar" (
    echo  Downloading Planetiler v0.8.3...
    curl -L "https://github.com/onthegomap/planetiler/releases/download/v0.8.3/planetiler.jar" -o planetiler.jar --progress-bar
    echo.
)

echo  Starting tile generation (5-15 mins)...
echo  *** Do NOT close this window ***
echo.

java -Xmx3g -jar planetiler.jar --osm-path="%OSM_FILE%" --output="pakistan.mbtiles" --threads=2 --download

if %errorlevel% neq 0 (
    echo.
    echo  [ERROR] Tile generation failed!
    pause
    exit /b 1
)

echo.
echo  ============================================
echo   SUCCESS! Tiles saved to: pakistan.mbtiles
echo   Now run: START-SERVER.bat
echo  ============================================
echo.
pause

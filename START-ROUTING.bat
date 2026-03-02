@echo off
title GraphHopper Offline Router — Pakistan
color 0A
echo.
echo ╔══════════════════════════════════════════════════════╗
echo ║        GraphHopper Offline Routing — Pakistan        ║
echo ╚══════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

REM ── Download GraphHopper JAR if not already present ───────────────────────
REM ── Delete corrupt/empty JAR from a previous failed download ─────────────
if exist graphhopper.jar (
    for %%A in (graphhopper.jar) do (
        if %%~zA LSS 1000000 (
            echo Corrupt graphhopper.jar detected. Deleting and re-downloading...
            del graphhopper.jar
        )
    )
)

if not exist graphhopper.jar (
    echo Downloading GraphHopper 9.1... (~50 MB, one-time only)
    echo.
    powershell -NoProfile -Command ^
        "$url = 'https://github.com/graphhopper/graphhopper/releases/download/9.1/graphhopper-web-9.1.jar';" ^
        "Write-Host 'Downloading from GitHub Releases (this may take a minute)...';" ^
        "try {" ^
        "  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;" ^
        "  Invoke-WebRequest -Uri $url -OutFile 'graphhopper.jar' -UseBasicParsing;" ^
        "  Write-Host 'Done.';" ^
        "} catch { Write-Host ('FAILED: ' + $_.Exception.Message); exit 1 }"

    if %errorlevel% neq 0 (
        echo Download failed.
        if exist graphhopper.jar del graphhopper.jar
        pause
        exit /b 1
    )
    REM Validate the download is a real JAR
    for %%A in (graphhopper.jar) do (
        if %%~zA LSS 10000000 (
            echo Downloaded file is too small - download likely failed.
            del graphhopper.jar
            pause
            exit /b 1
        )
    )
    echo GraphHopper downloaded successfully.
    echo.
)

REM ── Check the OSM PBF exists ──────────────────────────────────────────────
set OSM_FILE=
for %%f in (*.osm.pbf) do set OSM_FILE=%%f
if "%OSM_FILE%"=="" (
    echo ❌ No .osm.pbf file found. Place pakistan.osm.pbf in this folder.
    pause
    exit /b 1
)

echo Starting GraphHopper with: %OSM_FILE%
echo.
echo ── First run takes 3-10 minutes to build the routing graph ──
echo ── Subsequent runs start in seconds (graph is cached) ───────
echo.
echo Routing API will be available at: http://localhost:8989/route
echo.

java -Xmx2g -jar graphhopper.jar server graphhopper-config.yml

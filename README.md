# Pakistan Offline Map CDN

A fully offline, LAN-shareable vector map system for Pakistan built for the S4 (Secure Surveillance) application. The system generates vector tiles from OpenStreetMap data and serves them over a local network with no internet required at runtime.

---

## System Requirements

- Windows 10 or 11 (64-bit)
- Java 21 (JDK) — required for tile generation
- Node.js v18 or v20
- npm (comes with Node.js)
- curl (comes with Windows 10+)
- At least 4 GB free RAM and 5 GB free disk space

---

## Project Structure

```
OfflineMap/
  GENERATE-TILES.bat        -- Step 1: Generate map tiles from OSM data
  START-SERVER.bat          -- Step 2: Start the local map server
  pakistan-260224.osm.pbf   -- OSM source data (not included in repo, download separately)
  pakistan.mbtiles          -- Generated tile file (not included in repo)
  planetiler.jar            -- Tile generator (downloaded by GENERATE-TILES.bat)
  server/
    server.js               -- Express server
    package.json
    public/
      index.html            -- Map frontend
      libs/
        maplibre-gl.js      -- Offline map rendering library
        maplibre-gl.css
```

---

## Setup Instructions

### Step 1 — Download OSM data for Pakistan

Download the Pakistan OSM extract from Geofabrik:

```
https://download.geofabrik.de/asia/pakistan-latest.osm.pbf
```

Rename the file to `pakistan-260224.osm.pbf` (or any `.osm.pbf` name) and place it in the root `OfflineMap/` folder.

### Step 2 — Install Java 21

Download and install Java 21 JDK from:

```
https://www.java.com/en/download/
```

Or use the Microsoft OpenJDK 21:

```
winget install --id Microsoft.OpenJDK.21
```

The `GENERATE-TILES.bat` script expects Java 21 at:

```
C:\Program Files\Java\jdk-21
```

If your installation path is different, open `GENERATE-TILES.bat` in a text editor and update the `JAVA_HOME` line.

### Step 3 — Install Node.js

Download and install Node.js v18 or v20 from:

```
https://nodejs.org/
```

### Step 4 — Download MapLibre GL JS (for offline use)

The frontend requires MapLibre GL JS to be available locally. Download these two files and place them in `server/public/libs/`:

- `maplibre-gl.js` from https://unpkg.com/maplibre-gl/dist/maplibre-gl.js
- `maplibre-gl.css` from https://unpkg.com/maplibre-gl/dist/maplibre-gl.css

Or run in the `server/public/libs/` folder:

```
curl -L https://unpkg.com/maplibre-gl/dist/maplibre-gl.js -o maplibre-gl.js
curl -L https://unpkg.com/maplibre-gl/dist/maplibre-gl.css -o maplibre-gl.css
```

### Step 5 — Generate tiles

Double-click `GENERATE-TILES.bat` or run it from a terminal:

```
GENERATE-TILES.bat
```

This will:
1. Download `planetiler.jar` automatically (requires internet, one-time only)
2. Download required supporting datasets (Natural Earth, water polygons) — one-time only
3. Process the OSM file and produce `pakistan.mbtiles`

This step takes approximately 10 to 20 minutes depending on your hardware.

### Step 6 — Start the server

2. Double-click `START-SERVER.bat`.
   - On the very first run, it will automatically install `node_modules` (offline if cached, internet if not).
   - **Important:** On the first run, the script will also download a 70MB font archive (for city names and labels) and extract the required offline fonts. This needs internet. You only do this *once*.
3. The console will say: `S4 OFFLINE MAP SERVER — RUNNING`
The server will print your local and network IP addresses:

```
Local:    http://localhost:3000
Network:  http://192.168.x.x:3000
```

Share the Network URL with teammates on the same LAN.

---

## Accessing the Map

Open a browser and go to:

```
http://localhost:3000
```

Teammates on the same LAN can open:

```
http://<YOUR_LAN_IP>:3000
```

The map shows Pakistan with roads, rivers, province boundaries, water bodies, and buildings. Click anywhere to get coordinates.

---

## Notes

- `pakistan.mbtiles` and `pakistan-260224.osm.pbf` are not included in this repository due to file size. Generate them using the steps above.
- `planetiler.jar` is not included. It is downloaded automatically by `GENERATE-TILES.bat`.
- The server does not require internet access after the initial setup is complete.
- Tile data is sourced from OpenStreetMap and is subject to the Open Database License (ODbL).

---

## Data Sources

- Map data: OpenStreetMap contributors (openstreetmap.org)
- Tile generator: Planetiler (github.com/onthegomap/planetiler)
- Map renderer: MapLibre GL JS (maplibre.org)

# Pakistan Offline Map CDN

A fully offline map server for Pakistan. Serves vector tiles, fonts, and provides **offline road routing** via GraphHopper. Built for the S4 (Secure Surveillance) application — works completely without internet after setup.

## What This Does

| Service | Port | Description |
|---------|------|-------------|
| **Map Tiles** | `:3000/tiles/{z}/{x}/{y}` | Vector tiles from MBTiles |
| **Fonts** | `:3000/fonts/{stack}/{range}.pbf` | Offline glyphs for labels |
| **Routing** | `:3000/route` (POST) | Proxies to GraphHopper for road-snapped routes |
| **GraphHopper** | `:8989/route` | Offline Java routing engine |

## System Requirements

- Windows 10/11 (64-bit)
- Java 17+ (for GraphHopper and tile generation)
- Node.js v18+ with npm
- 4 GB RAM, 5 GB disk space minimum

## Quick Start

### 1. Download Pakistan OSM Data

```
https://download.geofabrik.de/asia/pakistan-latest.osm.pbf
```

Place the `.osm.pbf` file in this directory.

### 2. Generate Map Tiles

```batch
GENERATE-TILES.bat
```

Downloads Planetiler (~90MB, once) and processes the OSM file into `pakistan.mbtiles` (~320MB). Takes 10-20 minutes.

### 3. Start the Map Server

```batch
START-SERVER.bat
```

First run downloads offline fonts (~70MB, once). Server starts at `http://localhost:3000`.

### 4. Start Offline Routing (Optional)

```batch
START-ROUTING.bat
```

Downloads GraphHopper (~50MB, once). First run builds the routing graph (3-10 min, cached after that). Enables road-snapped routes at `http://localhost:8989`.

## Project Structure

```
OfflineMap/
├── GENERATE-TILES.bat          # Step 1: Generate tiles from OSM data
├── START-SERVER.bat            # Step 2: Start Express tile server
├── START-ROUTING.bat           # Step 3: Start GraphHopper routing
├── graphhopper-config.yml      # GraphHopper 9.x configuration
├── pakistan-260224.osm.pbf     # OSM source data (not in repo)
├── pakistan.mbtiles             # Generated tiles (not in repo)
├── graphhopper.jar             # Routing engine (downloaded by bat)
├── pakistan-ghrouting/          # Cached routing graph (generated)
└── server/
    ├── server.js               # Express server (tiles + route proxy)
    ├── package.json
    ├── fonts/                  # Offline font glyphs
    └── public/                 # Static frontend
```

## Routing API

```
POST /route
Content-Type: application/json

{
  "waypoints": "67.0,24.86;67.03,24.87"
}
```

Response:
```json
{
  "routing": true,
  "coordinates": [[67.0, 24.86], [67.001, 24.861], ...]
}
```

The server proxies to GraphHopper internally. If GraphHopper isn't running, returns `{"routing": false}`.

## Notes

- Large files (`*.mbtiles`, `*.osm.pbf`, `*.jar`) are gitignored
- No internet needed after initial setup
- Share via LAN: `http://<YOUR_LAN_IP>:3000`

## Related Repository

- **[Testing-OfflineMapCDN](https://github.com/itxsamad1/Testing-OfflineMapCDN)** — React frontend that visualizes vehicle GPS routes on this offline map

## Data Sources

- Map data: [OpenStreetMap](https://openstreetmap.org) (ODbL)
- Tile generator: [Planetiler](https://github.com/onthegomap/planetiler)
- Map renderer: [MapLibre GL JS](https://maplibre.org)
- Routing engine: [GraphHopper](https://github.com/graphhopper/graphhopper)

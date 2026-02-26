/**
 * S4 Offline Map Server
 * Serves map tiles from .mbtiles file + static frontend on one port.
 * Access from LAN: http://<YOUR_IP>:3000
 */

const express = require("express");
const path = require("path");
const fs = require("fs");

const app = express();
const PORT = 3000;

// ─── Locate .mbtiles file ─────────────────────────────────────────────────────
const MBTILES_DIR = path.join(__dirname, "..");
let db = null;
let mbtilesFile = null;

function findMBTiles() {
  const files = fs.readdirSync(MBTILES_DIR).filter((f) => f.endsWith(".mbtiles"));
  if (files.length === 0) {
    console.warn(
      "⚠  No .mbtiles file found in",
      MBTILES_DIR,
      "\n   Run generate-tiles.bat first, then restart this server."
    );
    return null;
  }
  return path.join(MBTILES_DIR, files[0]);
}

function openDB(filePath) {
  try {
    const Database = require("better-sqlite3");
    const database = new Database(filePath, { readonly: true });
    console.log("✅ Loaded MBTiles:", filePath);
    return database;
  } catch (e) {
    console.error("❌ Could not open MBTiles:", e.message);
    return null;
  }
}

mbtilesFile = findMBTiles();
if (mbtilesFile) db = openDB(mbtilesFile);

// ─── CORS ─────────────────────────────────────────────────────────────────────
app.use((req, res, next) => {
  res.header("Access-Control-Allow-Origin", "*");
  next();
});

// ─── Tile API ─────────────────────────────────────────────────────────────────
// MBTiles stores tiles with Y flipped (TMS convention). Leaflet/MapLibre use XYZ.
app.get("/tiles/:z/:x/:y", (req, res) => {
  if (!db) {
    return res.status(503).json({ error: "No .mbtiles file loaded. Run generate-tiles.bat first." });
  }

  const z = parseInt(req.params.z, 10);
  const x = parseInt(req.params.x, 10);
  // Flip Y for TMS
  const y = (1 << z) - 1 - parseInt(req.params.y, 10);

  try {
    const row = db
      .prepare("SELECT tile_data FROM tiles WHERE zoom_level=? AND tile_column=? AND tile_row=?")
      .get(z, x, y);

    if (!row) {
      return res.status(204).send(); // No tile — normal for sparse areas
    }

    // Detect tile format
    const data = row.tile_data;
    const isGzip = data[0] === 0x1f && data[1] === 0x8b;

    if (isGzip) {
      // Vector tile (gzipped PBF)
      res.setHeader("Content-Type", "application/x-protobuf");
      res.setHeader("Content-Encoding", "gzip");
    } else {
      // Raster tile (PNG/JPG)
      const isPng = data[0] === 0x89 && data[1] === 0x50;
      res.setHeader("Content-Type", isPng ? "image/png" : "image/jpeg");
    }

    res.setHeader("Cache-Control", "public, max-age=86400");
    res.send(data);
  } catch (err) {
    console.error("Tile error:", err.message);
    res.status(500).send("Internal error");
  }
});

// ─── MBTiles metadata (for MapLibre TileJSON) ─────────────────────────────────
app.get("/tiles/metadata", (req, res) => {
  if (!db) return res.status(503).json({ error: "No mbtiles loaded" });
  const rows = db.prepare("SELECT name, value FROM metadata").all();
  const meta = {};
  rows.forEach((r) => (meta[r.name] = r.value));
  res.json(meta);
});

// ─── TileJSON endpoint (MapLibre style source) ─────────────────────────────────
app.get("/tiles.json", (req, res) => {
  const host = req.headers.host || `localhost:${PORT}`;
  const protocol = req.protocol || "http";

  let minZoom = 0, maxZoom = 18, center = [69.3451, 30.3753, 6];

  if (db) {
    const meta = {};
    db.prepare("SELECT name, value FROM metadata").all().forEach((r) => (meta[r.name] = r.value));
    if (meta.minzoom) minZoom = parseInt(meta.minzoom);
    if (meta.maxzoom) maxZoom = parseInt(meta.maxzoom);
    if (meta.center) {
      const parts = meta.center.split(",").map(Number);
      if (parts.length >= 2) center = parts;
    }
  }

  res.json({
    tilejson: "2.2.0",
    name: "Pakistan Offline Map",
    tiles: [`${protocol}://${host}/tiles/{z}/{x}/{y}`],
    minzoom: minZoom,
    maxzoom: maxZoom,
    center: center,
  });
});

// ─── Status API ───────────────────────────────────────────────────────────────
app.get("/api/status", (req, res) => {
  res.json({
    status: db ? "ready" : "no_tiles",
    mbtiles: mbtilesFile ? path.basename(mbtilesFile) : null,
    message: db ? "Map server is running" : "Run generate-tiles.bat to generate tiles first",
  });
});

// ─── Static frontend ─────────────────────────────────────────────────────────
app.use(express.static(path.join(__dirname, "public")));

// Fallback → index.html
app.get("*", (req, res) => {
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

// ─── Start ────────────────────────────────────────────────────────────────────
app.listen(PORT, "0.0.0.0", () => {
  const { networkInterfaces } = require("os");
  const nets = networkInterfaces();
  let lanIP = "localhost";
  for (const name of Object.keys(nets)) {
    for (const net of nets[name]) {
      if (net.family === "IPv4" && !net.internal) {
        lanIP = net.address;
        break;
      }
    }
  }

  console.log("\n╔═══════════════════════════════════════════════╗");
  console.log("║       S4 OFFLINE MAP SERVER — RUNNING         ║");
  console.log("╠═══════════════════════════════════════════════╣");
  console.log(`║  Local:    http://localhost:${PORT}              ║`);
  console.log(`║  Network:  http://${lanIP}:${PORT}         ║`);
  console.log("║                                               ║");
  console.log("║  Share the Network URL with your teammates    ║");
  console.log("╚═══════════════════════════════════════════════╝\n");
});

---
name: rust-map-format
description: Read, analyze, and modify Rust (Facepunch game) custom map files (.map). Use when user works with Rust game maps, custom monuments, prefabs, heightmaps, splat maps, topology, paths, or wants to edit .map files for a Rust game server. Covers the WorldSerialization binary format, RustEdit editor conventions, prefab placement, monument replacement, and map validation.
---

# Rust Map Format

Deep knowledge of the Rust game (Facepunch) `.map` file format — the binary `WorldSerialization` format used by RustEdit and Rust servers.

## File structure (high-level)

A `.map` file is a ProtoBuf-serialized `WorldSerialization` message. Top-level layout:

```
WorldSerialization {
  uint32 Version     // e.g. 9, 10, 11
  World   world {
    uint32 size              // map size in world units (e.g. 4000)
    repeated MapData maps    // named binary blobs (heightmap, splatmap, etc.)
    repeated PrefabData prefabs
    repeated PathData paths
  }
}
```

### Named map blobs (`maps[].name`)

Standard names found in every map:
- `terrain` — 16-bit heightmap (width*width*2 bytes)
- `height` — legacy alias for terrain
- `splat` — 8-channel ground texture mix (dirt, grass, forest, rock, snow, sand, gravel, pebble)
- `topology` — 32-bit topology mask per cell (roadside, cliff, beach, ocean, etc.)
- `biome` — 4-channel biome blend (arid, temperate, tundra, arctic)
- `alpha` — holes in terrain (1 = solid, 0 = invisible)
- `water` — water level heightmap

### PrefabData

Each placed object:
```
PrefabData {
  string category      // path in game: "assets/bundled/prefabs/..."
  uint32 id            // prefab name hash (stable across versions)
  VectorData position  // world XYZ
  VectorData rotation  // euler XYZ (degrees)
  VectorData scale
}
```

### Custom monuments

Stored as **embedded XML** inside the name field of a special prefab entry. This is how `grand-falls.map` and similar community maps reference prefabs like "bridge short anglefix", "Elysium Compound", etc.:

```xml
<CustomMonumentData xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="...">
  <name>...</name>
  <prefabs>
    <position><x>771.42</x><y>17.80</y><z>-683.54</z></position>
    <rotation>...</rotation>
    <scale><x>1</x><y>1</y><z>1</z></scale>
    <uid>...</uid>
    <checksum>7fcede4c29256617bb8ac10b79fac1d1</checksum>
  </prefabs>
</CustomMonumentData>
```

## Working with .map files

### Inspection without RustEdit

```python
# Minimal Python reader (needs protobuf + the .proto definitions from RustEdit)
# https://github.com/k1lly0u/Oxide.Ext.RustEdit has canonical .proto files
import worldserialization_pb2 as ws

with open("grand-falls.map", "rb") as f:
    data = ws.WorldSerialization()
    data.ParseFromString(f.read())

print(f"Version: {data.Version}")
print(f"Size: {data.world.size}")
print(f"Prefabs: {len(data.world.prefabs)}")
print(f"Paths: {len(data.world.paths)}")
for m in data.world.maps:
    print(f"  map blob: {m.name} ({len(m.data)} bytes)")
```

### Heightmap extraction

```python
import struct, numpy as np
# heightmap is 16-bit uint, values 0..65535 mapped to 0..max_height
w = int((len(terrain_blob) // 2) ** 0.5)
heights = np.frombuffer(terrain_blob, dtype='<u2').reshape(w, w)
# Export as PNG:
from PIL import Image
Image.fromarray((heights // 256).astype(np.uint8)).save("height.png")
```

### Prefab catalog lookup

Prefab IDs are CRC32/stable-hash of the asset path. The authoritative list lives in:
- RustEdit's `Deployables.json` / `Rust_Client_Decompiled` prefab dumps
- `https://github.com/OumaRusty/Rust-Prefab-IDs` and similar community dumps

To find a prefab by name: search `assets/bundled/prefabs/autospawn/...` paths.

## Validation checklist for a custom map

Before uploading to a Rust server:

- [ ] Map size is one of 1000, 2000, 3000, 3500, 4000, 4500, 5000, 6000 (Facepunch's allowed sizes)
- [ ] Heightmap dimensions match `size` (resolution is typically `size/2 + 1`)
- [ ] No prefabs outside world bounds (-size/2 .. +size/2)
- [ ] At least 2 spawn.player prefabs (players need a spawn point)
- [ ] Monument paths are reachable (road network connects major monuments)
- [ ] Ocean topology covers the perimeter (otherwise players fall off the edge)
- [ ] No duplicate monument names (breaks vending machine markers and map markers)
- [ ] File validates in RustEdit without errors
- [ ] Splat/biome have sensible distributions (100% grass everywhere = boring)

## Tools

| Tool | Purpose |
|---|---|
| **RustEdit** (k1lly0u) | GUI editor — the canonical map editor. Windows-only |
| **Oxide.Ext.RustEdit** | .proto definitions + server-side extension |
| **WorldEdit** | In-game admin terrain editing (uMod plugin) |
| **MapViewer** | Web-based .map preview without installing RustEdit |
| **python3 + protobuf** | Scripted batch operations (replace prefab, shift all by X, etc.) |

## Common tasks

### Replace all instances of monument A with monument B
```python
# Iterate data.world.prefabs, match by prefab.id == hash_of("A"),
# overwrite with hash_of("B"), keep position/rotation/scale.
```

### Shift the whole map by (dx, dy, dz)
```python
for p in data.world.prefabs:
    p.position.x += dx; p.position.y += dy; p.position.z += dz
for path in data.world.paths:
    for node in path.nodes:
        node.x += dx; node.y += dy; node.z += dz
```

### Strip all prefabs of a category (clean wipe)
```python
data.world.prefabs[:] = [p for p in data.world.prefabs if "vendingmachine" not in p.category]
```

### Re-serialize and save
```python
with open("output.map", "wb") as f:
    f.write(data.SerializeToString())
```

## References

- **RustEdit**: https://www.rustedit.io/
- **Oxide.Ext.RustEdit** (with .proto files): https://github.com/k1lly0u/Oxide.Ext.RustEdit
- **Rust game asset paths**: decompile `Assembly-CSharp.dll` from any Rust client
- **Community map repo**: https://github.com/topics/rust-custom-map

## Notes specific to this project

- Working file in this repo: `grand-falls.map`
- Branch for map edits: `claude/install-ui-ux-repo-A8tE6` (default for all Claude Code work here)
- When inspecting the binary, use `hexdump -C | head` — the first bytes are the protobuf varint version field
- When the user asks to "edit the map", ALWAYS back up the file first: `cp grand-falls.map grand-falls.map.bak`

# VSMineralMasonry

Vintage Story masonry blocks built from vanilla stone, ore, and mineral textures.

## Block Tiers

- `polishedrock-*`
  - Plain polished stone blocks, including stones that do not have a vanilla polished variant.
- `polished-*`
  - Current mineral masonry tier, using baked full textures organized by mining-tier buckets.
  - These replace the earlier exposed mineral test blocks.

## Texture Processing

### Polished Mineral

- Goal: make the mineral more visible while still looking embedded in the host stone.
- Current workflow:
  1. Start from the vanilla host rock texture.
  2. Resize to `64x64`.
  3. Apply a stone-specific base treatment.
  4. Composite a baked mineral overlay onto that treated rock.
  5. Save the final texture as a full block texture in `textures/block/stone/polishedmineral/tier2`.

### Why baked full textures

Runtime `rock + overlay` composition was too limiting for the current art direction and caused resolution mismatches when mixing vanilla `32x32` textures with custom `64x64` overlays. The mineral masonry tier therefore uses baked full textures.

## Base Rock Treatment Plan

The base rock should not be processed the same way for every stone. Polished mineral finishes usually make stone look richer and clearer, not uniformly brighter.

### Brighten slightly, then blur

Use for very pale stones that otherwise go flat:

- `chalk`
- `halite`
- `limestone`
- `whitemarble`

### Darken slightly, then blur

Use for darker stones where polish should deepen the tone instead of washing it out:

- `andesite`
- `basalt`
- `granite`
- `greenmarble`
- `kimberlite`
- `peridotite`
- `phyllite`
- `shale`
- `slate`
- `suevite`

### Increase saturation slightly, then blur

Use for warmer or more neutral stones where polish should enrich the existing color:

- `bauxite`
- `chert`
- `claystone`
- `conglomerate`
- `redmarble`
- `sandstone`

## Current Polished Mineral Notes

- `nativecopper`
  - Current direction is copper-dominant with only subtle green influence in the host stone treatment.
- `malachite`
  - Current direction uses medium-coverage green masks rather than large masks.

## Development

```bash
export VINTAGE_STORY="/Applications/Vintage Story.app"
dotnet build
```

Install the current build into the local game setup:

```bash
cd ..
./build-install.sh
```

## Release

```bash
./release.sh
```

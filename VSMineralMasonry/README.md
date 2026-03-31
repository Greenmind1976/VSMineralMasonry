# VSMineralMasonry

Decorative stone masonry blocks for Vintage Story, built from curated overlay patterns and polished rock textures.

## Current Live Set

The current live mod ships with:

- `4` overlay families
- `2` finishes
- `5` colorways
- `10` supported host rocks

## Overlay Families

- `breccia`
- `travertine`
- `granite`
- `marble`

## Finishes

- `polished`
- `burnished`

## Colorways

The mod should be discussed in terms of color, not source mineral name.

Current live colorways:

- `black`
- `green`
- `brown`
- `white`
- `silver`

Current internal source mapping:

- `black` currently uses `bituminouscoal`
- `green` currently uses `emerald`
- `brown` currently uses `lignite`
- `white` currently uses `quartz`
- `silver` currently uses `silver`

Planned direction:

- `green` is intended to become a shared green color family that can draw from `malachite`, `emerald`, and `olivine`

## Host Rocks

Current live host rocks:

- `andesite`
- `basalt`
- `chalk`
- `chert`
- `granite`
- `limestone`
- `phyllite`
- `shale`
- `slate`
- `whitemarble`

## Block Types

Current live block/content set:

- `muralslab`
  - baked mural textures
- `slabcycle`
  - same mural set with tool-driven tile cycling/alignment
- `rockpolishedvsm`
  - standalone polished base-rock blocks using the current host rock set

## Tool Behavior

For `slabcycle` blocks:

- `wrench`
  - cycles only the clicked block through its local `3x3` tile set
  - useful for checkerboards, mixed layouts, and manual tile picking
- `hammer`
  - auto-aligns the local `3x3` mural layout on the clicked face plane
  - useful when you want adjacent blocks to snap into a coherent mural pattern

In practice:

- use the `wrench` when you want precise single-block control
- use the `hammer` when you want neighboring mural blocks to line up automatically

## Texture Source

The live build currently depends on these source folders:

- [`/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/overlay-source-3x3`](/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/overlay-source-3x3)
- [`/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/no-bevel-polished-vanilla-64`](/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/no-bevel-polished-vanilla-64)
- [`/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/polished-vanilla-64`](/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/polished-vanilla-64)

Everything else in the project texture tree is archival or reference material.

## Notes On Scope

This mod currently uses baked textures rather than runtime composition.

That choice was made because:

- it gives predictable in-game results
- it avoids orientation issues during normal mural use
- it keeps the art workflow straightforward

The tradeoff is mod size, so the live set is curated rather than fully combinatorial.

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

# VSMineralMasonry

Decorative stone masonry blocks for Vintage Story, built from curated overlay patterns and burnished rock textures.

## Current Live Set

The current live mod ships with:

- `5` overlay/decor families
- `1` finish
- `5` colorways
- `10` supported host rocks

## Overlay Families

- `breccia`
- `travertine`
- `granite`
- `marble`
- `triangleoverlay`

## Finish

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
  - overlay-composed mural textures for the live stone families
- `slabcycle`
  - same mural set with tool-driven tile cycling/alignment
- `burnished`
  - standalone burnished base-rock blocks using the current host rock set
- `burnishedbevel`
  - standalone one-side bevel blocks using the burnished slabbase textures
- `burnishedbevel4`
  - standalone four-side bevel blocks using the burnished slabbase textures
- `triangleoverlayvsm`
  - placeable triangular burnished-stone decor pieces for corners, diagonals, and trim work

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

For `grouttrowel` interactions:

- `groutvsm`, `groutcolorvsm`, `thickgroutvsm`, `thickgroutcolorvsm`
  - cycles the clicked grout decor through its corner variants
- `triangleoverlayvsm`
  - cycles the clicked triangle decor through its four triangle orientations

## Texture Source

The live build currently depends on these source folders:

- [`/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/overlay-source-3x3`](/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/overlay-source-3x3)
- [`/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/no-bevel-polished-vanilla-64`](/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/no-bevel-polished-vanilla-64)
- [`/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/polished-vanilla-64`](/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/polished-vanilla-64)

Those folder names still include `polished` for historical reasons, but they now feed the burnished-only live set.

## Notes On Scope

The mural/slab system now uses shared base faces plus reusable overlay textures instead of shipping a full baked mural bank.

That choice was made because:

- it gives predictable in-game results
- it keeps the mod size down dramatically
- it still keeps the art workflow straightforward

The tradeoff is larger generated JSON for mural/slab bindings, so the live set is curated rather than fully combinatorial.

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

# VSMineralMasonry

`VSMineralMasonry` is a Vintage Story building mod focused on elegant burnished stonework, grout-based customization, decorative path surfaces, and a smaller set of mossy accents.

## Current Direction

The mod currently centers on four content pillars:

- Burnished masonry for refined structural building pieces
- Grout systems for visual customization and finish work
- Decorative surface details like flagstone paths and overlays
- Moss accents for aged, overgrown variation without taking over the whole set

## Included Content

## Burnished Masonry

- Burnished stone blocks
- Burnished arches
- Burnished pillars
- Burnished pillar bases and tops
- Burnished thin pillars
- Burnished thin pillar bases and tops
- Mural slabs

## Decor And Surface Details

- Burnished cobblestone decor
- Burnished flagstone path
- Burnished mossy flagstone path
- Triangle overlay decor
- Slab-cycle decor

## Moss Accents

- Mossy masonry variants
- Mossy cobblestone
- Mossy flagstone path

`mossrockwall` is currently retired from the active content lineup to keep the moss set tighter and more cohesive. A backup copy is preserved under `workingdir/backups/` in case it is restored later.

## Grout System

- Grout
- Rock grout
- Colored grout variants
- Rock-specific grout variants
- Tile grout variants
- Thick grout variants

Grout is intended to be easy to make and easy to spend.

- Colored grout is currently mixed from `mortar + dye` in a barrel
- Rock grout is mixed in two steps:
- `hammer + loose rock -> crushed stone`
- `10 crushed stone + 10L water -> 20L stone slurry`
- `10L stone slurry + 10 mortar -> 50 rock grout`
- Grout batches are intentionally generous because removed grout is destroyed
- The goal is for grout to feel like disposable finish material, not a precious building resource

## Tools

- Grout trowel
- Grout sponge

## Current Design Read

The mod is meant to feel like a builder's toolkit first:

- polished masonry for main structures
- grout for finish work and customization
- paths and overlays for added detail
- moss as a smaller atmospheric accent layer

## Development Notes

- Use `dotnet build` for normal verification
- Do not run `build-install.sh` as part of routine edit/test work
- Texture and asset generation helpers live under `VSMineralMasonry/tools/`

## Status

This mod is still being actively shaped. Names, recipes, and the exact moss/decor lineup may continue to evolve as the set gets refined.

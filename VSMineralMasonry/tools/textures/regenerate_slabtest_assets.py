#!/usr/bin/env python3
from __future__ import annotations

import json
import shutil
import subprocess
from pathlib import Path


ROOT = Path("/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/VSMineralMasonry")
PROJECT_ROOT = ROOT.parent

SOURCE_BLOCK = ROOT / "assets/vsmineralmasonry/blocktypes/stone/slabtest.json"
SOURCE_LANG = ROOT / "assets/vsmineralmasonry/lang/en.json"
SOURCE_TEXTURE_ROOT = ROOT / "assets/vsmineralmasonry/textures/block/stone/slabtest"

DEBUG_ROOT = ROOT / "bin/Debug/Mods/mod/assets/vsmineralmasonry"
DEBUG_BLOCK = DEBUG_ROOT / "blocktypes/stone/slabtest.json"
DEBUG_LANG = DEBUG_ROOT / "lang/en.json"
DEBUG_TEXTURE_ROOT = DEBUG_ROOT / "textures/block/stone/slabtest"

ROCK_BASE_ROOT = PROJECT_ROOT / "textures/no-bevel-polished-vanilla-64"
OVERLAY_SOURCE_ROOT = PROJECT_ROOT / "textures/overlay-source-3x3"

FAMILIES = ["breccia", "soapstone", "travertine", "granite", "marble"]
FINISHES = ["polished", "burnished"]
MINERALS = ["emerald", "quartz", "bituminouscoal"]
ROCKS = ["basalt", "granite", "whitemarble"]
TILES = [f"r{row}c{col}" for row in range(1, 4) for col in range(1, 4)]

DISPLAY_NAMES = {
    "bituminouscoal": "Black Coal",
    "whitemarble": "White Marble",
}


def title_name(code: str) -> str:
    if code in DISPLAY_NAMES:
        return DISPLAY_NAMES[code]
    return " ".join(part.capitalize() for part in code.split("_"))


def load_json(path: Path) -> dict:
    return json.loads(path.read_text())


def dump_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=True) + "\n")


def tile_to_label(tile: str) -> str:
    return f"R{tile[1]}C{tile[3:]}"


def overlay_source(family: str, mineral: str, tile: str) -> Path:
    return OVERLAY_SOURCE_ROOT / family / mineral / f"{tile}.png"


def rock_base_source(rock: str) -> Path:
    return ROCK_BASE_ROOT / f"{rock}.png"


def generate_base_tile(target: Path, overlay: Path, rock_base: Path) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        ["magick", str(rock_base), str(overlay), "-compose", "over", "-composite", str(target)],
        check=True,
    )


def generate_face_files(base_tile: Path) -> None:
    south = base_tile.with_name(f"{base_tile.stem}-southface.png")
    north = base_tile.with_name(f"{base_tile.stem}-northface.png")
    west = base_tile.with_name(f"{base_tile.stem}-westface.png")
    east = base_tile.with_name(f"{base_tile.stem}-eastface.png")
    down = base_tile.with_name(f"{base_tile.stem}-downface.png")
    up = base_tile.with_name(f"{base_tile.stem}-upface.png")

    shutil.copy2(base_tile, south)
    shutil.copy2(base_tile, west)
    shutil.copy2(base_tile, up)

    subprocess.run(["magick", str(south), "-flop", str(north)], check=True)
    subprocess.run(["magick", str(west), "-flop", str(east)], check=True)
    subprocess.run(["magick", str(up), "-rotate", "180", str(down)], check=True)


def rebuild_texture_bank() -> None:
    if SOURCE_TEXTURE_ROOT.exists():
        shutil.rmtree(SOURCE_TEXTURE_ROOT)
    SOURCE_TEXTURE_ROOT.mkdir(parents=True, exist_ok=True)

    for family in FAMILIES:
        for mineral in MINERALS:
            for rock in ROCKS:
                rock_base = rock_base_source(rock)
                for tile in TILES:
                    overlay = overlay_source(family, mineral, tile)
                    if not overlay.exists():
                        raise FileNotFoundError(f"Missing overlay source: {overlay}")
                    if not rock_base.exists():
                        raise FileNotFoundError(f"Missing rock base: {rock_base}")

                    base_tile = (
                        SOURCE_TEXTURE_ROOT
                        / family
                        / "polished"
                        / mineral
                        / rock
                        / f"{tile}.png"
                    )
                    generate_base_tile(base_tile, overlay, rock_base)
                    generate_face_files(base_tile)


def slabtest_states(block: dict) -> dict[str, list[str]]:
    return {group["code"]: group["states"] for group in block["variantgroups"]}


def ensure_tile_variantgroup(block: dict) -> None:
    for group in block["variantgroups"]:
        if group["code"] == "tile":
            group["states"] = TILES
            return
    raise RuntimeError("Could not find tile variantgroup in slabtest.json")


def build_allowed_variants(states: dict[str, list[str]]) -> list[str]:
    variants = []
    for family in states["family"]:
        for finish in states["finish"]:
            for mineral in states["mineral"]:
                for rock in states["rock"]:
                    for tile in states["tile"]:
                        variants.append(
                            f"slabtest-{family}-{finish}-{mineral}-{rock}-{tile}"
                        )
    return variants


def build_textures_by_type(states: dict[str, list[str]]) -> dict[str, dict]:
    textures = {}
    for family in states["family"]:
        for finish in states["finish"]:
            for mineral in states["mineral"]:
                for rock in states["rock"]:
                    for tile in states["tile"]:
                        key = f"slabtest-{family}-{finish}-{mineral}-{rock}-{tile}"
                        texture_finish = "polished"
                        base_prefix = (
                            f"vsmineralmasonry:block/stone/slabtest/"
                            f"{family}/{texture_finish}/{mineral}/{rock}/{tile}"
                        )
                        textures[key] = {
                            "south": {"base": f"{base_prefix}-southface"},
                            "north": {"base": f"{base_prefix}-northface"},
                            "west": {"base": f"{base_prefix}-westface"},
                            "east": {"base": f"{base_prefix}-eastface"},
                            "down": {"base": f"{base_prefix}-downface"},
                            "up": {"base": f"{base_prefix}-upface"},
                        }
    return textures


def rebuild_block_json() -> dict:
    block = load_json(SOURCE_BLOCK)
    ensure_tile_variantgroup(block)
    states = slabtest_states(block)
    block["allowedVariants"] = build_allowed_variants(states)
    block["texturesByType"] = build_textures_by_type(states)
    dump_json(SOURCE_BLOCK, block)
    return block


def rebuild_lang(block: dict) -> None:
    lang = load_json(SOURCE_LANG)
    stale_keys = [k for k in lang if k.startswith("block-vsmineralmasonry-slabtest-")]
    for key in stale_keys:
        del lang[key]

    states = slabtest_states(block)
    for family in states["family"]:
        for finish in states["finish"]:
            for mineral in states["mineral"]:
                for rock in states["rock"]:
                    for tile in states["tile"]:
                        key = (
                            f"block-vsmineralmasonry-slabtest-"
                            f"{family}-{finish}-{mineral}-{rock}-{tile}"
                        )
                        lang[key] = (
                            f"{title_name(family)} "
                            f"{title_name(finish)} "
                            f"{title_name(mineral)} "
                            f"{title_name(rock)} "
                            f"{tile.upper()}"
                        )
    dump_json(SOURCE_LANG, lang)


def sync_debug_copy() -> None:
    DEBUG_BLOCK.parent.mkdir(parents=True, exist_ok=True)
    DEBUG_LANG.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(SOURCE_BLOCK, DEBUG_BLOCK)
    shutil.copy2(SOURCE_LANG, DEBUG_LANG)
    if DEBUG_TEXTURE_ROOT.exists():
        shutil.rmtree(DEBUG_TEXTURE_ROOT)
    shutil.copytree(SOURCE_TEXTURE_ROOT, DEBUG_TEXTURE_ROOT)


def main() -> None:
    rebuild_texture_bank()
    block = rebuild_block_json()
    rebuild_lang(block)
    sync_debug_copy()
    print(f"Rebuilt {len(block['allowedVariants'])} slabtest variants")
    print(f"Rebuilt {len(block['texturesByType'])} texture bindings")
    print(SOURCE_BLOCK)
    print(SOURCE_LANG)


if __name__ == "__main__":
    main()

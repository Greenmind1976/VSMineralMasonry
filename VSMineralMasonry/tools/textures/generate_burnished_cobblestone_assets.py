#!/usr/bin/env python3
from __future__ import annotations

import json
import shutil
import subprocess
from pathlib import Path


ROOT = Path("/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/VSMineralMasonry")
PROJECT_ROOT = ROOT.parent

SOURCE_ROOT = PROJECT_ROOT / "textures/cobblestone-source-3x3"
COBBLE_BASE_OVERRIDE_ROOT = PROJECT_ROOT / "textures/cobblestone-rock-bases"
SLABBASE_ROOT = ROOT / "assets/vsmineralmasonry/textures/block/stone/slabbase"
TEXTURE_ROOT = ROOT / "assets/vsmineralmasonry/textures/block/stone/burnishedcobblestone"
BLOCK_PATH = ROOT / "assets/vsmineralmasonry/blocktypes/stone/burnishedcobblestone.json"
LANG_PATH = ROOT / "assets/vsmineralmasonry/lang/en.json"

DEBUG_ROOT = ROOT / "bin/Debug/Mods/mod/assets/vsmineralmasonry"
DEBUG_TEXTURE_ROOT = DEBUG_ROOT / "textures/block/stone/burnishedcobblestone"
DEBUG_BLOCK_PATH = DEBUG_ROOT / "blocktypes/stone/burnishedcobblestone.json"
DEBUG_LANG_PATH = DEBUG_ROOT / "lang/en.json"

ROCKS = [
    "basalt",
    "granite",
    "whitemarble",
    "slate",
    "chert",
    "phyllite",
    "andesite",
    "limestone",
    "shale",
    "chalk",
]
TILES = [f"r{row}c{col}" for row in range(1, 4) for col in range(1, 4)]
FACES = ("south", "north", "west", "east", "down", "up")

DISPLAY_NAMES = {
    "whitemarble": "White Marble",
}


def title_name(code: str) -> str:
    return DISPLAY_NAMES.get(code, " ".join(part.capitalize() for part in code.split("_")))


def dump_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=True) + "\n")


def cobble_base_source(rock: str) -> Path:
    override = COBBLE_BASE_OVERRIDE_ROOT / f"{rock}.png"
    if override.exists():
        return override
    return SLABBASE_ROOT / f"{rock}.png"


def generate_face_files(base_tile: Path) -> None:
    south = base_tile.with_name(f"{base_tile.stem}-southface.png")
    north = base_tile.with_name(f"{base_tile.stem}-northface.png")
    west = base_tile.with_name(f"{base_tile.stem}-westface.png")
    east = base_tile.with_name(f"{base_tile.stem}-eastface.png")
    down = base_tile.with_name(f"{base_tile.stem}-downface.png")
    up = base_tile.with_name(f"{base_tile.stem}-upface.png")

    shutil.copy2(base_tile, south)
    shutil.copy2(base_tile, west)
    subprocess.run(["magick", str(base_tile), "-flop", str(up)], check=True)

    subprocess.run(["magick", str(south), "-flop", str(north)], check=True)
    subprocess.run(["magick", str(west), "-flop", str(east)], check=True)
    subprocess.run(["magick", str(up), "-flip", str(down)], check=True)


def build_textures() -> None:
    if TEXTURE_ROOT.exists():
        shutil.rmtree(TEXTURE_ROOT)
    TEXTURE_ROOT.mkdir(parents=True, exist_ok=True)

    for rock in ROCKS:
        base = cobble_base_source(rock)
        if not base.exists():
            raise FileNotFoundError(f"Missing rock base: {base}")
        for tile in TILES:
            overlay = SOURCE_ROOT / f"{tile}.png"
            if not overlay.exists():
                raise FileNotFoundError(f"Missing cobblestone overlay source: {overlay}")
            out = TEXTURE_ROOT / f"{rock}-{tile}.png"
            subprocess.run(
                ["magick", str(base), str(overlay), "-compose", "Over", "-composite", str(out)],
                check=True,
            )
            generate_face_files(out)

    if DEBUG_TEXTURE_ROOT.exists():
        shutil.rmtree(DEBUG_TEXTURE_ROOT)
    shutil.copytree(TEXTURE_ROOT, DEBUG_TEXTURE_ROOT)


def build_block() -> dict:
    creative = [f"*-{rock}-r1c1" for rock in ROCKS]
    textures_by_type = {}
    for rock in ROCKS:
        for tile in TILES:
            key = f"burnishedcobblestone-{rock}-{tile}"
            prefix = f"vsmineralmasonry:block/stone/burnishedcobblestone/{rock}-{tile}"
            textures_by_type[key] = {
                face: {"base": f"{prefix}-{face}face"}
                for face in FACES
            }

    block = {
        "code": "burnishedcobblestone",
        "class": "BlockCobblestoneCycle",
        "replaceable": 120,
        "blockmaterial": "Stone",
        "storageFlags": 5,
        "variantgroups": [
            {"code": "rock", "states": ROCKS},
            {"code": "tile", "states": TILES},
        ],
        "attributes": {
            "canChisel": True,
            "handbook": {
                "groupBy": ["burnishedcobblestone-{rock}"]
            }
        },
        "creativeinventory": {
            "general": creative,
            "construction": creative,
        },
        "shape": {
            "base": "game:block/basic/cube"
        },
        "drawtype": "cube",
        "heldTpIdleAnimation": "holdbothhandslarge",
        "heldRightReadyAnimation": "heldblockready",
        "heldTpUseAnimation": "twohandplaceblock",
        "allowedVariants": [
            f"burnishedcobblestone-{rock}-{tile}"
            for rock in ROCKS
            for tile in TILES
        ],
        "texturesByType": textures_by_type,
        "sounds": {
            "walk": "walk/stone",
            "byTool": {
                "Pickaxe": {
                    "hit": "block/rock-hit-pickaxe",
                    "break": "block/rock-break-pickaxe"
                }
            }
        },
        "tpHandTransform": {
            "translation": {"x": -1.23, "y": -0.91, "z": -0.8},
            "rotation": {"x": -2, "y": 25, "z": -78},
            "scale": 0.4
        }
    }
    dump_json(BLOCK_PATH, block)
    dump_json(DEBUG_BLOCK_PATH, block)
    return block


def update_lang() -> None:
    lang = json.loads(LANG_PATH.read_text())
    for key in [k for k in lang if k.startswith("block-vsmineralmasonry-burnishedcobblestone-")]:
        del lang[key]

    for rock in ROCKS:
        for tile in TILES:
            key = f"block-vsmineralmasonry-burnishedcobblestone-{rock}-{tile}"
            lang[key] = f"VSM Burnished Cobblestone {title_name(rock)}"

    dump_json(LANG_PATH, lang)
    dump_json(DEBUG_LANG_PATH, lang)


def main() -> None:
    build_textures()
    build_block()
    update_lang()
    print(BLOCK_PATH)
    print(f"rocks={len(ROCKS)}")
    print(f"tiles={len(TILES)}")
    print(f"variants={len(ROCKS) * len(TILES)}")


if __name__ == "__main__":
    main()

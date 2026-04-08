#!/usr/bin/env python3
from __future__ import annotations

import json
import shutil
import subprocess
import tempfile
from pathlib import Path


ROOT = Path("/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/VSMineralMasonry")
PROJECT_ROOT = ROOT.parent

SOURCE_ROOT = PROJECT_ROOT / "textures/cobblestone-source-5x5"
TEXTURE_ROOT = ROOT / "assets/vsmineralmasonry/textures/block/stone/burnishedcobblestone"
BLOCK_PATH = ROOT / "assets/vsmineralmasonry/blocktypes/stone/burnishedcobblestone.json"
LANG_PATH = ROOT / "assets/vsmineralmasonry/lang/en.json"

DEBUG_ROOT = ROOT / "bin/Debug/Mods/mod/assets/vsmineralmasonry"
DEBUG_TEXTURE_ROOT = DEBUG_ROOT / "textures/block/stone/burnishedcobblestone"
DEBUG_BLOCK_PATH = DEBUG_ROOT / "blocktypes/stone/burnishedcobblestone.json"
DEBUG_LANG_PATH = DEBUG_ROOT / "lang/en.json"
BASEFACE_PATH = "vsmineralmasonry:block/stone/muralslab-basefaces-mosscontrast/{rock}{variant}-{face}face"

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
TILES = [f"r{row}c{col}" for row in range(1, 6) for col in range(1, 6)]
FACES = ("south", "north", "west", "east", "down", "up")

DISPLAY_NAMES = {
    "whitemarble": "White Marble",
}


def title_name(code: str) -> str:
    return DISPLAY_NAMES.get(code, " ".join(part.capitalize() for part in code.split("_")))


def dump_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=True) + "\n")


def generate_overlay_face_files(input_tile: Path, output_prefix: Path) -> None:
    south = output_prefix.with_name(f"{output_prefix.name}-southface.png")
    north = output_prefix.with_name(f"{output_prefix.name}-northface.png")
    west = output_prefix.with_name(f"{output_prefix.name}-westface.png")
    east = output_prefix.with_name(f"{output_prefix.name}-eastface.png")
    down = output_prefix.with_name(f"{output_prefix.name}-downface.png")
    up = output_prefix.with_name(f"{output_prefix.name}-upface.png")

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp = Path(tmpdir)
        mask_gray = tmp / "mask-gray.png"
        mask_alpha = tmp / "mask-alpha.png"
        base_overlay = tmp / "base-overlay.png"
        up_overlay = tmp / "up-overlay.png"

        subprocess.run(
            [
                "magick",
                str(input_tile),
                "-colorspace",
                "Gray",
                "PNG32:" + str(mask_gray),
            ],
            check=True,
        )

        subprocess.run(
            [
                "magick",
                str(mask_gray),
                "-sigmoidal-contrast",
                "4,50%",
                "-negate",
                "PNG32:" + str(mask_alpha),
            ],
            check=True,
        )

        subprocess.run(
            [
                "magick",
                "-size",
                "64x64",
                "xc:#121212",
                str(mask_alpha),
                "-alpha",
                "off",
                "-compose",
                "CopyOpacity",
                "-composite",
                "PNG32:" + str(base_overlay),
            ],
            check=True,
        )

        shutil.copy2(base_overlay, south)
        shutil.copy2(base_overlay, west)
        subprocess.run(["magick", str(base_overlay), "-flop", "PNG32:" + str(up_overlay)], check=True)
        shutil.copy2(up_overlay, up)

    subprocess.run(["magick", str(south), "-flop", "PNG32:" + str(north)], check=True)
    subprocess.run(["magick", str(west), "-flop", "PNG32:" + str(east)], check=True)
    subprocess.run(["magick", str(up), "-flip", "PNG32:" + str(down)], check=True)


def build_textures() -> None:
    if TEXTURE_ROOT.exists():
        shutil.rmtree(TEXTURE_ROOT)
    TEXTURE_ROOT.mkdir(parents=True, exist_ok=True)

    for tile in TILES:
        overlay = SOURCE_ROOT / f"{tile}.png"
        if not overlay.exists():
            raise FileNotFoundError(f"Missing cobblestone overlay source: {overlay}")
        generate_overlay_face_files(overlay, TEXTURE_ROOT / tile)

    if DEBUG_TEXTURE_ROOT.exists():
        shutil.rmtree(DEBUG_TEXTURE_ROOT)
    shutil.copytree(TEXTURE_ROOT, DEBUG_TEXTURE_ROOT)


def build_block() -> dict:
    creative = [f"*-{rock}-r1c1" for rock in ROCKS]
    textures_by_type = {}
    textures_by_type["*"] = {}
    for face in FACES:
        textures_by_type["*"][face] = {
            "base": BASEFACE_PATH.format(rock="{rock}", variant="1", face=face),
            "overlays": [
                f"vsmineralmasonry:block/stone/burnishedcobblestone/{{tile}}-{face}face"
            ],
            "alternates": [
                {
                    "base": BASEFACE_PATH.format(rock="{rock}", variant="2", face=face),
                    "overlays": [
                        f"vsmineralmasonry:block/stone/burnishedcobblestone/{{tile}}-{face}face"
                    ],
                },
                {
                    "base": BASEFACE_PATH.format(rock="{rock}", variant="3", face=face),
                    "overlays": [
                        f"vsmineralmasonry:block/stone/burnishedcobblestone/{{tile}}-{face}face"
                    ],
                },
                {
                    "base": BASEFACE_PATH.format(rock="{rock}", variant="4", face=face),
                    "overlays": [
                        f"vsmineralmasonry:block/stone/burnishedcobblestone/{{tile}}-{face}face"
                    ],
                },
            ],
        }

    block = {
        "code": "burnishedcobblestone",
        "class": "BlockCobblestoneCycle5x5",
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

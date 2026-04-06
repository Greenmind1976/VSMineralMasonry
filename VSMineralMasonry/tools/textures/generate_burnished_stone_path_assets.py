#!/usr/bin/env python3
from __future__ import annotations

import json
import shutil
import subprocess
import tempfile
from pathlib import Path


ROOT = Path("/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/VSMineralMasonry")
PROJECT_ROOT = ROOT.parent

SOURCE_ROOT = PROJECT_ROOT / "textures/stone-path-source-3x3"
SLABBASE_ROOT = ROOT / "assets/vsmineralmasonry/textures/block/stone/slabbase"
TEXTURE_ROOT = ROOT / "assets/vsmineralmasonry/textures/block/stone/burnishedstonepath"
BLOCK_PATH = ROOT / "assets/vsmineralmasonry/blocktypes/stone/burnishedstonepath.json"
LANG_PATH = ROOT / "assets/vsmineralmasonry/lang/en.json"

DEBUG_ROOT = ROOT / "bin/Debug/Mods/mod/assets/vsmineralmasonry"
DEBUG_TEXTURE_ROOT = DEBUG_ROOT / "textures/block/stone/burnishedstonepath"
DEBUG_BLOCK_PATH = DEBUG_ROOT / "blocktypes/stone/burnishedstonepath.json"
DEBUG_LANG_PATH = DEBUG_ROOT / "lang/en.json"

ROCKS = [
    "andesite",
    "basalt",
    "chalk",
    "chert",
    "granite",
    "limestone",
    "phyllite",
    "shale",
    "slate",
    "whitemarble",
]
TILES = [f"r{row}c{col}" for row in range(1, 4) for col in range(1, 4)]
DISPLAY_NAMES = {
    "whitemarble": "White Marble",
}
INNER_SHADOW_ALPHA = "0.12"
GAP_DARKEN_ALPHA = "0.10"
OUTER_SHADOW_ALPHA = "0.18"


def title_name(code: str) -> str:
    return DISPLAY_NAMES.get(code, " ".join(part.capitalize() for part in code.split("_")))


def dump_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=True) + "\n")


def prepare_mask(tile: Path, out_path: Path) -> None:
    subprocess.run(
        [
            "magick",
            str(tile),
            "-resize",
            "64x64!",
            "-colorspace",
            "Gray",
            "-auto-level",
            "PNG32:" + str(out_path),
        ],
        check=True,
    )


def render_top_tile(base: Path, mask: Path, out_path: Path) -> None:
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp = Path(tmpdir)
        rock_rgba = tmp / "rock-rgba.png"
        binary_mask = tmp / "binary-mask.png"
        inverse_mask = tmp / "inverse-mask.png"
        eroded_mask = tmp / "eroded-mask.png"
        edge_mask = tmp / "edge-mask.png"
        dilated_mask = tmp / "dilated-mask.png"
        outer_shadow_mask = tmp / "outer-shadow-mask.png"
        gap_overlay = tmp / "gap-overlay.png"
        shadow_overlay = tmp / "shadow-overlay.png"
        outer_shadow_overlay = tmp / "outer-shadow-overlay.png"
        subprocess.run(["magick", str(base), "PNG32:" + str(rock_rgba)], check=True)
        subprocess.run(
            [
                "magick",
                str(rock_rgba),
                str(mask),
                "-alpha",
                "off",
                "-compose",
                "CopyOpacity",
                "-composite",
                "PNG32:" + str(out_path),
            ],
            check=True,
        )
        subprocess.run(
            [
                "magick",
                str(mask),
                "-threshold",
                "50%",
                "-alpha",
                "off",
                "PNG32:" + str(binary_mask),
            ],
            check=True,
        )
        subprocess.run(
            [
                "magick",
                str(binary_mask),
                "-negate",
                "PNG32:" + str(inverse_mask),
            ],
            check=True,
        )
        subprocess.run(
            [
                "magick",
                "-size",
                "64x64",
                "xc:black",
                str(inverse_mask),
                "-alpha",
                "off",
                "-compose",
                "CopyOpacity",
                "-composite",
                "-channel",
                "A",
                "-evaluate",
                "multiply",
                GAP_DARKEN_ALPHA,
                "+channel",
                "PNG32:" + str(gap_overlay),
            ],
            check=True,
        )
        subprocess.run(
            [
                "magick",
                str(out_path),
                str(gap_overlay),
                "-compose",
                "Over",
                "-composite",
                "PNG32:" + str(out_path),
            ],
            check=True,
        )
        subprocess.run(
            [
                "magick",
                str(binary_mask),
                "-morphology",
                "Erode",
                "Diamond",
                "PNG32:" + str(eroded_mask),
            ],
            check=True,
        )
        subprocess.run(
            [
                "magick",
                str(binary_mask),
                str(eroded_mask),
                "-compose",
                "Difference",
                "-composite",
                "PNG32:" + str(edge_mask),
            ],
            check=True,
        )
        subprocess.run(
            [
                "magick",
                "-size",
                "64x64",
                "xc:black",
                str(edge_mask),
                "-alpha",
                "off",
                "-compose",
                "CopyOpacity",
                "-composite",
                "-channel",
                "A",
                "-evaluate",
                "multiply",
                INNER_SHADOW_ALPHA,
                "+channel",
                "PNG32:" + str(shadow_overlay),
            ],
            check=True,
        )
        subprocess.run(
            [
                "magick",
                str(out_path),
                str(shadow_overlay),
                "-compose",
                "Over",
                "-composite",
                "PNG32:" + str(out_path),
            ],
            check=True,
        )
        subprocess.run(
            [
                "magick",
                str(binary_mask),
                "-morphology",
                "Dilate",
                "Diamond",
                "PNG32:" + str(dilated_mask),
            ],
            check=True,
        )
        subprocess.run(
            [
                "magick",
                str(dilated_mask),
                str(binary_mask),
                "-compose",
                "Difference",
                "-composite",
                "PNG32:" + str(outer_shadow_mask),
            ],
            check=True,
        )
        subprocess.run(
            [
                "magick",
                "-size",
                "64x64",
                "xc:black",
                str(outer_shadow_mask),
                "-alpha",
                "off",
                "-compose",
                "CopyOpacity",
                "-composite",
                "-channel",
                "A",
                "-evaluate",
                "multiply",
                OUTER_SHADOW_ALPHA,
                "+channel",
                "PNG32:" + str(outer_shadow_overlay),
            ],
            check=True,
        )
        subprocess.run(
            [
                "magick",
                str(out_path),
                str(outer_shadow_overlay),
                "-compose",
                "Over",
                "-composite",
                "PNG32:" + str(out_path),
            ],
            check=True,
        )


def build_textures() -> None:
    if TEXTURE_ROOT.exists():
        shutil.rmtree(TEXTURE_ROOT)
    TEXTURE_ROOT.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp = Path(tmpdir)
        for tile in TILES:
            src = SOURCE_ROOT / f"{tile}.png"
            if not src.exists():
                raise FileNotFoundError(f"Missing source tile: {src}")
            prepare_mask(src, tmp / f"{tile}-mask.png")

        for rock in ROCKS:
            base = SLABBASE_ROOT / f"{rock}.png"
            if not base.exists():
                raise FileNotFoundError(f"Missing rock base: {base}")
            for tile in TILES:
                mask = tmp / f"{tile}-mask.png"
                up = TEXTURE_ROOT / f"{rock}-{tile}-upface.png"
                up_raw = tmp / f"{rock}-{tile}-up-raw.png"

                render_top_tile(base, mask, up_raw)
                subprocess.run(["magick", str(up_raw), "-flop", "PNG32:" + str(up)], check=True)
                shutil.copy2(up, TEXTURE_ROOT / f"{rock}-{tile}.png")

    if DEBUG_TEXTURE_ROOT.exists():
        shutil.rmtree(DEBUG_TEXTURE_ROOT)
    shutil.copytree(TEXTURE_ROOT, DEBUG_TEXTURE_ROOT)


def build_block() -> None:
    block = {
        "code": "burnishedstonepath",
        "class": "BlockStonePathDecorCycle",
        "behaviors": [
            {
                "name": "Decor",
                "properties": {
                    "sides": ["up"],
                    "notFullFace": True,
                    "thickness": 0.0,
                    "removable": False
                }
            }
        ],
        "replaceable": 120,
        "blockmaterial": "Stone",
        "storageFlags": 5,
        "variantgroups": [
            {"code": "rock", "states": ROCKS},
            {"code": "tile", "states": TILES},
        ],
        "attributes": {
            "ignoreSounds": True,
            "handbook": {"include": False},
        },
        "shapeInventory": {
            "base": "game:block/basic/layers/0voxel",
            "rotateX": 90
        },
        "textures": {
            "all": {
                "base": "vsmineralmasonry:block/stone/burnishedstonepath/{rock}-{tile}"
            }
        },
        "allowedVariants": [
            f"burnishedstonepath-{rock}-{tile}"
            for rock in ROCKS
            for tile in TILES
        ],
        "vertexflags": {
            "zOffset": 1
        },
        "renderPass": "Transparent",
        "drawtype": "surfacelayer",
        "doNotRenderAtLod2": True,
        "randomizeRotations": False,
        "sidesolid": {
            "all": False
        },
        "sideopaque": {
            "all": False
        },
        "selectionBox": {
            "x1": 0,
            "y1": 0,
            "z1": 0,
            "x2": 1,
            "y2": 1,
            "z2": 1
        },
        "resistance": 0,
        "lightAbsorption": 0,
        "drops": [],
        "materialDensity": 400,
        "guiTransform": {
            "origin": {
                "x": 0.5,
                "y": 0.5,
                "z": 0
            }
        }
    }
    dump_json(BLOCK_PATH, block)
    dump_json(DEBUG_BLOCK_PATH, block)


def update_lang() -> None:
    lang = json.loads(LANG_PATH.read_text())
    for key in [k for k in lang if k.startswith("block-vsmineralmasonry-burnishedstonepath-")]:
        del lang[key]
    for key in [k for k in lang if k.startswith("item-vsmineralmasonry-burnishedstonepathitem-")]:
        del lang[key]

    for rock in ROCKS:
        for tile in TILES:
            key = f"block-vsmineralmasonry-burnishedstonepath-{rock}-{tile}"
            lang[key] = f"VSM Burnished Stone Path {title_name(rock)}"
        lang[f"item-vsmineralmasonry-burnishedstonepathitem-{rock}"] = f"VSM Burnished Stone Path {title_name(rock)}"

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

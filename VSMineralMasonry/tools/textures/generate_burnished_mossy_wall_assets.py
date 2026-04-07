#!/usr/bin/env python3
from __future__ import annotations

import json
import shutil
import subprocess
import tempfile
from pathlib import Path


ROOT = Path("/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/VSMineralMasonry")
PROJECT_ROOT = ROOT.parent

SOURCE_ROOT = PROJECT_ROOT / "textures/mossy-wall-source-3x3"
TEXTURE_ROOT = ROOT / "assets/vsmineralmasonry/textures/block/stone/burnishedmossywall"
BLOCK_PATH = ROOT / "assets/vsmineralmasonry/blocktypes/stone/burnishedmossywall.json"
LANG_PATH = ROOT / "assets/vsmineralmasonry/lang/en.json"

DEBUG_ROOT = ROOT / "bin/Debug/Mods/mod/assets/vsmineralmasonry"
DEBUG_TEXTURE_ROOT = DEBUG_ROOT / "textures/block/stone/burnishedmossywall"
DEBUG_BLOCK_PATH = DEBUG_ROOT / "blocktypes/stone/burnishedmossywall.json"
DEBUG_LANG_PATH = DEBUG_ROOT / "lang/en.json"

TOP_MOSS = PROJECT_ROOT / "workingdir/rock-texture-fixed/moss-base.png"
SIDE_MOSS = PROJECT_ROOT / "workingdir/rock-texture-fixed/moss3.png"

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
FACES = ("south", "north", "west", "east", "down", "up")
INNER_SHADOW_ALPHA = "0.10"
OUTER_SHADOW_ALPHA = "0.12"

DISPLAY_NAMES = {
    "whitemarble": "White Marble",
}


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


def render_overlay_face(moss: Path, mask: Path, out_path: Path) -> None:
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp = Path(tmpdir)
        moss_rgba = tmp / "moss-rgba.png"
        moss_masked = tmp / "moss-masked.png"
        inverse_mask = tmp / "inverse-mask.png"
        binary_mask = tmp / "binary-mask.png"
        eroded_mask = tmp / "eroded-mask.png"
        edge_mask = tmp / "edge-mask.png"
        dilated_mask = tmp / "dilated-mask.png"
        outer_shadow_mask = tmp / "outer-shadow-mask.png"
        shadow_overlay = tmp / "shadow-overlay.png"
        outer_shadow_overlay = tmp / "outer-shadow-overlay.png"
        subprocess.run(["magick", str(moss), "PNG32:" + str(moss_rgba)], check=True)
        subprocess.run(["magick", str(mask), "-negate", "PNG32:" + str(inverse_mask)], check=True)
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
                str(moss_rgba),
                str(inverse_mask),
                "-alpha",
                "off",
                "-compose",
                "CopyOpacity",
                "-composite",
                "PNG32:" + str(moss_masked),
            ],
            check=True,
        )
        shutil.copy2(moss_masked, out_path)
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

        for tile in TILES:
            mask = tmp / f"{tile}-mask.png"
            south = TEXTURE_ROOT / f"{tile}-southface.png"
            west = TEXTURE_ROOT / f"{tile}-westface.png"
            up = TEXTURE_ROOT / f"{tile}-upface.png"
            up_raw = tmp / f"{tile}-up-raw.png"

            render_overlay_face(SIDE_MOSS, mask, south)
            shutil.copy2(south, west)
            render_overlay_face(TOP_MOSS, mask, up_raw)

            subprocess.run(["magick", str(south), "-flop", "PNG32:" + str(TEXTURE_ROOT / f"{tile}-northface.png")], check=True)
            subprocess.run(["magick", str(west), "-flop", "PNG32:" + str(TEXTURE_ROOT / f"{tile}-eastface.png")], check=True)
            subprocess.run(["magick", str(up_raw), "-flop", "PNG32:" + str(up)], check=True)
            subprocess.run(["magick", str(up), "-flip", "PNG32:" + str(TEXTURE_ROOT / f"{tile}-downface.png")], check=True)
            shutil.copy2(south, TEXTURE_ROOT / f"{tile}.png")

    if DEBUG_TEXTURE_ROOT.exists():
        shutil.rmtree(DEBUG_TEXTURE_ROOT)
    shutil.copytree(TEXTURE_ROOT, DEBUG_TEXTURE_ROOT)


def build_block() -> None:
    creative = [f"*-{rock}-r1c1" for rock in ROCKS]
    textures_by_type = {"*": {}}
    for face in FACES:
        textures_by_type["*"][face] = {
            "base": f"vsmineralmasonry:block/stone/muralslab-basefaces/{{rock}}1-{face}face",
            "overlays": [
                f"vsmineralmasonry:block/stone/burnishedmossywall/{{tile}}-{face}face"
            ],
            "alternates": [
                {
                    "base": f"vsmineralmasonry:block/stone/muralslab-basefaces/{{rock}}2-{face}face",
                    "overlays": [
                        f"vsmineralmasonry:block/stone/burnishedmossywall/{{tile}}-{face}face"
                    ],
                },
                {
                    "base": f"vsmineralmasonry:block/stone/muralslab-basefaces/{{rock}}3-{face}face",
                    "overlays": [
                        f"vsmineralmasonry:block/stone/burnishedmossywall/{{tile}}-{face}face"
                    ],
                },
                {
                    "base": f"vsmineralmasonry:block/stone/muralslab-basefaces/{{rock}}4-{face}face",
                    "overlays": [
                        f"vsmineralmasonry:block/stone/burnishedmossywall/{{tile}}-{face}face"
                    ],
                },
            ],
        }

    block = {
        "code": "burnishedmossywall",
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
            "handbook": {"groupBy": ["burnishedmossywall-{rock}"]},
        },
        "creativeinventory": {
            "general": creative,
            "construction": creative,
        },
        "shape": {"base": "game:block/basic/cube"},
        "drawtype": "cube",
        "heldTpIdleAnimation": "holdbothhandslarge",
        "heldRightReadyAnimation": "heldblockready",
        "heldTpUseAnimation": "twohandplaceblock",
        "allowedVariants": [
            f"burnishedmossywall-{rock}-{tile}"
            for rock in ROCKS
            for tile in TILES
        ],
        "texturesByType": textures_by_type,
        "sounds": {
            "walk": "walk/stone",
            "byTool": {
                "Pickaxe": {
                    "hit": "block/rock-hit-pickaxe",
                    "break": "block/rock-break-pickaxe",
                }
            }
        },
        "tpHandTransform": {
            "translation": {"x": -1.23, "y": -0.91, "z": -0.8},
            "rotation": {"x": -2, "y": 25, "z": -78},
            "scale": 0.4,
        },
    }
    dump_json(BLOCK_PATH, block)
    dump_json(DEBUG_BLOCK_PATH, block)


def update_lang() -> None:
    lang = json.loads(LANG_PATH.read_text())
    for key in [k for k in lang if k.startswith("block-vsmineralmasonry-burnishedmossywall-")]:
        del lang[key]

    for rock in ROCKS:
        for tile in TILES:
            key = f"block-vsmineralmasonry-burnishedmossywall-{rock}-{tile}"
            lang[key] = f"VSM Burnished Mossy Wall {title_name(rock)}"

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

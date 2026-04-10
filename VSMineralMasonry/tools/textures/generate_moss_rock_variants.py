#!/usr/bin/env python3
from __future__ import annotations

import json
import shutil
import subprocess
import tempfile
from pathlib import Path


ROOT = Path("/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/VSMineralMasonry")
PROJECT_ROOT = ROOT.parent

LANG_PATH = ROOT / "assets/vsmineralmasonry/lang/en.json"

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
TILES = [f"r{row}c{col}" for row in range(1, 6) for col in range(1, 6)]
FACES = ("south", "north", "west", "east", "down", "up")
INNER_SHADOW_ALPHA = "0.10"
OUTER_SHADOW_ALPHA = "0.12"

DISPLAY_NAMES = {
    "whitemarble": "White Marble",
}

SIDE_MOSS_SOURCE = PROJECT_ROOT / "workingdir/backups/original-moss-source/moss3-original.png"
TOP_MOSS_SOURCE = PROJECT_ROOT / "workingdir/backups/original-moss-source/moss-base-original.png"

SETS = [
    {
        "code": "mossrockwall",
        "display": "Moss Rock Wall",
        "class": "BlockSlabCycle",
        "baseface_path": "vsmineralmasonry:block/stone/muralslab-basefaces-mosscontrast/{rock}{variant}-{face}face",
        "source_pattern": "moss-rocks-try2_{index:02d}.png",
        "texture_dir": ROOT / "assets/vsmineralmasonry/textures/block/stone/mossrockwall",
        "block_path": ROOT / "assets/vsmineralmasonry/blocktypes/stone/mossrockwall.json",
    },
    {
        "code": "smallmossrocks",
        "display": "Small Moss Rocks",
        "class": "BlockSlabCycle",
        "baseface_path": "vsmineralmasonry:block/stone/muralslab-basefaces-overlay/{rock}{variant}-{face}face",
        "source_pattern": "small-moss-rocks-try1_{index:02d}.png",
        "texture_dir": ROOT / "assets/vsmineralmasonry/textures/block/stone/smallmossrocks",
        "block_path": ROOT / "assets/vsmineralmasonry/blocktypes/stone/smallmossrocks.json",
    },
]

SOURCE_ROOT = PROJECT_ROOT / "workingdir/moss-rocks/images"


def title_name(code: str) -> str:
    return DISPLAY_NAMES.get(code, " ".join(part.capitalize() for part in code.split("_")))


def dump_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=True) + "\n")


def source_tile(source_pattern: str, tile: str) -> Path:
    row = int(tile[1])
    col = int(tile[3])
    index = ((row - 1) * 5) + col
    return SOURCE_ROOT / source_pattern.format(index=index)


def prepare_mask(tile: Path, out_path: Path) -> None:
    subprocess.run(
        [
            "magick",
            str(tile),
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


def build_textures(texture_root: Path, source_pattern: str) -> None:
    if texture_root.exists():
        shutil.rmtree(texture_root)
    texture_root.mkdir(parents=True, exist_ok=True)

    with tempfile.TemporaryDirectory() as tmpdir:
        tmp = Path(tmpdir)
        for tile in TILES:
            src = source_tile(source_pattern, tile)
            if not src.exists():
                raise FileNotFoundError(f"Missing source tile: {src}")
            prepare_mask(src, tmp / f"{tile}-mask.png")

        for tile in TILES:
            mask = tmp / f"{tile}-mask.png"
            south = texture_root / f"{tile}-southface.png"
            west = texture_root / f"{tile}-westface.png"
            up = texture_root / f"{tile}-upface.png"
            up_raw = tmp / f"{tile}-up-raw.png"

            render_overlay_face(SIDE_MOSS_SOURCE, mask, south)
            shutil.copy2(south, west)
            render_overlay_face(TOP_MOSS_SOURCE, mask, up_raw)

            subprocess.run(["magick", str(south), "-flop", "PNG32:" + str(texture_root / f"{tile}-northface.png")], check=True)
            subprocess.run(["magick", str(west), "-flop", "PNG32:" + str(texture_root / f"{tile}-eastface.png")], check=True)
            subprocess.run(["magick", str(up_raw), "-flop", "PNG32:" + str(up)], check=True)
            subprocess.run(["magick", str(up), "-flip", "PNG32:" + str(texture_root / f"{tile}-downface.png")], check=True)
            shutil.copy2(south, texture_root / f"{tile}.png")


def build_block(block_path: Path, code: str, display: str, class_name: str, baseface_path: str) -> None:
    creative = [f"*-{rock}-r1c1" for rock in ROCKS]
    textures_by_type = {"*": {}}
    for face in FACES:
        textures_by_type["*"][face] = {
            "base": baseface_path.format(rock="{rock}", variant="1", face=face),
            "overlays": [
                f"vsmineralmasonry:block/stone/{code}/{{tile}}-{face}face"
            ],
            "alternates": [
                {
                    "base": baseface_path.format(rock="{rock}", variant="2", face=face),
                    "overlays": [
                        f"vsmineralmasonry:block/stone/{code}/{{tile}}-{face}face"
                    ],
                },
                {
                    "base": baseface_path.format(rock="{rock}", variant="3", face=face),
                    "overlays": [
                        f"vsmineralmasonry:block/stone/{code}/{{tile}}-{face}face"
                    ],
                },
                {
                    "base": baseface_path.format(rock="{rock}", variant="4", face=face),
                    "overlays": [
                        f"vsmineralmasonry:block/stone/{code}/{{tile}}-{face}face"
                    ],
                },
            ],
        }

    block = {
        "code": code,
        "class": class_name,
        "replaceable": 120,
        "blockmaterial": "Stone",
        "storageFlags": 5,
        "variantgroups": [
            {"code": "rock", "states": ROCKS},
            {"code": "tile", "states": TILES},
        ],
        "attributes": {
            "canChisel": True,
            "handbook": {"groupBy": [f"{code}-{{rock}}"]},
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
            f"{code}-{rock}-{tile}"
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
    dump_json(block_path, block)


def update_lang() -> None:
    lang = json.loads(LANG_PATH.read_text())
    for setdef in SETS:
        prefix = f"block-vsmineralmasonry-{setdef['code']}-"
        for key in [k for k in lang if k.startswith(prefix)]:
            del lang[key]

    for setdef in SETS:
        for rock in ROCKS:
            for tile in TILES:
                key = f"block-vsmineralmasonry-{setdef['code']}-{rock}-{tile}"
                lang[key] = f"VSM {setdef['display']} {title_name(rock)}"

    dump_json(LANG_PATH, lang)


def main() -> None:
    for setdef in SETS:
        build_textures(setdef["texture_dir"], setdef["source_pattern"])
        build_block(setdef["block_path"], setdef["code"], setdef["display"], setdef["class"], setdef["baseface_path"])
        print(setdef["block_path"])
        print(f"{setdef['code']}: rocks={len(ROCKS)} tiles={len(TILES)} variants={len(ROCKS) * len(TILES)}")

    update_lang()


if __name__ == "__main__":
    main()

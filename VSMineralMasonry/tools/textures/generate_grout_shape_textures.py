#!/usr/bin/env python3
from __future__ import annotations

import subprocess
import tempfile
from pathlib import Path


ROOT = Path("/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/VSMineralMasonry")
PROJECT_ROOT = ROOT.parent
MASK_ROOT = PROJECT_ROOT / "textures" / "decor-overlays"
SLABBASE_DIR = ROOT / "assets" / "vsmineralmasonry" / "textures" / "block" / "stone" / "slabbase"
COLOR_OUTPUT_DIR = ROOT / "assets" / "vsmineralmasonry" / "textures" / "block" / "stone" / "groutshapecolor"
ROCK_OUTPUT_DIR = ROOT / "assets" / "vsmineralmasonry" / "textures" / "block" / "stone" / "groutshaperock"
TILESET_OUTPUT_DIR = ROOT / "assets" / "vsmineralmasonry" / "textures" / "block" / "stone" / "grouttilecolor"
TILESET_ROCK_OUTPUT_DIR = ROOT / "assets" / "vsmineralmasonry" / "textures" / "block" / "stone" / "grouttilerock"
COLOR_DETAIL_SOURCE = MASK_ROOT / "color-tile-texture2.png"
COLOR_SHADOW_FACTOR = 0.93
COLOR_HIGHLIGHT_FACTOR = 1.03
COLOR_DETAIL_SIGMOID = "1.4,50%"
COLOR_DETAIL_LEVEL = "18%,86%"

TILESETS = [f"tileset{i}" for i in range(1, 17)]
CUSTOM_BORDER_TILESET_SOURCES = {"tileset10": "border2"}
ROTATION_INVARIANT_TILESETS = {"tileset4", "tileset6", "tileset7", "tileset9", "tileset11", "tileset12", "tileset13", "tileset14", "tileset15"}
TWO_WAY_TILESETS = {"tileset1", "tileset3", "tileset8"}
EDGE_PARTS = ["top", "right", "bottom", "left"]
CORNER_PARTS = ["topleft", "topright", "bottomright", "bottomleft"]
NORMALIZED_MASK_SIZE = "64x64!"
PADDED_MASKS = {"tileset8"}

COLOR_BASES = {
    "black": "#2c2c30",
    "white": "#e0e0e0",
    "gold": "#d0b35b",
    "silver": "#b6bfc8",
    "red": "#8f655f",
    "blue": "#4f6180",
    "green": "#425a43",
    "yellow": "#8d7b33",
    "brown": "#a67647",
    "grey": "#9ea6ae",
    "darkgrey": "#575a5e",
}

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


def run(*args: str) -> None:
    subprocess.run(list(args), check=True)


def report_non_64_mask(mask_path: Path) -> None:
    result = subprocess.run(
        ["magick", "identify", "-format", "%w %h", str(mask_path)],
        check=True,
        capture_output=True,
        text=True
    )
    width, height = result.stdout.strip().split()
    if width != "64" or height != "64":
        print(f"warning: {mask_path} is {width}x{height}, expected 64x64")


def shade_color(hex_color: str, factor: float) -> str:
    value = hex_color.lstrip("#")
    rgb = [int(value[i:i + 2], 16) for i in (0, 2, 4)]
    shaded = [max(0, min(255, int(round(channel * factor)))) for channel in rgb]
    return f"#{shaded[0]:02x}{shaded[1]:02x}{shaded[2]:02x}"


def normalized_mask_args(mask_path: Path) -> list[str]:
    if mask_path.stem in PADDED_MASKS:
        return [
            str(mask_path),
            "-background",
            "white",
            "-gravity",
            "center",
            "-extent",
            NORMALIZED_MASK_SIZE
        ]

    return [
        str(mask_path),
        "-filter",
        "point",
        "-resize",
        NORMALIZED_MASK_SIZE
    ]


def build_color_variant(mask_path: Path, out_path: Path, color: str) -> None:
    shadow = shade_color(color, COLOR_SHADOW_FACTOR)
    highlight = shade_color(color, COLOR_HIGHLIGHT_FACTOR)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(suffix=".png", delete=False) as temp_file:
        base_out = Path(temp_file.name)
    run(
        "magick",
        str(COLOR_DETAIL_SOURCE),
        "-alpha",
        "off",
        "-colorspace",
        "Gray",
        "-auto-level",
        "-sigmoidal-contrast",
        COLOR_DETAIL_SIGMOID,
        "-level",
        COLOR_DETAIL_LEVEL,
        "-write",
        "mpr:detail",
        "+delete",
        "mpr:detail",
        "(",
        f"xc:{shadow}",
        f"xc:{color}",
        f"xc:{highlight}",
        "+append",
        "-filter",
        "point",
        "-resize",
        "256x1!",
        ")",
        "-compose",
        "CopyRed",
        "-clut",
        "-colorspace",
        "sRGB",
        "-alpha",
        "off",
        f"PNG32:{base_out}",
    )
    run(
        "magick",
        str(base_out),
        "-alpha",
        "off",
        "(",
        *normalized_mask_args(mask_path),
        "-alpha",
        "off",
        "-colorspace",
        "Gray",
        "-negate",
        "-threshold",
        "50%",
        ")",
        "-compose",
        "CopyOpacity",
        "-composite",
        f"PNG32:{out_path}",
    )
    base_out.unlink(missing_ok=True)


def build_rock_variant(mask_path: Path, source_path: Path, out_path: Path) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    run(
        "magick",
        str(source_path),
        "-alpha",
        "off",
        "(",
        *normalized_mask_args(mask_path),
        "-alpha",
        "off",
        "-colorspace",
        "Gray",
        "-negate",
        "-threshold",
        "50%",
        ")",
        "-compose",
        "CopyOpacity",
        "-composite",
        "-colorspace",
        "sRGB",
        "-define",
        "png:color-type=6",
        f"PNG32:{out_path}",
    )


def build_custom_border_color_variants(color_name: str, color_hex: str, family: str, source_prefix: str) -> None:
    frame_mask = MASK_ROOT / f"{source_prefix}-4x.png"
    edge_mask = MASK_ROOT / f"{source_prefix}-1x.png"
    corner_mask = MASK_ROOT / f"{source_prefix}-corner.png"
    report_non_64_mask(frame_mask)
    report_non_64_mask(edge_mask)
    report_non_64_mask(corner_mask)

    frame_out = COLOR_OUTPUT_DIR / f"{family}-{color_name}-frame-base.png"
    edge_out = COLOR_OUTPUT_DIR / f"{family}-{color_name}-edge-base.png"
    corner_out = COLOR_OUTPUT_DIR / f"{family}-{color_name}-corner-base.png"

    build_color_variant(frame_mask, frame_out, color_hex)
    build_color_variant(edge_mask, edge_out, color_hex)
    build_color_variant(corner_mask, corner_out, color_hex)

    run("magick", str(frame_out), f"PNG32:{TILESET_OUTPUT_DIR / f'{family}-{color_name}-frame.png'}")
    run("magick", str(edge_out), "-background", "none", "-gravity", "center", "-extent", NORMALIZED_MASK_SIZE, f"PNG32:{TILESET_OUTPUT_DIR / f'{family}-{color_name}-right.png'}")
    run("magick", str(edge_out), "-background", "none", "-gravity", "center", "-extent", NORMALIZED_MASK_SIZE, "-rotate", "270", f"PNG32:{TILESET_OUTPUT_DIR / f'{family}-{color_name}-top.png'}")
    run("magick", str(edge_out), "-background", "none", "-gravity", "center", "-extent", NORMALIZED_MASK_SIZE, "-rotate", "180", f"PNG32:{TILESET_OUTPUT_DIR / f'{family}-{color_name}-left.png'}")
    run("magick", str(edge_out), "-background", "none", "-gravity", "center", "-extent", NORMALIZED_MASK_SIZE, "-rotate", "90", f"PNG32:{TILESET_OUTPUT_DIR / f'{family}-{color_name}-bottom.png'}")
    run("magick", str(corner_out), f"PNG32:{TILESET_OUTPUT_DIR / f'{family}-{color_name}-topright.png'}")
    run("magick", str(corner_out), "-rotate", "270", f"PNG32:{TILESET_OUTPUT_DIR / f'{family}-{color_name}-topleft.png'}")
    run("magick", str(corner_out), "-rotate", "180", f"PNG32:{TILESET_OUTPUT_DIR / f'{family}-{color_name}-bottomleft.png'}")
    run("magick", str(corner_out), "-rotate", "90", f"PNG32:{TILESET_OUTPUT_DIR / f'{family}-{color_name}-bottomright.png'}")

    frame_out.unlink(missing_ok=True)
    edge_out.unlink(missing_ok=True)
    corner_out.unlink(missing_ok=True)


def build_custom_border_rock_variants(rock_name: str, family: str, source_prefix: str) -> None:
    frame_mask = MASK_ROOT / f"{source_prefix}-4x.png"
    edge_mask = MASK_ROOT / f"{source_prefix}-1x.png"
    corner_mask = MASK_ROOT / f"{source_prefix}-corner.png"
    report_non_64_mask(frame_mask)
    report_non_64_mask(edge_mask)
    report_non_64_mask(corner_mask)

    frame_out = ROCK_OUTPUT_DIR / f"{family}-{rock_name}-frame-base.png"
    edge_out = ROCK_OUTPUT_DIR / f"{family}-{rock_name}-edge-base.png"
    corner_out = ROCK_OUTPUT_DIR / f"{family}-{rock_name}-corner-base.png"

    build_rock_variant(frame_mask, SLABBASE_DIR / f"{rock_name}.png", frame_out)
    build_rock_variant(edge_mask, SLABBASE_DIR / f"{rock_name}.png", edge_out)
    build_rock_variant(corner_mask, SLABBASE_DIR / f"{rock_name}.png", corner_out)

    run("magick", str(frame_out), f"PNG32:{TILESET_ROCK_OUTPUT_DIR / f'{family}-{rock_name}-frame.png'}")
    run("magick", str(edge_out), "-background", "none", "-gravity", "center", "-extent", NORMALIZED_MASK_SIZE, f"PNG32:{TILESET_ROCK_OUTPUT_DIR / f'{family}-{rock_name}-right.png'}")
    run("magick", str(edge_out), "-background", "none", "-gravity", "center", "-extent", NORMALIZED_MASK_SIZE, "-rotate", "270", f"PNG32:{TILESET_ROCK_OUTPUT_DIR / f'{family}-{rock_name}-top.png'}")
    run("magick", str(edge_out), "-background", "none", "-gravity", "center", "-extent", NORMALIZED_MASK_SIZE, "-rotate", "180", f"PNG32:{TILESET_ROCK_OUTPUT_DIR / f'{family}-{rock_name}-left.png'}")
    run("magick", str(edge_out), "-background", "none", "-gravity", "center", "-extent", NORMALIZED_MASK_SIZE, "-rotate", "90", f"PNG32:{TILESET_ROCK_OUTPUT_DIR / f'{family}-{rock_name}-bottom.png'}")
    run("magick", str(corner_out), f"PNG32:{TILESET_ROCK_OUTPUT_DIR / f'{family}-{rock_name}-topright.png'}")
    run("magick", str(corner_out), "-rotate", "270", f"PNG32:{TILESET_ROCK_OUTPUT_DIR / f'{family}-{rock_name}-topleft.png'}")
    run("magick", str(corner_out), "-rotate", "180", f"PNG32:{TILESET_ROCK_OUTPUT_DIR / f'{family}-{rock_name}-bottomleft.png'}")
    run("magick", str(corner_out), "-rotate", "90", f"PNG32:{TILESET_ROCK_OUTPUT_DIR / f'{family}-{rock_name}-bottomright.png'}")

    frame_out.unlink(missing_ok=True)
    edge_out.unlink(missing_ok=True)
    corner_out.unlink(missing_ok=True)


def emit_tileset_parts(source_out: Path, tileset: str, variant_name: str, target_dir: Path) -> None:
    if tileset in TWO_WAY_TILESETS:
        run("magick", str(source_out), f"PNG32:{target_dir / f'{tileset}-{variant_name}-frame.png'}")
        run("magick", str(source_out), f"PNG32:{target_dir / f'{tileset}-{variant_name}-top.png'}")
        run("magick", str(source_out), f"PNG32:{target_dir / f'{tileset}-{variant_name}-bottom.png'}")
        run("magick", str(source_out), "-rotate", "90", f"PNG32:{target_dir / f'{tileset}-{variant_name}-right.png'}")
        run("magick", str(source_out), "-rotate", "90", f"PNG32:{target_dir / f'{tileset}-{variant_name}-left.png'}")
        for part in CORNER_PARTS:
            run("magick", str(source_out), f"PNG32:{target_dir / f'{tileset}-{variant_name}-{part}.png'}")
        return

    if tileset in ROTATION_INVARIANT_TILESETS:
        run("magick", str(source_out), f"PNG32:{target_dir / f'{tileset}-{variant_name}-frame.png'}")
        for part in EDGE_PARTS:
            run("magick", str(source_out), f"PNG32:{target_dir / f'{tileset}-{variant_name}-{part}.png'}")
        for part in CORNER_PARTS:
            run("magick", str(source_out), f"PNG32:{target_dir / f'{tileset}-{variant_name}-{part}.png'}")
        return

    run("magick", str(source_out), f"PNG32:{target_dir / f'{tileset}-{variant_name}-frame.png'}")
    run("magick", str(source_out), f"PNG32:{target_dir / f'{tileset}-{variant_name}-top.png'}")
    run("magick", str(source_out), "-rotate", "90", f"PNG32:{target_dir / f'{tileset}-{variant_name}-right.png'}")
    run("magick", str(source_out), "-rotate", "180", f"PNG32:{target_dir / f'{tileset}-{variant_name}-bottom.png'}")
    run("magick", str(source_out), "-rotate", "270", f"PNG32:{target_dir / f'{tileset}-{variant_name}-left.png'}")
    for part in CORNER_PARTS:
        run("magick", str(source_out), f"PNG32:{target_dir / f'{tileset}-{variant_name}-{part}.png'}")


def main() -> None:
    COLOR_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    ROCK_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    TILESET_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    TILESET_ROCK_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for old_png in COLOR_OUTPUT_DIR.glob("*.png"):
        old_png.unlink()
    for old_png in ROCK_OUTPUT_DIR.glob("*.png"):
        old_png.unlink()
    for old_png in TILESET_OUTPUT_DIR.glob("*.png"):
        old_png.unlink()
    for old_png in TILESET_ROCK_OUTPUT_DIR.glob("*.png"):
        old_png.unlink()

    for tileset in TILESETS:
        mask_path = MASK_ROOT / f"{tileset}.png"
        report_non_64_mask(mask_path)

        for color_name, color_hex in COLOR_BASES.items():
            color_out = COLOR_OUTPUT_DIR / f"{tileset}-{color_name}.png"
            build_color_variant(mask_path, color_out, color_hex)
            emit_tileset_parts(color_out, tileset, color_name, TILESET_OUTPUT_DIR)

        for rock in ROCKS:
            rock_out = ROCK_OUTPUT_DIR / f"{tileset}-{rock}.png"
            build_rock_variant(mask_path, SLABBASE_DIR / f"{rock}.png", rock_out)
            emit_tileset_parts(rock_out, tileset, rock, TILESET_ROCK_OUTPUT_DIR)

    for family, source_prefix in CUSTOM_BORDER_TILESET_SOURCES.items():
        for color_name, color_hex in COLOR_BASES.items():
            build_custom_border_color_variants(color_name, color_hex, family, source_prefix)
        for rock in ROCKS:
            build_custom_border_rock_variants(rock, family, source_prefix)


if __name__ == "__main__":
    main()

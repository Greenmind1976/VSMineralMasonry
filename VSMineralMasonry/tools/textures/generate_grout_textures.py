#!/usr/bin/env python3
from __future__ import annotations

import subprocess
from pathlib import Path


ROOT = Path("/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/VSMineralMasonry")
OUTPUT_DIR = ROOT / "assets/vsmineralmasonry/textures/block/stone/grout"
THICK_OUTPUT_DIR = ROOT / "assets/vsmineralmasonry/textures/block/stone/thickgrout"
ROCK_OUTPUT_DIR = ROOT / "assets/vsmineralmasonry/textures/block/stone/groutrock"
SLABBASE_DIR = ROOT / "assets/vsmineralmasonry/textures/block/stone/slabbase"
BLOB_MASK_SOURCE = OUTPUT_DIR / "black-blob.png"

PARTS = (
    "top",
    "bottom",
    "left",
    "right",
    "topleft",
    "topright",
    "bottomleft",
    "bottomright",
    "frame",
)

ROCKS = (
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
)

ALPHA_MULTIPLIER = "1.0"
COLOR_SHADOW_FACTOR = 0.93
COLOR_HIGHLIGHT_FACTOR = 1.03
COLOR_DETAIL_SIGMOID = "1.4,50%"

COLOR_BASES = {
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

ROCK_SOURCES = {
    "black": SLABBASE_DIR / "basalt.png",
    "white": SLABBASE_DIR / "whitemarble.png",
}


def run(*args: str) -> None:
    subprocess.run(list(args), check=True)


def shade_color(hex_color: str, factor: float) -> str:
    value = hex_color.lstrip("#")
    rgb = [int(value[i:i + 2], 16) for i in (0, 2, 4)]
    shaded = [max(0, min(255, int(round(channel * factor)))) for channel in rgb]
    return f"#{shaded[0]:02x}{shaded[1]:02x}{shaded[2]:02x}"


def transparent_canvas(path: Path) -> None:
    run("magick", "-size", "64x64", "xc:none", f"PNG32:{path}")


def apply_opacity(path: Path) -> None:
    run(
        "magick",
        str(path),
        "-channel",
        "A",
        "-evaluate",
        "multiply",
        ALPHA_MULTIPLIER,
        "+channel",
        f"PNG32:{path}",
    )


def neutralize_white_texture(path: Path) -> None:
    run(
        "magick",
        str(path),
        "-alpha",
        "extract",
        "-write",
        "mpr:alpha",
        "+delete",
        str(path),
        "-alpha",
        "off",
        "-colorspace",
        "Gray",
        "-colorspace",
        "sRGB",
        "-brightness-contrast",
        "6x8",
        "mpr:alpha",
        "-compose",
        "CopyOpacity",
        "-composite",
        f"PNG32:{path}",
    )


def composite_strip(canvas: Path, source: Path, x: int, y: int, width: int, height: int) -> None:
    crop = f"{width}x{height}+{x}+{y}"
    run(
        "magick",
        str(canvas),
        "(",
        str(source),
        "-crop",
        crop,
        "+repage",
        "-geometry",
        f"+{x}+{y}",
        ")",
        "-compose",
        "over",
        "-composite",
        f"PNG32:{canvas}",
    )


def build_part_from_rock(source: Path, out_path: Path, part: str) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    transparent_canvas(out_path)
    if part in {"top", "topleft", "topright", "frame"}:
        composite_strip(out_path, source, 0, 0, 64, 1)
    if part in {"bottom", "bottomleft", "bottomright", "frame"}:
        composite_strip(out_path, source, 0, 63, 64, 1)
    if part in {"left", "topleft", "bottomleft", "frame"}:
        composite_strip(out_path, source, 0, 0, 1, 64)
    if part in {"right", "topright", "bottomright", "frame"}:
        composite_strip(out_path, source, 63, 0, 1, 64)
    apply_opacity(out_path)


def composite_strip_with_alpha(canvas: Path, source: Path, x: int, y: int, width: int, height: int, alpha: float) -> None:
    crop = f"{width}x{height}+{x}+{y}"
    run(
        "magick",
        str(canvas),
        "(",
        str(source),
        "-crop",
        crop,
        "+repage",
        "-alpha",
        "set",
        "-channel",
        "A",
        "-evaluate",
        "multiply",
        str(alpha),
        "+channel",
        "-geometry",
        f"+{x}+{y}",
        ")",
        "-compose",
        "over",
        "-composite",
        f"PNG32:{canvas}",
    )


def build_thick_part_from_rock(source: Path, out_path: Path, part: str) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    transparent_canvas(out_path)
    if part in {"top", "topleft", "topright", "frame"}:
        composite_strip_with_alpha(out_path, source, 0, 0, 64, 1, 1.0)
        composite_strip_with_alpha(out_path, source, 0, 1, 64, 1, 0.4)
    if part in {"bottom", "bottomleft", "bottomright", "frame"}:
        composite_strip_with_alpha(out_path, source, 0, 63, 64, 1, 1.0)
        composite_strip_with_alpha(out_path, source, 0, 62, 64, 1, 0.4)
    if part in {"left", "topleft", "bottomleft", "frame"}:
        composite_strip_with_alpha(out_path, source, 0, 0, 1, 64, 1.0)
        composite_strip_with_alpha(out_path, source, 1, 0, 1, 64, 0.4)
    if part in {"right", "topright", "bottomright", "frame"}:
        composite_strip_with_alpha(out_path, source, 63, 0, 1, 64, 1.0)
        composite_strip_with_alpha(out_path, source, 62, 0, 1, 64, 0.4)


def build_blob_from_rock(source: Path, out_path: Path) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    run(
        "magick",
        str(source),
        "-alpha",
        "extract",
        "-write",
        "mpr:sourcealpha",
        "+delete",
        str(source),
        "-alpha",
        "off",
        str(BLOB_MASK_SOURCE),
        "-alpha",
        "extract",
        "-compose",
        "CopyOpacity",
        "-composite",
        f"PNG32:{out_path}",
    )


def tint_texture(source: Path, out_path: Path, shadow: str, mid: str, highlight: str) -> None:
    run(
        "magick",
        str(source),
        "-alpha",
        "extract",
        "-write",
        "mpr:alpha",
        "+delete",
        str(source),
        "-alpha",
        "off",
        "-colorspace",
        "Gray",
        "-auto-level",
        "-sigmoidal-contrast",
        "3,54%",
        "-write",
        "mpr:gray",
        "+delete",
        "mpr:gray",
        "(",
        f"xc:{shadow}",
        f"xc:{mid}",
        f"xc:{highlight}",
        "+append",
        "-filter",
        "point",
        "-resize",
        "256x1!",
        ")",
        "-clut",
        "-colorspace",
        "sRGB",
        "mpr:alpha",
        "-compose",
        "CopyOpacity",
        "-composite",
        f"PNG32:{out_path}",
    )


def tint_texture_single_color(source: Path, out_path: Path, color: str) -> None:
    shadow = shade_color(color, COLOR_SHADOW_FACTOR)
    highlight = shade_color(color, COLOR_HIGHLIGHT_FACTOR)
    run(
        "magick",
        str(source),
        "-alpha",
        "extract",
        "-write",
        "mpr:alpha",
        "+delete",
        str(source),
        "-alpha",
        "off",
        "-colorspace",
        "Gray",
        "-auto-level",
        "-sigmoidal-contrast",
        COLOR_DETAIL_SIGMOID,
        "-write",
        "mpr:gray",
        "+delete",
        "mpr:gray",
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
        "-clut",
        "-colorspace",
        "sRGB",
        "mpr:alpha",
        "-compose",
        "CopyOpacity",
        "-composite",
        f"PNG32:{out_path}",
    )


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    THICK_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    ROCK_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for color, source in ROCK_SOURCES.items():
        for part in PARTS:
            normal_out = OUTPUT_DIR / f"{color}-{part}.png"
            thick_out = THICK_OUTPUT_DIR / f"{color}-{part}.png"
            build_part_from_rock(source, normal_out, part)
            build_thick_part_from_rock(source, thick_out, part)
            if color == "white":
                neutralize_white_texture(normal_out)
                neutralize_white_texture(thick_out)

    for color, hex_color in COLOR_BASES.items():
        for part in PARTS:
            tint_texture_single_color(OUTPUT_DIR / f"black-{part}.png", OUTPUT_DIR / f"{color}-{part}.png", hex_color)
            tint_texture_single_color(THICK_OUTPUT_DIR / f"black-{part}.png", THICK_OUTPUT_DIR / f"{color}-{part}.png", hex_color)

    for old_png in ROCK_OUTPUT_DIR.glob("*.png"):
        old_png.unlink()

    for rock in ROCKS:
        source = SLABBASE_DIR / f"{rock}.png"
        for part in PARTS:
            build_part_from_rock(source, ROCK_OUTPUT_DIR / f"{rock}-{part}.png", part)
        build_blob_from_rock(source, ROCK_OUTPUT_DIR / f"{rock}-blob.png")


if __name__ == "__main__":
    main()

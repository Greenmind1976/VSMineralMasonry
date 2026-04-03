#!/usr/bin/env python3

import subprocess
from pathlib import Path


REPO_ROOT = Path("/Users/garretcoffman/Documents/VSMods/VSMineralMasonry")
TEXTURE_ROOT = REPO_ROOT / "textures" / "no-bevel-polished-vanilla-64"
OUTPUT_DIR = REPO_ROOT / "VSMineralMasonry" / "assets" / "vsmineralmasonry" / "textures" / "block" / "stone" / "triangleoverlay"

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

PARTS = {
    "topleft": "polygon 0,0 64,0 0,64",
    "topright": "polygon 0,0 64,0 64,64",
    "bottomleft": "polygon 0,0 0,64 64,64",
    "bottomright": "polygon 64,0 64,64 0,64",
}


def run(*args: str) -> None:
    subprocess.run(args, check=True)


def generate() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for old_png in OUTPUT_DIR.glob("*.png"):
        old_png.unlink()

    for rock in ROCKS:
        a_path = TEXTURE_ROOT / f"{rock}.png"

        for part, polygon in PARTS.items():
            out_path = OUTPUT_DIR / f"{rock}-{part}.png"
            run(
                "magick",
                str(a_path),
                "(",
                "-size",
                "64x64",
                "xc:black",
                "-fill",
                "white",
                "-draw",
                polygon,
                ")",
                "-alpha",
                "off",
                "-compose",
                "copyopacity",
                "-composite",
                "-colorspace",
                "sRGB",
                "-define",
                "png:color-type=6",
                f"PNG32:{out_path}",
            )


if __name__ == "__main__":
    generate()

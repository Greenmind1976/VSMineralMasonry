#!/usr/bin/env python3
from __future__ import annotations

import shutil
import subprocess
from pathlib import Path


ROOT = Path("/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/VSMineralMasonry")
SOURCE_ROOT = ROOT / "assets/vsmineralmasonry/textures/block/stone/muralslab-basefaces"
TARGET_ROOT = ROOT / "assets/vsmineralmasonry/textures/block/stone/muralslab-basefaces-overlay"
DEBUG_ROOT = ROOT / "bin/Debug/Mods/mod/assets/vsmineralmasonry/textures/block/stone/muralslab-basefaces-overlay"
MOSSCONTRAST_ROOT = ROOT / "assets/vsmineralmasonry/textures/block/stone/muralslab-basefaces-mosscontrast"
DEBUG_MOSSCONTRAST_ROOT = ROOT / "bin/Debug/Mods/mod/assets/vsmineralmasonry/textures/block/stone/muralslab-basefaces-mosscontrast"

ROCK_ADJUSTMENTS = {
    "whitemarble": {
        "brightness_contrast": "18x12",
        "sigmoidal": "3,52%",
    },
    "chert": {
        "brightness_contrast": "18x12",
        "sigmoidal": "3,52%",
    },
}

MOSSCONTRAST_ADJUSTMENTS = {
    "basalt": {
        "brightness_contrast": "10x5",
        "sigmoidal": "1.5,50%",
    },
    "shale": {
        "brightness_contrast": "10x5",
        "sigmoidal": "1.5,50%",
    },
    "slate": {
        "brightness_contrast": "10x5",
        "sigmoidal": "1.5,50%",
    },
}


def brighten_targets(target_root: Path, adjustments: dict[str, dict[str, str]]) -> None:
    for rock, settings in adjustments.items():
        for path in target_root.glob(f"{rock}*.png"):
            subprocess.run(
                [
                    "magick",
                    str(path),
                    "-brightness-contrast",
                    settings["brightness_contrast"],
                    "-sigmoidal-contrast",
                    settings["sigmoidal"],
                    "PNG32:" + str(path),
                ],
                check=True,
            )


def main() -> None:
    if TARGET_ROOT.exists():
        shutil.rmtree(TARGET_ROOT)
    shutil.copytree(SOURCE_ROOT, TARGET_ROOT)
    brighten_targets(TARGET_ROOT, ROCK_ADJUSTMENTS)

    if DEBUG_ROOT.exists():
        shutil.rmtree(DEBUG_ROOT)
    shutil.copytree(TARGET_ROOT, DEBUG_ROOT)

    if MOSSCONTRAST_ROOT.exists():
        shutil.rmtree(MOSSCONTRAST_ROOT)
    shutil.copytree(TARGET_ROOT, MOSSCONTRAST_ROOT)
    brighten_targets(MOSSCONTRAST_ROOT, MOSSCONTRAST_ADJUSTMENTS)

    if DEBUG_MOSSCONTRAST_ROOT.exists():
        shutil.rmtree(DEBUG_MOSSCONTRAST_ROOT)
    shutil.copytree(MOSSCONTRAST_ROOT, DEBUG_MOSSCONTRAST_ROOT)

    print(TARGET_ROOT)
    print(MOSSCONTRAST_ROOT)


if __name__ == "__main__":
    main()

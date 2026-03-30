#!/usr/bin/env python3
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path("/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/VSMineralMasonry")
SLABTEST_BLOCK = ROOT / "assets/vsmineralmasonry/blocktypes/stone/slabtest.json"
SLABCYCLE_BLOCK = ROOT / "assets/vsmineralmasonry/blocktypes/stone/slabcycle.json"
LANG_PATH = ROOT / "assets/vsmineralmasonry/lang/en.json"
DEBUG_ROOT = ROOT / "bin/Debug/Mods/mod/assets/vsmineralmasonry"
DEBUG_BLOCK = DEBUG_ROOT / "blocktypes/stone/slabcycle.json"
DEBUG_LANG = DEBUG_ROOT / "lang/en.json"

DISPLAY_NAMES = {
    "bituminouscoal": "Black Coal",
    "whitemarble": "White Marble",
}


def title_name(code: str) -> str:
    if code in DISPLAY_NAMES:
        return DISPLAY_NAMES[code]
    return " ".join(part.capitalize() for part in code.split("_"))


def dump_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=True) + "\n")


def main() -> None:
    slabtest = json.loads(SLABTEST_BLOCK.read_text())
    states = {group["code"]: group["states"] for group in slabtest["variantgroups"]}

    allowed_variants = []
    creative_variants = []
    for family in states["family"]:
        for finish in states["finish"]:
            for mineral in states["mineral"]:
                for rock in states["rock"]:
                    for tile in states["tile"]:
                        code = f"slabcycle-{family}-{finish}-{mineral}-{rock}-{tile}"
                        allowed_variants.append(code)
                        if tile == "r1c1":
                            creative_variants.append(code)

    textures_by_type = {}
    for key, value in slabtest["texturesByType"].items():
        textures_by_type[key.replace("slabtest-", "slabcycle-")] = value

    slabcycle = {
        "code": "slabcycle",
        "class": "BlockSlabCycle",
        "blockmaterial": slabtest["blockmaterial"],
        "storageFlags": slabtest["storageFlags"],
        "attributes": {
            "canChisel": True,
            "handbook": {
                "groupBy": ["slabcycle-{family}-{finish}-{mineral}-{rock}"]
            }
        },
        "variantgroups": slabtest["variantgroups"],
        "allowedVariants": allowed_variants,
        "creativeinventory": {
            "general": creative_variants,
            "construction": creative_variants,
        },
        "shape": slabtest["shape"],
        "drawtype": slabtest["drawtype"],
        "replaceable": slabtest["replaceable"],
        "resistance": slabtest["resistance"],
        "requiredMiningTier": slabtest["requiredMiningTier"],
        "texturesByType": textures_by_type,
    }

    dump_json(SLABCYCLE_BLOCK, slabcycle)
    dump_json(DEBUG_BLOCK, slabcycle)

    lang = json.loads(LANG_PATH.read_text())
    for key in [k for k in lang if k.startswith("block-vsmineralmasonry-slabcycle-")]:
        del lang[key]

    for family in states["family"]:
        for finish in states["finish"]:
            for mineral in states["mineral"]:
                for rock in states["rock"]:
                    for tile in states["tile"]:
                        key = f"block-vsmineralmasonry-slabcycle-{family}-{finish}-{mineral}-{rock}-{tile}"
                        lang[key] = (
                            f"{title_name(family)} "
                            f"{title_name(finish)} "
                            f"{title_name(mineral)} "
                            f"{title_name(rock)}"
                        )

    dump_json(LANG_PATH, lang)
    dump_json(DEBUG_LANG, lang)

    print(SLABCYCLE_BLOCK)
    print(f"allowedVariants={len(allowed_variants)}")
    print(f"creativeVariants={len(creative_variants)}")


if __name__ == "__main__":
    main()

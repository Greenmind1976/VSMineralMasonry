#!/usr/bin/env python3
from __future__ import annotations

import json
import tempfile
import shutil
import subprocess
from pathlib import Path


ROOT = Path("/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/VSMineralMasonry")
PROJECT_ROOT = ROOT.parent

SOURCE_BLOCK = ROOT / "assets/vsmineralmasonry/blocktypes/stone/muralslab.json"
SOURCE_LANG = ROOT / "assets/vsmineralmasonry/lang/en.json"
SOURCE_TEXTURE_ROOT = ROOT / "assets/vsmineralmasonry/textures/block/stone/muralslab"
SOURCE_MURAL_BASEFACE_ROOT = ROOT / "assets/vsmineralmasonry/textures/block/stone/muralslab-basefaces"
SOURCE_MURAL_OVERLAY_ROOT = ROOT / "assets/vsmineralmasonry/textures/block/stone/muralslab-overlays"
SOURCE_SLABBASE_ROOT = ROOT / "assets/vsmineralmasonry/textures/block/stone/slabbase"

DEBUG_ROOT = ROOT / "bin/Debug/Mods/mod/assets/vsmineralmasonry"
DEBUG_BLOCK = DEBUG_ROOT / "blocktypes/stone/muralslab.json"
DEBUG_LANG = DEBUG_ROOT / "lang/en.json"
DEBUG_TEXTURE_ROOT = DEBUG_ROOT / "textures/block/stone/muralslab"
DEBUG_MURAL_BASEFACE_ROOT = DEBUG_ROOT / "textures/block/stone/muralslab-basefaces"
DEBUG_MURAL_OVERLAY_ROOT = DEBUG_ROOT / "textures/block/stone/muralslab-overlays"
DEBUG_SLABBASE_ROOT = DEBUG_ROOT / "textures/block/stone/slabbase"

ROCK_BASE_ROOT = PROJECT_ROOT / "textures/no-bevel-polished-vanilla-64"
ALT_ROCK_BASE_ROOT = PROJECT_ROOT / "textures/polished-vanilla-64"
OVERLAY_SOURCE_ROOT = PROJECT_ROOT / "textures/overlay-source-3x3"

FAMILIES = ["breccia", "travertine", "granite", "marble"]
FINISHES = ["polished", "burnished"]
MINERALS = [
    "bituminouscoal",
    "emerald",
    "lignite",
    "quartz",
    "silver",
]
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
OVERLAY_COMPOSED_FAMILIES = {"breccia", "travertine", "marble", "granite"}

EXCLUDED_COMBINATIONS = {
    ("basalt", "polished", "bituminouscoal"),
    ("basalt", "burnished", "bituminouscoal"),
    ("basalt", "burnished", "lignite"),
    ("granite", "polished", "lignite"),
    ("granite", "burnished", "lignite"),
    ("granite", "burnished", "bituminouscoal"),
    ("granite", "burnished", "silver"),
    ("whitemarble", "polished", "quartz"),
    ("whitemarble", "burnished", "quartz"),
    ("whitemarble", "polished", "silver"),
    ("whitemarble", "burnished", "silver"),
    ("slate", "polished", "lignite"),
    ("slate", "burnished", "lignite"),
    ("slate", "burnished", "bituminouscoal"),
    ("chert", "polished", "lignite"),
    ("chert", "burnished", "lignite"),
    ("chert", "burnished", "bituminouscoal"),
    ("phyllite", "polished", "lignite"),
    ("phyllite", "burnished", "lignite"),
    ("phyllite", "burnished", "bituminouscoal"),
    ("phyllite", "burnished", "silver"),
    ("andesite", "polished", "lignite"),
    ("andesite", "burnished", "lignite"),
    ("andesite", "burnished", "bituminouscoal"),
    ("andesite", "burnished", "silver"),
    ("limestone", "polished", "silver"),
    ("limestone", "burnished", "silver"),
    ("limestone", "burnished", "lignite"),
    ("limestone", "burnished", "quartz"),
    ("shale", "polished", "lignite"),
    ("shale", "burnished", "lignite"),
    ("shale", "burnished", "bituminouscoal"),
    ("chalk", "polished", "silver"),
    ("chalk", "burnished", "silver"),
    ("chalk", "burnished", "lignite"),
    ("chalk", "burnished", "quartz"),
    ("granite", "polished", "emerald"),
    ("chert", "polished", "emerald"),
    ("phyllite", "polished", "emerald"),
    ("andesite", "polished", "emerald"),
    ("limestone", "polished", "emerald"),
    ("basalt", "burnished", "emerald"),
    ("granite", "burnished", "emerald"),
    ("slate", "burnished", "emerald"),
    ("chert", "burnished", "emerald"),
    ("phyllite", "burnished", "emerald"),
    ("andesite", "burnished", "emerald"),
    ("limestone", "burnished", "emerald"),
    ("shale", "burnished", "emerald"),
    ("chalk", "burnished", "emerald"),
}

DISPLAY_NAMES = {
    "bituminouscoal": "Black Coal",
    "whitemarble": "White Marble",
}

MINERAL_TINTS = {
    "bituminouscoal": (28, 28, 30),
    "emerald": (44, 132, 92),
    "hematite": (120, 52, 44),
    "lignite": (100, 76, 58),
    "magnetite": (78, 80, 88),
    "olivine": (72, 108, 44),
    "quartz": (224, 224, 224),
    "silver": (184, 189, 196),
}


def title_name(code: str) -> str:
    if code in DISPLAY_NAMES:
        return DISPLAY_NAMES[code]
    return " ".join(part.capitalize() for part in code.split("_"))


def load_json(path: Path) -> dict:
    return json.loads(path.read_text())


def dump_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2, ensure_ascii=True) + "\n")


def tile_to_label(tile: str) -> str:
    return f"R{tile[1]}C{tile[3:]}"


def overlay_source(family: str, mineral: str, tile: str) -> Path:
    return OVERLAY_SOURCE_ROOT / family / mineral / f"{tile}.png"


def overlay_seed_mineral(mineral: str) -> str:
    if mineral == "bituminouscoal":
        return "bituminouscoal"
    return "quartz"


def rock_base_source(rock: str) -> Path:
    if rock == "greenmarble":
        return ALT_ROCK_BASE_ROOT / f"{rock}.png"
    return ROCK_BASE_ROOT / f"{rock}.png"


def is_excluded(rock: str, finish: str, mineral: str) -> bool:
    return (rock, finish, mineral) in EXCLUDED_COMBINATIONS


def uses_overlay_composition(family: str, finish: str, mineral: str, rock: str) -> bool:
    if family in {"breccia", "travertine", "granite"}:
        return True

    if family == "marble":
        return True

    return False


def colorize_overlay(source: Path, target: Path, mineral: str) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)

    if mineral in {"bituminouscoal", "quartz"}:
        shutil.copy2(source, target)
        return

    rgb = MINERAL_TINTS[mineral]
    r_mult = rgb[0] / 255.0
    g_mult = rgb[1] / 255.0
    b_mult = rgb[2] / 255.0
    subprocess.run(
        [
            "magick",
            str(source),
            "-alpha",
            "off",
            "-colorspace",
            "Gray",
            "-colorspace",
            "sRGB",
            "-channel",
            "R",
            "-evaluate",
            "multiply",
            f"{r_mult:.6f}",
            "-channel",
            "G",
            "-evaluate",
            "multiply",
            f"{g_mult:.6f}",
            "-channel",
            "B",
            "-evaluate",
            "multiply",
            f"{b_mult:.6f}",
            "+channel",
            "(",
            str(source),
            "-alpha",
            "extract",
            ")",
            "-compose",
            "copyopacity",
            "-composite",
            str(target),
        ],
        check=True,
    )


def strengthen_overlay_if_needed(source: Path, target: Path, family: str, mineral: str) -> Path:
    if family == "marble" and mineral == "bituminouscoal":
        target.parent.mkdir(parents=True, exist_ok=True)
        subprocess.run(
            [
                "magick",
                str(source),
                "-channel",
                "A",
                "-morphology",
                "Dilate",
                "Diamond:1",
                "-evaluate",
                "multiply",
                "2.0",
                "+channel",
                str(target),
            ],
            check=True,
        )
        return target

    return source


def generate_base_tile(target: Path, overlay: Path, rock_base: Path, finish: str) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    if finish == "polished":
        subprocess.run(
            ["magick", str(rock_base), str(overlay), "-compose", "over", "-composite", str(target)],
            check=True,
        )
        return

    subprocess.run(
        [
            "magick",
            str(rock_base),
            "(",
            str(overlay),
            "-channel",
            "a",
            "-evaluate",
            "multiply",
            "0.4",
            "+channel",
            ")",
            "-compose",
            "over",
            "-composite",
            str(target),
        ],
        check=True,
    )


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


def face_output_map(prefix: Path) -> dict[str, Path]:
    return {face: prefix.with_name(f"{prefix.name}-{face}face.png") for face in FACES}


def generate_shared_base_faces() -> None:
    if SOURCE_MURAL_BASEFACE_ROOT.exists():
        shutil.rmtree(SOURCE_MURAL_BASEFACE_ROOT)
    SOURCE_MURAL_BASEFACE_ROOT.mkdir(parents=True, exist_ok=True)
    for rock in ROCKS:
        rock_base = rock_base_source(rock)
        if not rock_base.exists():
            raise FileNotFoundError(f"Missing rock base: {rock_base}")
        base_tile = SOURCE_MURAL_BASEFACE_ROOT / f"{rock}.png"
        shutil.copy2(rock_base, base_tile)
        generate_face_files(base_tile)


def overlay_alpha_for_finish(finish: str) -> str:
    return "0.85" if finish == "burnished" else "1.0"


def generate_overlay_face_files(input_tile: Path, output_prefix: Path, finish: str) -> None:
    outputs = face_output_map(output_prefix)
    subprocess.run(
        [
            "magick",
            str(input_tile),
            "-channel",
            "A",
            "-evaluate",
            "multiply",
            overlay_alpha_for_finish(finish),
            "+channel",
            str(outputs["south"]),
        ],
        check=True,
    )
    subprocess.run(["magick", str(outputs["south"]), "-flop", str(outputs["north"])], check=True)
    shutil.copy2(outputs["south"], outputs["west"])
    subprocess.run(["magick", str(outputs["west"]), "-flop", str(outputs["east"])], check=True)
    subprocess.run(["magick", str(outputs["west"]), "-flop", str(outputs["up"])], check=True)
    subprocess.run(["magick", str(outputs["up"]), "-flip", str(outputs["down"])], check=True)


def generate_shared_overlay_faces() -> None:
    if SOURCE_MURAL_OVERLAY_ROOT.exists():
        shutil.rmtree(SOURCE_MURAL_OVERLAY_ROOT)
    SOURCE_MURAL_OVERLAY_ROOT.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="muralslab-overlays-") as temp_dir:
        temp_root = Path(temp_dir)
        for family in OVERLAY_COMPOSED_FAMILIES:
            for finish in FINISHES:
                for mineral in MINERALS:
                    seed_mineral = overlay_seed_mineral(mineral)
                    for tile in TILES:
                        seed_overlay = overlay_source(family, seed_mineral, tile)
                        if not seed_overlay.exists():
                            raise FileNotFoundError(f"Missing overlay source: {seed_overlay}")
                        colored_overlay = temp_root / family / finish / mineral / f"{tile}.png"
                        colorize_overlay(seed_overlay, colored_overlay, mineral)
                        overlay_input = strengthen_overlay_if_needed(
                            colored_overlay,
                            temp_root / family / finish / mineral / f"{tile}-strong.png",
                            family,
                            mineral,
                        )
                        output_prefix = SOURCE_MURAL_OVERLAY_ROOT / family / finish / mineral / tile
                        output_prefix.parent.mkdir(parents=True, exist_ok=True)
                        generate_overlay_face_files(overlay_input, output_prefix, finish)


def rebuild_texture_bank() -> None:
    if SOURCE_TEXTURE_ROOT.exists():
        shutil.rmtree(SOURCE_TEXTURE_ROOT)
    SOURCE_TEXTURE_ROOT.mkdir(parents=True, exist_ok=True)
    generate_shared_base_faces()
    generate_shared_overlay_faces()
    with tempfile.TemporaryDirectory(prefix="muralslab-overlays-") as temp_dir:
        temp_root = Path(temp_dir)
        for family in FAMILIES:
            for finish in FINISHES:
                for mineral in MINERALS:
                    seed_mineral = overlay_seed_mineral(mineral)
                    for rock in ROCKS:
                        if is_excluded(rock, finish, mineral):
                            continue
                        if uses_overlay_composition(family, finish, mineral, rock):
                            continue
                        rock_base = rock_base_source(rock)
                        if not rock_base.exists():
                            raise FileNotFoundError(f"Missing rock base: {rock_base}")
                        for tile in TILES:
                            seed_overlay = overlay_source(family, seed_mineral, tile)
                            if not seed_overlay.exists():
                                raise FileNotFoundError(f"Missing overlay source: {seed_overlay}")

                            colored_overlay = temp_root / family / mineral / f"{tile}.png"
                            colorize_overlay(seed_overlay, colored_overlay, mineral)

                            base_tile = (
                                SOURCE_TEXTURE_ROOT
                                / family
                                / finish
                                / mineral
                                / rock
                                / f"{tile}.png"
                            )
                            generate_base_tile(base_tile, colored_overlay, rock_base, finish)
                            generate_face_files(base_tile)


def sync_slabbase_textures(target_root: Path) -> None:
    if target_root.exists():
        shutil.rmtree(target_root)
    target_root.mkdir(parents=True, exist_ok=True)
    for rock in ROCKS:
        shutil.copy2(rock_base_source(rock), target_root / f"{rock}.png")


def muralslab_states(block: dict) -> dict[str, list[str]]:
    return {group["code"]: group["states"] for group in block["variantgroups"]}


def ensure_variantgroup_states(block: dict) -> None:
    for group in block["variantgroups"]:
        if group["code"] == "family":
            group["states"] = FAMILIES
        elif group["code"] == "finish":
            group["states"] = FINISHES
        elif group["code"] == "mineral":
            group["states"] = MINERALS
        elif group["code"] == "rock":
            group["states"] = ROCKS
        if group["code"] == "tile":
            group["states"] = TILES

    codes = {group["code"] for group in block["variantgroups"]}
    required = {"family", "finish", "mineral", "rock", "tile"}
    missing = required - codes
    if missing:
        raise RuntimeError(f"Missing variantgroups in muralslab.json: {sorted(missing)}")


def build_allowed_variants(states: dict[str, list[str]]) -> list[str]:
    variants = []
    for family in states["family"]:
        for finish in states["finish"]:
            for mineral in states["mineral"]:
                for rock in states["rock"]:
                    if is_excluded(rock, finish, mineral):
                        continue
                    for tile in states["tile"]:
                        variants.append(
                            f"muralslab-{family}-{finish}-{mineral}-{rock}-{tile}"
                        )
    return variants


def build_textures_by_type(states: dict[str, list[str]]) -> dict[str, dict]:
    textures = {}
    for family in states["family"]:
        for finish in states["finish"]:
            for mineral in states["mineral"]:
                for rock in states["rock"]:
                    if is_excluded(rock, finish, mineral):
                        continue
                    for tile in states["tile"]:
                        key = f"muralslab-{family}-{finish}-{mineral}-{rock}-{tile}"
                        if uses_overlay_composition(family, finish, mineral, rock):
                            base_prefix = f"vsmineralmasonry:block/stone/muralslab-basefaces/{rock}"
                            overlay_prefix = (
                                f"vsmineralmasonry:block/stone/muralslab-overlays/"
                                f"{family}/{finish}/{mineral}/{tile}"
                            )
                            textures[key] = {
                                face: {
                                    "base": f"{base_prefix}-{face}face",
                                    "overlays": [f"{overlay_prefix}-{face}face"],
                                }
                                for face in FACES
                            }
                        else:
                            base_prefix = (
                                f"vsmineralmasonry:block/stone/muralslab/"
                                f"{family}/{finish}/{mineral}/{rock}/{tile}"
                            )
                            textures[key] = {
                                face: {"base": f"{base_prefix}-{face}face"}
                                for face in FACES
                            }
    return textures


def rebuild_block_json() -> dict:
    block = load_json(SOURCE_BLOCK)
    ensure_variantgroup_states(block)
    states = muralslab_states(block)
    block["allowedVariants"] = build_allowed_variants(states)
    block["texturesByType"] = build_textures_by_type(states)
    dump_json(SOURCE_BLOCK, block)
    return block


def rebuild_lang(block: dict) -> None:
    lang = load_json(SOURCE_LANG)
    stale_keys = [k for k in lang if k.startswith("block-vsmineralmasonry-muralslab-")]
    for key in stale_keys:
        del lang[key]

    states = muralslab_states(block)
    for family in states["family"]:
        for finish in states["finish"]:
            for mineral in states["mineral"]:
                for rock in states["rock"]:
                    if is_excluded(rock, finish, mineral):
                        continue
                    for tile in states["tile"]:
                        key = (
                            f"block-vsmineralmasonry-muralslab-"
                            f"{family}-{finish}-{mineral}-{rock}-{tile}"
                        )
                        lang[key] = (
                            f"{title_name(family)} "
                            f"{title_name(finish)} "
                            f"{title_name(mineral)} "
                            f"{title_name(rock)} "
                            f"{tile.upper()}"
                        )
    dump_json(SOURCE_LANG, lang)


def sync_debug_copy() -> None:
    DEBUG_BLOCK.parent.mkdir(parents=True, exist_ok=True)
    DEBUG_LANG.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(SOURCE_BLOCK, DEBUG_BLOCK)
    shutil.copy2(SOURCE_LANG, DEBUG_LANG)
    if DEBUG_TEXTURE_ROOT.exists():
        shutil.rmtree(DEBUG_TEXTURE_ROOT)
    shutil.copytree(SOURCE_TEXTURE_ROOT, DEBUG_TEXTURE_ROOT)
    if DEBUG_MURAL_BASEFACE_ROOT.exists():
        shutil.rmtree(DEBUG_MURAL_BASEFACE_ROOT)
    shutil.copytree(SOURCE_MURAL_BASEFACE_ROOT, DEBUG_MURAL_BASEFACE_ROOT)
    if DEBUG_MURAL_OVERLAY_ROOT.exists():
        shutil.rmtree(DEBUG_MURAL_OVERLAY_ROOT)
    shutil.copytree(SOURCE_MURAL_OVERLAY_ROOT, DEBUG_MURAL_OVERLAY_ROOT)
    sync_slabbase_textures(DEBUG_SLABBASE_ROOT)


def main() -> None:
    rebuild_texture_bank()
    sync_slabbase_textures(SOURCE_SLABBASE_ROOT)
    block = rebuild_block_json()
    rebuild_lang(block)
    sync_debug_copy()
    print(f"Rebuilt {len(block['allowedVariants'])} muralslab variants")
    print(f"Rebuilt {len(block['texturesByType'])} texture bindings")
    print(SOURCE_BLOCK)
    print(SOURCE_LANG)


if __name__ == "__main__":
    main()

#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUT_DIR="$PROJECT_DIR/assets/vsmineralmasonry/textures/block/stone/polishedmineral"
OVERLAY_BASE="$PROJECT_DIR/assets/vsmineralmasonry/textures/block/stone/polishedmineral-overlays"
MASTER_LISTS="$PROJECT_DIR/config/master-lists.json"
MANIFEST="$PROJECT_DIR/assets/vsmineralmasonry/textures/review/ore-color-studies/ore-curated-mask-manifest.json"
BEVEL_SCRIPT="$SCRIPT_DIR/apply-block-bevel.sh"

load_masks_from_manifest() {
  python3 - "$MANIFEST" "$1" <<'PY'
import json, sys
with open(sys.argv[1]) as f:
    j = json.load(f)
for mask in j[sys.argv[2]]:
    print(mask)
PY
}

if [ "${1:-}" = "" ]; then
  MINERALS=()
  while IFS= read -r mineral; do
    MINERALS+=("$mineral")
  done < <(python3 - "$MANIFEST" <<'PY'
import json, sys
with open(sys.argv[1]) as f:
    j = json.load(f)
for mineral in j.keys():
    print(mineral)
PY
)
elif [ "${2:-}" = "" ]; then
  MINERALS=("$1")
else
  if [ "${4:-}" = "" ]; then
    echo "Usage: $0 <mineral> <mask1.png> <mask2.png> <mask3.png>" >&2
    echo "   or: $0 <mineral>" >&2
    echo "   or: $0" >&2
    exit 1
  fi
  MINERALS=("$1")
fi

ROCKS=(
  andesite basalt bauxite chalk chert claystone conglomerate granite
  greenmarble halite kimberlite limestone peridotite phyllite redmarble
  sandstone shale slate suevite whitemarble
)

base_color_for() {
  case "$1" in
    bismuthinite) echo '#939b77' ;;
    cassiterite) echo '#7f745f' ;;
    chromite) echo '#6b5e54' ;;
    galena) echo '#495a69' ;;
    galena_nativesilver) echo '#8f949f' ;;
    lignite) echo '#665547' ;;
    nativecopper) echo '#d77733' ;;
    graphite) echo '#575a5e' ;;
    hematite) echo '#8c4438' ;;
    ilmenite) echo '#5a4338' ;;
    limonite) echo '#a46643' ;;
    magnetite) echo '#8f979e' ;;
    pentlandite) echo '#8f8758' ;;
    phosphorite) echo '#8e8c5f' ;;
    sphalerite) echo '#a67647' ;;
    sulfur) echo '#c6b12a' ;;
    *) echo '#999999' ;;
  esac
}

shade_color() {
  local hex="$1"
  local factor="$2"
  python3 - "$hex" "$factor" <<'PY'
import sys
hex_color = sys.argv[1].lstrip('#')
factor = float(sys.argv[2])
r = int(hex_color[0:2], 16)
g = int(hex_color[2:4], 16)
b = int(hex_color[4:6], 16)
def clamp(v): return max(0, min(255, int(round(v))))
print("#{0:02x}{1:02x}{2:02x}".format(clamp(r*factor), clamp(g*factor), clamp(b*factor)))
PY
}

build_overlay() {
  local mask_file="$1"
  local out_file="$2"
  local base="$3"
  local shadow="$4"
  local highlight="$5"

  magick "$mask_file" \
    -colorspace Gray \
    -auto-level \
    -sigmoidal-contrast 3,52% \
    -level 10%,100% \
    -evaluate Pow 0.82 \
    -write mpr:gray +delete \
    mpr:gray \
    \( xc:"$shadow" xc:"$base" xc:"$highlight" +append -filter triangle -resize 256x1! \) \
    -clut \
    -colorspace sRGB \
    mpr:gray -compose CopyOpacity -composite \
    PNG32:"$out_file"
}

build_galena_nativesilver_overlay() {
  local galena_mask="$1"
  local silver_mask="$2"
  local out_file="$3"

  local galena_base='#495a69'
  local galena_shadow
  local galena_highlight
  galena_shadow="$(shade_color "$galena_base" 0.75)"
  galena_highlight="$(shade_color "$galena_base" 1.22)"

  local silver_base='#c5ccd3'
  local silver_shadow
  local silver_highlight
  silver_shadow="$(shade_color "$silver_base" 0.80)"
  silver_highlight="$(shade_color "$silver_base" 1.15)"

  local galena_tmp
  local silver_tmp
  galena_tmp="$(mktemp /tmp/galena-baseXXXX.png)"
  silver_tmp="$(mktemp /tmp/silver-accentXXXX.png)"

  build_overlay "$galena_mask" "$galena_tmp" "$galena_base" "$galena_shadow" "$galena_highlight"
  build_overlay "$silver_mask" "$silver_tmp" "$silver_base" "$silver_shadow" "$silver_highlight"
  magick "$galena_tmp" "$silver_tmp" -compose Over -composite PNG32:"$out_file"
  rm -f "$galena_tmp" "$silver_tmp"
}

build_lignite_overlay() {
  local base_mask="$1"
  local dark_mask="$2"
  local out_file="$3"

  local body_base='#4f3a2b'
  local body_shadow
  local body_highlight
  body_shadow="$(shade_color "$body_base" 0.75)"
  body_highlight="$(shade_color "$body_base" 1.18)"

  local dark_base='#2f241c'
  local dark_shadow
  local dark_highlight
  dark_shadow="$(shade_color "$dark_base" 0.72)"
  dark_highlight="$(shade_color "$dark_base" 1.10)"

  local body_tmp
  local dark_tmp
  body_tmp="$(mktemp /tmp/lignite-bodyXXXX.png)"
  dark_tmp="$(mktemp /tmp/lignite-darkXXXX.png)"

  build_overlay "$base_mask" "$body_tmp" "$body_base" "$body_shadow" "$body_highlight"
  build_overlay "$dark_mask" "$dark_tmp" "$dark_base" "$dark_shadow" "$dark_highlight"
  magick "$body_tmp" "$dark_tmp" -compose Over -composite PNG32:"$out_file"
  rm -f "$body_tmp" "$dark_tmp"
}

build_sphalerite_overlay() {
  local light_mask="$1"
  local dark_mask="$2"
  local out_file="$3"

  local light_base='#a6a2a0'
  local light_shadow
  local light_highlight
  light_shadow="$(shade_color "$light_base" 0.78)"
  light_highlight="$(shade_color "$light_base" 1.12)"

  local dark_base='#5f5b59'
  local dark_shadow
  local dark_highlight
  dark_shadow="$(shade_color "$dark_base" 0.72)"
  dark_highlight="$(shade_color "$dark_base" 1.08)"

  local light_tmp
  local dark_tmp
  light_tmp="$(mktemp /tmp/sphalerite-lightXXXX.png)"
  dark_tmp="$(mktemp /tmp/sphalerite-darkXXXX.png)"

  build_overlay "$light_mask" "$light_tmp" "$light_base" "$light_shadow" "$light_highlight"
  build_overlay "$dark_mask" "$dark_tmp" "$dark_base" "$dark_shadow" "$dark_highlight"
  magick "$light_tmp" "$dark_tmp" -compose Over -composite PNG32:"$out_file"
  rm -f "$light_tmp" "$dark_tmp"
}

build_sulfur_overlay() {
  local bright_mask="$1"
  local dark_mask="$2"
  local out_file="$3"

  local bright_base='#c8bb63'
  local bright_shadow
  local bright_highlight
  bright_shadow="$(shade_color "$bright_base" 0.82)"
  bright_highlight="$(shade_color "$bright_base" 1.12)"

  local dark_base='#afaa59'
  local dark_shadow
  local dark_highlight
  dark_shadow="$(shade_color "$dark_base" 0.76)"
  dark_highlight="$(shade_color "$dark_base" 1.08)"

  local bright_tmp
  local dark_tmp
  bright_tmp="$(mktemp /tmp/sulfur-brightXXXX.png)"
  dark_tmp="$(mktemp /tmp/sulfur-darkXXXX.png)"

  build_overlay "$bright_mask" "$bright_tmp" "$bright_base" "$bright_shadow" "$bright_highlight"
  build_overlay "$dark_mask" "$dark_tmp" "$dark_base" "$dark_shadow" "$dark_highlight"
  magick "$bright_tmp" "$dark_tmp" -compose Over -composite PNG32:"$out_file"
  rm -f "$bright_tmp" "$dark_tmp"
}

build_anthracite_overlay() {
  local bright_mask="$1"
  local dark_mask="$2"
  local out_file="$3"

  local bright_base='#7d7f83'
  local bright_shadow
  local bright_highlight
  bright_shadow="$(shade_color "$bright_base" 0.78)"
  bright_highlight="$(shade_color "$bright_base" 1.10)"

  build_overlay "$bright_mask" "$out_file" "$bright_base" "$bright_shadow" "$bright_highlight"
}

build_bituminouscoal_overlay() {
  local base_mask="$1"
  local accent_mask="$2"
  local out_file="$3"

  local base_base='#1f1f20'
  local base_shadow
  local base_highlight
  base_shadow="$(shade_color "$base_base" 0.82)"
  base_highlight="$(shade_color "$base_base" 1.08)"

  local accent_base='#343537'
  local accent_shadow
  local accent_highlight
  accent_shadow="$(shade_color "$accent_base" 0.84)"
  accent_highlight="$(shade_color "$accent_base" 1.06)"

  local base_tmp
  local accent_tmp
  base_tmp="$(mktemp /tmp/bituminouscoal-baseXXXX.png)"
  accent_tmp="$(mktemp /tmp/bituminouscoal-accentXXXX.png)"

  build_overlay "$base_mask" "$base_tmp" "$base_base" "$base_shadow" "$base_highlight"
  magick "$base_mask" \
    -colorspace Gray \
    -auto-level \
    -sigmoidal-contrast 3,52% \
    -level 18%,96% \
    -evaluate Pow 1.10 \
    -write mpr:gray +delete \
    mpr:gray \
    \( xc:"$accent_shadow" xc:"$accent_base" xc:"$accent_highlight" +append -filter triangle -resize 256x1! \) \
    -clut \
    -colorspace sRGB \
    mpr:gray -compose CopyOpacity -composite \
    PNG32:"$accent_tmp"
  magick "$base_tmp" "$accent_tmp" -compose Over -composite PNG32:"$out_file"
  rm -f "$base_tmp" "$accent_tmp"
}

mkdir -p "$OUT_DIR"

for MINERAL in "${MINERALS[@]}"; do
if [ "${2:-}" = "" ]; then
  MASKS=()
  while IFS= read -r mask; do
    MASKS+=("$mask")
  done < <(load_masks_from_manifest "$MINERAL")
  MASK1="${MASKS[0]}"
  MASK2="${MASKS[1]}"
  MASK3="${MASKS[2]}"
else
  MASK1="$2"
  MASK2="$3"
  MASK3="$4"
fi

OVERLAY_DIR="$OVERLAY_BASE"
mkdir -p "$OVERLAY_DIR"

BASE="$(base_color_for "$MINERAL")"
SHADOW="$(shade_color "$BASE" 0.75)"
HIGHLIGHT="$(shade_color "$BASE" 1.22)"

TMP1="$OVERLAY_DIR/${MINERAL}1-overlay.png"
TMP2="$OVERLAY_DIR/${MINERAL}2-overlay.png"
TMP3="$OVERLAY_DIR/${MINERAL}3-overlay.png"
if [ "$MINERAL" = "galena_nativesilver" ]; then
  build_galena_nativesilver_overlay "$MASK1" "$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/low-coverage/low-coverage-mask-01.png" "$TMP1"
  build_galena_nativesilver_overlay "$MASK2" "$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/low-coverage/low-coverage-mask-02.png" "$TMP2"
  build_galena_nativesilver_overlay "$MASK3" "$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/low-coverage/low-coverage-mask-03.png" "$TMP3"
elif [ "$MINERAL" = "lignite" ]; then
  build_lignite_overlay "$MASK1" "$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-03.png" "$TMP1"
  build_lignite_overlay "$MASK2" "$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-02.png" "$TMP2"
  build_lignite_overlay "$MASK3" "$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-01.png" "$TMP3"
elif [ "$MINERAL" = "sphalerite" ]; then
  build_sphalerite_overlay "$MASK1" "$MASK2" "$TMP1"
  build_sphalerite_overlay "$MASK2" "$MASK3" "$TMP2"
  build_sphalerite_overlay "$MASK3" "$MASK1" "$TMP3"
elif [ "$MINERAL" = "sulfur" ]; then
  build_sulfur_overlay "$MASK1" "$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-14.png" "$TMP1"
  build_sulfur_overlay "$MASK2" "$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-11.png" "$TMP2"
  build_sulfur_overlay "$MASK3" "$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-13.png" "$TMP3"
elif [ "$MINERAL" = "anthracite" ]; then
  build_anthracite_overlay "$MASK1" "$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-14.png" "$TMP1"
  build_anthracite_overlay "$MASK2" "$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-11.png" "$TMP2"
  build_anthracite_overlay "$MASK3" "$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-13.png" "$TMP3"
elif [ "$MINERAL" = "bituminouscoal" ]; then
  build_bituminouscoal_overlay "$MASK1" "$MASK1" "$TMP1"
  build_bituminouscoal_overlay "$MASK2" "$MASK2" "$TMP2"
  build_bituminouscoal_overlay "$MASK3" "$MASK3" "$TMP3"
elif [ "$MINERAL" = "chromite" ]; then
  build_overlay "$MASK1" "$TMP1" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK2" "$TMP2" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK3" "$TMP3" "$BASE" "$SHADOW" "$HIGHLIGHT"
elif [ "$MINERAL" = "graphite" ]; then
  build_overlay "$MASK1" "$TMP1" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK2" "$TMP2" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK3" "$TMP3" "$BASE" "$SHADOW" "$HIGHLIGHT"
elif [ "$MINERAL" = "hematite" ]; then
  build_overlay "$MASK1" "$TMP1" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK2" "$TMP2" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK3" "$TMP3" "$BASE" "$SHADOW" "$HIGHLIGHT"
elif [ "$MINERAL" = "ilmenite" ]; then
  build_overlay "$MASK1" "$TMP1" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK2" "$TMP2" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK3" "$TMP3" "$BASE" "$SHADOW" "$HIGHLIGHT"
elif [ "$MINERAL" = "limonite" ]; then
  build_overlay "$MASK1" "$TMP1" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK2" "$TMP2" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK3" "$TMP3" "$BASE" "$SHADOW" "$HIGHLIGHT"
elif [ "$MINERAL" = "magnetite" ]; then
  build_overlay "$MASK1" "$TMP1" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK2" "$TMP2" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK3" "$TMP3" "$BASE" "$SHADOW" "$HIGHLIGHT"
elif [ "$MINERAL" = "pentlandite" ]; then
  build_overlay "$MASK1" "$TMP1" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK2" "$TMP2" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK3" "$TMP3" "$BASE" "$SHADOW" "$HIGHLIGHT"
elif [ "$MINERAL" = "phosphorite" ]; then
  build_overlay "$MASK1" "$TMP1" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK2" "$TMP2" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK3" "$TMP3" "$BASE" "$SHADOW" "$HIGHLIGHT"
else
  build_overlay "$MASK1" "$TMP1" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK2" "$TMP2" "$BASE" "$SHADOW" "$HIGHLIGHT"
  build_overlay "$MASK3" "$TMP3" "$BASE" "$SHADOW" "$HIGHLIGHT"
fi

for rock in "${ROCKS[@]}"; do
  rock_src="/Applications/Vintage Story.app/assets/survival/textures/block/stone/rock/${rock}1.png"
  for variant in 1 2 3; do
    overlay_var="TMP${variant}"
    overlay="${!overlay_var}"
    out="$OUT_DIR/${MINERAL}${variant}-${rock}.png"
    magick "$rock_src" \
      -resize 64x64! \
      -colorspace sRGB \
      "$overlay" -compose Over -composite \
      "PNG32:$out"
    "$BEVEL_SCRIPT" "$out"
  done
done

echo "Generated $MINERAL textures in $OUT_DIR"
echo "Saved $MINERAL overlays in $OVERLAY_DIR"
done

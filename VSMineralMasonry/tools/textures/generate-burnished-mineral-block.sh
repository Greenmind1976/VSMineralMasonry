#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "" ] || [ "${2:-}" = "" ] || [ "${3:-}" = "" ] || [ "${4:-}" = "" ]; then
  echo "Usage: $0 <base-texture.png> <marble-reference.png> <mineral> <output-name>" >&2
  echo "Example: $0 /path/to/limestone1.png /path/to/marble.png malachite malachite-limestone" >&2
  exit 1
fi

BASE_TEXTURE="$1"
MARBLE_TEXTURE="$2"
MINERAL="$3"
OUTPUT_NAME="$4"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_DIR/assets/vsmineralmasonry/textures/block/stone/burnishedmineral"
OUTPUT_FILE="$OUTPUT_DIR/$OUTPUT_NAME.png"

mkdir -p "$OUTPUT_DIR"

HASH="$(printf '%s' "$OUTPUT_NAME" | cksum | awk '{print $1}')"
TILE_W=64
TILE_H=64
IMG_W=696
IMG_H=444
MAX_X=$((IMG_W - TILE_W))
MAX_Y=$((IMG_H - TILE_H))
OFF_X=$((HASH % MAX_X))
OFF_Y=$(((HASH / 17) % MAX_Y))

DOM_COLOR="rgba(160,140,120,1.0)"
ACCENT_COLOR="rgba(210,190,168,1.0)"
DOM_OPACITY="0.18"
ACCENT_OPACITY="0.04"

case "$MINERAL" in
  malachite)
    DOM_COLOR="rgba(34,162,114,1.0)"
    ACCENT_COLOR="rgba(194,118,64,1.0)"
    DOM_OPACITY="0.20"
    ACCENT_OPACITY="0.05"
    ;;
  nativecopper)
    DOM_COLOR="rgba(194,112,60,1.0)"
    ACCENT_COLOR="rgba(66,146,114,1.0)"
    DOM_OPACITY="0.19"
    ACCENT_OPACITY="0.035"
    ;;
esac

magick \
  "$BASE_TEXTURE" -resize 64x64! \
    -brightness-contrast 6x3 \
    -modulate 101,94,100 \
    -sigmoidal-contrast 0.35,52% \
    -write mpr:base +delete \
  "$MARBLE_TEXTURE" -crop 64x64+"$OFF_X"+"$OFF_Y" +repage \
    -resize 64x64! \
    -write mpr:tile +delete \
  mpr:tile -colorspace gray -auto-level -negate \
    -level 60%,100% \
    -blur 0x0.35 \
    -write mpr:veinmask +delete \
  mpr:tile -colorspace gray -auto-level \
    -level 86%,100% \
    -blur 0x0.25 \
    -write mpr:lightmask +delete \
  -size 64x64 xc:"$DOM_COLOR" mpr:veinmask -compose CopyOpacity -composite \
    -evaluate multiply "$DOM_OPACITY" \
    -write mpr:domveins +delete \
  -size 64x64 xc:"$ACCENT_COLOR" mpr:veinmask -compose CopyOpacity -composite \
    -blur 0x0.6 -evaluate multiply "$ACCENT_OPACITY" \
    -write mpr:accentveins +delete \
  mpr:domveins mpr:accentveins -compose Over -composite -write mpr:coloredveins +delete \
  -size 64x64 xc:'rgba(255,255,255,1.0)' mpr:lightmask -compose CopyOpacity -composite \
    -evaluate multiply 0.06 \
    -write mpr:lightveins +delete \
  mpr:base mpr:coloredveins -compose Over -composite mpr:lightveins -compose Screen -composite \
    -channel RGB -level 12%,88%,1.005 +channel \
    -unsharp 0x0.12+0.16+0.002 \
    "$OUTPUT_FILE"

echo "Generated:"
echo "  $OUTPUT_FILE"

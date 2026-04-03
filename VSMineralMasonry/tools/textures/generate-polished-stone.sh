#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "" ] || [ "${2:-}" = "" ]; then
  echo "Usage: $0 <source-texture.png> <output-name>" >&2
  echo "Example: $0 /path/to/halite1.png halite" >&2
  exit 1
fi

SOURCE_TEXTURE="$1"
OUTPUT_NAME="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEXTURE_ROOT="$PROJECT_DIR/assets/game/textures/block/stone"
POLISHED_DIR="$TEXTURE_ROOT/polishedrock"
SLAB_DIR="$TEXTURE_ROOT/polishedrockslab"

base_args=()

case "$OUTPUT_NAME" in
  chalk|halite|limestone|whitemarble)
    base_args=(
      -modulate 112,100,100
      -blur 0x0.55
      -sigmoidal-contrast 3,52%
    )
    ;;
  andesite|basalt|granite|greenmarble|kimberlite|peridotite|phyllite|shale|slate|suevite)
    base_args=(
      -modulate 92,104,100
      -blur 0x0.55
      -sigmoidal-contrast 4,50%
    )
    ;;
  bauxite|chert|claystone|conglomerate|redmarble|sandstone)
    base_args=(
      -modulate 100,112,100
      -blur 0x0.55
      -sigmoidal-contrast 3,50%
    )
    ;;
  *)
    # Default to a restrained polish for stones without an explicit bucket yet.
    base_args=(
      -modulate 100,106,100
      -blur 0x0.55
      -sigmoidal-contrast 3,50%
    )
    ;;
esac

mkdir -p "$POLISHED_DIR" "$SLAB_DIR"

MAIN_OUT="$POLISHED_DIR/$OUTPUT_NAME.png"
INSIDE_OUT="$POLISHED_DIR/$OUTPUT_NAME-inside.png"
SLAB_OUT="$SLAB_DIR/$OUTPUT_NAME.png"

magick "$SOURCE_TEXTURE" \
  -colorspace sRGB \
  "${base_args[@]}" \
  -unsharp 0x0.85+0.9+0.015 \
  "$MAIN_OUT"

magick "$MAIN_OUT" \
  -fill 'rgba(255,255,255,0.18)' -draw 'line 0,0 31,0' \
  -fill 'rgba(255,255,255,0.18)' -draw 'line 0,0 0,31' \
  -fill 'rgba(255,255,255,0.09)' -draw 'line 1,1 30,1' \
  -fill 'rgba(255,255,255,0.09)' -draw 'line 1,1 1,30' \
  -fill 'rgba(0,0,0,0.18)' -draw 'line 0,31 31,31' \
  -fill 'rgba(0,0,0,0.18)' -draw 'line 31,0 31,31' \
  -fill 'rgba(0,0,0,0.09)' -draw 'line 1,30 30,30' \
  -fill 'rgba(0,0,0,0.09)' -draw 'line 30,1 30,30' \
  -modulate 100,92,106 \
  "$MAIN_OUT"

magick "$MAIN_OUT" \
  -modulate 90,82,96 \
  -fill 'rgba(32,32,32,0.18)' -draw 'rectangle 0,0 31,31' \
  "$INSIDE_OUT"

magick "$MAIN_OUT" \
  -modulate 94,86,102 \
  -fill 'rgba(32,32,32,0.10)' -draw 'rectangle 0,0 31,31' \
  "$SLAB_OUT"

echo "Generated:"
echo "  $MAIN_OUT"
echo "  $INSIDE_OUT"
echo "  $SLAB_OUT"

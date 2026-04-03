#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "" ] || [ "${2:-}" = "" ]; then
  echo "Usage: $0 <mineral> <source-overlay.png>" >&2
  echo "Example: $0 nativecopper /path/to/nativecopper1.png" >&2
  exit 1
fi

MINERAL="$1"
SOURCE_TEXTURE="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_DIR/assets/vsmineralmasonry/textures/references/processed/singleface"

case "$MINERAL" in
  nativecopper)
    SHADOW="#5f2f17"
    MID="#c8763a"
    HIGHLIGHT="#f0bb7b"
    ;;
  malachite)
    SHADOW="#0f5e36"
    MID="#2f9d63"
    HIGHLIGHT="#88ddb0"
    ;;
  magnetite)
    SHADOW="#22252a"
    MID="#59626b"
    HIGHLIGHT="#aab4bc"
    ;;
  hematite)
    SHADOW="#5a1f18"
    MID="#9d3a31"
    HIGHLIGHT="#d98a77"
    ;;
  *)
    echo "Unsupported mineral: $MINERAL" >&2
    exit 1
    ;;
esac

mkdir -p "$OUTPUT_DIR"

OVERLAY_FILE="$OUTPUT_DIR/${MINERAL}-overlay-64.png"

magick \
  "$SOURCE_TEXTURE" \
  -filter point -resize 64x64! \
  -write mpr:src +delete \
  mpr:src \
  -alpha extract \
  -morphology Dilate Octagon:1 \
  -blur 0x0.7 \
  -auto-level \
  -write mpr:alpha +delete \
  mpr:src \
  -alpha off \
  -colorspace gray \
  -auto-level \
  -blur 0x0.5 \
  -write mpr:detail +delete \
  \( xc:"$SHADOW" xc:"$MID" xc:"$HIGHLIGHT" +append -filter triangle -resize 256x1! \) \
  -write mpr:palette +delete \
  mpr:detail mpr:palette \
  -clut \
  -write mpr:colored +delete \
  mpr:colored mpr:alpha \
  -compose CopyOpacity -composite \
  "$OVERLAY_FILE"

echo "Generated:"
echo "  $OVERLAY_FILE"

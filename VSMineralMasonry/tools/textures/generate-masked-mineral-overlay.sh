#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "" ] || [ "${2:-}" = "" ] || [ "${3:-}" = "" ]; then
  echo "Usage: $0 <mineral> <mask.png> <source-overlay.png>" >&2
  echo "Example: $0 nativecopper /path/to/ore-mask-64.png /path/to/exposed-nativecopper-overlay.png" >&2
  exit 1
fi

MINERAL="$1"
MASK_FILE="$2"
SOURCE_FILE="$3"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUT_DIR="$PROJECT_DIR/assets/vsmineralmasonry/textures/references/processed/masked"

case "$MINERAL" in
  nativecopper)
    SHADOW="#7a3416"
    MID="#d77733"
    HIGHLIGHT="#f4b06a"
    ;;
  malachite)
    SHADOW="#0f5d36"
    MID="#2d9f63"
    HIGHLIGHT="#87deb0"
    ;;
  magnetite)
    SHADOW="#1f2328"
    MID="#616870"
    HIGHLIGHT="#b6bec5"
    ;;
  hematite)
    SHADOW="#55231c"
    MID="#9d4339"
    HIGHLIGHT="#d69077"
    ;;
  *)
    echo "Unsupported mineral: $MINERAL" >&2
    exit 1
    ;;
esac

mkdir -p "$OUT_DIR"
OUT_FILE="$OUT_DIR/${MINERAL}-masked-overlay-64.png"

magick \
  "$MASK_FILE" \
  -filter point -resize 64x64! \
  -colorspace gray \
  -auto-level \
  -write mpr:mask +delete \
  mpr:mask \
  -sigmoidal-contrast 3x50% \
  -write mpr:detail +delete \
  \( xc:"$SHADOW" xc:"$MID" xc:"$HIGHLIGHT" +append -filter triangle -resize 256x1! \) \
  -write mpr:palette +delete \
  mpr:detail mpr:palette \
  -clut \
  -modulate 105,135,100 \
  -write mpr:finalcolored +delete \
  mpr:finalcolored mpr:mask \
  -compose CopyOpacity -composite \
  "$OUT_FILE"

echo "Generated:"
echo "  $OUT_FILE"

#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "" ] || [ "${2:-}" = "" ]; then
  echo "Usage: $0 <mineral> <overlay.png>" >&2
  echo "Example: $0 nativecopper /path/to/exposed-nativecopper-overlay.png" >&2
  exit 1
fi

MINERAL="$1"
OVERLAY="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
ROCK_DIR="$PROJECT_DIR/assets/vsmineralmasonry/textures/references/vanilla/rock"
OUT_DIR="$PROJECT_DIR/assets/vsmineralmasonry/textures/block/stone/exposedfull"

case "$MINERAL" in
  malachite)
    ROCKS=(greenmarble limestone redmarble whitemarble)
    ;;
  nativecopper)
    ROCKS=(andesite basalt chalk chert claystone conglomerate granite peridotite phyllite sandstone shale slate)
    ;;
  magnetite)
    ROCKS=(andesite chalk claystone conglomerate slate)
    ;;
  *)
    echo "Unsupported mineral: $MINERAL" >&2
    exit 1
    ;;
esac

mkdir -p "$OUT_DIR"

for rock in "${ROCKS[@]}"; do
  magick \
    "$ROCK_DIR/${rock}1.png" \
    "$OVERLAY" \
    -compose over -composite \
    "$OUT_DIR/${MINERAL}-${rock}.png"
done

echo "Baked exposed textures for $MINERAL:"
for rock in "${ROCKS[@]}"; do
  echo "  $OUT_DIR/${MINERAL}-${rock}.png"
done

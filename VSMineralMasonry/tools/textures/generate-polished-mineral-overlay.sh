#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "" ] || [ "${2:-}" = "" ]; then
  echo "Usage: $0 <ore-overlay.png> <output-name>" >&2
  echo "Example: $0 /path/to/nativecopper1.png nativecopper" >&2
  exit 1
fi

SOURCE_TEXTURE="$1"
OUTPUT_NAME="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="$PROJECT_DIR/assets/vsmineralmasonry/textures/references/processed/polished"
OUTPUT_FILE="$OUTPUT_DIR/${OUTPUT_NAME}-overlay-64.png"

mkdir -p "$OUTPUT_DIR"

magick \
  "$SOURCE_TEXTURE" \
  -filter point -resize 64x64! \
  -write mpr:base +delete \
  mpr:base \
  -modulate 100,150,100 \
  -brightness-contrast 0x10 \
  -write mpr:enhanced +delete \
  mpr:base mpr:enhanced \
  -compose Over -composite \
  "$OUTPUT_FILE"

echo "Generated:"
echo "  $OUTPUT_FILE"

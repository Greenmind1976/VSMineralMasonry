#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <image.png> [more-images...]" >&2
  exit 1
fi

for img in "$@"; do
  magick "$img" \
    -fill 'rgba(255,255,255,0.18)' -draw 'line 0,0 63,0' \
    -fill 'rgba(255,255,255,0.18)' -draw 'line 0,0 0,63' \
    -fill 'rgba(255,255,255,0.09)' -draw 'line 1,1 62,1' \
    -fill 'rgba(255,255,255,0.09)' -draw 'line 1,1 1,62' \
    -fill 'rgba(0,0,0,0.18)' -draw 'line 0,63 63,63' \
    -fill 'rgba(0,0,0,0.18)' -draw 'line 63,0 63,63' \
    -fill 'rgba(0,0,0,0.09)' -draw 'line 1,62 62,62' \
    -fill 'rgba(0,0,0,0.09)' -draw 'line 62,1 62,62' \
    "$img"
done

#!/usr/bin/env bash
set -euo pipefail

BLACK_LEVEL_PCT="${BLACK_LEVEL_PCT:-5.88235%}"  # 15 / 255
WHITE_LEVEL_PCT="${WHITE_LEVEL_PCT:-94.11765%}" # 240 / 255
SHADOW_OPACITY="${SHADOW_OPACITY:-0.30}"
HIGHLIGHT_OPACITY="${HIGHLIGHT_OPACITY:-0.54}"
GAUSSIAN_BLUR="${GAUSSIAN_BLUR:-0x0.6}"
DETAIL_MASK_BLACK_PCT="${DETAIL_MASK_BLACK_PCT:-45%}"
DETAIL_MASK_WHITE_PCT="${DETAIL_MASK_WHITE_PCT:-88%}"
DETAIL_MASK_POW="${DETAIL_MASK_POW:-1.35}"
SPARKLE_BLACK_PCT="${SPARKLE_BLACK_PCT:-78%}"
SPARKLE_WHITE_PCT="${SPARKLE_WHITE_PCT:-92%}"
SPARKLE_BLUR="${SPARKLE_BLUR:-0x0.45}"
SPARKLE_OPACITY="${SPARKLE_OPACITY:-0.10}"

usage() {
  echo "Usage: $0 <overlay.png> [more-overlays...]" >&2
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

process_overlay() {
  local img="$1"
  local alpha gray detail_mask processed shadow highlight sparkle
  local original
  local shadow_alpha highlight_alpha shadow_color highlight_color
  local dir base shadow_out highlight_out
  alpha="$(mktemp /tmp/gimp-alphaXXXX.png)"
  gray="$(mktemp /tmp/gimp-grayXXXX.png)"
  detail_mask="$(mktemp /tmp/gimp-detail-maskXXXX.png)"
  processed="$(mktemp /tmp/gimp-processedXXXX.png)"
  shadow="$(mktemp /tmp/gimp-shadowXXXX.png)"
  highlight="$(mktemp /tmp/gimp-highlightXXXX.png)"
  sparkle="$(mktemp /tmp/gimp-sparkleXXXX.png)"
  original="$(mktemp /tmp/gimp-originalXXXX.png)"
  shadow_alpha="$(mktemp /tmp/gimp-shadow-alphaXXXX.png)"
  highlight_alpha="$(mktemp /tmp/gimp-highlight-alphaXXXX.png)"
  shadow_color="$(mktemp /tmp/gimp-shadow-colorXXXX.png)"
  highlight_color="$(mktemp /tmp/gimp-highlight-colorXXXX.png)"
  dir="$(dirname "$img")"
  base="$(basename "$img" .png)"
  base="${base%-overlay}"
  shadow_out="$dir/${base}-shadow-overlay.png"
  highlight_out="$dir/${base}-highlight-overlay.png"

  cp "$img" "$original"

  magick "$img" -alpha extract "PNG32:$alpha"
  magick "$img" \
    -alpha off \
    -colorspace Gray \
    "PNG32:$gray"

  # Restrict the effect to brighter internal structure so the copper/crystal
  # midtone body stays dominant instead of getting pushed brown by global multiply.
  magick "$gray" \
    -level "$DETAIL_MASK_BLACK_PCT","$DETAIL_MASK_WHITE_PCT" \
    -evaluate Pow "$DETAIL_MASK_POW" \
    "$alpha" -compose Multiply -composite \
    "PNG32:$detail_mask"

  # GIMP-equivalent working copy:
  # desaturate luminance -> levels -> sobel -> levels -> gaussian blur.
  magick "$img" \
    -alpha off \
    -colorspace Gray \
    -level "$BLACK_LEVEL_PCT","$WHITE_LEVEL_PCT" \
    -morphology Convolve Sobel \
    -level "$BLACK_LEVEL_PCT","$WHITE_LEVEL_PCT" \
    -blur "$GAUSSIAN_BLUR" \
    "$detail_mask" -compose CopyOpacity -composite \
    "PNG32:$processed"

  magick "$processed" -alpha extract -evaluate Multiply "$SHADOW_OPACITY" "PNG32:$shadow_alpha"
  magick "$processed" -alpha extract -evaluate Multiply "$HIGHLIGHT_OPACITY" "PNG32:$highlight_alpha"
  magick xc:black "$shadow_alpha" -compose CopyOpacity -composite "PNG32:$shadow"
  magick xc:white "$highlight_alpha" -compose CopyOpacity -composite "PNG32:$highlight"
  magick "$processed" \
    -level "$SPARKLE_BLACK_PCT","$SPARKLE_WHITE_PCT" \
    -blur "$SPARKLE_BLUR" \
    -channel A -evaluate Multiply "$SPARKLE_OPACITY" +channel \
    "PNG32:$sparkle"

  magick "$img" \
    "$shadow" -compose Multiply -composite \
    "$highlight" -compose Overlay -composite \
    "$sparkle" -compose Screen -composite \
    "$alpha" -compose CopyOpacity -composite \
    "PNG32:$img"

  # Save editable companion layers that preserve the original hue instead of the
  # literal black/white blend layers, which are not very useful in GIMP by
  # themselves.
  magick "$original" "$shadow_alpha" -compose CopyOpacity -composite "PNG32:$shadow_color"
  magick "$original" "$highlight_alpha" -compose CopyOpacity -composite "PNG32:$highlight_color"
  cp "$shadow_color" "$shadow_out"
  cp "$highlight_color" "$highlight_out"

  rm -f "$alpha" "$gray" "$detail_mask" "$processed" "$shadow" "$highlight" "$sparkle" \
    "$original" "$shadow_alpha" "$highlight_alpha" "$shadow_color" "$highlight_color"
}

for img in "$@"; do
  process_overlay "$img"
done

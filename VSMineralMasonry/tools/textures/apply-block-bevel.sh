#!/usr/bin/env bash
set -euo pipefail

ENABLE_DEPTH_ENHANCE=0
DEPTH_HIGHLIGHT_OPACITY="${DEPTH_HIGHLIGHT_OPACITY:-0.12}"
DEPTH_SHADOW_OPACITY="${DEPTH_SHADOW_OPACITY:-0.16}"
DEPTH_RIM_OPACITY="${DEPTH_RIM_OPACITY:-0.10}"
DEPTH_LEVEL_RANGE="${DEPTH_LEVEL_RANGE:-16%,88%}"
DEPTH_DETAIL_BLUR="${DEPTH_DETAIL_BLUR:-0x0.8}"
DEPTH_EDGE_BLUR="${DEPTH_EDGE_BLUR:-0x0.30}"
DEPTH_RIM_BLUR="${DEPTH_RIM_BLUR:-0x0.18}"
DEPTH_INTERIOR_ERODE="${DEPTH_INTERIOR_ERODE:-Diamond:1}"

usage() {
  echo "Usage: $0 [--depth-enhance] <image.png> [more-images...]" >&2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --depth-enhance)
      ENABLE_DEPTH_ENHANCE=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    --*)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

enhance_depth() {
  local img="$1"
  local alpha interior_alpha rim_alpha gray gray_blur detail highlight_map shadow_map
  local detail_highlight rim_highlight shadow highlight
  alpha="$(mktemp /tmp/depth-alphaXXXX.png)"
  interior_alpha="$(mktemp /tmp/depth-interior-alphaXXXX.png)"
  rim_alpha="$(mktemp /tmp/depth-rim-alphaXXXX.png)"
  gray="$(mktemp /tmp/depth-grayXXXX.png)"
  gray_blur="$(mktemp /tmp/depth-gray-blurXXXX.png)"
  detail="$(mktemp /tmp/depth-detailXXXX.png)"
  highlight_map="$(mktemp /tmp/depth-highlight-mapXXXX.png)"
  shadow_map="$(mktemp /tmp/depth-shadow-mapXXXX.png)"
  detail_highlight="$(mktemp /tmp/depth-detail-highlightXXXX.png)"
  rim_highlight="$(mktemp /tmp/depth-rim-highlightXXXX.png)"
  highlight="$(mktemp /tmp/depth-highlightXXXX.png)"
  shadow="$(mktemp /tmp/depth-shadowXXXX.png)"

  # Build structure from luminance only, leaving the original color image untouched.
  magick "$img" -alpha extract "PNG32:$alpha"
  magick "$alpha" \
    -morphology Erode "$DEPTH_INTERIOR_ERODE" \
    "PNG32:$interior_alpha"
  # Inner rim only, so the lift happens inside the ore/crystal body and not outside
  # the transparent silhouette.
  magick "$alpha" "$interior_alpha" -compose MinusSrc -composite \
    "PNG32:$rim_alpha"
  magick "$img" \
    -alpha off \
    -colorspace Gray \
    -virtual-pixel tile \
    -level "$DEPTH_LEVEL_RANGE" \
    -sigmoidal-contrast 3,50% \
    "PNG32:$gray"

  # Use a small blurred copy to derive local luminance contrast from the existing
  # colored texture. This strengthens internal creases and ridges without replacing
  # the original texture or building a cartoon outline on the silhouette.
  magick "$gray" \
    -virtual-pixel tile \
    -blur "$DEPTH_DETAIL_BLUR" \
    "PNG32:$gray_blur"

  magick "$gray" "$gray_blur" \
    -compose Mathematics -define compose:args='1,0,-1,0.5' -composite \
    "PNG32:$detail"

  # Positive local contrast becomes a thin selective highlight map.
  magick "$detail" \
    -fx "max(0,u-0.5)*2" \
    -evaluate Pow 1.8 \
    "$interior_alpha" -compose Multiply -composite \
    "PNG32:$highlight_map"

  # Negative local contrast becomes a restrained recess/shadow map.
  magick "$detail" \
    -fx "max(0,0.5-u)*2" \
    -evaluate Pow 1.45 \
    "$interior_alpha" -compose Multiply -composite \
    "PNG32:$shadow_map"

  # Lift the inner rim slightly so the ore/crystal reads as catching light where it
  # meets the host rock, but only inside the opaque shape.
  magick "$rim_alpha" \
    -blur "$DEPTH_RIM_BLUR" \
    -evaluate Multiply "$DEPTH_RIM_OPACITY" \
    -write mpr:mask +delete \
    xc:white mpr:mask -compose CopyOpacity -composite \
    "PNG32:$rim_highlight"

  magick "$highlight_map" \
    -blur "$DEPTH_EDGE_BLUR" \
    -evaluate Multiply "$DEPTH_HIGHLIGHT_OPACITY" \
    -write mpr:mask +delete \
    xc:white mpr:mask -compose CopyOpacity -composite \
    "PNG32:$detail_highlight"

  magick "$detail_highlight" "$rim_highlight" -compose Over -composite \
    "PNG32:$highlight"

  magick "$shadow_map" \
    -blur "$DEPTH_EDGE_BLUR" \
    -evaluate Multiply "$DEPTH_SHADOW_OPACITY" \
    -write mpr:mask +delete \
    xc:black mpr:mask -compose CopyOpacity -composite \
    "PNG32:$shadow"

  magick "$img" \
    "$highlight" -compose Screen -composite \
    "$shadow" -compose Multiply -composite \
    "$alpha" -compose CopyOpacity -composite \
    "PNG32:$img"

  rm -f "$alpha" "$interior_alpha" "$rim_alpha" "$gray" "$gray_blur" "$detail" \
    "$highlight_map" "$shadow_map" "$detail_highlight" "$rim_highlight" \
    "$highlight" "$shadow"
}

for img in "$@"; do
  if [[ "$ENABLE_DEPTH_ENHANCE" -eq 1 ]]; then
    enhance_depth "$img"
  fi

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

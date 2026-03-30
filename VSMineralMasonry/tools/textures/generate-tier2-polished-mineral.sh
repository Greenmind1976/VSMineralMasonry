#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <mineral> <mask1.png|vanilla|vanilla:mineral> <mask2.png|vanilla|vanilla:mineral> <mask3.png|vanilla|vanilla:mineral> [--base-palette-mineral <mineral>] [--overlay2-mask1 <mask>] [--overlay2-mask2 <mask>] [--overlay2-mask3 <mask>] [--overlay2-palette-mineral <mineral>]" >&2
}

if [ "${1:-}" = "" ] || [ "${2:-}" = "" ] || [ "${3:-}" = "" ] || [ "${4:-}" = "" ]; then
  usage
  exit 1
fi

MINERAL="$1"
MASK1="$2"
MASK2="$3"
MASK3="$4"
shift 4

BASE_PALETTE_MINERAL="$MINERAL"
OVERLAY2_MASK1=""
OVERLAY2_MASK2=""
OVERLAY2_MASK3=""
OVERLAY2_PALETTE_MINERAL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base-palette-mineral)
      BASE_PALETTE_MINERAL="${2:-}"
      shift 2
      ;;
    --overlay2-mask1)
      OVERLAY2_MASK1="${2:-}"
      shift 2
      ;;
    --overlay2-mask2)
      OVERLAY2_MASK2="${2:-}"
      shift 2
      ;;
    --overlay2-mask3)
      OVERLAY2_MASK3="${2:-}"
      shift 2
      ;;
    --overlay2-palette-mineral)
      OVERLAY2_PALETTE_MINERAL="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUT_DIR="$PROJECT_DIR/assets/vsmineralmasonry/textures/block/stone/polishedmineral"
BEVEL_SCRIPT="$SCRIPT_DIR/apply-block-bevel.sh"

ROCKS=(
  andesite basalt bauxite chalk chert claystone conglomerate granite
  greenmarble halite kimberlite limestone peridotite phyllite redmarble
  sandstone shale slate suevite whitemarble
)

rock_args() {
  case "$1" in
    chalk|halite|limestone|whitemarble)
      printf '%s\n' -modulate 112,100,100 -blur 0x0.55 -sigmoidal-contrast 3,52%
      ;;
    andesite|basalt|granite|greenmarble|kimberlite|peridotite|phyllite|shale|slate|suevite)
      printf '%s\n' -modulate 92,104,100 -blur 0x0.55 -sigmoidal-contrast 4,50%
      ;;
    bauxite|chert|claystone|conglomerate|redmarble|sandstone)
      printf '%s\n' -modulate 100,112,100 -blur 0x0.55 -sigmoidal-contrast 3,50%
      ;;
    *)
      printf '%s\n' -modulate 100,106,100 -blur 0x0.55 -sigmoidal-contrast 3,50%
      ;;
  esac
}

palette_for() {
  case "$1" in
    bismuthinite)
      printf '%s\n' '#6f7658' '#939b77' '#b8c59b'
      ;;
    cassiterite)
      printf '%s\n' '#3e392f' '#7f745f' '#c1b293'
      ;;
    corundum)
      printf '%s\n' '#5f2f34' '#b15a61' '#e2a4ab'
      ;;
    galena)
      printf '%s\n' '#38434b' '#697880' '#aeb9bf'
      ;;
    galena_nativesilver)
      printf '%s\n' '#4d4f56' '#8f949f' '#d8dce2'
      ;;
    lapislazuli)
      printf '%s\n' '#18345c' '#3265a2' '#7fb0ea'
      ;;
    lignite)
      printf '%s\n' '#332b24' '#665547' '#ab9788'
      ;;
    malachite)
      printf '%s\n' '#0f5d36' '#2d9f63' '#87deb0'
      ;;
    nativecopper)
      printf '%s\n' '#7a3416' '#d77733' '#f4b06a'
      ;;
    sphalerite)
      printf '%s\n' '#5f4024' '#a67647' '#deb27f'
      ;;
    sulfur)
      printf '%s\n' '#716311' '#c6b12a' '#f2e078'
      ;;
    silver)
      printf '%s\n' '#636a73' '#b7c0cb' '#fbfdff'
      ;;
    sylvite)
      printf '%s\n' '#794634' '#bf7a5f' '#efb59a'
      ;;
    *)
      printf '%s\n' '#555555' '#999999' '#dddddd'
      ;;
  esac
}

sample_palette_from_ore() {
  local mineral="$1"
  local ore="/Applications/Vintage Story.app/assets/survival/textures/block/stone/ore/${mineral}1.png"
  if [ ! -f "$ore" ]; then
    palette_for "$mineral"
    return
  fi

  python3 - "$ore" "$mineral" <<'PY'
import re
import subprocess
import sys

ore = sys.argv[1]
mineral = sys.argv[2]
lines = subprocess.check_output(["magick", ore, "txt:-"]).decode(errors="ignore").splitlines()[1:]
pixels = []
for line in lines:
    m = re.match(r'(\d+),(\d+): \((\d+),(\d+),(\d+),(\d+)\)', line)
    if not m:
        continue
    r, g, b, a = map(int, m.groups()[2:])
    if a == 0:
        continue
    lum = 0.2126 * r + 0.7152 * g + 0.0722 * b
    w = a / 255.0
    pixels.append((lum, r, g, b, w))

if not pixels:
    print("#555555")
    print("#999999")
    print("#dddddd")
    raise SystemExit

if mineral == "bismuthinite":
    # Hand-tuned to match the simpler granite/slate/marble pass that looked right.
    print("#6f7658")
    print("#939b77")
    print("#b8c59b")
    raise SystemExit

pixels.sort(key=lambda t: t[0])
n = len(pixels)
q1 = pixels[:max(1, n // 3)]
q2 = pixels[n // 3:max(2, (2 * n) // 3)]
q3 = pixels[(2 * n) // 3:]

def avg(items):
    sw = sr = sg = sb = 0.0
    for _, r, g, b, w in items:
        sw += w
        sr += r * w
        sg += g * w
        sb += b * w
    return (
        int(round(sr / sw)),
        int(round(sg / sw)),
        int(round(sb / sw)),
    )

shadow = avg(q1)
mid = avg(q2)
highlight = avg(q3)
highlight = tuple(min(255, int(c * 1.08)) for c in highlight)

for rgb in (shadow, mid, highlight):
    print("#{0:02x}{1:02x}{2:02x}".format(*rgb))
PY
}

mkdir -p "$OUT_DIR"

PALETTE="$(sample_palette_from_ore "$BASE_PALETTE_MINERAL")"
SHADOW="$(printf '%s\n' "$PALETTE" | sed -n '1p')"
MID="$(printf '%s\n' "$PALETTE" | sed -n '2p')"
HIGHLIGHT="$(printf '%s\n' "$PALETTE" | sed -n '3p')"

SECONDARY_SHADOW=""
SECONDARY_MID=""
SECONDARY_HIGHLIGHT=""
if [[ -n "$OVERLAY2_PALETTE_MINERAL" ]]; then
  SECONDARY_PALETTE="$(sample_palette_from_ore "$OVERLAY2_PALETTE_MINERAL")"
  SECONDARY_SHADOW="$(printf '%s\n' "$SECONDARY_PALETTE" | sed -n '1p')"
  SECONDARY_MID="$(printf '%s\n' "$SECONDARY_PALETTE" | sed -n '2p')"
  SECONDARY_HIGHLIGHT="$(printf '%s\n' "$SECONDARY_PALETTE" | sed -n '3p')"
fi

mask_overlay() {
  local mask_file="$1"
  local variant="$2"
  local out_file="$3"
  local shadow="$4"
  local mid="$5"
  local highlight="$6"
  local source_file="$mask_file"
  local source_mineral="$MINERAL"

  if [[ "$mask_file" == vanilla:* ]]; then
    source_mineral="${mask_file#vanilla:}"
    source_file="/Applications/Vintage Story.app/assets/survival/textures/block/stone/ore/${source_mineral}${variant}.png"
    magick "$source_file" \
      -filter point -resize 64x64! \
      -colorspace sRGB \
      -modulate 100,118,100 \
      -sigmoidal-contrast 3,50% \
      -type TrueColorAlpha \
      PNG32:"$out_file"
    return
  fi

  if [ "$mask_file" = "vanilla" ]; then
    source_file="/Applications/Vintage Story.app/assets/survival/textures/block/stone/ore/${source_mineral}${variant}.png"
    magick "$source_file" \
      -filter point -resize 64x64! \
      -colorspace sRGB \
      -modulate 100,118,100 \
      -sigmoidal-contrast 3,50% \
      -type TrueColorAlpha \
      PNG32:"$out_file"
    return
  fi

  magick "$source_file" \
    -colorspace Gray \
    -auto-level \
    -level 18%,96% \
    -write mpr:gray +delete \
    mpr:gray \
    \( xc:"$shadow" xc:"$mid" xc:"$highlight" +append -filter triangle -resize 256x1! \) \
    -clut \
    -colorspace sRGB \
    mpr:gray -compose CopyOpacity -composite \
    PNG32:"$out_file"
}

compose_overlay_pair() {
  local primary_mask="$1"
  local secondary_mask="$2"
  local variant="$3"
  local out_file="$4"

  local primary_tmp
  local secondary_tmp
  primary_tmp="$(mktemp /tmp/${MINERAL}-primary-XXXX.png)"
  secondary_tmp="$(mktemp /tmp/${MINERAL}-secondary-XXXX.png)"

  mask_overlay "$primary_mask" "$variant" "$primary_tmp" "$SHADOW" "$MID" "$HIGHLIGHT"
  mask_overlay "$secondary_mask" "$variant" "$secondary_tmp" "$SECONDARY_SHADOW" "$SECONDARY_MID" "$SECONDARY_HIGHLIGHT"

  magick "$primary_tmp" "$secondary_tmp" -compose Over -composite PNG32:"$out_file"
  rm -f "$primary_tmp" "$secondary_tmp"
}

TMP1="/tmp/${MINERAL}-overlay-1.png"
TMP2="/tmp/${MINERAL}-overlay-2.png"
TMP3="/tmp/${MINERAL}-overlay-3.png"
if [[ -n "$OVERLAY2_MASK1" || -n "$OVERLAY2_MASK2" || -n "$OVERLAY2_MASK3" ]]; then
  if [[ -z "$OVERLAY2_MASK1" || -z "$OVERLAY2_MASK2" || -z "$OVERLAY2_MASK3" || -z "$OVERLAY2_PALETTE_MINERAL" ]]; then
    echo "Secondary overlay requires all three overlay2 masks and --overlay2-palette-mineral" >&2
    exit 1
  fi
  compose_overlay_pair "$MASK1" "$OVERLAY2_MASK1" "1" "$TMP1"
  compose_overlay_pair "$MASK2" "$OVERLAY2_MASK2" "2" "$TMP2"
  compose_overlay_pair "$MASK3" "$OVERLAY2_MASK3" "3" "$TMP3"
else
  mask_overlay "$MASK1" "1" "$TMP1" "$SHADOW" "$MID" "$HIGHLIGHT"
  mask_overlay "$MASK2" "2" "$TMP2" "$SHADOW" "$MID" "$HIGHLIGHT"
  mask_overlay "$MASK3" "3" "$TMP3" "$SHADOW" "$MID" "$HIGHLIGHT"
fi

for rock in "${ROCKS[@]}"; do
  rock_src="/Applications/Vintage Story.app/assets/survival/textures/block/stone/rock/${rock}1.png"
  for variant in 1 2 3; do
    overlay_var="TMP${variant}"
    overlay="${!overlay_var}"
    out="$OUT_DIR/${MINERAL}${variant}-${rock}.png"
    rock_cmd=(magick "$rock_src" \
      -resize 64x64! \
      -colorspace sRGB \
    )
    while IFS= read -r arg; do
      rock_cmd+=("$arg")
    done < <(rock_args "$rock")
    rock_cmd+=(
      -type TrueColorAlpha \
      "$overlay" -compose Over -composite \
      -unsharp 0x0.85+0.9+0.015 \
      "PNG32:$out"
    )
    "${rock_cmd[@]}"
    "$BEVEL_SCRIPT" "$out"
  done
done

echo "Generated $MINERAL textures in $OUT_DIR"

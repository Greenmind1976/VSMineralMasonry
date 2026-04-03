#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
MASK_DIR="$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/extra-high-legacy"
MANIFEST="$PROJECT_DIR/assets/vsmineralmasonry/textures/review/crystal-color-studies/crystal-curated-mask-manifest.json"
BEVEL_SCRIPT="$SCRIPT_DIR/apply-block-bevel.sh"
OUT_BASE="$PROJECT_DIR/assets/vsmineralmasonry/textures/block/stone/polishedcrystal"
OVERLAY_BASE="$PROJECT_DIR/assets/vsmineralmasonry/textures/block/stone/polishedcrystal-overlays"

if [ ! -f "$MANIFEST" ]; then
  echo "Missing manifest: $MANIFEST" >&2
  exit 1
fi

ROCKS=(
  andesite basalt bauxite chalk chert claystone conglomerate granite
  greenmarble halite kimberlite limestone peridotite phyllite redmarble
  sandstone shale slate suevite whitemarble
)

palette_for() {
  case "$1" in
    alum) echo '#8e806d #c8baa4 #f2eadc' ;;
    borax) echo '#7f9491 #b9d0ca #eefbf8' ;;
    corundum) echo '#7e404b #bb6777 #ffd2dc' ;;
    diamond) echo '#7b8f9f #afc0cf #f9fdff' ;;
    emerald) echo '#1d6947 #3fb878 #c7ffe2' ;;
    fluorite) echo '#504c7a #8a80be #e5dcff' ;;
    kernite) echo '#7f5f49 #ab7f61 #f7e6d8' ;;
    lapislazuli) echo '#17346f #2550b2 #b8cbff' ;;
    malachite) echo '#1f6d57 #45b88f #d8fff2' ;;
    olivine) echo '#35591b #5f8f34 #bde28a' ;;
    olivine_peridot) echo '#37610f #70ad28 #c7f579' ;;
    quartz) echo '#bfc5cd #eef1f4 #ffffff' ;;
    quartz_nativegold) echo '#8c7d4d #d0b35b #fff3c1' ;;
    quartz_nativesilver) echo '#687078 #b6bfc8 #f3f5f8' ;;
    rhodochrosite) echo '#7d4458 #bf7289 #ffd1df' ;;
    sylvite) echo '#8f556d #c57b98 #ffd2e2' ;;
    uranium) echo '#497c39 #7fbf62 #dfffbf' ;;
    *) echo '#777777 #aaaaaa #dddddd' ;;
  esac
}

blend_hex() {
  python3 - "$1" "$2" "$3" <<'PY'
import sys
a = sys.argv[1].lstrip('#')
b = sys.argv[2].lstrip('#')
t = float(sys.argv[3])
av = [int(a[i:i+2], 16) for i in (0, 2, 4)]
bv = [int(b[i:i+2], 16) for i in (0, 2, 4)]
out = []
for x, y in zip(av, bv):
    out.append(max(0, min(255, int(round(x + (y - x) * t)))))
print('#%02x%02x%02x' % tuple(out))
PY
}

remap_palette() {
  local mineral="${1:-}"
  shift
  local shadow="$1"
  local mid="$2"
  local hi="$3"
  local new_shadow
  local new_hi
  # Keep the tonal spread tighter around the main crystal color so
  # darker minerals don't lose footprint and lighter minerals don't wash out.
  new_shadow="$(blend_hex "$mid" "$shadow" 0.35)"
  new_hi="$(blend_hex "$mid" "$hi" 0.20)"
  case "$mineral" in
    alum|quartz)
      new_hi="$(blend_hex "$mid" "$hi" 0.38)"
      ;;
  esac
  echo "$new_shadow $mid $new_hi"
}

build_overlay() {
  local mineral="$1"
  shift
  local mask_path="$1"
  local out_path="$2"
  local shadow="$3"
  local mid="$4"
  local hi="$5"
  local level_low='10%'
  local pow='0.92'

  case "$mineral" in
    alum|quartz)
      level_low='4%'
      pow='0.78'
      ;;
  esac

  read -r shadow mid hi <<<"$(remap_palette "$mineral" "$shadow" "$mid" "$hi")"

  magick "$mask_path" \
    -colorspace Gray \
    -auto-level \
    -sigmoidal-contrast 3,54% \
    -level ${level_low},100% \
    -evaluate Pow "$pow" \
    -write mpr:gray +delete \
    mpr:gray \
    \( xc:"$shadow" xc:"$mid" xc:"$hi" +append -filter point -resize 256x1! \) \
    -clut \
    -colorspace sRGB \
    mpr:gray -compose CopyOpacity -composite \
    "PNG32:$out_path"
}

build_quartz_metal_overlay() {
  local mask_path="$1"
  local out_path="$2"
  local metal="$3"
  local variant="$4"
  local silver_boost="${5:-0}"

  local quartz_shadow quartz_mid quartz_hi
  local metal_shadow metal_mid metal_hi
  local qtmp atmp
  qtmp="$(mktemp /tmp/quartz-bodyXXXX.png)"
  atmp="$(mktemp /tmp/quartz-metalXXXX.png)"

  if [ "$metal" = "gold" ]; then
    quartz_shadow='#bfc5cd'
    quartz_mid='#eef1f4'
    quartz_hi='#ffffff'
    metal_shadow='#92743a'
    metal_mid='#bf9645'
    metal_hi='#d8b564'
  else
    quartz_shadow='#bfc5cd'
    quartz_mid='#eef1f4'
    quartz_hi='#ffffff'
    metal_shadow='#555d66'
    metal_mid='#7a838d'
    metal_hi='#a4adb7'
  fi

  build_overlay quartz "$mask_path" "$qtmp" "$quartz_shadow" "$quartz_mid" "$quartz_hi"

  local medium_mask="$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-14.png"
  if [ "$metal" = "gold" ]; then
    case "$variant" in
      1) medium_mask="$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-11.png" ;;
      2) medium_mask="$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-13.png" ;;
      3) medium_mask="$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-14.png" ;;
    esac
  else
    case "$variant" in
      1) medium_mask="$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-13.png" ;;
      2) medium_mask="$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-11.png" ;;
      3) medium_mask="$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-14.png" ;;
    esac
    if [ "$silver_boost" = "1" ]; then
      medium_mask="$PROJECT_DIR/assets/vsmineralmasonry/textures/curated-masks/medium-coverage/medium-coverage-mask-13.png"
    fi
  fi

  local cmd=(
    magick "$medium_mask"
    -colorspace Gray
    -auto-level
    -level 8%,100%
    -evaluate Pow 0.82
    -write mpr:gray +delete
    mpr:gray
    \( xc:"$metal_shadow" xc:"$metal_mid" xc:"$metal_hi" +append -filter point -resize 256x1! \)
    -clut
    -colorspace sRGB
    mpr:gray -compose CopyOpacity -composite
    "PNG32:$atmp"
  )
  "${cmd[@]}"

  magick "$qtmp" "$atmp" -compose Over -composite "PNG32:$out_path"
  rm -f "$qtmp" "$atmp"
}

if [ "${1:-}" = "" ]; then
  mapfile -t MINERALS < <(python3 - "$MANIFEST" <<'PY'
import json, sys
with open(sys.argv[1]) as f:
    j = json.load(f)
for mineral in j.keys():
    print(mineral)
PY
)
else
  MINERALS=("$@")
fi

for MINERAL in "${MINERALS[@]}"; do
  read -r SHADOW MID HI <<<"$(palette_for "$MINERAL")"
  MASKS=()
  while IFS= read -r num; do
    MASKS+=("$num")
  done < <(python3 - "$MANIFEST" "$MINERAL" <<'PY'
import json, sys
with open(sys.argv[1]) as f:
    j = json.load(f)
for num in j[sys.argv[2]]:
    print(num)
PY
)
  OUT_DIR="$OUT_BASE"
  OVERLAY_DIR="$OVERLAY_BASE"
  mkdir -p "$OUT_DIR"
  mkdir -p "$OVERLAY_DIR"

  TMP1="$OVERLAY_DIR/${MINERAL}1-overlay.png"
  TMP2="$OVERLAY_DIR/${MINERAL}2-overlay.png"
  TMP3="$OVERLAY_DIR/${MINERAL}3-overlay.png"

  for idx in 1 2 3; do
    mask_num="${MASKS[$((idx-1))]}"
    mask_path="$MASK_DIR/extra-high-mask-${mask_num}.png"
    tmp_var="TMP${idx}"
    tmp_path="${!tmp_var}"
    if [ "$MINERAL" = "quartz_nativegold" ]; then
      build_quartz_metal_overlay "$mask_path" "$tmp_path" gold "$idx" 0
    elif [ "$MINERAL" = "quartz_nativesilver" ]; then
      if [ "$idx" = "1" ]; then
        build_quartz_metal_overlay "$mask_path" "$tmp_path" silver "$idx" 1
      else
        build_quartz_metal_overlay "$mask_path" "$tmp_path" silver "$idx" 0
      fi
    else
      build_overlay "$MINERAL" "$mask_path" "$tmp_path" "$SHADOW" "$MID" "$HI"
    fi
  done

  for rock in "${ROCKS[@]}"; do
    rock_src="/Applications/Vintage Story.app/assets/survival/textures/block/stone/rock/${rock}1.png"
    for idx in 1 2 3; do
      tmp_var="TMP${idx}"
      overlay="${!tmp_var}"
      out="$OUT_DIR/${MINERAL}${idx}-${rock}.png"
      magick "$rock_src" \
        -filter point -resize 64x64! \
        -colorspace sRGB \
        "$overlay" -compose Over -composite \
        "PNG32:$out"
      "$BEVEL_SCRIPT" "$out"
    done
  done

  echo "Generated $MINERAL crystal textures in $OUT_DIR"
  echo "Saved $MINERAL crystal overlays in $OVERLAY_DIR"
done

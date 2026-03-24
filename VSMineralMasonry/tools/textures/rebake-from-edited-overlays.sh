#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$PROJECT_DIR/.." && pwd)"
MASTER_LISTS="$PROJECT_DIR/config/master-lists.json"
DEPTH_SETTINGS="$PROJECT_DIR/config/overlay-depth-settings.json"
BEVEL_SCRIPT="$SCRIPT_DIR/apply-block-bevel.sh"
GIMP_DEPTH_SCRIPT="$SCRIPT_DIR/apply-gimp-overlay-depth.sh"

usage() {
  cat >&2 <<'EOF'
Usage:
  rebake-from-edited-overlays.sh <mineral> [--kind ore|crystal] [--depth-enhance] [--gimp-depth] [--no-review]

Examples:
  rebake-from-edited-overlays.sh nativecopper
  rebake-from-edited-overlays.sh quartz --kind crystal
  rebake-from-edited-overlays.sh nativecopper --depth-enhance
  rebake-from-edited-overlays.sh nativecopper --gimp-depth
EOF
}

apply_gimp_depth_settings() {
  python3 - "$DEPTH_SETTINGS" "$MINERAL" <<'PY'
import json, os, sys
path, mineral = sys.argv[1], sys.argv[2]
with open(path) as f:
    j = json.load(f)
defaults = j.get("gimpDepthDefaults", {})
overrides = j.get("gimpDepthByMineral", {}).get(mineral, {})
merged = defaults.copy()
merged.update(overrides)
for key, value in merged.items():
    if os.environ.get(key) in (None, ""):
        print(f'export {key}="{value}"')
PY
}

MINERAL=""
KIND=""
WRITE_REVIEW=1
ENABLE_DEPTH_ENHANCE=0
ENABLE_GIMP_DEPTH=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --kind)
      KIND="${2:-}"
      shift 2
      ;;
    --no-review)
      WRITE_REVIEW=0
      shift
      ;;
    --depth-enhance)
      ENABLE_DEPTH_ENHANCE=1
      shift
      ;;
    --gimp-depth)
      ENABLE_GIMP_DEPTH=1
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
      if [[ -n "$MINERAL" ]]; then
        echo "Only one mineral may be specified." >&2
        usage
        exit 1
      fi
      MINERAL="$1"
      shift
      ;;
  esac
done

if [[ -z "$MINERAL" ]]; then
  usage
  exit 1
fi

ROCKS=()
while IFS= read -r rock; do
  ROCKS+=("$rock")
done < <(python3 - "$MASTER_LISTS" <<'PY'
import json, sys
with open(sys.argv[1]) as f:
    j = json.load(f)
for rock in j["rocks"]:
    print(rock)
PY
)

detect_kind_and_tier() {
  python3 - "$MASTER_LISTS" "$MINERAL" "$KIND" <<'PY'
import json, sys
with open(sys.argv[1]) as f:
    j = json.load(f)
mineral = sys.argv[2]
kind = sys.argv[3]
visual = j.get("mineralVisualCategory", {})
tier = j.get("mineralMiningTier", {}).get(mineral)
if kind:
    if tier is None:
        raise SystemExit(f"Unknown mineral: {mineral}")
    print(kind)
    print(tier)
    raise SystemExit
if mineral in visual:
    print(visual[mineral])
    print(tier)
    raise SystemExit
raise SystemExit(f"Unable to detect kind for {mineral}")
PY
}

DETECTED=()
while IFS= read -r line; do
  DETECTED+=("$line")
done < <(detect_kind_and_tier)
KIND="${DETECTED[0]}"
TIER="${DETECTED[1]}"

if [[ "$KIND" != "ore" && "$KIND" != "crystal" ]]; then
  echo "Unsupported kind: $KIND" >&2
  exit 1
fi

if [[ "$KIND" == "ore" ]]; then
  EDIT_ROOT="$REPO_ROOT/textures/ore/tier$TIER"
  OUT_DIR="$PROJECT_DIR/assets/vsmineralmasonry/textures/block/stone/polishedmineral/tier2"
  REVIEW_DIR="$PROJECT_DIR/assets/vsmineralmasonry/textures/review"
else
  EDIT_ROOT="$REPO_ROOT/textures/crystal/tier$TIER"
  OUT_DIR="$PROJECT_DIR/assets/vsmineralmasonry/textures/block/stone/polishedcrystal/tier$TIER"
  REVIEW_DIR="$PROJECT_DIR/assets/vsmineralmasonry/textures/review"
fi

mkdir -p "$OUT_DIR" "$REVIEW_DIR"

declare -a OVERLAYS=()
declare -a WORK_OVERLAYS=()
for idx in 1 2 3; do
  overlay="$EDIT_ROOT/${MINERAL}${idx}-overlay.png"
  if [[ ! -f "$overlay" ]]; then
    echo "Missing edited overlay: $overlay" >&2
    exit 1
  fi
  OVERLAYS+=("$overlay")
done

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

for idx in 1 2 3; do
  src="${OVERLAYS[$((idx-1))]}"
  work="$TMPDIR/${MINERAL}${idx}-overlay.png"
  cp "$src" "$work"
  WORK_OVERLAYS+=("$work")
done

if [[ "$ENABLE_GIMP_DEPTH" -eq 1 ]]; then
  if [[ -f "$DEPTH_SETTINGS" ]]; then
    eval "$(apply_gimp_depth_settings)"
  fi
  "$GIMP_DEPTH_SCRIPT" "${WORK_OVERLAYS[@]}"
  for idx in 1 2 3; do
    src_overlay="${OVERLAYS[$((idx-1))]}"
    work_overlay="${WORK_OVERLAYS[$((idx-1))]}"
    base_name="$(basename "$src_overlay" .png)"
    clean_base="${base_name%-overlay}"
    src_dir="$(dirname "$src_overlay")"
    cp "$(dirname "$work_overlay")/${clean_base}-shadow-overlay.png" \
      "$src_dir/${base_name}-shadow-overlay.png"
    cp "$(dirname "$work_overlay")/${clean_base}-highlight-overlay.png" \
      "$src_dir/${base_name}-highlight-overlay.png"
  done
fi

for rock in "${ROCKS[@]}"; do
  rock_src="/Applications/Vintage Story.app/assets/survival/textures/block/stone/rock/${rock}1.png"
  if [[ ! -f "$rock_src" ]]; then
    echo "Missing rock source: $rock_src" >&2
    exit 1
  fi
  for idx in 1 2 3; do
    overlay="${WORK_OVERLAYS[$((idx-1))]}"
    out="$OUT_DIR/${MINERAL}${idx}-${rock}.png"
    magick "$rock_src" \
      -filter point -resize 64x64! \
      -colorspace sRGB \
      "$overlay" -compose Over -composite \
      "PNG32:$out"
    if [[ "$ENABLE_DEPTH_ENHANCE" -eq 1 ]]; then
      "$BEVEL_SCRIPT" --depth-enhance "$out"
    else
      "$BEVEL_SCRIPT" "$out"
    fi
  done
done

if [[ "$WRITE_REVIEW" -eq 1 ]]; then
  FONT=/System/Library/Fonts/Supplemental/Verdana.ttf
  if [[ ! -f "$FONT" ]]; then
    FONT=/System/Library/Fonts/Verdana.ttf
  fi
  REVIEW_OUT="$REVIEW_DIR/${MINERAL}-${KIND}-edited-review.png"
  rows=()

  title="$TMPDIR/title.png"
  magick -background '#f5f5f5' -fill '#111111' -font "$FONT" -pointsize 18 \
    label:"${MINERAL} edited overlays" "$title"
  rows+=("$title")

  header_label="$TMPDIR/header-label.png"
  magick -background '#f5f5f5' -fill '#111111' -font "$FONT" -pointsize 14 \
    label:'rock' -gravity west -extent 150x22! "$header_label"
  header_cells=()
  for idx in 1 2 3; do
    cell="$TMPDIR/header-$idx.png"
    magick -background '#f5f5f5' -fill '#111111' -font "$FONT" -pointsize 14 \
      label:"${idx}" -gravity center -extent 64x22! "$cell"
    header_cells+=("$cell")
  done
  header_strip="$TMPDIR/header-strip.png"
  magick "${header_cells[@]}" +append "$header_strip"
  header_row="$TMPDIR/header-row.png"
  magick "$header_label" "$header_strip" +append "$header_row"
  rows+=("$header_row")

  row=0
  for rock in "${ROCKS[@]}"; do
    label="$TMPDIR/label-$row.png"
    magick -background '#f5f5f5' -fill '#111111' -font "$FONT" -pointsize 13 \
      label:"$rock" -gravity west -extent 150x64! "$label"
    cells=()
    for idx in 1 2 3; do
      cells+=("$OUT_DIR/${MINERAL}${idx}-${rock}.png")
    done
    strip="$TMPDIR/strip-$row.png"
    magick "${cells[@]}" +append "$strip"
    out_row="$TMPDIR/row-$row.png"
    magick "$label" "$strip" +append "$out_row"
    rows+=("$out_row")
    row=$((row+1))
  done

  magick "${rows[@]}" -append "$REVIEW_OUT"
fi

echo "kind=$KIND"
echo "tier=$TIER"
echo "depth_enhance=$ENABLE_DEPTH_ENHANCE"
echo "gimp_depth=$ENABLE_GIMP_DEPTH"
echo "output_dir=$OUT_DIR"
if [[ "$WRITE_REVIEW" -eq 1 ]]; then
  echo "review=$REVIEW_OUT"
fi

#!/bin/zsh
set -euo pipefail
OUT=/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-6x6-renders
ROCKSRC="/Applications/Vintage Story.app/assets/survival/textures/block/stone/rock"
mkdir -p "$OUT"/green/tiles "$OUT"/darkred/tiles "$OUT"/yellow/tiles "$OUT"/tmp "$OUT"/rocks
for rock in basalt chalk chert granite; do
  magick "$ROCKSRC/${rock}1.png" -filter point -resize 64x64! "$OUT/rocks/${rock}-64.png"
done
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_01.png" -resize 64x64! "$OUT/green/tiles/green_01.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_02.png" -resize 64x64! "$OUT/green/tiles/green_02.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_03.png" -resize 64x64! "$OUT/green/tiles/green_03.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_04.png" -resize 64x64! "$OUT/green/tiles/green_04.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_05.png" -resize 64x64! "$OUT/green/tiles/green_05.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_06.png" -resize 64x64! "$OUT/green/tiles/green_06.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_07.png" -resize 64x64! "$OUT/green/tiles/green_07.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_08.png" -resize 64x64! "$OUT/green/tiles/green_08.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_09.png" -resize 64x64! "$OUT/green/tiles/green_09.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_10.png" -resize 64x64! "$OUT/green/tiles/green_10.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_11.png" -resize 64x64! "$OUT/green/tiles/green_11.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_12.png" -resize 64x64! "$OUT/green/tiles/green_12.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_13.png" -resize 64x64! "$OUT/green/tiles/green_13.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_14.png" -resize 64x64! "$OUT/green/tiles/green_14.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_15.png" -resize 64x64! "$OUT/green/tiles/green_15.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_16.png" -resize 64x64! "$OUT/green/tiles/green_16.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_17.png" -resize 64x64! "$OUT/green/tiles/green_17.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_18.png" -resize 64x64! "$OUT/green/tiles/green_18.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_19.png" -resize 64x64! "$OUT/green/tiles/green_19.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_20.png" -resize 64x64! "$OUT/green/tiles/green_20.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_21.png" -resize 64x64! "$OUT/green/tiles/green_21.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_22.png" -resize 64x64! "$OUT/green/tiles/green_22.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_23.png" -resize 64x64! "$OUT/green/tiles/green_23.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_24.png" -resize 64x64! "$OUT/green/tiles/green_24.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_25.png" -resize 64x64! "$OUT/green/tiles/green_25.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_26.png" -resize 64x64! "$OUT/green/tiles/green_26.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_27.png" -resize 64x64! "$OUT/green/tiles/green_27.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_28.png" -resize 64x64! "$OUT/green/tiles/green_28.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_29.png" -resize 64x64! "$OUT/green/tiles/green_29.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_30.png" -resize 64x64! "$OUT/green/tiles/green_30.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_31.png" -resize 64x64! "$OUT/green/tiles/green_31.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_32.png" -resize 64x64! "$OUT/green/tiles/green_32.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_33.png" -resize 64x64! "$OUT/green/tiles/green_33.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_34.png" -resize 64x64! "$OUT/green/tiles/green_34.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_35.png" -resize 64x64! "$OUT/green/tiles/green_35.png"
magick "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/emerald-slices/6x6/images/Untitled-1_36.png" -resize 64x64! "$OUT/green/tiles/green_36.png"
for f in "$OUT"/green/tiles/*.png; do
  name=$(basename "$f")
  magick "$f" -colorspace gray -fill 'rgb(140,28,28)' -colorize 100 "$OUT/darkred/tiles/${name/green_/darkred_}"
  magick "$f" -colorspace gray -fill 'rgb(201,162,39)' -colorize 100 "$OUT/yellow/tiles/${name/green_/yellow_}"
done
reconstruct() {
  local color="$1"
  local dest="$2"
  magick -size 391x391 canvas:black     "$OUT/$color/tiles/${"color"}_01.png" -geometry +1+1 -composite \
    "$OUT/$color/tiles/${"color"}_02.png" -geometry +66+1 -composite \
    "$OUT/$color/tiles/${"color"}_03.png" -geometry +131+1 -composite \
    "$OUT/$color/tiles/${"color"}_04.png" -geometry +196+1 -composite \
    "$OUT/$color/tiles/${"color"}_05.png" -geometry +261+1 -composite \
    "$OUT/$color/tiles/${"color"}_06.png" -geometry +326+1 -composite \
    "$OUT/$color/tiles/${"color"}_07.png" -geometry +1+66 -composite \
    "$OUT/$color/tiles/${"color"}_08.png" -geometry +66+66 -composite \
    "$OUT/$color/tiles/${"color"}_09.png" -geometry +131+66 -composite \
    "$OUT/$color/tiles/${"color"}_10.png" -geometry +196+66 -composite \
    "$OUT/$color/tiles/${"color"}_11.png" -geometry +261+66 -composite \
    "$OUT/$color/tiles/${"color"}_12.png" -geometry +326+66 -composite \
    "$OUT/$color/tiles/${"color"}_13.png" -geometry +1+131 -composite \
    "$OUT/$color/tiles/${"color"}_14.png" -geometry +66+131 -composite \
    "$OUT/$color/tiles/${"color"}_15.png" -geometry +131+131 -composite \
    "$OUT/$color/tiles/${"color"}_16.png" -geometry +196+131 -composite \
    "$OUT/$color/tiles/${"color"}_17.png" -geometry +261+131 -composite \
    "$OUT/$color/tiles/${"color"}_18.png" -geometry +326+131 -composite \
    "$OUT/$color/tiles/${"color"}_19.png" -geometry +1+196 -composite \
    "$OUT/$color/tiles/${"color"}_20.png" -geometry +66+196 -composite \
    "$OUT/$color/tiles/${"color"}_21.png" -geometry +131+196 -composite \
    "$OUT/$color/tiles/${"color"}_22.png" -geometry +196+196 -composite \
    "$OUT/$color/tiles/${"color"}_23.png" -geometry +261+196 -composite \
    "$OUT/$color/tiles/${"color"}_24.png" -geometry +326+196 -composite \
    "$OUT/$color/tiles/${"color"}_25.png" -geometry +1+261 -composite \
    "$OUT/$color/tiles/${"color"}_26.png" -geometry +66+261 -composite \
    "$OUT/$color/tiles/${"color"}_27.png" -geometry +131+261 -composite \
    "$OUT/$color/tiles/${"color"}_28.png" -geometry +196+261 -composite \
    "$OUT/$color/tiles/${"color"}_29.png" -geometry +261+261 -composite \
    "$OUT/$color/tiles/${"color"}_30.png" -geometry +326+261 -composite \
    "$OUT/$color/tiles/${"color"}_31.png" -geometry +1+326 -composite \
    "$OUT/$color/tiles/${"color"}_32.png" -geometry +66+326 -composite \
    "$OUT/$color/tiles/${"color"}_33.png" -geometry +131+326 -composite \
    "$OUT/$color/tiles/${"color"}_34.png" -geometry +196+326 -composite \
    "$OUT/$color/tiles/${"color"}_35.png" -geometry +261+326 -composite \
    "$OUT/$color/tiles/${"color"}_36.png" -geometry +326+326 -composite \
    "$dest"
}
reconstruct green "$OUT/overlay-6x6-reconstructed-bordered-green.png"
reconstruct darkred "$OUT/overlay-6x6-reconstructed-bordered-darkred.png"
reconstruct yellow "$OUT/overlay-6x6-reconstructed-bordered-yellow.png"
for rock in basalt chalk chert granite; do
  for color in green darkred yellow; do
    mkdir -p "$OUT/tmp/${rock}-${color}"
    for i in {01..36}; do
      magick "$OUT/rocks/${rock}-64.png" "$OUT/${color}/tiles/${color}_${i}.png" -compose over -composite "$OUT/tmp/${rock}-${color}/${rock}-${color}_${i}.png"
    done
    magick -size 391x391 canvas:black       "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_01.png" -geometry +1+1 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_02.png" -geometry +66+1 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_03.png" -geometry +131+1 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_04.png" -geometry +196+1 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_05.png" -geometry +261+1 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_06.png" -geometry +326+1 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_07.png" -geometry +1+66 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_08.png" -geometry +66+66 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_09.png" -geometry +131+66 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_10.png" -geometry +196+66 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_11.png" -geometry +261+66 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_12.png" -geometry +326+66 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_13.png" -geometry +1+131 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_14.png" -geometry +66+131 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_15.png" -geometry +131+131 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_16.png" -geometry +196+131 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_17.png" -geometry +261+131 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_18.png" -geometry +326+131 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_19.png" -geometry +1+196 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_20.png" -geometry +66+196 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_21.png" -geometry +131+196 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_22.png" -geometry +196+196 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_23.png" -geometry +261+196 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_24.png" -geometry +326+196 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_25.png" -geometry +1+261 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_26.png" -geometry +66+261 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_27.png" -geometry +131+261 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_28.png" -geometry +196+261 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_29.png" -geometry +261+261 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_30.png" -geometry +326+261 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_31.png" -geometry +1+326 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_32.png" -geometry +66+326 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_33.png" -geometry +131+326 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_34.png" -geometry +196+326 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_35.png" -geometry +261+326 -composite \
      "$OUT/tmp/${"rock"}-${"color"}/${"rock"}-${"color"}_36.png" -geometry +326+326 -composite \
      "$OUT/${rock}-reconstructed-bordered-${color}.png"
  done
done
magick -size 1664x1285 canvas:'rgb(245,245,245)'   "$OUT/basalt-reconstructed-bordered-green.png" -geometry +80+44 -composite   "$OUT/chalk-reconstructed-bordered-green.png" -geometry +471+44 -composite   "$OUT/chert-reconstructed-bordered-green.png" -geometry +862+44 -composite   "$OUT/granite-reconstructed-bordered-green.png" -geometry +1253+44 -composite   "$OUT/basalt-reconstructed-bordered-darkred.png" -geometry +80+459 -composite   "$OUT/chalk-reconstructed-bordered-darkred.png" -geometry +471+459 -composite   "$OUT/chert-reconstructed-bordered-darkred.png" -geometry +862+459 -composite   "$OUT/granite-reconstructed-bordered-darkred.png" -geometry +1253+459 -composite   "$OUT/basalt-reconstructed-bordered-yellow.png" -geometry +80+874 -composite   "$OUT/chalk-reconstructed-bordered-yellow.png" -geometry +471+874 -composite   "$OUT/chert-reconstructed-bordered-yellow.png" -geometry +862+874 -composite   "$OUT/granite-reconstructed-bordered-yellow.png" -geometry +1253+874 -composite   "$OUT/multi-rock-color-comparison-sheet.png"
printf 'Rows: green, darkred, yellow
Cols: basalt, chalk, chert, granite
Grid: 6x6, 64x64 per tile with 1px borders
' > "$OUT/order.txt"

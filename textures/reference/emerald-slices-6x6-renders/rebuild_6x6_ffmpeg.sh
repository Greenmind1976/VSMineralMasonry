#!/bin/zsh
set -euo pipefail
OUT="/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-6x6-renders"
for rock in basalt chalk chert granite; do
  for color in green darkred yellow; do
    rm -rf "$OUT/tmp/${rock}-${color}"
    mkdir -p "$OUT/tmp/${rock}-${color}"
    for i in {01..36}; do
      ffmpeg -y -loglevel error -i "$OUT/rocks/${rock}-64.png" -i "$OUT/${color}/tiles/${color}_${i}.png" -filter_complex "[0][1]overlay=0:0:format=auto" "$OUT/tmp/${rock}-${color}/${rock}-${color}_${i}.png"
    done
    magick -size 391x391 canvas:black \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_01.png" -geometry +1+1 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_02.png" -geometry +66+1 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_03.png" -geometry +131+1 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_04.png" -geometry +196+1 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_05.png" -geometry +261+1 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_06.png" -geometry +326+1 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_07.png" -geometry +1+66 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_08.png" -geometry +66+66 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_09.png" -geometry +131+66 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_10.png" -geometry +196+66 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_11.png" -geometry +261+66 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_12.png" -geometry +326+66 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_13.png" -geometry +1+131 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_14.png" -geometry +66+131 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_15.png" -geometry +131+131 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_16.png" -geometry +196+131 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_17.png" -geometry +261+131 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_18.png" -geometry +326+131 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_19.png" -geometry +1+196 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_20.png" -geometry +66+196 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_21.png" -geometry +131+196 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_22.png" -geometry +196+196 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_23.png" -geometry +261+196 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_24.png" -geometry +326+196 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_25.png" -geometry +1+261 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_26.png" -geometry +66+261 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_27.png" -geometry +131+261 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_28.png" -geometry +196+261 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_29.png" -geometry +261+261 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_30.png" -geometry +326+261 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_31.png" -geometry +1+326 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_32.png" -geometry +66+326 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_33.png" -geometry +131+326 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_34.png" -geometry +196+326 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_35.png" -geometry +261+326 -composite \
      "$OUT/tmp/${rock}-${color}/${rock}-${color}_36.png" -geometry +326+326 -composite "$OUT/${rock}-reconstructed-bordered-${color}.png"
  done
done
magick -size 1644x1260 canvas:"rgb(245,245,245)" \
  "$OUT/basalt-reconstructed-bordered-green.png" -geometry +80+44 -composite \
  "$OUT/chalk-reconstructed-bordered-green.png" -geometry +471+44 -composite \
  "$OUT/chert-reconstructed-bordered-green.png" -geometry +862+44 -composite \
  "$OUT/granite-reconstructed-bordered-green.png" -geometry +1253+44 -composite \
  "$OUT/basalt-reconstructed-bordered-darkred.png" -geometry +80+459 -composite \
  "$OUT/chalk-reconstructed-bordered-darkred.png" -geometry +471+459 -composite \
  "$OUT/chert-reconstructed-bordered-darkred.png" -geometry +862+459 -composite \
  "$OUT/granite-reconstructed-bordered-darkred.png" -geometry +1253+459 -composite \
  "$OUT/basalt-reconstructed-bordered-yellow.png" -geometry +80+874 -composite \
  "$OUT/chalk-reconstructed-bordered-yellow.png" -geometry +471+874 -composite \
  "$OUT/chert-reconstructed-bordered-yellow.png" -geometry +862+874 -composite \
  "$OUT/granite-reconstructed-bordered-yellow.png" -geometry +1253+874 -composite "$OUT/multi-rock-color-comparison-sheet.png"

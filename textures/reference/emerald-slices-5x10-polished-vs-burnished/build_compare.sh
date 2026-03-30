#!/bin/zsh
set -euo pipefail
OUT="/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-polished-vs-burnished"
magick -size 1382x2140 canvas:"rgb(245,245,245)" \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-renders/basalt-reconstructed-bordered-green.png" -geometry +40+44 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-opacity-renders/basalt-reconstructed-bordered-green-40pct.png" -geometry +40+378 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-renders/chalk-reconstructed-bordered-green.png" -geometry +691+44 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-opacity-renders/chalk-reconstructed-bordered-green-40pct.png" -geometry +691+378 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-renders/chert-reconstructed-bordered-green.png" -geometry +1342+44 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-opacity-renders/chert-reconstructed-bordered-green-40pct.png" -geometry +1342+378 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-renders/granite-reconstructed-bordered-green.png" -geometry +1993+44 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-opacity-renders/granite-reconstructed-bordered-green-40pct.png" -geometry +1993+378 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-renders/basalt-reconstructed-bordered-darkred.png" -geometry +40+746 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-opacity-renders/basalt-reconstructed-bordered-darkred-40pct.png" -geometry +40+1080 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-renders/chalk-reconstructed-bordered-darkred.png" -geometry +691+746 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-opacity-renders/chalk-reconstructed-bordered-darkred-40pct.png" -geometry +691+1080 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-renders/chert-reconstructed-bordered-darkred.png" -geometry +1342+746 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-opacity-renders/chert-reconstructed-bordered-darkred-40pct.png" -geometry +1342+1080 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-renders/granite-reconstructed-bordered-darkred.png" -geometry +1993+746 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-opacity-renders/granite-reconstructed-bordered-darkred-40pct.png" -geometry +1993+1080 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-renders/basalt-reconstructed-bordered-yellow.png" -geometry +40+1448 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-opacity-renders/basalt-reconstructed-bordered-yellow-40pct.png" -geometry +40+1782 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-renders/chalk-reconstructed-bordered-yellow.png" -geometry +691+1448 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-opacity-renders/chalk-reconstructed-bordered-yellow-40pct.png" -geometry +691+1782 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-renders/chert-reconstructed-bordered-yellow.png" -geometry +1342+1448 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-opacity-renders/chert-reconstructed-bordered-yellow-40pct.png" -geometry +1342+1782 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-renders/granite-reconstructed-bordered-yellow.png" -geometry +1993+1448 -composite \
  "/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-opacity-renders/granite-reconstructed-bordered-yellow-40pct.png" -geometry +1993+1782 -composite "$OUT/polished-vs-burnished-sheet.png"
printf "Rows grouped by color: green, darkred, yellow\nWithin each group: top = 100%% polished, bottom = 40%% burnished\nCols: basalt, chalk, chert, granite\n" > "$OUT/order.txt"

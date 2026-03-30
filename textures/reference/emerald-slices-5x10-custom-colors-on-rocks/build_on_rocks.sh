#!/bin/zsh
set -euo pipefail
BASE="/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-custom-colors"
OUT="/Users/garretcoffman/Documents/VSMods/VSMineralMasonry/textures/reference/emerald-slices-5x10-custom-colors-on-rocks"
mkdir -p "$OUT/rocks" "$OUT/composited"
for rock in basalt chalk chert granite; do
  magick "/Applications/Vintage Story.app/assets/survival/textures/block/stone/rock/${rock}1.png" -filter point -resize 64x64! "$OUT/rocks/${rock}-64.png"
done
mkdir -p "$OUT/composited/lignite"
ffmpeg -y -loglevel error -i "$BASE/lignite-reconstructed.png" -i "$OUT/rocks/basalt-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/lignite/lignite-basalt.png"
ffmpeg -y -loglevel error -i "$BASE/lignite-reconstructed.png" -i "$OUT/rocks/chalk-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/lignite/lignite-chalk.png"
ffmpeg -y -loglevel error -i "$BASE/lignite-reconstructed.png" -i "$OUT/rocks/chert-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/lignite/lignite-chert.png"
ffmpeg -y -loglevel error -i "$BASE/lignite-reconstructed.png" -i "$OUT/rocks/granite-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/lignite/lignite-granite.png"
mkdir -p "$OUT/composited/quartz"
ffmpeg -y -loglevel error -i "$BASE/quartz-reconstructed.png" -i "$OUT/rocks/basalt-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/quartz/quartz-basalt.png"
ffmpeg -y -loglevel error -i "$BASE/quartz-reconstructed.png" -i "$OUT/rocks/chalk-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/quartz/quartz-chalk.png"
ffmpeg -y -loglevel error -i "$BASE/quartz-reconstructed.png" -i "$OUT/rocks/chert-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/quartz/quartz-chert.png"
ffmpeg -y -loglevel error -i "$BASE/quartz-reconstructed.png" -i "$OUT/rocks/granite-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/quartz/quartz-granite.png"
mkdir -p "$OUT/composited/magnetite"
ffmpeg -y -loglevel error -i "$BASE/magnetite-reconstructed.png" -i "$OUT/rocks/basalt-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/magnetite/magnetite-basalt.png"
ffmpeg -y -loglevel error -i "$BASE/magnetite-reconstructed.png" -i "$OUT/rocks/chalk-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/magnetite/magnetite-chalk.png"
ffmpeg -y -loglevel error -i "$BASE/magnetite-reconstructed.png" -i "$OUT/rocks/chert-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/magnetite/magnetite-chert.png"
ffmpeg -y -loglevel error -i "$BASE/magnetite-reconstructed.png" -i "$OUT/rocks/granite-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/magnetite/magnetite-granite.png"
mkdir -p "$OUT/composited/hematite"
ffmpeg -y -loglevel error -i "$BASE/hematite-reconstructed.png" -i "$OUT/rocks/basalt-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/hematite/hematite-basalt.png"
ffmpeg -y -loglevel error -i "$BASE/hematite-reconstructed.png" -i "$OUT/rocks/chalk-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/hematite/hematite-chalk.png"
ffmpeg -y -loglevel error -i "$BASE/hematite-reconstructed.png" -i "$OUT/rocks/chert-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/hematite/hematite-chert.png"
ffmpeg -y -loglevel error -i "$BASE/hematite-reconstructed.png" -i "$OUT/rocks/granite-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/hematite/hematite-granite.png"
mkdir -p "$OUT/composited/cinnabar"
ffmpeg -y -loglevel error -i "$BASE/cinnabar-reconstructed.png" -i "$OUT/rocks/basalt-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/cinnabar/cinnabar-basalt.png"
ffmpeg -y -loglevel error -i "$BASE/cinnabar-reconstructed.png" -i "$OUT/rocks/chalk-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/cinnabar/cinnabar-chalk.png"
ffmpeg -y -loglevel error -i "$BASE/cinnabar-reconstructed.png" -i "$OUT/rocks/chert-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/cinnabar/cinnabar-chert.png"
ffmpeg -y -loglevel error -i "$BASE/cinnabar-reconstructed.png" -i "$OUT/rocks/granite-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/cinnabar/cinnabar-granite.png"
mkdir -p "$OUT/composited/olivine"
ffmpeg -y -loglevel error -i "$BASE/olivine-reconstructed.png" -i "$OUT/rocks/basalt-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/olivine/olivine-basalt.png"
ffmpeg -y -loglevel error -i "$BASE/olivine-reconstructed.png" -i "$OUT/rocks/chalk-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/olivine/olivine-chalk.png"
ffmpeg -y -loglevel error -i "$BASE/olivine-reconstructed.png" -i "$OUT/rocks/chert-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/olivine/olivine-chert.png"
ffmpeg -y -loglevel error -i "$BASE/olivine-reconstructed.png" -i "$OUT/rocks/granite-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/olivine/olivine-granite.png"
mkdir -p "$OUT/composited/malachite"
ffmpeg -y -loglevel error -i "$BASE/malachite-reconstructed.png" -i "$OUT/rocks/basalt-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/malachite/malachite-basalt.png"
ffmpeg -y -loglevel error -i "$BASE/malachite-reconstructed.png" -i "$OUT/rocks/chalk-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/malachite/malachite-chalk.png"
ffmpeg -y -loglevel error -i "$BASE/malachite-reconstructed.png" -i "$OUT/rocks/chert-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/malachite/malachite-chert.png"
ffmpeg -y -loglevel error -i "$BASE/malachite-reconstructed.png" -i "$OUT/rocks/granite-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/malachite/malachite-granite.png"
mkdir -p "$OUT/composited/emerald"
ffmpeg -y -loglevel error -i "$BASE/emerald-reconstructed.png" -i "$OUT/rocks/basalt-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/emerald/emerald-basalt.png"
ffmpeg -y -loglevel error -i "$BASE/emerald-reconstructed.png" -i "$OUT/rocks/chalk-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/emerald/emerald-chalk.png"
ffmpeg -y -loglevel error -i "$BASE/emerald-reconstructed.png" -i "$OUT/rocks/chert-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/emerald/emerald-chert.png"
ffmpeg -y -loglevel error -i "$BASE/emerald-reconstructed.png" -i "$OUT/rocks/granite-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/emerald/emerald-granite.png"
mkdir -p "$OUT/composited/lapis_lazuli"
ffmpeg -y -loglevel error -i "$BASE/lapis_lazuli-reconstructed.png" -i "$OUT/rocks/basalt-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/lapis_lazuli/lapis_lazuli-basalt.png"
ffmpeg -y -loglevel error -i "$BASE/lapis_lazuli-reconstructed.png" -i "$OUT/rocks/chalk-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/lapis_lazuli/lapis_lazuli-chalk.png"
ffmpeg -y -loglevel error -i "$BASE/lapis_lazuli-reconstructed.png" -i "$OUT/rocks/chert-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/lapis_lazuli/lapis_lazuli-chert.png"
ffmpeg -y -loglevel error -i "$BASE/lapis_lazuli-reconstructed.png" -i "$OUT/rocks/granite-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/lapis_lazuli/lapis_lazuli-granite.png"
mkdir -p "$OUT/composited/sulfur"
ffmpeg -y -loglevel error -i "$BASE/sulfur-reconstructed.png" -i "$OUT/rocks/basalt-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/sulfur/sulfur-basalt.png"
ffmpeg -y -loglevel error -i "$BASE/sulfur-reconstructed.png" -i "$OUT/rocks/chalk-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/sulfur/sulfur-chalk.png"
ffmpeg -y -loglevel error -i "$BASE/sulfur-reconstructed.png" -i "$OUT/rocks/chert-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/sulfur/sulfur-chert.png"
ffmpeg -y -loglevel error -i "$BASE/sulfur-reconstructed.png" -i "$OUT/rocks/granite-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/sulfur/sulfur-granite.png"
mkdir -p "$OUT/composited/gold"
ffmpeg -y -loglevel error -i "$BASE/gold-reconstructed.png" -i "$OUT/rocks/basalt-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/gold/gold-basalt.png"
ffmpeg -y -loglevel error -i "$BASE/gold-reconstructed.png" -i "$OUT/rocks/chalk-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/gold/gold-chalk.png"
ffmpeg -y -loglevel error -i "$BASE/gold-reconstructed.png" -i "$OUT/rocks/chert-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/gold/gold-chert.png"
ffmpeg -y -loglevel error -i "$BASE/gold-reconstructed.png" -i "$OUT/rocks/granite-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/gold/gold-granite.png"
mkdir -p "$OUT/composited/silver"
ffmpeg -y -loglevel error -i "$BASE/silver-reconstructed.png" -i "$OUT/rocks/basalt-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/silver/silver-basalt.png"
ffmpeg -y -loglevel error -i "$BASE/silver-reconstructed.png" -i "$OUT/rocks/chalk-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/silver/silver-chalk.png"
ffmpeg -y -loglevel error -i "$BASE/silver-reconstructed.png" -i "$OUT/rocks/chert-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/silver/silver-chert.png"
ffmpeg -y -loglevel error -i "$BASE/silver-reconstructed.png" -i "$OUT/rocks/granite-64.png" -filter_complex "[1]scale=651:326:flags=neighbor[bg];[bg][0]overlay=0:0:format=auto" "$OUT/composited/silver/silver-granite.png"
magick -size 2644x3932 canvas:"rgb(245,245,245)" \
  "$OUT/composited/lignite/lignite-basalt.png" -geometry +20+10 -composite \
  "$OUT/composited/lignite/lignite-chalk.png" -geometry +671+10 -composite \
  "$OUT/composited/lignite/lignite-chert.png" -geometry +1322+10 -composite \
  "$OUT/composited/lignite/lignite-granite.png" -geometry +1973+10 -composite \
  "$OUT/composited/quartz/quartz-basalt.png" -geometry +20+336 -composite \
  "$OUT/composited/quartz/quartz-chalk.png" -geometry +671+336 -composite \
  "$OUT/composited/quartz/quartz-chert.png" -geometry +1322+336 -composite \
  "$OUT/composited/quartz/quartz-granite.png" -geometry +1973+336 -composite \
  "$OUT/composited/magnetite/magnetite-basalt.png" -geometry +20+662 -composite \
  "$OUT/composited/magnetite/magnetite-chalk.png" -geometry +671+662 -composite \
  "$OUT/composited/magnetite/magnetite-chert.png" -geometry +1322+662 -composite \
  "$OUT/composited/magnetite/magnetite-granite.png" -geometry +1973+662 -composite \
  "$OUT/composited/hematite/hematite-basalt.png" -geometry +20+988 -composite \
  "$OUT/composited/hematite/hematite-chalk.png" -geometry +671+988 -composite \
  "$OUT/composited/hematite/hematite-chert.png" -geometry +1322+988 -composite \
  "$OUT/composited/hematite/hematite-granite.png" -geometry +1973+988 -composite \
  "$OUT/composited/cinnabar/cinnabar-basalt.png" -geometry +20+1314 -composite \
  "$OUT/composited/cinnabar/cinnabar-chalk.png" -geometry +671+1314 -composite \
  "$OUT/composited/cinnabar/cinnabar-chert.png" -geometry +1322+1314 -composite \
  "$OUT/composited/cinnabar/cinnabar-granite.png" -geometry +1973+1314 -composite \
  "$OUT/composited/olivine/olivine-basalt.png" -geometry +20+1640 -composite \
  "$OUT/composited/olivine/olivine-chalk.png" -geometry +671+1640 -composite \
  "$OUT/composited/olivine/olivine-chert.png" -geometry +1322+1640 -composite \
  "$OUT/composited/olivine/olivine-granite.png" -geometry +1973+1640 -composite \
  "$OUT/composited/malachite/malachite-basalt.png" -geometry +20+1966 -composite \
  "$OUT/composited/malachite/malachite-chalk.png" -geometry +671+1966 -composite \
  "$OUT/composited/malachite/malachite-chert.png" -geometry +1322+1966 -composite \
  "$OUT/composited/malachite/malachite-granite.png" -geometry +1973+1966 -composite \
  "$OUT/composited/emerald/emerald-basalt.png" -geometry +20+2292 -composite \
  "$OUT/composited/emerald/emerald-chalk.png" -geometry +671+2292 -composite \
  "$OUT/composited/emerald/emerald-chert.png" -geometry +1322+2292 -composite \
  "$OUT/composited/emerald/emerald-granite.png" -geometry +1973+2292 -composite \
  "$OUT/composited/lapis_lazuli/lapis_lazuli-basalt.png" -geometry +20+2618 -composite \
  "$OUT/composited/lapis_lazuli/lapis_lazuli-chalk.png" -geometry +671+2618 -composite \
  "$OUT/composited/lapis_lazuli/lapis_lazuli-chert.png" -geometry +1322+2618 -composite \
  "$OUT/composited/lapis_lazuli/lapis_lazuli-granite.png" -geometry +1973+2618 -composite \
  "$OUT/composited/sulfur/sulfur-basalt.png" -geometry +20+2944 -composite \
  "$OUT/composited/sulfur/sulfur-chalk.png" -geometry +671+2944 -composite \
  "$OUT/composited/sulfur/sulfur-chert.png" -geometry +1322+2944 -composite \
  "$OUT/composited/sulfur/sulfur-granite.png" -geometry +1973+2944 -composite \
  "$OUT/composited/gold/gold-basalt.png" -geometry +20+3270 -composite \
  "$OUT/composited/gold/gold-chalk.png" -geometry +671+3270 -composite \
  "$OUT/composited/gold/gold-chert.png" -geometry +1322+3270 -composite \
  "$OUT/composited/gold/gold-granite.png" -geometry +1973+3270 -composite \
  "$OUT/composited/silver/silver-basalt.png" -geometry +20+3596 -composite \
  "$OUT/composited/silver/silver-chalk.png" -geometry +671+3596 -composite \
  "$OUT/composited/silver/silver-chert.png" -geometry +1322+3596 -composite \
  "$OUT/composited/silver/silver-granite.png" -geometry +1973+3596 -composite "$OUT/custom-colors-on-rocks-sheet.png"
printf "Rows: lignite, quartz, magnetite, hematite, cinnabar, olivine, malachite, emerald, lapis_lazuli, sulfur, gold, silver\nCols: basalt, chalk, chert, granite\n" > "$OUT/order.txt"

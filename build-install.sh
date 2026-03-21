#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Build + Install VSMineralMasonry into /Applications/Vintage Story.app/Mods
###############################################################################

MOD_ID="vsmineralmasonry"
PROJECT_DIR="VSMineralMasonry"
MOD_BUILD_DIR="$PROJECT_DIR/bin/Debug/Mods/mod"
VS_MODS_DIR="/Applications/Vintage Story.app/Mods"

rm -rf "$PROJECT_DIR/bin" "$PROJECT_DIR/obj"

echo "Deleting installed mod dir: $VS_MODS_DIR/$MOD_ID"
rm -rf "$VS_MODS_DIR/$MOD_ID"

if [[ -e "$VS_MODS_DIR/$MOD_ID" ]]; then
  echo "ERROR: Mod dir still exists: $VS_MODS_DIR/$MOD_ID" >&2
  exit 1
fi

dotnet build "$PROJECT_DIR/VSMineralMasonry.csproj"

if [[ ! -d "$MOD_BUILD_DIR" ]]; then
  echo "ERROR: Expected build output folder not found: $MOD_BUILD_DIR" >&2
  exit 1
fi

if [[ ! -w "$VS_MODS_DIR" ]]; then
  echo "Mods folder not writable, using sudo..."
  sudo mkdir -p "$VS_MODS_DIR"
  sudo rm -rf "$VS_MODS_DIR/$MOD_ID"
  sudo cp -R "$MOD_BUILD_DIR" "$VS_MODS_DIR/$MOD_ID"
else
  mkdir -p "$VS_MODS_DIR"
  rm -rf "$VS_MODS_DIR/$MOD_ID"
  cp -R "$MOD_BUILD_DIR" "$VS_MODS_DIR/$MOD_ID"
fi

echo "Installed '$MOD_ID' to:"
echo "  $VS_MODS_DIR/$MOD_ID"

if [[ -n "${VINTAGE_STORY:-}" ]]; then
  open "$VINTAGE_STORY"
fi

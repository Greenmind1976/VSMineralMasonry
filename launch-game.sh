#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Launch Vintage Story 1.22.0-rc.8 without rebuilding or reinstalling mods
###############################################################################

VS_APP_DIR="/Applications/Vintage Story 1.22.0-rc.8.app"
VS_LAUNCHER="$HOME/bin/vs-1.22.0-rc.8"

if [[ ! -d "$VS_APP_DIR" ]]; then
  echo "ERROR: Vintage Story app not found: $VS_APP_DIR" >&2
  exit 1
fi

if [[ ! -x "$VS_LAUNCHER" ]]; then
  echo "ERROR: RC launcher not found or not executable: $VS_LAUNCHER" >&2
  exit 1
fi

echo "Launching Vintage Story 1.22.0-rc.8 via:"
echo "  $VS_LAUNCHER"
"$VS_LAUNCHER" >/dev/null 2>&1 &

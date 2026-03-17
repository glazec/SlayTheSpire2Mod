#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

MODS_PATH="$HOME/Library/Application Support/Steam/steamapps/common/Slay the Spire 2/SlayTheSpire2.app/Contents/MacOS/mods"
SOURCE_MODS="${SCRIPT_DIR}/mods"

echo "1. Pulling latest mods..."
BRANCH=$(git branch --show-current)
git pull origin "$BRANCH"

echo "2. Ensuring mods path exists..."
if [[ ! -d "$MODS_PATH" ]]; then
  echo "   Mods path does not exist, creating: $MODS_PATH"
  mkdir -p "$MODS_PATH"
else
  echo "   Mods path exists."
fi

echo "3. Copying mods (overwriting existing)..."
if [[ -d "$SOURCE_MODS" ]]; then
  rsync -a --delete "$SOURCE_MODS/" "$MODS_PATH/"
  echo "Done. Mods copied to: $MODS_PATH"
  osascript -e 'display notification "Mods updated to game folder." with title "Slay the Spire 2 Mods"'
else
  echo "Error: Source mods directory not found: $SOURCE_MODS" >&2
  exit 1
fi

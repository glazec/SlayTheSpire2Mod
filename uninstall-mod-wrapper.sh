#!/usr/bin/env bash
set -e

APP_PATH="$HOME/Library/Application Support/Steam/steamapps/common/Slay the Spire 2/SlayTheSpire2.app"
MACOS_DIR="$APP_PATH/Contents/MacOS"
INFO_PLIST="$APP_PATH/Contents/Info.plist"
SUPPORT_DIR="$HOME/Library/Application Support/SlayTheSpire2Mod"
PLIST="$HOME/Library/LaunchAgents/com.slaythespire2mod.checkwrapper.plist"

# Restore real binary if we have a backup
if [[ -f "$INFO_PLIST" ]]; then
  BINARY=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "$INFO_PLIST")
  BINARY_PATH="$MACOS_DIR/$BINARY"
  REAL_PATH="$MACOS_DIR/$BINARY.real"

  if [[ -f "$REAL_PATH" ]]; then
    echo "Restoring original game executable..."
    cp "$REAL_PATH" "$BINARY_PATH"
    rm -f "$REAL_PATH"
    echo "Restored $BINARY."
  fi
fi

# Unload and remove LaunchAgent
if [[ -f "$PLIST" ]]; then
  launchctl unload "$PLIST" 2>/dev/null || true
  rm -f "$PLIST"
  echo "Removed background check (LaunchAgent)."
fi

# Remove check script and support files
rm -f "$SUPPORT_DIR/STS2-mods-check-wrapper.sh"
rm -f "$SUPPORT_DIR/wrapper-installed"
rm -f "$SUPPORT_DIR/repo-path"
if [[ -d "$SUPPORT_DIR" ]] && [[ -z "$(ls -A "$SUPPORT_DIR" 2>/dev/null)" ]]; then
  rmdir "$SUPPORT_DIR" 2>/dev/null || true
fi

echo "Auto-update feature uninstalled. You can still run ./update-mods.sh manually."

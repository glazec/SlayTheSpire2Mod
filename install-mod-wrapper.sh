#!/usr/bin/env bash
set -e

APP_PATH="$HOME/Library/Application Support/Steam/steamapps/common/Slay the Spire 2/SlayTheSpire2.app"
MACOS_DIR="$APP_PATH/Contents/MacOS"
INFO_PLIST="$APP_PATH/Contents/Info.plist"
SUPPORT_DIR="$HOME/Library/Application Support/SlayTheSpire2Mod"
WRAPPER_MAGIC="SlayTheSpire2Mod wrapper"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -d "$APP_PATH" ]]; then
  echo "Error: Slay the Spire 2 app not found at: $APP_PATH" >&2
  exit 1
fi

if [[ ! -f "$INFO_PLIST" ]]; then
  echo "Error: Info.plist not found at: $INFO_PLIST" >&2
  exit 1
fi

BINARY=$(/usr/libexec/PlistBuddy -c "Print :CFBundleExecutable" "$INFO_PLIST")
BINARY_PATH="$MACOS_DIR/$BINARY"
REAL_PATH="$MACOS_DIR/$BINARY.real"
PLIST="$HOME/Library/LaunchAgents/com.slaythespire2mod.checkwrapper.plist"

# Uninstall existing wrapper first so we always install the latest version
if [[ -f "$REAL_PATH" ]]; then
  echo "Removing existing wrapper..."
  cp "$REAL_PATH" "$BINARY_PATH"
  rm -f "$REAL_PATH"
fi
if [[ -f "$PLIST" ]]; then
  launchctl unload "$PLIST" 2>/dev/null || true
  rm -f "$PLIST"
fi
rm -f "$SUPPORT_DIR/STS2-mods-check-wrapper.sh" "$SUPPORT_DIR/wrapper-installed" "$SUPPORT_DIR/repo-path" "$SUPPORT_DIR/game-binary.info"
if [[ -d "$SUPPORT_DIR" ]] && [[ -z "$(ls -A "$SUPPORT_DIR" 2>/dev/null)" ]]; then
  rmdir "$SUPPORT_DIR" 2>/dev/null || true
fi

# Backup real binary if not already backed up
if [[ ! -f "$REAL_PATH" ]]; then
  if [[ ! -f "$BINARY_PATH" ]]; then
    echo "Error: Executable not found: $BINARY_PATH" >&2
    exit 1
  fi
  echo "Backing up real binary to $BINARY.real"
  cp "$BINARY_PATH" "$REAL_PATH"
fi

echo "Installing wrapper as $BINARY"
mkdir -p "$SUPPORT_DIR"
echo "$REPO_DIR" > "$SUPPORT_DIR/repo-path"
echo "$BINARY_PATH" > "$SUPPORT_DIR/wrapper-installed"

cat > "$BINARY_PATH" << 'WRAPPER_EOF'
#!/usr/bin/env bash
# SlayTheSpire2Mod wrapper
SUPPORT_DIR="$HOME/Library/Application Support/SlayTheSpire2Mod"
CHECK_SCRIPT="$SUPPORT_DIR/STS2-mods-check-wrapper.sh"
[[ -x "$CHECK_SCRIPT" ]] && "$CHECK_SCRIPT" || true
BINARY_NAME="BINARY_PLACEHOLDER"
REAL_PATH="$(dirname "$0")/${BINARY_NAME}.real"
INFO_FILE="$SUPPORT_DIR/game-binary.info"
if [[ -f "$INFO_FILE" ]]; then
  if [[ ! -f "$REAL_PATH" ]]; then
    /usr/bin/osascript -e 'display dialog "Game was updated. Re-run install-mod-wrapper.sh from the SlayTheSpire2Mod repo, then start the game again." with title "Slay the Spire 2 Mods" buttons {"OK"} default button 1'
    exit 1
  fi
  SAVED=$(cat "$INFO_FILE")
  CURRENT=$(stat -f '%m %z' "$REAL_PATH" 2>/dev/null || true)
  if [[ "$SAVED" != "$CURRENT" ]]; then
    /usr/bin/osascript -e 'display dialog "Game was updated. Re-run install-mod-wrapper.sh from the SlayTheSpire2Mod repo, then start the game again." with title "Slay the Spire 2 Mods" buttons {"OK"} default button 1'
    exit 1
  fi
fi
REPO_PATH_FILE="$SUPPORT_DIR/repo-path"
if [[ -f "$REPO_PATH_FILE" ]]; then
  REPO_PATH=$(cat "$REPO_PATH_FILE")
  if [[ -x "$REPO_PATH/update-mods.sh" ]]; then
    "$REPO_PATH/update-mods.sh" || true
  fi
fi
exec "$REAL_PATH" "$@"
WRAPPER_EOF

# Replace placeholder with actual binary name
sed -i '' "s/BINARY_PLACEHOLDER/$BINARY/" "$BINARY_PATH"

chmod +x "$BINARY_PATH"
stat -f '%m %z' "$REAL_PATH" > "$SUPPORT_DIR/game-binary.info"
echo "Wrapper installed. Mods will update every time you launch the game."

# Install check script and LaunchAgent
CHECK_SCRIPT="$SUPPORT_DIR/STS2-mods-check-wrapper.sh"
cat > "$CHECK_SCRIPT" << 'CHECK_EOF'
#!/usr/bin/env bash
MARKER="$HOME/Library/Application Support/SlayTheSpire2Mod/wrapper-installed"
[[ ! -f "$MARKER" ]] && exit 0
EXE=$(cat "$MARKER")
[[ ! -f "$EXE" ]] && exit 0
if head -1 "$EXE" 2>/dev/null | grep -q '^#!'; then
  grep -q "SlayTheSpire2Mod wrapper" "$EXE" 2>/dev/null && exit 0
fi
osascript -e 'display notification "Slay the Spire 2 mod auto-update was removed (e.g. by a Steam update). Re-run install-mod-wrapper.sh from the SlayTheSpire2Mod repo to restore." with title "Slay the Spire 2 Mods"'
rm -f "$MARKER"
exit 0
CHECK_EOF
chmod +x "$CHECK_SCRIPT"

cat > "$PLIST" << PLIST_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.slaythespire2mod.checkwrapper</string>
  <key>ProgramArguments</key>
  <array>
    <string>$CHECK_SCRIPT</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
PLIST_EOF

launchctl unload "$PLIST" 2>/dev/null || true
launchctl load "$PLIST"
echo "Background check installed: you'll get a notification if Steam overwrites the wrapper."
echo "Done. Open Slay the Spire 2 as usual; mods will update every time you launch."

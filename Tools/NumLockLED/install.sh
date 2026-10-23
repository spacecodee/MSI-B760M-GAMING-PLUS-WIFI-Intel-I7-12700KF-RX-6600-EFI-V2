#!/bin/bash
# Build numled and install it as a per-user LaunchAgent that keeps the Num Lock LED on.
set -euo pipefail

LABEL="local.numled"
SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
BIN="$BIN_DIR/numled"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/numled.log"

command -v swiftc >/dev/null || { echo "swiftc not found. Install it with: xcode-select --install"; exit 1; }

echo "Building numled..."
mkdir -p "$BIN_DIR" "$(dirname "$PLIST")"
swiftc -O "$SRC_DIR/numled.swift" -o "$BIN"
# Input Monitoring (TCC) needs a code identity; swiftc leaves Intel binaries unsigned.
codesign --force --sign - --identifier "$LABEL" "$BIN"

echo "Writing $PLIST..."
cat > "$PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$BIN</string>
        <string>--daemon</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ProcessType</key>
    <string>Background</string>
    <key>StandardOutPath</key>
    <string>$LOG</string>
    <key>StandardErrorPath</key>
    <string>$LOG</string>
</dict>
</plist>
PLIST

echo "Loading LaunchAgent..."
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"

echo "Done. numled starts at every login."
echo "Required: enable numled in System Settings > Privacy & Security > Input Monitoring."
echo "Without it the LED never turns on. Re-enable it after every reinstall (the binary changes)."

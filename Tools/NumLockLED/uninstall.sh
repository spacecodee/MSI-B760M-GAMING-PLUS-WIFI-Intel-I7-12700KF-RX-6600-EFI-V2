#!/bin/bash
# Stop and remove the numled LaunchAgent and binary.
set -euo pipefail

LABEL="local.numled"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
rm -f "$PLIST" "$HOME/.local/bin/numled" "$HOME/Library/Logs/numled.log"
echo "numled removed."

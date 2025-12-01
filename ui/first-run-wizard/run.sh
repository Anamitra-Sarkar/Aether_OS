#!/bin/bash
# =============================================================================
# AetherOS First Run Wizard Launcher
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIRST_RUN_MARKER="$HOME/.config/aetheros-first-run-complete"

# Check if first run is already complete
if [[ -f "$FIRST_RUN_MARKER" ]]; then
    echo "First run already completed"
    exit 0
fi

# Run the wizard
if command -v qmlscene &>/dev/null; then
    qmlscene "$SCRIPT_DIR/main.qml"
elif command -v qml &>/dev/null; then
    qml "$SCRIPT_DIR/main.qml"
else
    echo "Error: QML runtime not found. Please install qt5-qmlscene or qml-qt5."
    # Fall back to zenity if available
    if command -v zenity &>/dev/null; then
        zenity --info --title="Welcome to AetherOS" \
            --text="Welcome to AetherOS!\n\nPlease install qt5-qmlscene for the full setup experience.\n\nYou can configure settings in System Settings."
    fi
    exit 1
fi

# Mark first run as complete
mkdir -p "$(dirname "$FIRST_RUN_MARKER")"
touch "$FIRST_RUN_MARKER"

#!/bin/bash
# =============================================================================
# AetherOS Control Center Launcher
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check for QML runtime
if command -v qmlscene &>/dev/null; then
    exec qmlscene "$SCRIPT_DIR/main.qml"
elif command -v qml &>/dev/null; then
    exec qml "$SCRIPT_DIR/main.qml"
else
    echo "Error: QML runtime not found. Please install qt5-qmlscene or qml-qt5."
    exit 1
fi

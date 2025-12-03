#!/bin/bash
# =============================================================================
# Aether Quick Actions Launcher
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run the QML application
qmlscene "$SCRIPT_DIR/main.qml" 2>/dev/null || {
    # Try alternative methods
    if command -v qml &>/dev/null; then
        qml "$SCRIPT_DIR/main.qml"
    else
        echo "Error: QML runtime not found. Install qtdeclarative5-dev-tools"
        exit 1
    fi
}

#!/bin/bash
# =============================================================================
# AetherOS Updater Launcher
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$HOME/.local/share/aetheros/logs"
LOG_FILE="$LOG_DIR/updater.log"

# =============================================================================
# Logging
# =============================================================================
log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] [updater] $1"
    echo "$message"
    mkdir -p "$LOG_DIR"
    echo "$message" >> "$LOG_FILE" 2>/dev/null || true
}

log_error() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] [updater] ERROR: $1"
    echo "$message" >&2
    mkdir -p "$LOG_DIR"
    echo "$message" >> "$LOG_FILE" 2>/dev/null || true
}

log "Starting Aether Updater..."

# Run the QML UI
if command -v qmlscene &>/dev/null; then
    log "Using qmlscene"
    qmlscene "$SCRIPT_DIR/main.qml" 2>&1 | tee -a "$LOG_FILE" || {
        log_error "qmlscene exited with error"
        exit 1
    }
elif command -v qml &>/dev/null; then
    log "Using qml"
    qml "$SCRIPT_DIR/main.qml" 2>&1 | tee -a "$LOG_FILE" || {
        log_error "qml exited with error"
        exit 1
    }
else
    log_error "QML runtime not found. Please install qt5-qmlscene or qml-qt5."
    # Fall back to terminal updates
    echo "Aether Updater requires QML runtime."
    echo ""
    echo "For now, you can update via terminal:"
    echo "  sudo apt update && sudo apt upgrade"
    echo "  flatpak update"
    echo ""
    echo "Or open Discover for graphical updates."
    exit 1
fi

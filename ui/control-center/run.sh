#!/bin/bash
# =============================================================================
# AetherOS Control Center Launcher
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$HOME/.local/share/aetheros/logs"
LOG_FILE="$LOG_DIR/control-center.log"

# =============================================================================
# Logging
# =============================================================================
log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] [control-center] $1"
    echo "$message"
    mkdir -p "$LOG_DIR"
    echo "$message" >> "$LOG_FILE" 2>/dev/null || true
}

log_error() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] [control-center] ERROR: $1"
    echo "$message" >&2
    mkdir -p "$LOG_DIR"
    echo "$message" >> "$LOG_FILE" 2>/dev/null || true
}

log "Starting Control Center..."

# Check for QML runtime
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
    exit 1
fi

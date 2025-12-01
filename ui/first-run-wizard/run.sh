#!/bin/bash
# =============================================================================
# AetherOS First Run Wizard Launcher
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIRST_RUN_MARKER="$HOME/.config/aetheros-first-run-complete"
LOG_DIR="$HOME/.local/share/aetheros/logs"
LOG_FILE="$LOG_DIR/first-run-wizard.log"

# =============================================================================
# Logging
# =============================================================================
log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] [first-run-wizard] $1"
    echo "$message"
    mkdir -p "$LOG_DIR"
    echo "$message" >> "$LOG_FILE" 2>/dev/null || true
}

log_error() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] [first-run-wizard] ERROR: $1"
    echo "$message" >&2
    mkdir -p "$LOG_DIR"
    echo "$message" >> "$LOG_FILE" 2>/dev/null || true
}

# Check if first run is already complete
if [[ -f "$FIRST_RUN_MARKER" ]]; then
    log "First run already completed"
    exit 0
fi

log "Starting First Run Wizard..."

# Run the wizard
if command -v qmlscene &>/dev/null; then
    log "Using qmlscene to run wizard"
    qmlscene "$SCRIPT_DIR/main.qml" 2>&1 | tee -a "$LOG_FILE" || {
        log_error "qmlscene exited with error"
        exit 1
    }
elif command -v qml &>/dev/null; then
    log "Using qml to run wizard"
    qml "$SCRIPT_DIR/main.qml" 2>&1 | tee -a "$LOG_FILE" || {
        log_error "qml exited with error"
        exit 1
    }
else
    log_error "QML runtime not found. Please install qt5-qmlscene or qml-qt5."
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
log "First run wizard completed successfully"

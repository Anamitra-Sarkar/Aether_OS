#!/bin/bash
# =============================================================================
# AetherOS Latte Dock Layout Application Script
# Applies the AetherOS Latte Dock layout
# =============================================================================

set -euo pipefail

# Configuration
USER_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
LAYOUT_NAME="AetherOS"
LAYOUT_FILE="AetherOS.layout.latte"

log() {
    echo "[AetherOS] $1"
}

log_success() {
    echo "[AetherOS] ✓ $1"
}

log_error() {
    echo "[AetherOS] ✗ $1" >&2
}

# Check if Latte Dock is installed
if ! command -v latte-dock &>/dev/null; then
    log_error "Latte Dock is not installed"
    log "Install with: sudo apt install latte-dock"
    exit 1
fi

# Create latte config directory
mkdir -p "$USER_CONFIG/latte"

# Find layout file
LAYOUT_SOURCE=""
if [[ -f "/etc/skel/.config/latte/$LAYOUT_FILE" ]]; then
    LAYOUT_SOURCE="/etc/skel/.config/latte/$LAYOUT_FILE"
elif [[ -f "/usr/share/aetheros/latte/$LAYOUT_FILE" ]]; then
    LAYOUT_SOURCE="/usr/share/aetheros/latte/$LAYOUT_FILE"
elif [[ -f "$(dirname "$0")/../configs/kde/latte/$LAYOUT_FILE" ]]; then
    LAYOUT_SOURCE="$(dirname "$0")/../configs/kde/latte/$LAYOUT_FILE"
fi

if [[ -z "$LAYOUT_SOURCE" ]]; then
    log_error "Layout file not found: $LAYOUT_FILE"
    exit 1
fi

log "Found layout at: $LAYOUT_SOURCE"

# Copy layout to user config
cp "$LAYOUT_SOURCE" "$USER_CONFIG/latte/"
log "Layout copied to user config"

# Kill existing Latte instance if running
if pgrep -x latte-dock > /dev/null; then
    log "Stopping existing Latte Dock instance..."
    killall latte-dock 2>/dev/null || true
    sleep 1
fi

# Import and apply layout
log "Importing layout..."
latte-dock --import-layout "$USER_CONFIG/latte/$LAYOUT_FILE" 2>/dev/null || true

# Start Latte with the new layout
log "Starting Latte Dock with AetherOS layout..."
latte-dock --layout "$LAYOUT_NAME" &

sleep 2

if pgrep -x latte-dock > /dev/null; then
    log_success "Latte Dock is now running with AetherOS layout"
else
    log_error "Failed to start Latte Dock"
    exit 1
fi

log_success "Layout application complete!"

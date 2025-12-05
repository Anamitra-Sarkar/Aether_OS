#!/bin/bash
# =============================================================================
# AetherOS Command Handler
# Helper script for Control Center to execute commands
# =============================================================================

set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Execute command based on first argument
case "${1:-}" in
    focus-toggle)
        "$SCRIPTS_DIR/aether-focus-mode.sh" toggle
        ;;
    theme-schedule-enable)
        "$SCRIPTS_DIR/aether-theme-scheduler.sh" enable
        ;;
    theme-schedule-disable)
        "$SCRIPTS_DIR/aether-theme-scheduler.sh" disable
        ;;
    sounds-enable)
        "$SCRIPTS_DIR/aether-sounds.sh" enable
        ;;
    sounds-disable)
        "$SCRIPTS_DIR/aether-sounds.sh" disable
        ;;
    *)
        echo "Usage: $0 {focus-toggle|theme-schedule-enable|theme-schedule-disable|sounds-enable|sounds-disable}"
        exit 1
        ;;
esac

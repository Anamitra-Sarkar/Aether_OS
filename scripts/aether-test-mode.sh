#!/bin/bash
# =============================================================================
# AetherOS Test Mode Handler
# Checks for test mode flag and runs diagnostics on first login if enabled
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
TEST_MODE_FLAG="/etc/aetheros/test-mode"
TEST_MODE_RAN="${HOME}/.local/share/aetheros/.test-mode-ran"
DIAGNOSTICS_SCRIPT="/usr/share/aetheros/scripts/aether-diagnostics.sh"

# Fallback to local script if not installed
if [[ ! -f "$DIAGNOSTICS_SCRIPT" ]]; then
    DIAGNOSTICS_SCRIPT="$(dirname "$(dirname "$(readlink -f "$0")")")/scripts/aether-diagnostics.sh"
fi

# =============================================================================
# Check if test mode is enabled
# =============================================================================
is_test_mode_enabled() {
    [[ -f "$TEST_MODE_FLAG" ]]
}

# =============================================================================
# Check if test mode diagnostics already ran
# =============================================================================
has_test_mode_ran() {
    [[ -f "$TEST_MODE_RAN" ]]
}

# =============================================================================
# Mark test mode as ran
# =============================================================================
mark_test_mode_ran() {
    mkdir -p "$(dirname "$TEST_MODE_RAN")"
    touch "$TEST_MODE_RAN"
}

# =============================================================================
# Run diagnostics and show results
# =============================================================================
run_diagnostics() {
    local log_file
    log_file="${HOME}/.local/share/aetheros/diagnostics/test-mode-$(date +%Y%m%d-%H%M%S).log"
    
    # Run diagnostics
    if [[ -f "$DIAGNOSTICS_SCRIPT" ]]; then
        bash "$DIAGNOSTICS_SCRIPT" 2>&1 | tee "$log_file"
        local exit_code=${PIPESTATUS[0]}
        
        # Show result in dialog
        show_result_dialog "$exit_code" "$log_file"
    else
        show_error_dialog "Diagnostics script not found: $DIAGNOSTICS_SCRIPT"
    fi
}

# =============================================================================
# Show result dialog
# =============================================================================
show_result_dialog() {
    local exit_code=$1
    local log_file=$2
    
    if [[ $exit_code -eq 0 ]]; then
        local title="AetherOS Test Mode - Diagnostics Passed"
        local message="All system diagnostics completed successfully!\n\nThe system is ready for testing.\n\nLog saved to:\n$log_file"
    else
        local title="AetherOS Test Mode - Diagnostics Completed"
        local message="System diagnostics completed with some warnings.\n\nPlease review the log for details.\n\nLog saved to:\n$log_file"
    fi
    
    # Try different dialog tools in order of preference
    if command -v kdialog &>/dev/null; then
        kdialog --title "$title" --msgbox "$message"
    elif command -v zenity &>/dev/null; then
        zenity --info --title="$title" --text="$message" --width=400
    elif command -v notify-send &>/dev/null; then
        notify-send "$title" "$message"
    else
        # Fallback to terminal output
        echo ""
        echo "=========================================="
        echo "$title"
        echo "=========================================="
        echo -e "$message"
        echo ""
    fi
}

# =============================================================================
# Show error dialog
# =============================================================================
show_error_dialog() {
    local message=$1
    
    if command -v kdialog &>/dev/null; then
        kdialog --error "$message"
    elif command -v zenity &>/dev/null; then
        zenity --error --text="$message"
    elif command -v notify-send &>/dev/null; then
        notify-send "AetherOS Test Mode Error" "$message"
    else
        echo "ERROR: $message" >&2
    fi
}

# =============================================================================
# Main
# =============================================================================
main() {
    # Check if test mode is enabled
    if ! is_test_mode_enabled; then
        # Test mode not enabled, exit silently
        exit 0
    fi
    
    # Check if diagnostics already ran for this user
    if has_test_mode_ran; then
        # Already ran, exit silently
        exit 0
    fi
    
    # Run diagnostics and show results
    run_diagnostics
    
    # Mark as ran
    mark_test_mode_ran
}

main "$@"

#!/bin/bash
# =============================================================================
# AetherOS Focus Mode / Do Not Disturb
# Toggles KDE's notification Do Not Disturb mode
# =============================================================================

set -euo pipefail

# Toggle Do Not Disturb via KDE's notification settings
toggle_focus_mode() {
    # Use qdbus to interact with KDE notification settings
    if command -v qdbus &>/dev/null; then
        # Try to toggle notifications via KDE's org.freedesktop.Notifications
        # Get current state
        local current_state
        current_state=$(kreadconfig5 --file knotificationmanagerrc --group DoNotDisturb --key Enabled 2>/dev/null || echo "false")
        
        if [[ "$current_state" == "true" ]]; then
            # Turn off Focus Mode
            kwriteconfig5 --file knotificationmanagerrc --group DoNotDisturb --key Enabled false
            echo "Focus Mode: OFF"
            notify-send "Focus Mode" "Notifications enabled" -i preferences-desktop-notification -t 3000 || true
        else
            # Turn on Focus Mode
            kwriteconfig5 --file knotificationmanagerrc --group DoNotDisturb --key Enabled true
            echo "Focus Mode: ON"
            # Note: Don't send notification when enabling DND
        fi
        
        # Reload notification settings
        qdbus org.kde.Plasmashell /PlasmaShell evaluateScript 'notificationSettings.reload()' 2>/dev/null || true
    else
        echo "Error: qdbus not found. Please install KDE tools."
        exit 1
    fi
}

# Get current state
get_focus_state() {
    local state
    state=$(kreadconfig5 --file knotificationmanagerrc --group DoNotDisturb --key Enabled 2>/dev/null || echo "false")
    echo "$state"
}

# Main
case "${1:-toggle}" in
    toggle)
        toggle_focus_mode
        ;;
    on)
        kwriteconfig5 --file knotificationmanagerrc --group DoNotDisturb --key Enabled true
        echo "Focus Mode: ON"
        ;;
    off)
        kwriteconfig5 --file knotificationmanagerrc --group DoNotDisturb --key Enabled false
        echo "Focus Mode: OFF"
        notify-send "Focus Mode" "Notifications enabled" -i preferences-desktop-notification -t 3000 || true
        ;;
    status)
        get_focus_state
        ;;
    *)
        echo "Usage: $0 {toggle|on|off|status}"
        exit 1
        ;;
esac

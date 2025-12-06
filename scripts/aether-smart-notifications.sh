#!/bin/bash
# =============================================================================
# AetherOS Smart Notifications
# Automatically mutes notifications during gaming, presentations, etc.
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
SMART_NOTIF_FILE="$CONFIG_DIR/.aether-smart-notifications"

# =============================================================================
# Detection Functions
# =============================================================================

# Check if gaming (Steam, Lutris, or known games)
is_gaming() {
    if command -v wmctrl &>/dev/null; then
        local windows
        windows=$(wmctrl -l | awk '{print tolower($0)}')
        
        # Check for gaming clients and common games
        if echo "$windows" | grep -qE "steam|lutris|minecraft|wine|proton"; then
            return 0
        fi
    fi
    
    # Check for gaming processes
    if pgrep -x "steam" >/dev/null || pgrep -x "lutris" >/dev/null; then
        return 0
    fi
    
    return 1
}

# Check if watching fullscreen video
is_watching_video() {
    if command -v wmctrl &>/dev/null; then
        local windows
        windows=$(wmctrl -l | awk '{print tolower($0)}')
        
        # Check for video players and streaming sites
        if echo "$windows" | grep -qE "youtube|netflix|vlc|mpv|video|movie"; then
            # Also check if fullscreen
            if is_fullscreen_active; then
                return 0
            fi
        fi
    fi
    
    return 1
}

# Check if in presentation mode
is_presenting() {
    # Check for presentation software
    if command -v wmctrl &>/dev/null; then
        local windows
        windows=$(wmctrl -l | awk '{print tolower($0)}')
        
        if echo "$windows" | grep -qE "impress|powerpoint|presentation|libreoffice.*present|keynote"; then
            return 0
        fi
    fi
    
    # Check for screen sharing (common meeting apps)
    if pgrep -f "zoom|teams|meet|webex" >/dev/null; then
        return 0
    fi
    
    return 1
}

# Check if in meeting
is_in_meeting() {
    if command -v wmctrl &>/dev/null; then
        local windows
        windows=$(wmctrl -l | awk '{print tolower($0)}')
        
        # Check for meeting applications
        if echo "$windows" | grep -qE "zoom|microsoft teams|google meet|webex|discord|slack call"; then
            return 0
        fi
    fi
    
    return 1
}

# Check if any window is fullscreen
is_fullscreen_active() {
    if command -v qdbus &>/dev/null; then
        local windows
        windows=$(qdbus org.kde.KWin /KWin org.kde.KWin.windowList 2>/dev/null || echo "")
        for win in $windows; do
            local state
            state=$(qdbus org.kde.KWin "/windows/$win" org.kde.KWin.Window.fullScreen 2>/dev/null || echo "false")
            if [ "$state" = "true" ]; then
                return 0
            fi
        done
    fi
    return 1
}

# =============================================================================
# Notification Control
# =============================================================================

enable_do_not_disturb() {
    kwriteconfig5 --file knotificationmanagerrc --group DoNotDisturb --key Enabled true
    qdbus org.kde.Plasmashell /PlasmaShell evaluateScript 'notificationSettings.reload()' 2>/dev/null || true
}

disable_do_not_disturb() {
    kwriteconfig5 --file knotificationmanagerrc --group DoNotDisturb --key Enabled false
    qdbus org.kde.Plasmashell /PlasmaShell evaluateScript 'notificationSettings.reload()' 2>/dev/null || true
}

is_do_not_disturb_enabled() {
    local state
    state=$(kreadconfig5 --file knotificationmanagerrc --group DoNotDisturb --key Enabled 2>/dev/null || echo "false")
    [ "$state" = "true" ]
}

# =============================================================================
# Smart Monitoring
# =============================================================================

smart_monitor() {
    echo "=== AetherOS Smart Notifications ==="
    echo "Monitoring for gaming, presentations, meetings..."
    echo "Press Ctrl+C to stop"
    echo ""
    
    local was_suppressed=false
    local suppress_reason=""
    
    while true; do
        local should_suppress=false
        local new_reason=""
        
        # Check all conditions
        if is_gaming; then
            should_suppress=true
            new_reason="gaming"
        elif is_watching_video; then
            should_suppress=true
            new_reason="watching video"
        elif is_presenting; then
            should_suppress=true
            new_reason="presenting"
        elif is_in_meeting; then
            should_suppress=true
            new_reason="in meeting"
        fi
        
        # Take action if state changed
        if [ "$should_suppress" = "true" ] && [ "$was_suppressed" = "false" ]; then
            echo "[$(date '+%H:%M:%S')] Detected: $new_reason - Muting notifications"
            enable_do_not_disturb
            was_suppressed=true
            suppress_reason="$new_reason"
        elif [ "$should_suppress" = "false" ] && [ "$was_suppressed" = "true" ]; then
            echo "[$(date '+%H:%M:%S')] Stopped: $suppress_reason - Unmuting notifications"
            disable_do_not_disturb
            was_suppressed=false
            suppress_reason=""
        fi
        
        sleep 10
    done
}

# =============================================================================
# Enable/Disable
# =============================================================================

enable_smart_notifications() {
    echo "enabled" > "$SMART_NOTIF_FILE"
    echo "✓ Smart Notifications enabled"
    echo ""
    echo "Notifications will automatically mute during:"
    echo "  - Gaming (Steam, Lutris, Wine games)"
    echo "  - Fullscreen videos (YouTube, Netflix, VLC)"
    echo "  - Presentations (LibreOffice Impress, PowerPoint)"
    echo "  - Meetings (Zoom, Teams, Meet, Webex)"
    echo ""
    echo "To start monitoring, run:"
    echo "  $(basename "$0") monitor"
}

disable_smart_notifications() {
    rm -f "$SMART_NOTIF_FILE"
    echo "✓ Smart Notifications disabled"
}

is_enabled() {
    [ -f "$SMART_NOTIF_FILE" ]
}

# =============================================================================
# Status
# =============================================================================

show_status() {
    echo "=== Smart Notifications Status ==="
    echo ""
    
    if is_enabled; then
        echo "Smart Notifications: ENABLED"
    else
        echo "Smart Notifications: DISABLED"
    fi
    echo ""
    
    echo "Current conditions:"
    echo -n "  Gaming: "
    is_gaming && echo "YES" || echo "no"
    
    echo -n "  Watching video: "
    is_watching_video && echo "YES" || echo "no"
    
    echo -n "  Presenting: "
    is_presenting && echo "YES" || echo "no"
    
    echo -n "  In meeting: "
    is_in_meeting && echo "YES" || echo "no"
    
    echo ""
    echo -n "Do Not Disturb: "
    is_do_not_disturb_enabled && echo "ACTIVE" || echo "inactive"
}

# =============================================================================
# Main
# =============================================================================

show_help() {
    cat << EOF
AetherOS Smart Notifications

Automatically mutes notifications during gaming, presentations, and meetings.

Usage: $(basename "$0") [OPTIONS]

Options:
  enable            Enable smart notifications
  disable           Disable smart notifications
  monitor           Start monitoring (foreground)
  status            Show current status
  --help, -h        Show this help

Examples:
  $(basename "$0") enable       # Enable the feature
  $(basename "$0") monitor      # Start monitoring
  $(basename "$0") status       # Check what's happening

Auto-mute scenarios:
  - Gaming: Steam, Lutris, Wine games
  - Videos: YouTube, Netflix, VLC (fullscreen)
  - Presenting: LibreOffice Impress, PowerPoint
  - Meetings: Zoom, Teams, Meet, Webex, Discord calls

Note: Add 'monitor' to autostart for automatic background operation.
EOF
}

main() {
    case "${1:-status}" in
        enable|on)
            enable_smart_notifications
            ;;
        disable|off)
            disable_smart_notifications
            ;;
        monitor)
            smart_monitor
            ;;
        status)
            show_status
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            show_help
            exit 1
            ;;
    esac
}

main "$@"

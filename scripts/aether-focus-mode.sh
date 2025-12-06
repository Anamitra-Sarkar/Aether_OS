#!/bin/bash
# =============================================================================
# AetherOS Focus Mode 2.0 / Do Not Disturb
# Enhanced notification management with auto-activation and scheduling
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
FOCUS_CONFIG="$CONFIG_DIR/.aether-focus-mode"
AUTO_FULLSCREEN_FILE="$CONFIG_DIR/.aether-focus-auto-fullscreen"

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

# =============================================================================
# Auto-activation on fullscreen
# =============================================================================
enable_auto_fullscreen() {
    echo "enabled" > "$AUTO_FULLSCREEN_FILE"
    echo "✓ Auto-activation on fullscreen apps enabled"
    echo "Focus Mode will automatically activate when apps go fullscreen"
}

disable_auto_fullscreen() {
    rm -f "$AUTO_FULLSCREEN_FILE"
    echo "✓ Auto-activation on fullscreen apps disabled"
}

check_auto_fullscreen_enabled() {
    [ -f "$AUTO_FULLSCREEN_FILE" ]
}

# Check if any window is fullscreen
is_fullscreen_active() {
    if command -v qdbus &>/dev/null; then
        # Check KWin for fullscreen windows
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

# Monitor for fullscreen apps and auto-enable Focus Mode
monitor_fullscreen() {
    echo "Monitoring for fullscreen apps... (Press Ctrl+C to stop)"
    echo "Focus Mode will auto-activate when apps go fullscreen"
    
    local was_fullscreen=false
    local focus_was_auto=false
    
    while true; do
        if is_fullscreen_active; then
            if [ "$was_fullscreen" = "false" ]; then
                echo "Fullscreen app detected - activating Focus Mode"
                kwriteconfig5 --file knotificationmanagerrc --group DoNotDisturb --key Enabled true
                was_fullscreen=true
                focus_was_auto=true
            fi
        else
            if [ "$was_fullscreen" = "true" ] && [ "$focus_was_auto" = "true" ]; then
                echo "Exited fullscreen - deactivating Focus Mode"
                kwriteconfig5 --file knotificationmanagerrc --group DoNotDisturb --key Enabled false
                was_fullscreen=false
                focus_was_auto=false
            fi
        fi
        sleep 5
    done
}

# =============================================================================
# Schedule support (study mode)
# =============================================================================
enable_schedule() {
    local start_time="${1:-09:00}"
    local end_time="${2:-17:00}"
    
    echo "schedule_enabled=true" > "$FOCUS_CONFIG"
    echo "schedule_start=$start_time" >> "$FOCUS_CONFIG"
    echo "schedule_end=$end_time" >> "$FOCUS_CONFIG"
    
    echo "✓ Focus Mode schedule enabled"
    echo "  Active: $start_time - $end_time"
    echo ""
    echo "Focus Mode will automatically enable during these hours"
}

disable_schedule() {
    rm -f "$FOCUS_CONFIG"
    echo "✓ Focus Mode schedule disabled"
}

check_schedule() {
    if [ ! -f "$FOCUS_CONFIG" ]; then
        return 1
    fi
    
    local enabled start_time end_time
    enabled=$(grep "schedule_enabled" "$FOCUS_CONFIG" | cut -d= -f2)
    [ "$enabled" = "true" ] || return 1
    
    start_time=$(grep "schedule_start" "$FOCUS_CONFIG" | cut -d= -f2)
    end_time=$(grep "schedule_end" "$FOCUS_CONFIG" | cut -d= -f2)
    
    local current_time
    current_time=$(date +%H:%M)
    
    # Simple time comparison (works for same-day ranges)
    if [[ "$current_time" > "$start_time" ]] && [[ "$current_time" < "$end_time" ]]; then
        return 0
    fi
    
    return 1
}

# =============================================================================
# Main
# =============================================================================
show_help() {
    cat << EOF
AetherOS Focus Mode 2.0

Enhanced notification management with smart features.

Usage: $(basename "$0") [OPTIONS]

Options:
  toggle                    Toggle Focus Mode on/off (default)
  on                        Enable Focus Mode
  off                       Disable Focus Mode
  status                    Show current status
  
  auto-fullscreen on        Enable auto-activation for fullscreen apps
  auto-fullscreen off       Disable auto-activation
  monitor                   Monitor and auto-toggle on fullscreen (foreground)
  
  schedule START END        Enable scheduled Focus Mode
                            Example: schedule 09:00 17:00 (9 AM to 5 PM)
  schedule off              Disable scheduled Focus Mode
  
  --help, -h                Show this help

Examples:
  $(basename "$0")                      # Toggle Focus Mode
  $(basename "$0") auto-fullscreen on   # Auto-enable on fullscreen
  $(basename "$0") schedule 14:00 18:00 # Study mode 2-6 PM
  $(basename "$0") monitor              # Run monitor in foreground

Note: For background monitoring, add monitor to autostart.
EOF
}

main() {
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
            local state
            state=$(get_focus_state)
            echo "Focus Mode: $([[ "$state" == "true" ]] && echo "ON" || echo "OFF")"
            
            if check_auto_fullscreen_enabled; then
                echo "Auto-fullscreen: ENABLED"
            else
                echo "Auto-fullscreen: DISABLED"
            fi
            
            if [ -f "$FOCUS_CONFIG" ]; then
                echo "Schedule: ENABLED"
                grep "schedule_start\|schedule_end" "$FOCUS_CONFIG" | sed 's/schedule_/  /g'
            else
                echo "Schedule: DISABLED"
            fi
            ;;
        auto-fullscreen)
            case "${2:-}" in
                on|enable)
                    enable_auto_fullscreen
                    ;;
                off|disable)
                    disable_auto_fullscreen
                    ;;
                *)
                    echo "Usage: $0 auto-fullscreen {on|off}" >&2
                    exit 1
                    ;;
            esac
            ;;
        monitor)
            monitor_fullscreen
            ;;
        schedule)
            if [ "${2:-}" = "off" ] || [ "${2:-}" = "disable" ]; then
                disable_schedule
            elif [ -n "${2:-}" ] && [ -n "${3:-}" ]; then
                enable_schedule "$2" "$3"
            else
                echo "Usage: $0 schedule START_TIME END_TIME" >&2
                echo "       $0 schedule off" >&2
                exit 1
            fi
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

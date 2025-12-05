#!/bin/bash
# =============================================================================
# AetherOS Theme Scheduler
# Automatically switches between light and dark themes based on time of day
# Light theme: 7:00 AM - 7:00 PM
# Dark theme: 7:00 PM - 7:00 AM
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$HOME/.config/aetheros/theme-scheduler.conf"

# Default configuration
LIGHT_START_HOUR=7
LIGHT_END_HOUR=19
AUTO_SCHEDULE_ENABLED="false"

# Load config if it exists
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    fi
}

# Save config
save_config() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat > "$CONFIG_FILE" << EOF
# AetherOS Theme Scheduler Configuration
AUTO_SCHEDULE_ENABLED="$AUTO_SCHEDULE_ENABLED"
LIGHT_START_HOUR=$LIGHT_START_HOUR
LIGHT_END_HOUR=$LIGHT_END_HOUR
EOF
}

# Apply theme based on time
apply_scheduled_theme() {
    load_config
    
    if [[ "$AUTO_SCHEDULE_ENABLED" != "true" ]]; then
        echo "Auto theme scheduling is disabled"
        exit 0
    fi
    
    local current_hour
    current_hour=$(date +%H)
    
    # Remove leading zero for comparison
    current_hour=$((10#$current_hour))
    
    if [[ $current_hour -ge $LIGHT_START_HOUR && $current_hour -lt $LIGHT_END_HOUR ]]; then
        # Apply light theme
        echo "Applying light theme (time: ${current_hour}:00)"
        "$SCRIPT_DIR/apply-theme.sh" light 2>/dev/null || echo "Warning: Could not apply light theme"
    else
        # Apply dark theme
        echo "Applying dark theme (time: ${current_hour}:00)"
        "$SCRIPT_DIR/apply-theme.sh" dark 2>/dev/null || echo "Warning: Could not apply dark theme"
    fi
}

# Enable auto scheduling
enable_auto_schedule() {
    AUTO_SCHEDULE_ENABLED="true"
    save_config
    
    # Apply immediately
    apply_scheduled_theme
    
    # Create systemd user timer if not exists
    create_systemd_timer
    
    echo "Auto theme scheduling enabled"
}

# Disable auto scheduling
disable_auto_schedule() {
    AUTO_SCHEDULE_ENABLED="false"
    save_config
    
    # Stop and disable timer
    systemctl --user stop aether-theme-scheduler.timer 2>/dev/null || true
    systemctl --user disable aether-theme-scheduler.timer 2>/dev/null || true
    
    echo "Auto theme scheduling disabled"
}

# Create systemd user timer
create_systemd_timer() {
    local user_systemd_dir="$HOME/.config/systemd/user"
    mkdir -p "$user_systemd_dir"
    
    # Create service file
    cat > "$user_systemd_dir/aether-theme-scheduler.service" << EOF
[Unit]
Description=AetherOS Auto Theme Scheduler
After=graphical-session.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_DIR/aether-theme-scheduler.sh apply

[Install]
WantedBy=default.target
EOF
    
    # Create timer file (run every hour)
    cat > "$user_systemd_dir/aether-theme-scheduler.timer" << EOF
[Unit]
Description=AetherOS Auto Theme Scheduler Timer
RefuseManualStart=no
RefuseManualStop=no

[Timer]
Persistent=false
OnBootSec=1min
OnCalendar=hourly
Unit=aether-theme-scheduler.service

[Install]
WantedBy=timers.target
EOF
    
    # Reload systemd and enable timer
    systemctl --user daemon-reload
    systemctl --user enable aether-theme-scheduler.timer
    systemctl --user start aether-theme-scheduler.timer
    
    echo "Systemd timer created and enabled"
}

# Get status
get_status() {
    load_config
    echo "Auto Schedule Enabled: $AUTO_SCHEDULE_ENABLED"
    echo "Light Theme Hours: ${LIGHT_START_HOUR}:00 - ${LIGHT_END_HOUR}:00"
    
    if systemctl --user is-active aether-theme-scheduler.timer &>/dev/null; then
        echo "Timer Status: Active"
    else
        echo "Timer Status: Inactive"
    fi
}

# Main
case "${1:-}" in
    apply)
        apply_scheduled_theme
        ;;
    enable)
        enable_auto_schedule
        ;;
    disable)
        disable_auto_schedule
        ;;
    status)
        get_status
        ;;
    *)
        echo "Usage: $0 {apply|enable|disable|status}"
        echo ""
        echo "Commands:"
        echo "  apply   - Apply theme based on current time"
        echo "  enable  - Enable auto theme scheduling"
        echo "  disable - Disable auto theme scheduling"
        echo "  status  - Show current configuration"
        exit 1
        ;;
esac

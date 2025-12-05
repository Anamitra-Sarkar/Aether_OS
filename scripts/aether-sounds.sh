#!/bin/bash
# =============================================================================
# AetherOS Sound Theme Manager
# Manages system sound theme (login, notifications, alerts)
# =============================================================================

set -euo pipefail

CONFIG_FILE="$HOME/.config/aetheros/sounds.conf"
SOUNDS_ENABLED="true"

# Load config
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
    fi
}

# Save config
save_config() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat > "$CONFIG_FILE" << EOF
# AetherOS Sound Theme Configuration
SOUNDS_ENABLED="$SOUNDS_ENABLED"
EOF
}

# Enable system sounds
enable_sounds() {
    SOUNDS_ENABLED="true"
    save_config
    
    # Configure KDE sound theme using Ocean theme (included in KDE)
    # Set notification sounds
    kwriteconfig5 --file kdeglobals --group Sounds --key Theme ocean 2>/dev/null || true
    
    # Enable event sounds in plasma
    kwriteconfig5 --file plasmarc --group PlasmaEventSounds --key Enabled true 2>/dev/null || true
    
    # Configure specific sounds
    # Login sound
    kwriteconfig5 --file knotifyrc --group Event/startkde --key Action Sound 2>/dev/null || true
    
    # Notification sound
    kwriteconfig5 --file knotifyrc --group Event/notification --key Action Sound 2>/dev/null || true
    
    echo "System sounds enabled (using Ocean theme)"
    notify-send "System Sounds" "Sound theme enabled" -i audio-volume-high -t 3000 || true
}

# Disable system sounds
disable_sounds() {
    SOUNDS_ENABLED="false"
    save_config
    
    # Disable event sounds in plasma
    kwriteconfig5 --file plasmarc --group PlasmaEventSounds --key Enabled false 2>/dev/null || true
    
    echo "System sounds disabled"
    # Don't send notification when disabling sounds
}

# Toggle sounds
toggle_sounds() {
    load_config
    
    if [[ "$SOUNDS_ENABLED" == "true" ]]; then
        disable_sounds
    else
        enable_sounds
    fi
}

# Get status
get_status() {
    load_config
    echo "System Sounds: $SOUNDS_ENABLED"
}

# Test sound
test_sound() {
    if command -v paplay &>/dev/null; then
        # Play a test sound using pulseaudio
        paplay /usr/share/sounds/freedesktop/stereo/message.oga 2>/dev/null || \
        paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null || \
        echo "Could not find test sound file"
    elif command -v aplay &>/dev/null; then
        # Fallback to alsa
        aplay /usr/share/sounds/alsa/Front_Center.wav 2>/dev/null || \
        echo "Could not play test sound"
    else
        echo "No audio player found (paplay or aplay)"
    fi
}

# Main
case "${1:-status}" in
    enable)
        enable_sounds
        ;;
    disable)
        disable_sounds
        ;;
    toggle)
        toggle_sounds
        ;;
    status)
        get_status
        ;;
    test)
        test_sound
        ;;
    *)
        echo "Usage: $0 {enable|disable|toggle|status|test}"
        echo ""
        echo "Commands:"
        echo "  enable  - Enable system sounds"
        echo "  disable - Disable system sounds"
        echo "  toggle  - Toggle system sounds"
        echo "  status  - Show current status"
        echo "  test    - Play a test sound"
        exit 1
        ;;
esac

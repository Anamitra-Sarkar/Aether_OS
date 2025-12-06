#!/bin/bash
# =============================================================================
# AetherOS Profile Sync
# Save and restore user preferences
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
PROFILE_FILE="$HOME/.aether-profile.json"
BACKUP_DIR="$HOME/.aether-profile-backups"

# =============================================================================
# Collect current settings
# =============================================================================
collect_profile() {
    echo "Collecting current profile settings..."
    
    local profile_data="{"
    
    # Theme (KDE color scheme)
    local color_scheme
    color_scheme=$(kreadconfig5 --file kdeglobals --group General --key ColorScheme 2>/dev/null || echo "")
    profile_data+='"theme":"'$color_scheme'",'
    
    # Wallpaper
    local wallpaper
    wallpaper=$(kreadconfig5 --file plasma-org.kde.plasma.desktop-appletsrc --group Containments --group 1 --group Wallpaper --group org.kde.image --group General --key Image 2>/dev/null || echo "")
    profile_data+='"wallpaper":"'$wallpaper'",'
    
    # Performance profile
    local perf_profile=""
    if [ -f "$CONFIG_DIR/.aether-performance-profile" ]; then
        perf_profile=$(cat "$CONFIG_DIR/.aether-performance-profile")
    fi
    profile_data+='"performance_profile":"'$perf_profile'",'
    
    # Blur mode
    local blur_mode=""
    if [ -f "$CONFIG_DIR/.aether-blur-mode" ]; then
        blur_mode=$(cat "$CONFIG_DIR/.aether-blur-mode")
    fi
    profile_data+='"blur_mode":"'$blur_mode'",'
    
    # CleanMode status
    local cleanmode="false"
    if [ -f "$CONFIG_DIR/.aether-cleanmode" ]; then
        cleanmode="true"
    fi
    profile_data+='"cleanmode":'$cleanmode','
    
    # Focus Mode settings
    local focus_auto_fullscreen="false"
    if [ -f "$CONFIG_DIR/.aether-focus-auto-fullscreen" ]; then
        focus_auto_fullscreen="true"
    fi
    profile_data+='"focus_auto_fullscreen":'$focus_auto_fullscreen','
    
    # Smart notifications
    local smart_notifications="false"
    if [ -f "$CONFIG_DIR/.aether-smart-notifications" ]; then
        smart_notifications="true"
    fi
    profile_data+='"smart_notifications":'$smart_notifications','
    
    # Sound theme enabled
    local sound_enabled
    sound_enabled=$(kreadconfig5 --file kdeglobals --group Sounds --key Theme 2>/dev/null || echo "")
    profile_data+='"sound_theme":"'$sound_enabled'",'
    
    # Touchpad settings
    local touchpad_tap_enabled
    touchpad_tap_enabled=$(kreadconfig5 --file touchpadxlibinputrc --group "Alps Touchpad" --key TapToClick 2>/dev/null || echo "")
    profile_data+='"touchpad_tap":'$touchpad_tap_enabled','
    
    # Animation speed
    local anim_speed
    anim_speed=$(kreadconfig5 --file kwinrc --group Compositing --key AnimationSpeed 2>/dev/null || echo "3")
    profile_data+='"animation_speed":'$anim_speed','
    
    # Timestamp
    profile_data+='"timestamp":"'$(date -Iseconds)'",'
    profile_data+='"version":"2.0"'
    
    profile_data+="}"
    
    echo "$profile_data"
}

# =============================================================================
# Save profile
# =============================================================================
save_profile() {
    local profile_name="${1:-default}"
    local target_file="$PROFILE_FILE"
    
    if [ "$profile_name" != "default" ]; then
        target_file="$HOME/.aether-profile-${profile_name}.json"
    fi
    
    echo "Saving profile to: $target_file"
    
    local profile_data
    profile_data=$(collect_profile)
    
    # Pretty print JSON if jq is available
    if command -v jq &>/dev/null; then
        echo "$profile_data" | jq '.' > "$target_file"
    else
        echo "$profile_data" > "$target_file"
    fi
    
    # Create backup
    mkdir -p "$BACKUP_DIR"
    cp "$target_file" "$BACKUP_DIR/profile-$(date +%Y%m%d-%H%M%S).json"
    
    echo "✓ Profile saved successfully!"
    echo "  File: $target_file"
    echo "  Backup: $BACKUP_DIR/"
}

# =============================================================================
# Restore profile
# =============================================================================
restore_profile() {
    local profile_name="${1:-default}"
    local source_file="$PROFILE_FILE"
    
    if [ "$profile_name" != "default" ]; then
        source_file="$HOME/.aether-profile-${profile_name}.json"
    fi
    
    if [ ! -f "$source_file" ]; then
        echo "Error: Profile not found: $source_file" >&2
        exit 1
    fi
    
    echo "Restoring profile from: $source_file"
    
    # Read JSON (requires jq for proper parsing, or use basic grep)
    if command -v jq &>/dev/null; then
        local theme wallpaper perf_profile blur_mode cleanmode
        local focus_auto sound_theme smart_notif touchpad_tap anim_speed
        
        theme=$(jq -r '.theme' "$source_file")
        wallpaper=$(jq -r '.wallpaper' "$source_file")
        perf_profile=$(jq -r '.performance_profile' "$source_file")
        blur_mode=$(jq -r '.blur_mode' "$source_file")
        cleanmode=$(jq -r '.cleanmode' "$source_file")
        focus_auto=$(jq -r '.focus_auto_fullscreen' "$source_file")
        sound_theme=$(jq -r '.sound_theme' "$source_file")
        smart_notif=$(jq -r '.smart_notifications' "$source_file")
        touchpad_tap=$(jq -r '.touchpad_tap' "$source_file")
        anim_speed=$(jq -r '.animation_speed' "$source_file")
        
        echo "Applying settings..."
        
        # Theme
        if [ -n "$theme" ] && [ "$theme" != "null" ]; then
            echo "  - Theme: $theme"
            kwriteconfig5 --file kdeglobals --group General --key ColorScheme "$theme"
        fi
        
        # Wallpaper (complex, skip for now)
        
        # Performance profile
        if [ -n "$perf_profile" ] && [ "$perf_profile" != "null" ]; then
            echo "  - Performance: $perf_profile"
            echo "$perf_profile" > "$CONFIG_DIR/.aether-performance-profile"
            if [ -f "$( dirname "$0" )/aether-performance-profiler.sh" ]; then
                "$( dirname "$0" )/aether-performance-profiler.sh" "$perf_profile" 2>/dev/null || true
            fi
        fi
        
        # Blur mode
        if [ -n "$blur_mode" ] && [ "$blur_mode" != "null" ]; then
            echo "  - Blur: $blur_mode"
            if [ -f "$( dirname "$0" )/aether-adaptive-blur.sh" ]; then
                "$( dirname "$0" )/aether-adaptive-blur.sh" "$blur_mode" 2>/dev/null || true
            fi
        fi
        
        # CleanMode
        if [ "$cleanmode" = "true" ]; then
            echo "  - CleanMode: enabled"
            if [ -f "$( dirname "$0" )/aether-cleanmode.sh" ]; then
                "$( dirname "$0" )/aether-cleanmode.sh" on 2>/dev/null || true
            fi
        fi
        
        # Focus Mode auto-fullscreen
        if [ "$focus_auto" = "true" ]; then
            echo "  - Focus auto-fullscreen: enabled"
            touch "$CONFIG_DIR/.aether-focus-auto-fullscreen"
        fi
        
        # Smart notifications
        if [ "$smart_notif" = "true" ]; then
            echo "  - Smart notifications: enabled"
            touch "$CONFIG_DIR/.aether-smart-notifications"
        fi
        
        # Touchpad tap-to-click
        if [ -n "$touchpad_tap" ] && [ "$touchpad_tap" != "null" ]; then
            echo "  - Touchpad tap-to-click: $touchpad_tap"
            kwriteconfig5 --file touchpadxlibinputrc --group "Alps Touchpad" --key TapToClick "$touchpad_tap"
        fi
        
        # Animation speed
        if [ -n "$anim_speed" ] && [ "$anim_speed" != "null" ]; then
            echo "  - Animation speed: $anim_speed"
            kwriteconfig5 --file kwinrc --group Compositing --key AnimationSpeed "$anim_speed"
        fi
        
        # Restart services to apply
        echo ""
        echo "Restarting services..."
        qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
        kquitapp5 plasmashell 2>/dev/null && kstart5 plasmashell 2>/dev/null &
        
        echo ""
        echo "✓ Profile restored successfully!"
        echo "  Some changes may require logout/login to fully apply"
    else
        echo "Error: jq not installed. Cannot parse JSON profile." >&2
        echo "Install with: sudo apt install jq" >&2
        exit 1
    fi
}

# =============================================================================
# List profiles
# =============================================================================
list_profiles() {
    echo "=== Available Profiles ==="
    echo ""
    
    if [ -f "$PROFILE_FILE" ]; then
        echo "default"
        if command -v jq &>/dev/null; then
            local timestamp
            timestamp=$(jq -r '.timestamp' "$PROFILE_FILE" 2>/dev/null || echo "")
            [ -n "$timestamp" ] && echo "  Saved: $timestamp"
        fi
    fi
    
    # List named profiles
    for profile in "$HOME"/.aether-profile-*.json; do
        if [ -f "$profile" ]; then
            local name
            name=$(basename "$profile" | sed 's/^\.aether-profile-//; s/\.json$//')
            echo "$name"
            if command -v jq &>/dev/null; then
                local timestamp
                timestamp=$(jq -r '.timestamp' "$profile" 2>/dev/null || echo "")
                [ -n "$timestamp" ] && echo "  Saved: $timestamp"
            fi
        fi
    done
    
    echo ""
    echo "=== Backups ==="
    if [ -d "$BACKUP_DIR" ]; then
        ls -lh "$BACKUP_DIR"/*.json 2>/dev/null || echo "No backups found"
    else
        echo "No backup directory"
    fi
}

# =============================================================================
# Main
# =============================================================================
show_help() {
    cat << EOF
AetherOS Profile Sync

Save and restore your AetherOS preferences in one click.

Usage: $(basename "$0") [OPTIONS]

Options:
  save [NAME]           Save current profile (default: "default")
  restore [NAME]        Restore saved profile (default: "default")
  list                  List all saved profiles
  --help, -h            Show this help

What gets saved:
  - Theme and color scheme
  - Wallpaper
  - Performance profile
  - Blur settings
  - CleanMode status
  - Focus Mode settings
  - Smart notifications
  - Sound theme
  - Touchpad settings
  - Animation speed

Examples:
  $(basename "$0") save                # Save to default profile
  $(basename "$0") save work           # Save as "work" profile
  $(basename "$0") restore work        # Restore "work" profile
  $(basename "$0") list                # List all profiles

Note: Profile files are stored as JSON in your home directory.
      Backups are automatically created in ~/.aether-profile-backups/
EOF
}

main() {
    case "${1:-help}" in
        save)
            save_profile "${2:-default}"
            ;;
        restore)
            restore_profile "${2:-default}"
            ;;
        list)
            list_profiles
            ;;
        --help|-h|help)
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

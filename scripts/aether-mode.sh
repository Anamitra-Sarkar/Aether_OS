#!/bin/bash
# AetherOS Mode Switcher - Game Mode & Creator Mode
# v2.2 Feature: Easy mode switching for different use cases

set -euo pipefail

# Colors for output
readonly COLOR_RESET='\033[0m'
readonly COLOR_BLUE='\033[1;34m'
readonly COLOR_GREEN='\033[1;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_RED='\033[1;31m'

# Configuration
readonly SCRIPT_NAME="aether-mode"
readonly CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/aetheros"
readonly MODE_FILE="$CONFIG_DIR/current-mode"

# Logging
log() {
    echo -e "${COLOR_BLUE}[$SCRIPT_NAME]${COLOR_RESET} $*"
}

error() {
    echo -e "${COLOR_RED}[$SCRIPT_NAME ERROR]${COLOR_RESET} $*" >&2
}

success() {
    echo -e "${COLOR_GREEN}[$SCRIPT_NAME]${COLOR_RESET} $*"
}

warning() {
    echo -e "${COLOR_YELLOW}[$SCRIPT_NAME WARNING]${COLOR_RESET} $*"
}

# Ensure config directory exists
init_config() {
    mkdir -p "$CONFIG_DIR"
}

# Save current mode
save_mode() {
    local mode=$1
    echo "$mode" > "$MODE_FILE"
}

# Get current mode
get_current_mode() {
    if [ -f "$MODE_FILE" ]; then
        cat "$MODE_FILE"
    else
        echo "normal"
    fi
}

# Check if gamemode is available
check_gamemode() {
    if command -v gamemoded &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Set CPU governor
set_cpu_governor() {
    local governor=$1
    
    # Check if cpufreq is available
    if [ ! -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
        warning "CPU frequency scaling not available"
        return 1
    fi
    
    log "Setting CPU governor to $governor..."
    
    # Try using cpupower if available
    if command -v cpupower &> /dev/null; then
        sudo cpupower frequency-set -g "$governor" &> /dev/null || true
        return 0
    fi
    
    # Fallback: direct sysfs write
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        if [ -w "$cpu" ]; then
            echo "$governor" | sudo tee "$cpu" > /dev/null 2>&1 || true
        fi
    done
    
    return 0
}

# Disable/enable background indexers
toggle_indexers() {
    local action=$1  # disable or enable
    
    log "${action^}ing background indexers..."
    
    # Baloo (KDE file indexer)
    if command -v balooctl &> /dev/null; then
        case "$action" in
            disable)
                balooctl disable &> /dev/null || true
                balooctl suspend &> /dev/null || true
                ;;
            enable)
                balooctl enable &> /dev/null || true
                balooctl resume &> /dev/null || true
                ;;
        esac
    fi
    
    return 0
}

# Toggle notifications
toggle_notifications() {
    local action=$1  # disable or enable
    
    log "${action^}ing notifications..."
    
    # Try using Focus Mode if available
    if [ -f "$(dirname "$0")/aether-focus-mode.sh" ]; then
        case "$action" in
            disable)
                "$(dirname "$0")/aether-focus-mode.sh" on &> /dev/null || true
                ;;
            enable)
                "$(dirname "$0")/aether-focus-mode.sh" off &> /dev/null || true
                ;;
        esac
        return 0
    fi
    
    # Fallback: KDE notification settings
    if command -v kwriteconfig5 &> /dev/null; then
        case "$action" in
            disable)
                kwriteconfig5 --file plasmanotifyrc --group DoNotDisturb --key Enabled true
                ;;
            enable)
                kwriteconfig5 --file plasmanotifyrc --group DoNotDisturb --key Enabled false
                ;;
        esac
        
        # Restart plasmashell to apply (optional, may not be needed)
        # kquitapp5 plasmashell && kstart5 plasmashell &> /dev/null &
    fi
    
    return 0
}

# Enable Game Mode
enable_game_mode() {
    log "Activating Game Mode..."
    
    # 1. Set performance CPU governor
    if set_cpu_governor "performance"; then
        success "CPU governor set to performance"
    else
        warning "Could not set CPU governor"
    fi
    
    # 2. Disable background indexers
    if toggle_indexers "disable"; then
        success "Background indexers disabled"
    fi
    
    # 3. Disable notifications
    if toggle_notifications "disable"; then
        success "Notifications disabled"
    fi
    
    # 4. Try to use gamemode if available
    if check_gamemode; then
        log "gamemode daemon is available"
        # Note: Individual games should be launched with 'gamemoderun game'
        success "Use 'gamemoderun <game>' to launch games with gamemode"
    else
        warning "gamemode not installed (optional)"
        warning "Install with: sudo apt install gamemode"
    fi
    
    # 5. Disable compositor if possible (for performance)
    if command -v qdbus &> /dev/null; then
        qdbus org.kde.KWin /Compositor suspend &> /dev/null || true
        success "Compositor suspended for better performance"
    fi
    
    # Save current mode
    save_mode "game"
    
    success "Game Mode activated!"
    success "Remember to restore normal mode when done: $0 normal"
}

# Enable Creator Mode
enable_creator_mode() {
    log "Activating Creator Mode..."
    
    # 1. Set balanced performance governor
    if set_cpu_governor "schedutil"; then
        success "CPU governor set to schedutil (balanced)"
    elif set_cpu_governor "ondemand"; then
        success "CPU governor set to ondemand (balanced)"
    else
        warning "Could not set CPU governor"
    fi
    
    # 2. Keep compositor enabled for smooth UI
    if command -v qdbus &> /dev/null; then
        qdbus org.kde.KWin /Compositor resume &> /dev/null || true
        success "Compositor enabled for smooth UI"
    fi
    
    # 3. Keep indexers running (might need to search files)
    if toggle_indexers "enable"; then
        success "Background indexers enabled"
    fi
    
    # 4. Keep notifications enabled
    if toggle_notifications "enable"; then
        success "Notifications enabled"
    fi
    
    # 5. Ensure network and backups accessible
    log "Network and backup services remain active"
    
    # Save current mode
    save_mode "creator"
    
    success "Creator Mode activated!"
    success "Optimized for video editing, graphics work, and content creation"
}

# Restore normal mode
restore_normal_mode() {
    log "Restoring Normal Mode..."
    
    # 1. Set default CPU governor
    if set_cpu_governor "schedutil"; then
        success "CPU governor restored to schedutil"
    elif set_cpu_governor "ondemand"; then
        success "CPU governor restored to ondemand"
    else
        warning "Could not restore CPU governor"
    fi
    
    # 2. Enable background indexers
    if toggle_indexers "enable"; then
        success "Background indexers enabled"
    fi
    
    # 3. Enable notifications
    if toggle_notifications "enable"; then
        success "Notifications enabled"
    fi
    
    # 4. Resume compositor
    if command -v qdbus &> /dev/null; then
        qdbus org.kde.KWin /Compositor resume &> /dev/null || true
        success "Compositor resumed"
    fi
    
    # Save current mode
    save_mode "normal"
    
    success "Normal Mode restored!"
}

# Show current status
show_status() {
    local current_mode=$(get_current_mode)
    
    echo -e "${COLOR_BLUE}╔═══════════════════════════════════════════════════════════════╗${COLOR_RESET}"
    echo -e "${COLOR_BLUE}║${COLOR_RESET}              AetherOS Mode Status                            ${COLOR_BLUE}║${COLOR_RESET}"
    echo -e "${COLOR_BLUE}╚═══════════════════════════════════════════════════════════════╝${COLOR_RESET}"
    echo ""
    echo -e "Current Mode: ${COLOR_GREEN}${current_mode}${COLOR_RESET}"
    echo ""
    
    # Show CPU governor
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        local governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
        echo -e "CPU Governor: ${COLOR_YELLOW}$governor${COLOR_RESET}"
    fi
    
    # Show gamemode availability
    if check_gamemode; then
        echo -e "gamemode: ${COLOR_GREEN}Available${COLOR_RESET}"
    else
        echo -e "gamemode: ${COLOR_RED}Not installed${COLOR_RESET} (optional)"
    fi
    
    echo ""
}

# Show help
show_help() {
    cat << EOF
AetherOS Mode Switcher - Game Mode & Creator Mode

Usage: $0 [MODE]

Modes:
  game          Activate Game Mode (performance optimization)
  creator       Activate Creator Mode (content creation)
  normal        Restore Normal Mode
  status        Show current mode status
  help          Show this help message

Game Mode:
  - Sets CPU governor to performance
  - Disables background indexers
  - Disables notifications (Focus Mode)
  - Suspends compositor for better FPS
  - Works with gamemode daemon if installed

Creator Mode:
  - Balanced CPU governor (performance + efficiency)
  - Keeps compositor enabled (smooth UI)
  - Keeps network and backups accessible
  - Optimized for Kdenlive, GIMP, Krita

Normal Mode:
  - Restores default settings
  - Re-enables all features

Examples:
  $0 game         # Activate Game Mode
  $0 creator      # Activate Creator Mode
  $0 normal       # Restore to normal
  $0 status       # Check current mode

Notes:
  - Game Mode is best for gaming sessions
  - Creator Mode is for video/graphics work
  - Remember to restore normal mode when done
  - Some features require sudo (CPU governor)

EOF
}

# Main function
main() {
    # Initialize config
    init_config
    
    # Parse command line arguments
    local mode="${1:-status}"
    
    case "$mode" in
        game)
            enable_game_mode
            ;;
        creator)
            enable_creator_mode
            ;;
        normal)
            restore_normal_mode
            ;;
        status)
            show_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Unknown mode: $mode"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"

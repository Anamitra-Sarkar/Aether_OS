#!/bin/bash
# =============================================================================
# AetherOS CleanMode Toggle
# One-toggle performance mode for low-end hardware
# Disables animations, reduces blur, simplifies UI
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
PLASMA_CONFIG="$CONFIG_DIR/kwinrc"
CLEANMODE_FILE="$CONFIG_DIR/.aether-cleanmode"

# =============================================================================
# Enable CleanMode
# =============================================================================
enable_cleanmode() {
    echo "Enabling CleanMode (Performance optimization for low-end hardware)..."
    
    # Disable animations
    kwriteconfig5 --file "$PLASMA_CONFIG" --group Compositing --key AnimationSpeed 0
    
    # Disable blur
    "$( dirname "$0" )/aether-adaptive-blur.sh" off 2>/dev/null || \
        kwriteconfig5 --file "$PLASMA_CONFIG" --group Plugins --key blurEnabled false
    
    # Disable shadows
    kwriteconfig5 --file "$PLASMA_CONFIG" --group Plugins --key kwin4_effect_translucencyEnabled false
    kwriteconfig5 --file "$PLASMA_CONFIG" --group Effect-PresentWindows --key ShowPanel false
    
    # Disable window decorations animations
    kwriteconfig5 --file "$PLASMA_CONFIG" --group Plugins --key slideEnabled false
    kwriteconfig5 --file "$PLASMA_CONFIG" --group Plugins --key fadeEnabled false
    
    # Reduce compositor quality
    kwriteconfig5 --file "$PLASMA_CONFIG" --group Compositing --key GLTextureFilter 0
    
    # Disable wobbly windows
    kwriteconfig5 --file "$PLASMA_CONFIG" --group Plugins --key wobblywindowsEnabled false
    
    # Disable magnifier
    kwriteconfig5 --file "$PLASMA_CONFIG" --group Plugins --key zoomEnabled false
    
    # Save state
    echo "enabled" > "$CLEANMODE_FILE"
    
    # Restart KWin
    if command -v qdbus &> /dev/null; then
        qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
    fi
    
    echo "✓ CleanMode enabled"
    echo "  - Animations: OFF"
    echo "  - Blur: OFF"
    echo "  - Shadows: OFF"
    echo "  - Effects: Minimal"
    echo ""
    echo "Your system should feel much faster now!"
}

# =============================================================================
# Disable CleanMode (Restore defaults)
# =============================================================================
disable_cleanmode() {
    echo "Disabling CleanMode (Restoring visual effects)..."
    
    # Re-enable animations with medium speed
    kwriteconfig5 --file "$PLASMA_CONFIG" --group Compositing --key AnimationSpeed 3
    
    # Re-enable blur with auto-detection
    "$( dirname "$0" )/aether-adaptive-blur.sh" auto 2>/dev/null || \
        kwriteconfig5 --file "$PLASMA_CONFIG" --group Plugins --key blurEnabled true
    
    # Re-enable effects
    kwriteconfig5 --file "$PLASMA_CONFIG" --group Plugins --key kwin4_effect_translucencyEnabled true
    kwriteconfig5 --file "$PLASMA_CONFIG" --group Effect-PresentWindows --key ShowPanel true
    kwriteconfig5 --file "$PLASMA_CONFIG" --group Plugins --key slideEnabled true
    kwriteconfig5 --file "$PLASMA_CONFIG" --group Plugins --key fadeEnabled true
    
    # Restore compositor quality
    kwriteconfig5 --file "$PLASMA_CONFIG" --group Compositing --key GLTextureFilter 2
    
    # Remove state file
    rm -f "$CLEANMODE_FILE"
    
    # Restart KWin
    if command -v qdbus &> /dev/null; then
        qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
    fi
    
    echo "✓ CleanMode disabled"
    echo "  - Animations: ON"
    echo "  - Blur: AUTO"
    echo "  - Shadows: ON"
    echo "  - Effects: Enabled"
    echo ""
    echo "Visual effects restored!"
}

# =============================================================================
# Toggle CleanMode
# =============================================================================
toggle_cleanmode() {
    if [ -f "$CLEANMODE_FILE" ]; then
        disable_cleanmode
    else
        enable_cleanmode
    fi
}

# =============================================================================
# Check status
# =============================================================================
check_status() {
    if [ -f "$CLEANMODE_FILE" ]; then
        echo "CleanMode: ENABLED"
        echo "System is optimized for maximum performance"
    else
        echo "CleanMode: DISABLED"
        echo "System is using full visual effects"
    fi
}

# =============================================================================
# Main
# =============================================================================
show_help() {
    cat << EOF
AetherOS CleanMode - Performance Toggle

CleanMode disables visual effects for better performance on low-end hardware.
Perfect for:
  - Intel HD Graphics 3000 and below
  - Systems with 4GB RAM or less
  - Older laptops
  - Virtual machines

Usage: $(basename "$0") [OPTIONS]

Options:
  on                Enable CleanMode
  off               Disable CleanMode
  toggle            Toggle CleanMode on/off (default)
  status            Check current status
  --help, -h        Show this help

Examples:
  $(basename "$0")              # Toggle CleanMode
  $(basename "$0") on           # Enable CleanMode
  $(basename "$0") status       # Check if enabled
EOF
}

main() {
    case "${1:-toggle}" in
        on|enable)
            enable_cleanmode
            ;;
        off|disable)
            disable_cleanmode
            ;;
        toggle)
            toggle_cleanmode
            ;;
        status)
            check_status
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

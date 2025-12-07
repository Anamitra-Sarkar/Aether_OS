#!/bin/bash
# =============================================================================
# AetherOS Accessibility Manager
# Controls accessibility features like reduced motion, high contrast, etc.
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/aetheros"
STATE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/aetheros"
REDUCED_MOTION_FILE="$STATE_DIR/.reduced-motion-enabled"
HIGH_CONTRAST_FILE="$STATE_DIR/.high-contrast-enabled"

# =============================================================================
# Enable Reduced Motion
# =============================================================================
enable_reduced_motion() {
    echo "=== Enabling Reduced Motion ==="
    echo ""
    
    # Disable animations in KWin
    if command -v kwriteconfig5 &>/dev/null; then
        kwriteconfig5 --file "$CONFIG_DIR/kwinrc" --group Compositing --key AnimationSpeed 0
        echo "  ✓ Animations disabled"
        
        # Disable various effects
        kwriteconfig5 --file "$CONFIG_DIR/kwinrc" --group Plugins --key slideEnabled false
        kwriteconfig5 --file "$CONFIG_DIR/kwinrc" --group Plugins --key fadeEnabled false
        kwriteconfig5 --file "$CONFIG_DIR/kwinrc" --group Plugins --key kwin4_effect_translucencyEnabled false
        kwriteconfig5 --file "$CONFIG_DIR/kwinrc" --group Plugins --key minimizeanimationEnabled false
        echo "  ✓ Transition effects disabled"
        
        # Disable blur transitions
        kwriteconfig5 --file "$CONFIG_DIR/kwinrc" --group Plugins --key blurEnabled false
        echo "  ✓ Blur transitions disabled"
    fi
    
    # Disable Plasma animations
    if command -v kwriteconfig5 &>/dev/null; then
        kwriteconfig5 --file "$CONFIG_DIR/plasmarc" --group Units --key duration 0
        echo "  ✓ Plasma animations disabled"
    fi
    
    # Save state
    touch "$REDUCED_MOTION_FILE"
    
    # Restart KWin
    if command -v qdbus &>/dev/null; then
        qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
    fi
    
    echo ""
    echo "✓ Reduced Motion enabled"
    echo "  All animations and transitions disabled"
    echo ""
}

# =============================================================================
# Disable Reduced Motion (restore normal)
# =============================================================================
disable_reduced_motion() {
    echo "=== Disabling Reduced Motion ==="
    echo ""
    
    # Re-enable animations
    if command -v kwriteconfig5 &>/dev/null; then
        kwriteconfig5 --file "$CONFIG_DIR/kwinrc" --group Compositing --key AnimationSpeed 3
        echo "  ✓ Animations restored"
        
        # Re-enable effects
        kwriteconfig5 --file "$CONFIG_DIR/kwinrc" --group Plugins --key slideEnabled true
        kwriteconfig5 --file "$CONFIG_DIR/kwinrc" --group Plugins --key fadeEnabled true
        kwriteconfig5 --file "$CONFIG_DIR/kwinrc" --group Plugins --key minimizeanimationEnabled true
        echo "  ✓ Transition effects restored"
    fi
    
    # Restore Plasma animations
    if command -v kwriteconfig5 &>/dev/null; then
        kwriteconfig5 --file "$CONFIG_DIR/plasmarc" --group Units --key duration 200
        echo "  ✓ Plasma animations restored"
    fi
    
    # Remove state
    rm -f "$REDUCED_MOTION_FILE"
    
    # Restart KWin
    if command -v qdbus &>/dev/null; then
        qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
    fi
    
    echo ""
    echo "✓ Reduced Motion disabled"
    echo "  Normal animations restored"
    echo ""
}

# =============================================================================
# Enable High Contrast
# =============================================================================
enable_high_contrast() {
    echo "=== Enabling High Contrast Mode ==="
    echo ""
    
    # Switch to high contrast Plasma theme
    if command -v plasma-apply-colorscheme &>/dev/null; then
        plasma-apply-colorscheme BreezeDark 2>/dev/null || true
        echo "  ✓ Dark theme applied"
    fi
    
    # Increase contrast in KWin
    if command -v kwriteconfig5 &>/dev/null; then
        # Disable blur for better text readability
        kwriteconfig5 --file "$CONFIG_DIR/kwinrc" --group Plugins --key blurEnabled false
        
        # Disable translucency
        kwriteconfig5 --file "$CONFIG_DIR/kwinrc" --group Plugins --key kwin4_effect_translucencyEnabled false
        
        echo "  ✓ Reduced visual complexity"
    fi
    
    # Save state
    touch "$HIGH_CONTRAST_FILE"
    
    # Restart KWin
    if command -v qdbus &>/dev/null; then
        qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
    fi
    
    echo ""
    echo "✓ High Contrast Mode enabled"
    echo "  Better readability for low vision users"
    echo ""
}

# =============================================================================
# Disable High Contrast
# =============================================================================
disable_high_contrast() {
    echo "=== Disabling High Contrast Mode ==="
    echo ""
    
    # Restore normal theme
    if command -v plasma-apply-colorscheme &>/dev/null; then
        plasma-apply-colorscheme BreezeLight 2>/dev/null || true
        echo "  ✓ Normal theme restored"
    fi
    
    # Restore normal KWin settings
    if command -v kwriteconfig5 &>/dev/null; then
        kwriteconfig5 --file "$CONFIG_DIR/kwinrc" --group Plugins --key blurEnabled true
        kwriteconfig5 --file "$CONFIG_DIR/kwinrc" --group Plugins --key kwin4_effect_translucencyEnabled true
        echo "  ✓ Normal visual effects restored"
    fi
    
    # Remove state
    rm -f "$HIGH_CONTRAST_FILE"
    
    # Restart KWin
    if command -v qdbus &>/dev/null; then
        qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
    fi
    
    echo ""
    echo "✓ High Contrast Mode disabled"
    echo "  Normal appearance restored"
    echo ""
}

# =============================================================================
# Show status
# =============================================================================
show_status() {
    echo "=== AetherOS Accessibility Status ==="
    echo ""
    
    # Reduced Motion status
    if [ -f "$REDUCED_MOTION_FILE" ]; then
        echo "Reduced Motion:  ENABLED"
    else
        echo "Reduced Motion:  Disabled"
    fi
    
    # High Contrast status
    if [ -f "$HIGH_CONTRAST_FILE" ]; then
        echo "High Contrast:   ENABLED"
    else
        echo "High Contrast:   Disabled"
    fi
    
    echo ""
}

# =============================================================================
# Help
# =============================================================================
show_help() {
    cat << EOF
AetherOS Accessibility Manager

Controls accessibility features for better usability.

Usage: $(basename "$0") COMMAND

Commands:
  reduce-motion on      Enable reduced motion (disable animations)
  reduce-motion off     Disable reduced motion (restore animations)
  high-contrast on      Enable high contrast mode
  high-contrast off     Disable high contrast mode
  status                Show current accessibility settings
  help                  Show this help

Features:

Reduced Motion:
  • Disables all animations and transitions
  • Disables blur effects
  • Reduces visual distractions
  • Helpful for:
    - Users with vestibular disorders
    - Users who prefer static UI
    - Low-performance systems

High Contrast:
  • Increases contrast for better readability
  • Reduces transparency and blur
  • Helpful for:
    - Users with low vision
    - Users with color blindness
    - Bright/dark environment viewing

Examples:
  $(basename "$0") reduce-motion on    # Disable animations
  $(basename "$0") high-contrast on    # Enable high contrast
  $(basename "$0") status              # Show current settings

Note:
  Changes take effect immediately but require KWin restart
  for full effect. Log out and back in if issues persist.

Additional Accessibility:
  • Screen Reader: Install Orca (orca)
  • Magnifier: Use KDE Magnifier (Meta+Plus)
  • On-Screen Keyboard: Install onboard
  • Color Filters: System Settings → Accessibility

EOF
}

# =============================================================================
# Main
# =============================================================================
main() {
    mkdir -p "$STATE_DIR"
    mkdir -p "$CONFIG_DIR"
    
    case "${1:-status}" in
        reduce-motion|reduced-motion)
            case "${2:-}" in
                on|enable)
                    enable_reduced_motion
                    ;;
                off|disable)
                    disable_reduced_motion
                    ;;
                *)
                    echo "Error: Please specify 'on' or 'off'" >&2
                    echo "Usage: $(basename "$0") reduce-motion [on|off]" >&2
                    exit 1
                    ;;
            esac
            ;;
        high-contrast)
            case "${2:-}" in
                on|enable)
                    enable_high_contrast
                    ;;
                off|disable)
                    disable_high_contrast
                    ;;
                *)
                    echo "Error: Please specify 'on' or 'off'" >&2
                    echo "Usage: $(basename "$0") high-contrast [on|off]" >&2
                    exit 1
                    ;;
            esac
            ;;
        status)
            show_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo "Error: Unknown command: $1" >&2
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"

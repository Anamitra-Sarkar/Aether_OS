#!/bin/bash
# =============================================================================
# AetherOS Adaptive Blur System
# Automatically adjusts blur effects based on GPU capabilities
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
PLASMA_CONFIG="$CONFIG_DIR/kwinrc"
BLUR_MODE_FILE="$CONFIG_DIR/.aether-blur-mode"

# Blur modes
BLUR_HIGH="high"        # For strong GPUs (NVIDIA RTX, AMD RX 6000+, Intel Xe)
BLUR_FROSTED="frosted"  # For mid-range GPUs (Intel HD 4000-6000, older GPUs)
BLUR_OFF="off"          # For very weak GPUs or CleanMode

# =============================================================================
# GPU Detection
# =============================================================================
detect_gpu() {
    local gpu_info
    gpu_info=$(lspci | grep -i "vga\|3d\|display" || echo "")
    
    # Check for high-end GPUs
    if echo "$gpu_info" | grep -iE "rtx|rx 6[0-9]{3}|rx 7[0-9]{3}|intel.*iris.*xe|arc" > /dev/null; then
        echo "$BLUR_HIGH"
        return
    fi
    
    # Check for mid-range GPUs (Intel HD 4000+, older dedicated GPUs)
    if echo "$gpu_info" | grep -iE "hd graphics [4-9][0-9]{3}|uhd|iris|geforce [89][0-9]{2}|radeon.*r[x5-9]|vega" > /dev/null; then
        echo "$BLUR_FROSTED"
        return
    fi
    
    # Default to frosted for safety
    echo "$BLUR_FROSTED"
}

# =============================================================================
# Apply Blur Settings
# =============================================================================
apply_blur_mode() {
    local mode=$1
    
    case $mode in
        $BLUR_HIGH)
            echo "Applying High Blur Mode (Premium visuals)"
            # Enable full blur with high quality settings
            kwriteconfig5 --file "$PLASMA_CONFIG" --group Plugins --key blurEnabled true
            kwriteconfig5 --file "$PLASMA_CONFIG" --group Effect-Blur --key BlurStrength 15
            kwriteconfig5 --file "$PLASMA_CONFIG" --group Effect-Blur --key NoiseStrength 2
            ;;
        $BLUR_FROSTED)
            echo "Applying Frosted Lite Mode (Balanced performance)"
            # Enable moderate blur for better performance
            kwriteconfig5 --file "$PLASMA_CONFIG" --group Plugins --key blurEnabled true
            kwriteconfig5 --file "$PLASMA_CONFIG" --group Effect-Blur --key BlurStrength 8
            kwriteconfig5 --file "$PLASMA_CONFIG" --group Effect-Blur --key NoiseStrength 0
            ;;
        $BLUR_OFF)
            echo "Disabling blur (Maximum performance)"
            # Disable blur completely
            kwriteconfig5 --file "$PLASMA_CONFIG" --group Plugins --key blurEnabled false
            ;;
        *)
            echo "Unknown blur mode: $mode" >&2
            return 1
            ;;
    esac
    
    # Save current mode
    echo "$mode" > "$BLUR_MODE_FILE"
    
    # Restart KWin to apply changes
    if command -v qdbus &> /dev/null; then
        qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
    fi
}

# =============================================================================
# Auto-detect and apply
# =============================================================================
auto_apply() {
    echo "Detecting GPU capabilities..."
    local detected_mode
    detected_mode=$(detect_gpu)
    
    echo "Detected optimal blur mode: $detected_mode"
    apply_blur_mode "$detected_mode"
    
    echo "Blur configuration applied successfully!"
}

# =============================================================================
# Main
# =============================================================================
show_help() {
    cat << EOF
AetherOS Adaptive Blur System

Usage: $(basename "$0") [OPTIONS]

Options:
  auto              Auto-detect GPU and apply optimal blur mode (default)
  high              Enable High Blur Mode (for strong GPUs)
  frosted           Enable Frosted Lite Mode (for mid-range GPUs)
  off               Disable blur effects
  status            Show current blur mode
  --help, -h        Show this help

Examples:
  $(basename "$0") auto         # Auto-detect and apply
  $(basename "$0") frosted      # Force Frosted Lite mode
  $(basename "$0") status       # Check current mode
EOF
}

show_status() {
    if [ -f "$BLUR_MODE_FILE" ]; then
        local current_mode
        current_mode=$(cat "$BLUR_MODE_FILE")
        echo "Current blur mode: $current_mode"
    else
        echo "Blur mode not configured yet"
    fi
}

main() {
    case "${1:-auto}" in
        auto)
            auto_apply
            ;;
        high|$BLUR_HIGH)
            apply_blur_mode "$BLUR_HIGH"
            ;;
        frosted|$BLUR_FROSTED)
            apply_blur_mode "$BLUR_FROSTED"
            ;;
        off|$BLUR_OFF)
            apply_blur_mode "$BLUR_OFF"
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

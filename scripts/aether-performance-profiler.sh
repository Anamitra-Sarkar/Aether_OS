#!/bin/bash
# =============================================================================
# AetherOS Auto Performance Profiler
# Detects hardware and applies optimal performance settings
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
PROFILE_FILE="$CONFIG_DIR/.aether-performance-profile"

# Performance profiles
PROFILE_MAX="max"           # For strong laptops (16GB+ RAM, modern GPU)
PROFILE_BALANCED="balanced" # Default (8-12GB RAM, mid-range GPU)
PROFILE_LITE="lite"         # For weak systems (4-6GB RAM, Intel HD)

# =============================================================================
# Hardware Detection
# =============================================================================
detect_ram_gb() {
    # Get total RAM in GB
    local ram_kb
    ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    echo $((ram_kb / 1024 / 1024))
}

detect_cpu_generation() {
    # Detect CPU generation (Intel/AMD)
    local cpu_info
    cpu_info=$(lscpu | grep "Model name" || echo "")
    
    # Check for modern CPUs (Intel 10th gen+, AMD Ryzen 3000+)
    if echo "$cpu_info" | grep -iE "i[3579]-1[0-9]{4}|ryzen.*[3-9][0-9]{3}" > /dev/null; then
        echo "modern"
        return
    fi
    
    # Check for mid-range CPUs (Intel 6-9th gen, AMD Ryzen 1000-2000)
    if echo "$cpu_info" | grep -iE "i[3579]-[6-9][0-9]{3}|ryzen.*[12][0-9]{3}" > /dev/null; then
        echo "midrange"
        return
    fi
    
    # Older CPUs
    echo "old"
}

detect_gpu_tier() {
    local gpu_info
    gpu_info=$(lspci | grep -i "vga\|3d\|display" || echo "")
    
    # High-end GPUs
    if echo "$gpu_info" | grep -iE "rtx [234][0-9]{3}|rx 6[0-9]{3}|rx 7[0-9]{3}|arc.*[5-9]|iris.*xe" > /dev/null; then
        echo "high"
        return
    fi
    
    # Mid-range GPUs
    if echo "$gpu_info" | grep -iE "gtx [19][0-9]{3}|rx [45][0-9]{3}|hd.*[5-9][0-9]{3}|uhd.*[67][0-9]{2}" > /dev/null; then
        echo "mid"
        return
    fi
    
    # Low-end GPUs (Intel HD 3000-4000, old integrated)
    echo "low"
}

# =============================================================================
# Profile Selection
# =============================================================================
select_optimal_profile() {
    local ram_gb cpu_gen gpu_tier
    
    ram_gb=$(detect_ram_gb)
    cpu_gen=$(detect_cpu_generation)
    gpu_tier=$(detect_gpu_tier)
    
    echo "Hardware detected:"
    echo "  RAM: ${ram_gb}GB"
    echo "  CPU: $cpu_gen generation"
    echo "  GPU: $gpu_tier tier"
    echo ""
    
    # Decision logic
    if [ "$ram_gb" -ge 16 ] && [ "$gpu_tier" = "high" ]; then
        echo "$PROFILE_MAX"
    elif [ "$ram_gb" -le 4 ] || [ "$gpu_tier" = "low" ]; then
        echo "$PROFILE_LITE"
    else
        echo "$PROFILE_BALANCED"
    fi
}

# =============================================================================
# Apply Performance Profile
# =============================================================================
apply_max_profile() {
    echo "Applying MaxMode Profile (Premium performance)..."
    
    # Enable all visual effects
    "$( dirname "$0" )/aether-adaptive-blur.sh" high 2>/dev/null || true
    "$( dirname "$0" )/aether-cleanmode.sh" off 2>/dev/null || true
    
    # Set high animation speed
    kwriteconfig5 --file "${CONFIG_DIR}/kwinrc" --group Compositing --key AnimationSpeed 4
    
    # Enable compositing with best quality
    kwriteconfig5 --file "${CONFIG_DIR}/kwinrc" --group Compositing --key Enabled true
    kwriteconfig5 --file "${CONFIG_DIR}/kwinrc" --group Compositing --key GLTextureFilter 2
    
    echo "✓ MaxMode enabled - All visual effects at maximum quality"
}

apply_balanced_profile() {
    echo "Applying Balanced Profile (Default)..."
    
    # Moderate visual effects
    "$( dirname "$0" )/aether-adaptive-blur.sh" frosted 2>/dev/null || true
    "$( dirname "$0" )/aether-cleanmode.sh" off 2>/dev/null || true
    
    # Normal animation speed
    kwriteconfig5 --file "${CONFIG_DIR}/kwinrc" --group Compositing --key AnimationSpeed 3
    
    # Standard compositing
    kwriteconfig5 --file "${CONFIG_DIR}/kwinrc" --group Compositing --key Enabled true
    kwriteconfig5 --file "${CONFIG_DIR}/kwinrc" --group Compositing --key GLTextureFilter 1
    
    echo "✓ Balanced mode enabled - Good balance of performance and visuals"
}

apply_lite_profile() {
    echo "Applying LiteMode Profile (Maximum performance)..."
    
    # Minimal visual effects
    "$( dirname "$0" )/aether-cleanmode.sh" on 2>/dev/null || true
    
    # Fast animations
    kwriteconfig5 --file "${CONFIG_DIR}/kwinrc" --group Compositing --key AnimationSpeed 2
    
    # Basic compositing
    kwriteconfig5 --file "${CONFIG_DIR}/kwinrc" --group Compositing --key Enabled true
    kwriteconfig5 --file "${CONFIG_DIR}/kwinrc" --group Compositing --key GLTextureFilter 0
    
    echo "✓ LiteMode enabled - Optimized for low-end hardware"
}

apply_profile() {
    local profile=$1
    
    case $profile in
        $PROFILE_MAX)
            apply_max_profile
            ;;
        $PROFILE_BALANCED)
            apply_balanced_profile
            ;;
        $PROFILE_LITE)
            apply_lite_profile
            ;;
        *)
            echo "Unknown profile: $profile" >&2
            return 1
            ;;
    esac
    
    # Save profile
    echo "$profile" > "$PROFILE_FILE"
    
    # Restart KWin
    if command -v qdbus &> /dev/null; then
        qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
    fi
}

# =============================================================================
# Auto Profile
# =============================================================================
auto_profile() {
    echo "=== AetherOS Performance Profiler ==="
    echo ""
    
    local optimal_profile
    optimal_profile=$(select_optimal_profile)
    
    echo "Recommended profile: $optimal_profile"
    echo ""
    
    apply_profile "$optimal_profile"
    
    echo ""
    echo "Performance profile applied successfully!"
    echo "Restart your session for all changes to take effect."
}

# =============================================================================
# Main
# =============================================================================
show_help() {
    cat << EOF
AetherOS Auto Performance Profiler

Automatically detects hardware and applies optimal performance settings.

Usage: $(basename "$0") [OPTIONS]

Options:
  auto              Auto-detect hardware and apply best profile (default)
  max               Force MaxMode (for powerful systems)
  balanced          Force Balanced mode (default preset)
  lite              Force LiteMode (for weak hardware)
  status            Show current profile
  --help, -h        Show this help

Profiles:
  MaxMode      - 16GB+ RAM, high-end GPU, all effects enabled
  Balanced     - 8-12GB RAM, mid-range GPU, balanced settings
  LiteMode     - 4-6GB RAM, integrated GPU, minimal effects

Examples:
  $(basename "$0")              # Auto-detect and apply
  $(basename "$0") lite         # Force LiteMode
  $(basename "$0") status       # Check current profile
EOF
}

show_status() {
    if [ -f "$PROFILE_FILE" ]; then
        local current_profile
        current_profile=$(cat "$PROFILE_FILE")
        echo "Current performance profile: $current_profile"
    else
        echo "No performance profile configured yet"
    fi
}

main() {
    case "${1:-auto}" in
        auto)
            auto_profile
            ;;
        max|$PROFILE_MAX)
            apply_profile "$PROFILE_MAX"
            ;;
        balanced|$PROFILE_BALANCED)
            apply_profile "$PROFILE_BALANCED"
            ;;
        lite|$PROFILE_LITE)
            apply_profile "$PROFILE_LITE"
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

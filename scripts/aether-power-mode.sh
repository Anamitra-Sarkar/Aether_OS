#!/bin/bash
# =============================================================================
# AetherOS Power Mode Script
# CLI wrapper for power-profiles-daemon with TLP fallback
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
LOG_DIR="$HOME/.local/share/aetheros/logs"
LOG_FILE="${LOG_DIR}/power-mode.log"

# Power profile names
PROFILE_SAVER="power-saver"
PROFILE_BALANCED="balanced"
PROFILE_PERFORMANCE="performance"

# =============================================================================
# Colors
# =============================================================================
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
RESET="\033[0m"

# =============================================================================
# Logging
# =============================================================================
log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo -e "$message"
    mkdir -p "$LOG_DIR"
    echo "$message" >> "$LOG_FILE" 2>/dev/null || true
}

log_error() {
    log "${RED}[ERROR]${RESET} $1"
}

log_success() {
    log "${GREEN}[OK]${RESET} $1"
}

log_info() {
    log "${BLUE}[INFO]${RESET} $1"
}

# =============================================================================
# Detect Power Management Backend
# =============================================================================
detect_backend() {
    if command -v powerprofilesctl &>/dev/null; then
        echo "power-profiles-daemon"
    elif command -v tlp &>/dev/null; then
        echo "tlp"
    else
        echo "none"
    fi
}

# =============================================================================
# Get Current Power Profile
# =============================================================================
get_current_profile() {
    local backend
    backend=$(detect_backend)
    
    case "$backend" in
        power-profiles-daemon)
            powerprofilesctl get 2>/dev/null || echo "unknown"
            ;;
        tlp)
            # TLP doesn't have direct profile names, infer from settings
            if tlp-stat -s 2>/dev/null | grep -q "power save"; then
                echo "power-saver"
            elif tlp-stat -s 2>/dev/null | grep -q "performance"; then
                echo "performance"
            else
                echo "balanced"
            fi
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# =============================================================================
# Set Power Profile
# =============================================================================
set_profile() {
    local profile="$1"
    local backend
    backend=$(detect_backend)
    
    # Validate profile name
    case "$profile" in
        power-saver|saver|battery)
            profile="$PROFILE_SAVER"
            ;;
        balanced|default)
            profile="$PROFILE_BALANCED"
            ;;
        performance|high)
            profile="$PROFILE_PERFORMANCE"
            ;;
        *)
            log_error "Unknown profile: $profile"
            echo "Valid profiles: power-saver, balanced, performance"
            return 1
            ;;
    esac
    
    log_info "Setting power profile to: $profile"
    
    case "$backend" in
        power-profiles-daemon)
            if powerprofilesctl set "$profile" 2>/dev/null; then
                log_success "Power profile set to: $profile"
                return 0
            else
                log_error "Failed to set power profile"
                return 1
            fi
            ;;
        tlp)
            # TLP uses different approach - switch between AC and battery modes
            case "$profile" in
                power-saver)
                    sudo tlp bat 2>/dev/null || {
                        log_error "Failed to set TLP to battery mode"
                        return 1
                    }
                    ;;
                performance)
                    sudo tlp ac 2>/dev/null || {
                        log_error "Failed to set TLP to AC mode"
                        return 1
                    }
                    ;;
                *)
                    # Balanced - let TLP auto-detect
                    sudo tlp start 2>/dev/null || true
                    ;;
            esac
            log_success "TLP mode set"
            return 0
            ;;
        *)
            log_error "No power management backend found"
            echo "Install power-profiles-daemon or tlp for power management."
            return 1
            ;;
    esac
}

# =============================================================================
# List Available Profiles
# =============================================================================
list_profiles() {
    local backend
    backend=$(detect_backend)
    
    echo ""
    echo -e "${CYAN}Available Power Profiles${RESET}"
    echo "========================="
    echo ""
    
    case "$backend" in
        power-profiles-daemon)
            powerprofilesctl list 2>/dev/null || {
                echo "  power-saver"
                echo "  balanced"
                echo "  performance"
            }
            ;;
        tlp)
            echo "  power-saver  (TLP battery mode)"
            echo "  balanced     (TLP auto mode)"
            echo "  performance  (TLP AC mode)"
            ;;
        *)
            echo "  No power management backend available"
            echo ""
            echo "  Install power-profiles-daemon:"
            echo "    sudo apt install power-profiles-daemon"
            ;;
    esac
    
    echo ""
}

# =============================================================================
# Show Status
# =============================================================================
show_status() {
    local backend
    local current
    
    backend=$(detect_backend)
    current=$(get_current_profile)
    
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║     AetherOS Power Mode Status        ║${RESET}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${RESET}"
    echo ""
    
    echo -e "  Backend: ${YELLOW}$backend${RESET}"
    echo -e "  Current: ${GREEN}$current${RESET}"
    
    # Show battery info if available
    if [[ -d /sys/class/power_supply/BAT0 ]]; then
        local capacity
        local status
        capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "?")
        status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "?")
        echo ""
        echo -e "  Battery: ${capacity}% (${status})"
    fi
    
    echo ""
}

# =============================================================================
# Show Help
# =============================================================================
show_help() {
    cat << 'EOF'
AetherOS Power Mode Script

Usage: aether-power-mode.sh [COMMAND|PROFILE]

Commands:
  --status, -s      Show current power profile status
  --list, -l        List available profiles
  --help, -h        Show this help

Profiles:
  --battery         Set to power-saver mode
  --balanced        Set to balanced mode (default)
  --performance     Set to performance mode

Or use profile names directly:
  power-saver       Maximum battery life
  balanced          Balance of power and performance
  performance       Maximum performance

Examples:
  aether-power-mode.sh --status
  aether-power-mode.sh --battery
  aether-power-mode.sh performance

Note: Some operations may require sudo for TLP backend.
EOF
}

# =============================================================================
# Main
# =============================================================================
main() {
    local command="${1:-}"
    
    case "$command" in
        --help|-h|"")
            show_help
            exit 0
            ;;
        --status|-s|status)
            show_status
            ;;
        --list|-l|list)
            list_profiles
            ;;
        --battery|battery|power-saver|saver)
            set_profile "power-saver"
            ;;
        --balanced|balanced|default)
            set_profile "balanced"
            ;;
        --performance|performance|high)
            set_profile "performance"
            ;;
        *)
            # Try to set as profile name
            set_profile "$command"
            ;;
    esac
}

main "$@"

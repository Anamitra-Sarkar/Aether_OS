#!/bin/bash
# =============================================================================
# AetherOS Updates Script
# Checks for and summarizes available updates from APT and Flatpak
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
LOG_DIR="$HOME/.local/share/aetheros/logs"
LOG_FILE="${LOG_DIR}/updates.log"

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

log_info() {
    log "${BLUE}[INFO]${RESET} $1"
}

log_success() {
    log "${GREEN}[OK]${RESET} $1"
}

log_warn() {
    log "${YELLOW}[WARN]${RESET} $1"
}

# =============================================================================
# Check APT Updates
# =============================================================================
check_apt_updates() {
    # Logs go to stderr so they don't pollute captured output
    echo "[INFO] Checking APT updates..." >&2
    
    local apt_updates=0
    local apt_security=0
    
    # Update package lists (may require sudo for full refresh)
    if [[ $EUID -eq 0 ]]; then
        apt-get update -qq 2>/dev/null || true
    else
        # Try without sudo - use cached data
        true
    fi
    
    # Count upgradable packages
    if command -v apt &>/dev/null; then
        apt_updates=$(apt list --upgradable 2>/dev/null | grep -c "upgradable" || echo 0)
        apt_security=$(apt list --upgradable 2>/dev/null | grep -ic "security" || echo 0)
    fi
    
    echo "$apt_updates:$apt_security"
}

# =============================================================================
# Check Flatpak Updates
# =============================================================================
check_flatpak_updates() {
    echo "[INFO] Checking Flatpak updates..." >&2
    
    local flatpak_updates=0
    
    if command -v flatpak &>/dev/null; then
        flatpak_updates=$(flatpak remote-ls --updates 2>/dev/null | wc -l || echo 0)
    fi
    
    echo "$flatpak_updates"
}

# =============================================================================
# Display Summary
# =============================================================================
display_summary() {
    local apt_result
    local flatpak_result
    
    apt_result=$(check_apt_updates)
    flatpak_result=$(check_flatpak_updates)
    
    local apt_total="${apt_result%%:*}"
    local apt_security="${apt_result##*:}"
    
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║       AetherOS Update Summary             ║${RESET}"
    echo -e "${CYAN}╚═══════════════════════════════════════════╝${RESET}"
    echo ""
    
    # APT Updates
    if [[ "$apt_total" -gt 0 ]]; then
        echo -e "  📦 ${YELLOW}APT Packages:${RESET} $apt_total update(s) available"
        if [[ "$apt_security" -gt 0 ]]; then
            echo -e "     ${RED}└─ $apt_security security update(s)${RESET}"
        fi
    else
        echo -e "  📦 ${GREEN}APT Packages:${RESET} Up to date"
    fi
    
    # Flatpak Updates
    if [[ "$flatpak_result" -gt 0 ]]; then
        echo -e "  📱 ${YELLOW}Flatpak Apps:${RESET} $flatpak_result update(s) available"
    else
        echo -e "  📱 ${GREEN}Flatpak Apps:${RESET} Up to date"
    fi
    
    echo ""
    
    # Total summary
    local total=$((apt_total + flatpak_result))
    if [[ "$total" -gt 0 ]]; then
        echo -e "  ${YELLOW}Total: $total update(s) available${RESET}"
        echo ""
        echo "  To update:"
        echo "    • APT: sudo apt update && sudo apt upgrade"
        echo "    • Flatpak: flatpak update"
        echo "    • Or use Discover for graphical updates"
    else
        echo -e "  ${GREEN}✓ Your system is up to date!${RESET}"
    fi
    
    echo ""
    
    # Return total for scripting purposes
    return $total
}

# =============================================================================
# JSON Output
# =============================================================================
output_json() {
    local apt_result
    local flatpak_result
    
    apt_result=$(check_apt_updates)
    flatpak_result=$(check_flatpak_updates)
    
    local apt_total="${apt_result%%:*}"
    local apt_security="${apt_result##*:}"
    
    cat << EOF
{
  "apt": {
    "total": $apt_total,
    "security": $apt_security
  },
  "flatpak": {
    "total": $flatpak_result
  },
  "total": $((apt_total + flatpak_result)),
  "timestamp": "$(date -Iseconds)"
}
EOF
}

# =============================================================================
# Notify User (for timer/cron)
# =============================================================================
notify_user() {
    local apt_result
    local flatpak_result
    
    apt_result=$(check_apt_updates)
    flatpak_result=$(check_flatpak_updates)
    
    local apt_total="${apt_result%%:*}"
    local total=$((apt_total + flatpak_result))
    
    if [[ "$total" -gt 0 ]]; then
        log_info "Found $total update(s) available"
        
        # Send desktop notification if possible
        if command -v notify-send &>/dev/null; then
            notify-send -i software-update-available "AetherOS Updates" \
                "$total update(s) available. Open Aether Updater to install." 2>/dev/null || true
        fi
        
        return 0
    else
        log_info "System is up to date"
        return 0
    fi
}

# =============================================================================
# Show Help
# =============================================================================
show_help() {
    cat << 'EOF'
AetherOS Updates Script

Usage: aether-updates.sh [COMMAND]

Commands:
  summary     Show update summary (default)
  json        Output update info as JSON
  notify      Check and send desktop notification
  apt         Show only APT updates
  flatpak     Show only Flatpak updates

Options:
  --help      Show this help

Examples:
  ./aether-updates.sh
  ./aether-updates.sh json
  ./aether-updates.sh notify

Note: For most accurate APT results, run with sudo.
EOF
}

# =============================================================================
# Main
# =============================================================================
main() {
    local command="${1:-summary}"
    
    case "$command" in
        --help|-h)
            show_help
            exit 0
            ;;
        summary)
            display_summary
            ;;
        json)
            output_json
            ;;
        notify)
            notify_user
            ;;
        apt)
            local result
            result=$(check_apt_updates)
            echo "APT updates: ${result%%:*} (${result##*:} security)"
            ;;
        flatpak)
            local result
            result=$(check_flatpak_updates)
            echo "Flatpak updates: $result"
            ;;
        *)
            echo "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"

#!/bin/bash
# =============================================================================
# AetherOS Security Update Script
# Checks and installs security updates from Ubuntu security pocket
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
LOG_DIR="/var/log/aetheros"
LOG_FILE="${LOG_DIR}/security-updates.log"
LOCK_FILE="/var/lock/aether-security-update.lock"

# =============================================================================
# Colors
# =============================================================================
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
RESET="\033[0m"

# =============================================================================
# Logging
# =============================================================================
log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo -e "$message"
    if [[ $EUID -eq 0 ]]; then
        mkdir -p "$LOG_DIR"
        echo "$message" >> "$LOG_FILE" 2>/dev/null || true
    fi
}

log_error() {
    log "${RED}[ERROR]${RESET} $1"
}

log_success() {
    log "${GREEN}[SUCCESS]${RESET} $1"
}

log_info() {
    log "${BLUE}[INFO]${RESET} $1"
}

log_warn() {
    log "${YELLOW}[WARN]${RESET} $1"
}

# =============================================================================
# Check if running as root
# =============================================================================
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# =============================================================================
# Lock to prevent concurrent runs
# =============================================================================
acquire_lock() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid
        pid=$(cat "$LOCK_FILE" 2>/dev/null || true)
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            log_error "Another security update is already running (PID: $pid)"
            exit 1
        fi
    fi
    echo $$ > "$LOCK_FILE"
    trap 'rm -f "$LOCK_FILE"' EXIT
}

# =============================================================================
# Check for security updates
# =============================================================================
check_security_updates() {
    log_info "Checking for security updates..."

    # Update package lists
    apt-get update -q || {
        log_error "Failed to update package lists"
        return 1
    }

    # Get list of security updates
    local updates
    updates=$(apt-get -s dist-upgrade 2>/dev/null | grep -i "^Inst" | grep -i "security" | wc -l)

    echo "$updates"
}

# =============================================================================
# List security updates
# =============================================================================
list_security_updates() {
    log_info "Listing available security updates..."
    
    apt-get update -q >/dev/null 2>&1 || true
    
    # Show upgradable packages from security repository
    apt list --upgradable 2>/dev/null | grep -i "security" || {
        log_info "No security updates available"
        return 0
    }
}

# =============================================================================
# Install security updates
# =============================================================================
install_security_updates() {
    log_info "Installing security updates..."

    export DEBIAN_FRONTEND=noninteractive

    # First, update package lists
    apt-get update -q || {
        log_error "Failed to update package lists"
        return 1
    }

    # Install only security updates using unattended-upgrades pattern
    # This approach filters packages from the security pocket
    local release
    release=$(lsb_release -cs 2>/dev/null || echo "noble")
    
    # Use apt with specific origin for security updates
    apt-get -s dist-upgrade 2>/dev/null | grep -i "^Inst" | grep -i "security" | awk '{print $2}' | while read -r pkg; do
        if [[ -n "$pkg" ]]; then
            log_info "Upgrading security package: $pkg"
            apt-get install -y --only-upgrade "$pkg" 2>&1 | while read -r line; do
                log "$line"
            done
        fi
    done

    log_success "Security updates completed"
}

# =============================================================================
# Check and notify (for timer/cron)
# =============================================================================
check_and_notify() {
    local count
    count=$(check_security_updates)

    if [[ "$count" -gt 0 ]]; then
        log_info "Found $count security update(s) available"
        
        # Try to send a desktop notification if possible
        if command -v notify-send &>/dev/null; then
            # Find active user sessions and notify
            for user in $(who | awk '{print $1}' | sort -u); do
                local uid
                uid=$(id -u "$user" 2>/dev/null || true)
                if [[ -n "$uid" ]]; then
                    sudo -u "$user" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${uid}/bus" \
                        notify-send -i security-high "AetherOS Security" \
                        "$count security update(s) available. Open Aether Updater to install." 2>/dev/null || true
                fi
            done
        fi
        
        return 0
    else
        log_info "No security updates available"
        return 0
    fi
}

# =============================================================================
# Show Help
# =============================================================================
show_help() {
    cat << 'EOF'
AetherOS Security Update Script

Usage: aether-security-update.sh [COMMAND]

Commands:
  check       Check for available security updates (default)
  list        List available security updates
  install     Install all security updates
  notify      Check and send desktop notification if updates available

Options:
  --help      Show this help

Examples:
  sudo ./aether-security-update.sh check
  sudo ./aether-security-update.sh install
  sudo ./aether-security-update.sh notify

This script requires root privileges.
EOF
}

# =============================================================================
# Main
# =============================================================================
main() {
    local command="${1:-check}"

    case "$command" in
        --help|-h)
            show_help
            exit 0
            ;;
        check)
            check_root
            acquire_lock
            local count
            count=$(check_security_updates)
            if [[ "$count" -gt 0 ]]; then
                log_success "Found $count security update(s) available"
                exit 0
            else
                log_info "No security updates available"
                exit 0
            fi
            ;;
        list)
            check_root
            list_security_updates
            ;;
        install)
            check_root
            acquire_lock
            install_security_updates
            ;;
        notify)
            check_root
            acquire_lock
            check_and_notify
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"

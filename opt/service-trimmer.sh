#!/bin/bash
# =============================================================================
# AetherOS Service Trimmer Script
# Disables unnecessary services for a lean, fast system
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
DRY_RUN=false
VERBOSE=false

# Services to disable for live session
LIVE_SESSION_DISABLE=(
    "apt-daily.timer"
    "apt-daily-upgrade.timer"
    "apt-daily.service"
    "apt-daily-upgrade.service"
    "unattended-upgrades.service"
    "packagekit.service"
    "packagekit-offline-update.service"
)

# Services that are safe to disable for most desktop users
OPTIONAL_DISABLE=(
    "snapd.service"
    "snapd.socket"
    "snapd.seeded.service"
    "cups.service"
    "cups-browsed.service"
    "ModemManager.service"
    "bluetooth.service"
    "accounts-daemon.service"
    "avahi-daemon.service"
    "speech-dispatcher.service"
    "whoopsie.service"
    "kerneloops.service"
    "apport.service"
)

# Heavy services that may slow down boot
HEAVY_SERVICES=(
    "tracker-miner-fs-3.service"
    "tracker-extract-3.service"
    "tracker-miner-rss-3.service"
    "evolution-data-server.service"
    "evolution-calendar-factory.service"
    "evolution-addressbook-factory.service"
)

# =============================================================================
# Logging
# =============================================================================
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        log "$1"
    fi
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

# =============================================================================
# Check if running as root
# =============================================================================
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# =============================================================================
# Check if Live Session
# =============================================================================
is_live_session() {
    [[ -f /run/live/medium ]] || [[ -d /cdrom ]] || grep -q "boot=casper" /proc/cmdline 2>/dev/null
}

# =============================================================================
# Get Service Status
# =============================================================================
get_service_status() {
    local service="$1"
    
    if systemctl is-enabled "$service" &>/dev/null; then
        if systemctl is-active "$service" &>/dev/null; then
            echo "enabled (active)"
        else
            echo "enabled (inactive)"
        fi
    else
        echo "disabled"
    fi
}

# =============================================================================
# Disable Service
# =============================================================================
disable_service() {
    local service="$1"
    
    if ! systemctl list-unit-files | grep -q "^$service"; then
        log_verbose "Service not found: $service"
        return 0
    fi
    
    local status
    status=$(get_service_status "$service")
    
    if [[ "$status" == "disabled" ]]; then
        log_verbose "Already disabled: $service"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log "Would disable: $service (currently $status)"
    else
        log "Disabling: $service"
        systemctl stop "$service" 2>/dev/null || true
        systemctl disable "$service" 2>/dev/null || true
        systemctl mask "$service" 2>/dev/null || true
    fi
}

# =============================================================================
# Enable Service
# =============================================================================
enable_service() {
    local service="$1"
    
    if ! systemctl list-unit-files | grep -q "^$service"; then
        log_verbose "Service not found: $service"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log "Would enable: $service"
    else
        log "Enabling: $service"
        systemctl unmask "$service" 2>/dev/null || true
        systemctl enable "$service" 2>/dev/null || true
    fi
}

# =============================================================================
# Disable Live Session Services
# =============================================================================
disable_live_services() {
    log "=== Disabling Live Session Services ==="
    
    for service in "${LIVE_SESSION_DISABLE[@]}"; do
        disable_service "$service"
    done
}

# =============================================================================
# Disable Optional Services
# =============================================================================
disable_optional_services() {
    log "=== Disabling Optional Services ==="
    
    for service in "${OPTIONAL_DISABLE[@]}"; do
        disable_service "$service"
    done
}

# =============================================================================
# Disable Heavy Services
# =============================================================================
disable_heavy_services() {
    log "=== Disabling Heavy Services ==="
    
    for service in "${HEAVY_SERVICES[@]}"; do
        disable_service "$service"
    done
}

# =============================================================================
# Show Service Status
# =============================================================================
show_status() {
    log "=== Service Status ==="
    
    echo ""
    echo "Live Session Services:"
    for service in "${LIVE_SESSION_DISABLE[@]}"; do
        if systemctl list-unit-files | grep -q "^$service"; then
            printf "  %-40s %s\n" "$service" "$(get_service_status "$service")"
        fi
    done
    
    echo ""
    echo "Optional Services:"
    for service in "${OPTIONAL_DISABLE[@]}"; do
        if systemctl list-unit-files | grep -q "^$service"; then
            printf "  %-40s %s\n" "$service" "$(get_service_status "$service")"
        fi
    done
    
    echo ""
    echo "Heavy Services:"
    for service in "${HEAVY_SERVICES[@]}"; do
        if systemctl list-unit-files | grep -q "^$service"; then
            printf "  %-40s %s\n" "$service" "$(get_service_status "$service")"
        fi
    done
}

# =============================================================================
# Interactive Mode
# =============================================================================
interactive_mode() {
    log "=== Interactive Service Trimmer ==="
    
    echo ""
    echo "This will show you services that can be disabled."
    echo "Press Enter to review each category, or Ctrl+C to exit."
    echo ""
    
    read -p "Disable live session services (apt-daily, etc.)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        disable_live_services
    fi
    
    read -p "Disable optional services (snapd, cups, modem-manager, etc.)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        disable_optional_services
    fi
    
    read -p "Disable heavy services (tracker, evolution, etc.)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        disable_heavy_services
    fi
    
    echo ""
    show_status
}

# =============================================================================
# Show Help
# =============================================================================
show_help() {
    cat << 'EOF'
AetherOS Service Trimmer

Usage: service-trimmer.sh [OPTIONS] [COMMAND]

Commands:
  all         Disable all non-essential services
  live        Disable only live session services
  optional    Disable optional services
  heavy       Disable heavy indexing services
  status      Show current service status
  interactive Interactive mode (asks before disabling)

Options:
  -n, --dry-run    Show what would be done without making changes
  -v, --verbose    Show more detailed output
  -h, --help       Show this help

Examples:
  ./service-trimmer.sh status
  ./service-trimmer.sh --dry-run all
  ./service-trimmer.sh live
  ./service-trimmer.sh interactive
EOF
}

# =============================================================================
# Main
# =============================================================================
main() {
    local command="${1:-}"
    
    # Check for root first
    if [[ "$command" != "--help" ]] && [[ "$command" != "-h" ]]; then
        check_root
    fi
    
    case "$command" in
        all)
            disable_live_services
            disable_optional_services
            disable_heavy_services
            show_status
            ;;
        live)
            disable_live_services
            show_status
            ;;
        optional)
            disable_optional_services
            show_status
            ;;
        heavy)
            disable_heavy_services
            show_status
            ;;
        status)
            show_status
            ;;
        interactive)
            interactive_mode
            ;;
        --help|-h)
            show_help
            ;;
        "")
            # Default: auto-detect live session
            if is_live_session; then
                log "Detected live session"
                disable_live_services
            fi
            show_status
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Parse global options
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

main "$@"

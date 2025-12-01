#!/bin/bash
# =============================================================================
# AetherOS Health Check Script
# Performs system health checks and returns a summary with PASS/FAIL status
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
LOG_DIR="${HOME}/.local/share/aetheros/logs"
LOG_FILE="${LOG_DIR}/health-check-$(date +%Y%m%d-%H%M%S).log"
EXIT_CODE=0

# Thresholds
DISK_WARN_PERCENT=80
DISK_CRIT_PERCENT=95

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
    mkdir -p "$LOG_DIR"
    echo "$message" >> "$LOG_FILE" 2>/dev/null || true
}

log_pass() {
    log "${GREEN}[PASS]${RESET} $1"
}

log_fail() {
    log "${RED}[FAIL]${RESET} $1"
    EXIT_CODE=1
}

log_warn() {
    log "${YELLOW}[WARN]${RESET} $1"
}

log_info() {
    log "${BLUE}[INFO]${RESET} $1"
}

# =============================================================================
# Check Disk Space
# =============================================================================
check_disk_space() {
    log_info "Checking disk space..."

    for mount_point in / /home; do
        if ! mountpoint -q "$mount_point" 2>/dev/null && [[ "$mount_point" != "/" ]]; then
            continue
        fi

        local usage
        usage=$(df -h "$mount_point" 2>/dev/null | awk 'NR==2 {gsub(/%/,"",$5); print $5}')
        
        if [[ -z "$usage" ]]; then
            log_warn "Could not determine disk usage for $mount_point"
            continue
        fi

        if [[ "$usage" -ge "$DISK_CRIT_PERCENT" ]]; then
            log_fail "Disk usage on $mount_point is critical: ${usage}%"
        elif [[ "$usage" -ge "$DISK_WARN_PERCENT" ]]; then
            log_warn "Disk usage on $mount_point is high: ${usage}%"
        else
            log_pass "Disk usage on $mount_point: ${usage}%"
        fi
    done
}

# =============================================================================
# Check ZRAM Status
# =============================================================================
check_zram() {
    log_info "Checking ZRAM status..."

    if [[ -e /dev/zram0 ]] && swapon --show 2>/dev/null | grep -q zram; then
        local zram_size
        zram_size=$(cat /sys/block/zram0/disksize 2>/dev/null || echo 0)
        local zram_mb=$((zram_size / 1024 / 1024))
        log_pass "ZRAM is active with ${zram_mb}MB configured"
    else
        log_warn "ZRAM is not active (optional for performance)"
    fi
}

# =============================================================================
# Check Important Services
# =============================================================================
check_services() {
    log_info "Checking important services..."

    local services=(
        "NetworkManager:Network Manager"
        "sddm:Display Manager"
        "pipewire:Audio Server"
    )

    for service_entry in "${services[@]}"; do
        local service_name="${service_entry%%:*}"
        local service_desc="${service_entry##*:}"

        if systemctl is-active --quiet "$service_name" 2>/dev/null; then
            log_pass "$service_desc ($service_name) is running"
        elif systemctl is-enabled --quiet "$service_name" 2>/dev/null; then
            log_warn "$service_desc ($service_name) is enabled but not running"
        else
            log_fail "$service_desc ($service_name) is not running"
        fi
    done

    # Bluetooth is optional
    if systemctl is-active --quiet bluetooth 2>/dev/null; then
        log_pass "Bluetooth service is running"
    else
        log_info "Bluetooth service is not running (optional)"
    fi
}

# =============================================================================
# Check APT/DPKG Status
# =============================================================================
check_apt_status() {
    log_info "Checking APT/DPKG status..."

    # Check for dpkg lock
    if [[ -f /var/lib/dpkg/lock-frontend ]]; then
        if fuser /var/lib/dpkg/lock-frontend &>/dev/null; then
            log_fail "DPKG is locked - another package operation may be running"
        else
            log_pass "DPKG is not locked"
        fi
    else
        log_pass "DPKG lock file not present"
    fi

    # Check for apt lock
    if [[ -f /var/lib/apt/lists/lock ]]; then
        if fuser /var/lib/apt/lists/lock &>/dev/null; then
            log_warn "APT lists are locked - package list update in progress"
        else
            log_pass "APT is not locked"
        fi
    else
        log_pass "APT lock file not present"
    fi

    # Check for broken packages
    if command -v dpkg &>/dev/null; then
        local broken
        broken=$(dpkg --audit 2>/dev/null | wc -l || echo 0)
        if [[ "$broken" -gt 0 ]]; then
            log_fail "Found $broken broken package(s) - run 'sudo dpkg --configure -a'"
        else
            log_pass "No broken packages detected"
        fi
    fi
}

# =============================================================================
# Check Memory Status
# =============================================================================
check_memory() {
    log_info "Checking memory status..."

    local mem_avail
    mem_avail=$(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo 2>/dev/null)
    local mem_total
    mem_total=$(awk '/MemTotal/{print int($2/1024)}' /proc/meminfo 2>/dev/null)

    if [[ -n "$mem_avail" ]] && [[ -n "$mem_total" ]]; then
        local percent=$((100 * mem_avail / mem_total))
        if [[ "$mem_avail" -lt 256 ]]; then
            log_fail "Available memory critically low: ${mem_avail}MB (${percent}% free)"
        elif [[ "$mem_avail" -lt 512 ]]; then
            log_warn "Available memory low: ${mem_avail}MB (${percent}% free)"
        else
            log_pass "Available memory: ${mem_avail}MB of ${mem_total}MB (${percent}% free)"
        fi
    else
        log_warn "Could not determine memory status"
    fi
}

# =============================================================================
# Check Firewall Status
# =============================================================================
check_firewall() {
    log_info "Checking firewall status..."

    if command -v ufw &>/dev/null; then
        local status
        status=$(sudo ufw status 2>/dev/null | head -1 || echo "unknown")
        if echo "$status" | grep -qi "active"; then
            log_pass "Firewall (ufw) is active"
        else
            log_warn "Firewall (ufw) is not active - consider enabling with 'sudo ufw enable'"
        fi
    else
        log_info "UFW not installed (firewall check skipped)"
    fi
}

# =============================================================================
# Show Summary
# =============================================================================
show_summary() {
    echo ""
    log "=============================================="
    log "AetherOS Health Check Summary"
    log "=============================================="
    
    if [[ $EXIT_CODE -eq 0 ]]; then
        log "${GREEN}All checks passed!${RESET}"
    else
        log "${RED}Some checks failed. Review the output above.${RESET}"
    fi
    
    log ""
    log "Log saved to: $LOG_FILE"
}

# =============================================================================
# Show Help
# =============================================================================
show_help() {
    cat << 'EOF'
AetherOS Health Check Script

Usage: aether-health.sh [OPTIONS]

Options:
  --quiet       Only show FAIL messages
  --json        Output in JSON format (TODO)
  --help        Show this help

Checks performed:
  - Disk space on / and /home
  - ZRAM swap status
  - Important services (NetworkManager, SDDM, PipeWire, Bluetooth)
  - APT/DPKG lock and broken packages
  - Memory availability
  - Firewall status

Exit codes:
  0 - All checks passed
  1 - One or more checks failed
EOF
}

# =============================================================================
# Main
# =============================================================================
main() {
    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
        --quiet|-q)
            # Quiet mode - suppress non-fail messages
            # TODO: Implement quiet mode
            ;;
    esac

    echo ""
    log "=============================================="
    log "AetherOS Health Check"
    log "=============================================="
    echo ""

    check_disk_space
    check_zram
    check_services
    check_apt_status
    check_memory
    check_firewall

    show_summary

    exit $EXIT_CODE
}

main "$@"

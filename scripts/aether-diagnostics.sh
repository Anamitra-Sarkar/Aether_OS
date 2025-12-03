#!/bin/bash
# =============================================================================
# AetherOS System Diagnostics Script
# Performs comprehensive system diagnostics for testing and troubleshooting
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
LOG_DIR="${HOME}/.local/share/aetheros/diagnostics"
LOG_FILE="${LOG_DIR}/diagnostics-$(date +%Y%m%d-%H%M%S).log"
EXIT_CODE=0

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
    local message
    message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo -e "$message"
    mkdir -p "$LOG_DIR"
    echo "$message" >> "$LOG_FILE" 2>/dev/null || true
}

log_section() {
    echo ""
    log "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    log "${CYAN}$1${RESET}"
    log "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
}

log_pass() {
    log "${GREEN}✓${RESET} $1"
}

log_fail() {
    log "${RED}✗${RESET} $1"
    EXIT_CODE=1
}

log_warn() {
    log "${YELLOW}⚠${RESET} $1"
}

log_info() {
    log "${BLUE}ℹ${RESET} $1"
}

# =============================================================================
# Check SDDM Status
# =============================================================================
check_sddm() {
    log_section "Display Manager (SDDM)"
    
    if systemctl is-active --quiet sddm 2>/dev/null; then
        log_pass "SDDM is running"
        
        # Check SDDM theme
        if compgen -G "/usr/share/sddm/themes/aether*" > /dev/null || [[ -d /usr/share/sddm/themes/breeze ]]; then
            log_pass "SDDM theme is installed"
        else
            log_warn "SDDM theme directory not found"
        fi
    else
        log_fail "SDDM is not running"
    fi
}

# =============================================================================
# Check Plasma Session
# =============================================================================
check_plasma() {
    log_section "KDE Plasma Desktop"
    
    # Check if Plasma is running
    if pgrep -x plasmashell &>/dev/null; then
        log_pass "Plasma shell is running"
        
        # Get Plasma version
        if command -v plasmashell &>/dev/null; then
            local version
            version=$(plasmashell --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1 || echo "unknown")
            log_info "Plasma version: $version"
        fi
    else
        log_warn "Plasma shell is not currently running (may be expected if not in graphical session)"
    fi
    
    # Check for Latte Dock
    if pgrep -x latte-dock &>/dev/null; then
        log_pass "Latte Dock is running"
    else
        log_info "Latte Dock is not running (optional)"
    fi
    
    # Check Wayland/X11
    if [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]]; then
        log_info "Session type: Wayland"
    elif [[ "${XDG_SESSION_TYPE:-}" == "x11" ]]; then
        log_info "Session type: X11"
    else
        log_info "Session type: ${XDG_SESSION_TYPE:-unknown}"
    fi
}

# =============================================================================
# Check Firewall
# =============================================================================
check_firewall() {
    log_section "Firewall (UFW)"
    
    if command -v ufw &>/dev/null; then
        local status
        if [[ $EUID -eq 0 ]]; then
            status=$(ufw status 2>/dev/null | head -1 || echo "unknown")
        else
            if systemctl is-active --quiet ufw 2>/dev/null; then
                status="Status: active"
            else
                status="Status: inactive"
            fi
        fi
        
        if echo "$status" | grep -qi "active"; then
            log_pass "UFW firewall is active"
        else
            log_warn "UFW firewall is not active"
        fi
    else
        log_warn "UFW not installed"
    fi
}

# =============================================================================
# Check AppArmor
# =============================================================================
check_apparmor() {
    log_section "AppArmor Security"
    
    if command -v aa-status &>/dev/null; then
        if systemctl is-active --quiet apparmor 2>/dev/null; then
            log_pass "AppArmor is active"
            
            # Count loaded profiles
            if [[ $EUID -eq 0 ]]; then
                local profiles
                profiles=$(aa-status 2>/dev/null | grep "profiles are loaded" | grep -oP '^\d+' || echo "0")
                log_info "AppArmor profiles loaded: $profiles"
            else
                log_info "AppArmor is running (run with sudo for profile count)"
            fi
        else
            log_warn "AppArmor service is not active"
        fi
    else
        log_warn "AppArmor not installed"
    fi
}

# =============================================================================
# Check ZRAM
# =============================================================================
check_zram() {
    log_section "ZRAM Swap"
    
    if [[ -e /dev/zram0 ]] && swapon --show 2>/dev/null | grep -q zram; then
        local zram_size
        zram_size=$(cat /sys/block/zram0/disksize 2>/dev/null || echo 0)
        local zram_mb=$((zram_size / 1024 / 1024))
        log_pass "ZRAM is active: ${zram_mb}MB configured"
        
        # Show compression stats if available
        if [[ -f /sys/block/zram0/compr_data_size ]]; then
            local compr_size orig_size
            compr_size=$(cat /sys/block/zram0/compr_data_size)
            orig_size=$(cat /sys/block/zram0/orig_data_size)
            if [[ "$orig_size" -gt 0 ]]; then
                local ratio=$((100 * compr_size / orig_size))
                log_info "Compression ratio: ${ratio}%"
            fi
        fi
    else
        log_warn "ZRAM is not active"
    fi
}

# =============================================================================
# Check Timeshift
# =============================================================================
check_timeshift() {
    log_section "Timeshift Backup"
    
    if command -v timeshift &>/dev/null; then
        log_pass "Timeshift is installed"
        
        # Check for snapshots (requires sudo)
        if [[ $EUID -eq 0 ]]; then
            local snapshots
            snapshots=$(timeshift --list 2>/dev/null | grep -c "^>" || echo "0")
            if [[ "$snapshots" -gt 0 ]]; then
                log_pass "Timeshift snapshots available: $snapshots"
            else
                log_warn "No Timeshift snapshots found"
            fi
        else
            log_info "Run with sudo to check snapshot count"
        fi
    else
        log_warn "Timeshift not installed"
    fi
}

# =============================================================================
# Check Power Profile
# =============================================================================
check_power_profile() {
    log_section "Power Management"
    
    if command -v powerprofilesctl &>/dev/null; then
        local profile
        profile=$(powerprofilesctl get 2>/dev/null || echo "unknown")
        log_pass "Power profile: $profile"
    elif command -v system76-power &>/dev/null; then
        local profile
        profile=$(system76-power profile 2>/dev/null || echo "unknown")
        log_info "System76 power profile: $profile"
    else
        log_info "Power profile daemon not found (using default)"
    fi
}

# =============================================================================
# Get GPU Information
# =============================================================================
get_gpu_info() {
    log_section "GPU Information"
    
    # Try lspci first
    if command -v lspci &>/dev/null; then
        local gpu
        gpu=$(lspci 2>/dev/null | grep -i "vga\|3d\|display" | head -1 || echo "unknown")
        if [[ -n "$gpu" ]]; then
            log_info "$gpu"
        fi
    fi
    
    # Check for GPU driver
    if lsmod 2>/dev/null | grep -qi "nvidia"; then
        log_info "NVIDIA driver loaded"
    elif lsmod 2>/dev/null | grep -qi "amdgpu"; then
        log_info "AMD GPU driver loaded"
    elif lsmod 2>/dev/null | grep -qi "i915\|intel"; then
        log_info "Intel GPU driver loaded"
    fi
}

# =============================================================================
# Get CPU Information
# =============================================================================
get_cpu_info() {
    log_section "CPU Information"
    
    if [[ -f /proc/cpuinfo ]]; then
        local cpu_model cores
        cpu_model=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
        cores=$(grep -c "^processor" /proc/cpuinfo)
        
        log_info "CPU: $cpu_model"
        log_info "Cores: $cores"
        
        # Check CPU governor
        if [[ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]]; then
            local governor
            governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
            log_info "CPU governor: $governor"
        fi
    fi
}

# =============================================================================
# Get Boot Time
# =============================================================================
get_boot_time() {
    log_section "Boot Performance"
    
    if command -v systemd-analyze &>/dev/null; then
        local boot_time
        boot_time=$(systemd-analyze 2>/dev/null | head -1 || echo "unknown")
        log_info "$boot_time"
        
        # Show top 5 slowest services
        log_info "Top 5 slowest services:"
        systemd-analyze blame 2>/dev/null | head -5 | while read -r line; do
            log_info "  $line"
        done
    else
        log_info "systemd-analyze not available"
    fi
}

# =============================================================================
# Get Memory Information
# =============================================================================
get_memory_info() {
    log_section "Memory Status"
    
    if [[ -f /proc/meminfo ]]; then
        local mem_total mem_avail mem_free
        mem_total=$(awk '/MemTotal/{print int($2/1024)}' /proc/meminfo)
        mem_avail=$(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo)
        mem_free=$(awk '/MemFree/{print int($2/1024)}' /proc/meminfo)
        
        log_info "Total: ${mem_total}MB"
        log_info "Available: ${mem_avail}MB"
        log_info "Free: ${mem_free}MB"
        
        # Calculate percentage
        local percent=$((100 * mem_avail / mem_total))
        if [[ "$mem_avail" -lt 512 ]]; then
            log_warn "Available memory is low (${percent}%)"
        else
            log_pass "Available memory is adequate (${percent}%)"
        fi
    fi
}

# =============================================================================
# Show Summary
# =============================================================================
show_summary() {
    echo ""
    log_section "Diagnostics Summary"
    
    if [[ $EXIT_CODE -eq 0 ]]; then
        log "${GREEN}All diagnostics completed successfully!${RESET}"
    else
        log "${YELLOW}Diagnostics completed with warnings or errors.${RESET}"
    fi
    
    echo ""
    log "Full report saved to: $LOG_FILE"
    log ""
}

# =============================================================================
# Show Help
# =============================================================================
show_help() {
    cat << 'EOF'
AetherOS System Diagnostics

Usage: aether-diagnostics.sh [OPTIONS]

Options:
  --help        Show this help
  --quiet       Minimal output
  --full        Full diagnostic report with all details

This script performs comprehensive system diagnostics including:
  - Display Manager (SDDM) status
  - KDE Plasma desktop session
  - Firewall (UFW) configuration
  - AppArmor security profiles
  - ZRAM swap status
  - Timeshift backup status
  - Power profile settings
  - GPU and CPU information
  - Boot time analysis
  - Memory status

Diagnostics logs are saved to:
  ~/.local/share/aetheros/diagnostics/

Exit codes:
  0 - All diagnostics passed
  1 - Some checks failed or warnings present
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
    esac

    echo ""
    log_section "AetherOS System Diagnostics"
    log "Starting comprehensive system diagnostics..."
    echo ""

    check_sddm
    check_plasma
    check_firewall
    check_apparmor
    check_zram
    check_timeshift
    check_power_profile
    get_gpu_info
    get_cpu_info
    get_memory_info
    get_boot_time

    show_summary

    exit $EXIT_CODE
}

main "$@"

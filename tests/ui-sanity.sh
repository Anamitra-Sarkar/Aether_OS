#!/bin/bash
# =============================================================================
# AetherOS UI Sanity Checks
# Performs lightweight checks on the system configuration
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTIFACTS_DIR="$SCRIPT_DIR/artifacts"
RESULTS_FILE="$ARTIFACTS_DIR/sanity-results.txt"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# =============================================================================
# Logging
# =============================================================================
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$RESULTS_FILE"
}

log_pass() {
    echo "[PASS] $1" | tee -a "$RESULTS_FILE"
    ((TESTS_PASSED++))
}

log_fail() {
    echo "[FAIL] $1" | tee -a "$RESULTS_FILE"
    ((TESTS_FAILED++))
}

log_skip() {
    echo "[SKIP] $1" | tee -a "$RESULTS_FILE"
    ((TESTS_SKIPPED++))
}

# =============================================================================
# Setup
# =============================================================================
setup() {
    mkdir -p "$ARTIFACTS_DIR"
    echo "=== AetherOS UI Sanity Check Results ===" > "$RESULTS_FILE"
    echo "Date: $(date)" >> "$RESULTS_FILE"
    echo "" >> "$RESULTS_FILE"
}

# =============================================================================
# Test: System Info
# =============================================================================
test_system_info() {
    log "=== System Information ==="
    
    echo "" >> "$RESULTS_FILE"
    echo "--- System Info ---" >> "$RESULTS_FILE"
    
    # OS Release
    if [[ -f /etc/os-release ]]; then
        cat /etc/os-release >> "$RESULTS_FILE"
        log_pass "OS release file exists"
    else
        log_fail "OS release file not found"
    fi
    
    # Memory
    echo "" >> "$RESULTS_FILE"
    echo "--- Memory ---" >> "$RESULTS_FILE"
    free -h >> "$RESULTS_FILE" 2>/dev/null || true
    
    if command -v free &>/dev/null; then
        log_pass "Memory check (free -h)"
    else
        log_skip "free command not available"
    fi
    
    # Disk
    echo "" >> "$RESULTS_FILE"
    echo "--- Disk ---" >> "$RESULTS_FILE"
    df -h / >> "$RESULTS_FILE" 2>/dev/null || true
}

# =============================================================================
# Test: Boot Analysis
# =============================================================================
test_boot_analysis() {
    log "=== Boot Analysis ==="
    
    echo "" >> "$RESULTS_FILE"
    echo "--- Boot Blame ---" >> "$RESULTS_FILE"
    
    if command -v systemd-analyze &>/dev/null; then
        systemd-analyze >> "$RESULTS_FILE" 2>/dev/null || true
        echo "" >> "$RESULTS_FILE"
        systemd-analyze blame | head -20 >> "$RESULTS_FILE" 2>/dev/null || true
        log_pass "systemd-analyze blame"
    else
        log_skip "systemd-analyze not available"
    fi
}

# =============================================================================
# Test: Skeleton Files
# =============================================================================
test_skel_files() {
    log "=== Skeleton Files ==="
    
    echo "" >> "$RESULTS_FILE"
    echo "--- /etc/skel contents ---" >> "$RESULTS_FILE"
    
    if [[ -d /etc/skel ]]; then
        ls -la /etc/skel/ >> "$RESULTS_FILE" 2>/dev/null || true
        log_pass "/etc/skel exists"
        
        # Check for config directory
        if [[ -d /etc/skel/.config ]]; then
            ls -la /etc/skel/.config/ >> "$RESULTS_FILE" 2>/dev/null || true
            log_pass "/etc/skel/.config exists"
        else
            log_fail "/etc/skel/.config not found"
        fi
    else
        log_fail "/etc/skel not found"
    fi
}

# =============================================================================
# Test: AetherOS Files
# =============================================================================
test_aetheros_files() {
    log "=== AetherOS Files ==="
    
    echo "" >> "$RESULTS_FILE"
    echo "--- AetherOS files ---" >> "$RESULTS_FILE"
    
    # Check opt scripts
    if [[ -d /opt/aetheros ]]; then
        ls -la /opt/aetheros/ >> "$RESULTS_FILE" 2>/dev/null || true
        log_pass "/opt/aetheros exists"
        
        for script in enable-zram.sh system-tuning.sh service-trimmer.sh; do
            if [[ -f "/opt/aetheros/$script" ]]; then
                log_pass "Script: $script"
            else
                log_fail "Script missing: $script"
            fi
        done
    else
        log_skip "/opt/aetheros not found (expected in chroot)"
    fi
    
    # Check UI files
    if [[ -d /usr/share/aetheros/ui ]]; then
        ls -laR /usr/share/aetheros/ui/ >> "$RESULTS_FILE" 2>/dev/null || true
        log_pass "/usr/share/aetheros/ui exists"
    else
        log_skip "/usr/share/aetheros/ui not found (expected in chroot)"
    fi
}

# =============================================================================
# Test: Required Commands
# =============================================================================
test_commands() {
    log "=== Required Commands ==="
    
    echo "" >> "$RESULTS_FILE"
    echo "--- Command availability ---" >> "$RESULTS_FILE"
    
    local commands=(
        "plasma-desktop"
        "sddm"
        "kwin_x11"
        "dolphin"
        "konsole"
        "firefox"
        "nmcli"
        "systemctl"
    )
    
    for cmd in "${commands[@]}"; do
        if command -v "$cmd" &>/dev/null; then
            echo "$cmd: $(which "$cmd")" >> "$RESULTS_FILE"
            log_pass "Command: $cmd"
        else
            echo "$cmd: NOT FOUND" >> "$RESULTS_FILE"
            log_fail "Command missing: $cmd"
        fi
    done
}

# =============================================================================
# Test: Services
# =============================================================================
test_services() {
    log "=== Services ==="
    
    echo "" >> "$RESULTS_FILE"
    echo "--- Service Status ---" >> "$RESULTS_FILE"
    
    if ! command -v systemctl &>/dev/null; then
        log_skip "systemctl not available"
        return
    fi
    
    local services=(
        "sddm"
        "NetworkManager"
    )
    
    for svc in "${services[@]}"; do
        local status
        status=$(systemctl is-enabled "$svc" 2>/dev/null || echo "not-found")
        echo "$svc: $status" >> "$RESULTS_FILE"
        
        if [[ "$status" == "enabled" ]] || [[ "$status" == "static" ]]; then
            log_pass "Service enabled: $svc"
        elif [[ "$status" == "not-found" ]]; then
            log_skip "Service not found: $svc"
        else
            log_fail "Service not enabled: $svc"
        fi
    done
}

# =============================================================================
# Test: Display Configuration
# =============================================================================
test_display() {
    log "=== Display Configuration ==="
    
    echo "" >> "$RESULTS_FILE"
    echo "--- Display ---" >> "$RESULTS_FILE"
    
    # Check SDDM config
    if [[ -d /etc/sddm.conf.d ]]; then
        ls -la /etc/sddm.conf.d/ >> "$RESULTS_FILE" 2>/dev/null || true
        log_pass "SDDM config directory exists"
    else
        log_skip "SDDM config directory not found"
    fi
    
    # Check for X11/Wayland
    if [[ -n "${DISPLAY:-}" ]]; then
        echo "DISPLAY=$DISPLAY" >> "$RESULTS_FILE"
        log_pass "X11 display available"
    elif [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY" >> "$RESULTS_FILE"
        log_pass "Wayland display available"
    else
        log_skip "No display session active"
    fi
}

# =============================================================================
# Print Summary
# =============================================================================
print_summary() {
    log ""
    log "=== Summary ==="
    log "Passed: $TESTS_PASSED"
    log "Failed: $TESTS_FAILED"
    log "Skipped: $TESTS_SKIPPED"
    log ""
    log "Results saved to: $RESULTS_FILE"
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        return 1
    fi
    return 0
}

# =============================================================================
# Show Help
# =============================================================================
show_help() {
    cat << 'EOF'
AetherOS UI Sanity Checks

Usage: ui-sanity.sh [OPTIONS]

Options:
  --help    Show this help
  --quiet   Only show summary

This script performs lightweight checks on the system configuration
to verify that AetherOS is set up correctly.

Checks performed:
  - System information (OS release, memory, disk)
  - Boot analysis (systemd-analyze)
  - Skeleton files (/etc/skel)
  - AetherOS files (/opt/aetheros, /usr/share/aetheros)
  - Required commands (plasma-desktop, sddm, etc.)
  - Services (sddm, NetworkManager)
  - Display configuration

Results are saved to tests/artifacts/sanity-results.txt
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
    
    log "=== AetherOS UI Sanity Checks ==="
    
    setup
    test_system_info
    test_boot_analysis
    test_skel_files
    test_aetheros_files
    test_commands
    test_services
    test_display
    
    if print_summary; then
        exit 0
    else
        exit 1
    fi
}

main "$@"

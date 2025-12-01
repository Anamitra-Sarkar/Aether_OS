#!/bin/bash
# =============================================================================
# AetherOS First Run Configuration Script
# Configures system settings after first boot
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
CONFIG_DIR="/etc/aetheros"
FIRST_RUN_MARKER="$CONFIG_DIR/.first-run-complete"

# =============================================================================
# Logging
# =============================================================================
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

# =============================================================================
# Check if First Run
# =============================================================================
check_first_run() {
    if [[ -f "$FIRST_RUN_MARKER" ]]; then
        log "First run already completed"
        exit 0
    fi
}

# =============================================================================
# Disable SDDM Autologin
# =============================================================================
disable_autologin() {
    log "Disabling autologin..."
    
    if [[ -f /etc/sddm.conf.d/autologin.conf ]]; then
        rm -f /etc/sddm.conf.d/autologin.conf
    fi
    
    log "Autologin disabled"
}

# =============================================================================
# Configure Privacy Settings
# =============================================================================
configure_privacy() {
    log "Configuring privacy settings..."
    
    # Disable telemetry-related services
    systemctl disable whoopsie.service 2>/dev/null || true
    systemctl disable apport.service 2>/dev/null || true
    systemctl stop whoopsie.service 2>/dev/null || true
    systemctl stop apport.service 2>/dev/null || true
    
    # Disable crash reports
    if [[ -f /etc/default/apport ]]; then
        sed -i 's/enabled=1/enabled=0/' /etc/default/apport
    fi
    
    log "Privacy settings configured"
}

# =============================================================================
# Setup Flatpak
# =============================================================================
setup_flatpak() {
    log "Setting up Flatpak..."
    
    if command -v flatpak &>/dev/null; then
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
    fi
    
    log "Flatpak configured"
}

# =============================================================================
# Configure Timeshift
# =============================================================================
configure_timeshift() {
    log "Configuring Timeshift..."
    
    if command -v timeshift &>/dev/null; then
        mkdir -p /etc/timeshift
        
        cat > /etc/timeshift/timeshift.json << 'EOF'
{
  "backup_device_uuid" : "",
  "parent_device_uuid" : "",
  "do_first_run" : "true",
  "btrfs_mode" : "false",
  "include_btrfs_home_for_backup" : "false",
  "include_btrfs_home_for_restore" : "false",
  "stop_cron_emails" : "true",
  "schedule_monthly" : "false",
  "schedule_weekly" : "true",
  "schedule_daily" : "false",
  "schedule_hourly" : "false",
  "schedule_boot" : "false",
  "count_monthly" : "2",
  "count_weekly" : "3",
  "count_daily" : "5",
  "count_hourly" : "6",
  "count_boot" : "5",
  "snapshot_size" : "0",
  "snapshot_count" : "0",
  "date_format" : "%Y-%m-%d %H:%M:%S",
  "exclude" : [],
  "exclude-apps" : []
}
EOF
    fi
    
    log "Timeshift configured"
}

# =============================================================================
# Apply Theme
# =============================================================================
apply_theme() {
    local theme="${1:-dark}"
    
    log "Applying theme: $theme"
    
    local config_dir="/etc/skel/.config"
    
    if [[ "$theme" == "light" ]]; then
        # Light theme settings
        sed -i 's/BreezeClassic/BreezeLight/' "$config_dir/kdeglobals" 2>/dev/null || true
        sed -i 's/breezedark/breezelight/' "$config_dir/kdeglobals" 2>/dev/null || true
    else
        # Dark theme (default)
        log "Using default dark theme"
    fi
    
    log "Theme applied"
}

# =============================================================================
# Install Restricted Extras (opt-in)
# =============================================================================
install_restricted_extras() {
    log "Installing restricted extras..."
    
    # This should only run if user opted in
    export DEBIAN_FRONTEND=noninteractive
    
    apt-get update
    apt-get install -y ubuntu-restricted-extras 2>/dev/null || {
        log "Some restricted extras failed to install"
    }
    
    log "Restricted extras installed"
}

# =============================================================================
# Mark First Run Complete
# =============================================================================
mark_complete() {
    mkdir -p "$CONFIG_DIR"
    date > "$FIRST_RUN_MARKER"
    log "First run marked as complete"
}

# =============================================================================
# Show Help
# =============================================================================
show_help() {
    cat << 'EOF'
AetherOS First Run Configuration

Usage: configure-first-run.sh [OPTIONS]

Options:
  --disable-autologin     Disable SDDM autologin
  --privacy               Configure privacy settings
  --flatpak               Setup Flatpak
  --timeshift             Configure Timeshift
  --theme [light|dark]    Apply theme
  --restricted            Install restricted extras (codecs, etc.)
  --all                   Apply all configurations
  --help                  Show this help

Examples:
  ./configure-first-run.sh --all
  ./configure-first-run.sh --theme dark --privacy
EOF
}

# =============================================================================
# Main
# =============================================================================
main() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    log "=== AetherOS First Run Configuration ==="
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --disable-autologin)
                disable_autologin
                shift
                ;;
            --privacy)
                configure_privacy
                shift
                ;;
            --flatpak)
                setup_flatpak
                shift
                ;;
            --timeshift)
                configure_timeshift
                shift
                ;;
            --theme)
                apply_theme "${2:-dark}"
                shift 2 || shift
                ;;
            --restricted)
                install_restricted_extras
                shift
                ;;
            --all)
                check_first_run
                disable_autologin
                configure_privacy
                setup_flatpak
                configure_timeshift
                mark_complete
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    log "=== Configuration Complete ==="
}

main "$@"

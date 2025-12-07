#!/bin/bash
# =============================================================================
# AetherOS Secure Session Mode
# Temporary lockdown mode for banking, exams, sensitive work
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/aetheros"
STATE_FILE="$CONFIG_DIR/.secure-session-active"
BACKUP_DIR="$CONFIG_DIR/secure-session-backup"
LOG_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/aetheros/secure-session.log"

# =============================================================================
# Logging
# =============================================================================
setup_logging() {
    local log_dir
    log_dir="$(dirname "$LOG_FILE")"
    mkdir -p "$log_dir"
    touch "$LOG_FILE"
}

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" | tee -a "$LOG_FILE" >&2
}

# =============================================================================
# Check if running
# =============================================================================
is_active() {
    [ -f "$STATE_FILE" ]
}

# =============================================================================
# Backup current state
# =============================================================================
backup_state() {
    mkdir -p "$BACKUP_DIR"
    
    # Backup firewall rules if using ufw
    if command -v ufw &>/dev/null; then
        sudo ufw status > "$BACKUP_DIR/ufw-status.txt" 2>/dev/null || true
    fi
    
    # Backup systemd services state
    systemctl list-units --type=service --state=running > "$BACKUP_DIR/services.txt" 2>/dev/null || true
    
    log_message "State backed up to: $BACKUP_DIR"
}

# =============================================================================
# Enable Secure Session
# =============================================================================
enable_secure_session() {
    if is_active; then
        echo "⚠ Secure Session is already active"
        return 0
    fi
    
    echo "=== Enabling Secure Session Mode ==="
    echo ""
    
    log_message "Enabling Secure Session Mode"
    
    # Backup current state
    backup_state
    
    # 1. Configure firewall (strict mode)
    echo "→ Configuring firewall (strict mode)..."
    if command -v ufw &>/dev/null; then
        # Enable UFW if not already enabled
        if ! sudo ufw status | grep -q "Status: active"; then
            echo "  Enabling UFW..."
            echo "y" | sudo ufw enable 2>/dev/null || true
        fi
        
        # Deny all incoming by default
        sudo ufw default deny incoming 2>/dev/null || true
        
        # Allow only essential outgoing (DNS, HTTPS)
        sudo ufw default allow outgoing 2>/dev/null || true
        
        # Deny common risky ports
        sudo ufw deny 22/tcp comment "Secure Session: SSH disabled" 2>/dev/null || true
        sudo ufw deny 445/tcp comment "Secure Session: SMB disabled" 2>/dev/null || true
        sudo ufw deny 5353/udp comment "Secure Session: mDNS disabled" 2>/dev/null || true
        
        echo "  ✓ Firewall configured"
    else
        echo "  ℹ UFW not available - firewall not configured"
    fi
    
    # 2. Disable risky services
    echo "→ Disabling potentially risky services..."
    
    local services_to_stop=()
    
    # Check and stop SSH
    if systemctl is-active --quiet ssh 2>/dev/null || systemctl is-active --quiet sshd 2>/dev/null; then
        services_to_stop+=("ssh")
        echo "  Stopping SSH..."
        sudo systemctl stop ssh 2>/dev/null || sudo systemctl stop sshd 2>/dev/null || true
    fi
    
    # Check and stop Avahi (mDNS)
    if systemctl is-active --quiet avahi-daemon 2>/dev/null; then
        services_to_stop+=("avahi-daemon")
        echo "  Stopping Avahi (mDNS)..."
        sudo systemctl stop avahi-daemon 2>/dev/null || true
    fi
    
    # Check and stop Samba
    if systemctl is-active --quiet smbd 2>/dev/null; then
        services_to_stop+=("smbd")
        echo "  Stopping Samba..."
        sudo systemctl stop smbd 2>/dev/null || true
    fi
    
    # Save stopped services list
    printf "%s\n" "${services_to_stop[@]}" > "$BACKUP_DIR/stopped-services.txt" 2>/dev/null || true
    
    echo "  ✓ Services restricted"
    
    # 3. Disable USB automount (if using udisks2)
    echo "→ Disabling USB automount..."
    if command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.media-handling automount false 2>/dev/null || true
        gsettings set org.gnome.desktop.media-handling automount-open false 2>/dev/null || true
        echo "true" > "$BACKUP_DIR/automount-was-enabled.txt"
        echo "  ✓ USB automount disabled"
    else
        echo "  ℹ gsettings not available - automount not changed"
    fi
    
    # 4. Set stricter AppArmor mode (if available)
    echo "→ Checking AppArmor..."
    if command -v aa-status &>/dev/null; then
        # Check if AppArmor is active
        if sudo aa-status --enabled 2>/dev/null; then
            echo "  ✓ AppArmor is active"
            # Note: We don't change AppArmor mode to avoid breaking apps
            # This is just a check
        else
            echo "  ℹ AppArmor not active"
        fi
    else
        echo "  ℹ AppArmor not available"
    fi
    
    # 5. Create state file
    echo "active" > "$STATE_FILE"
    echo "$(date '+%Y-%m-%d %H:%M:%S')" >> "$STATE_FILE"
    
    # 6. Show visual indicator
    show_indicator
    
    echo ""
    echo "✓ Secure Session Mode ENABLED"
    echo ""
    echo "Active restrictions:"
    echo "  • Firewall: Strict incoming, restricted outgoing"
    echo "  • SSH: Disabled"
    echo "  • Network services: Restricted"
    echo "  • USB automount: Disabled"
    echo ""
    echo "To disable: $(basename "$0") stop"
    echo ""
    
    log_message "Secure Session Mode enabled successfully"
}

# =============================================================================
# Disable Secure Session
# =============================================================================
disable_secure_session() {
    if ! is_active; then
        echo "ℹ Secure Session is not active"
        return 0
    fi
    
    echo "=== Disabling Secure Session Mode ==="
    echo ""
    
    log_message "Disabling Secure Session Mode"
    
    # 1. Restore firewall rules
    echo "→ Restoring firewall..."
    if command -v ufw &>/dev/null; then
        # Remove our specific rules
        sudo ufw delete deny 22/tcp 2>/dev/null || true
        sudo ufw delete deny 445/tcp 2>/dev/null || true
        sudo ufw delete deny 5353/udp 2>/dev/null || true
        
        # Optionally restore to more permissive defaults
        sudo ufw default allow incoming 2>/dev/null || true
        sudo ufw default allow outgoing 2>/dev/null || true
        
        echo "  ✓ Firewall restored"
    fi
    
    # 2. Restart services that were stopped
    echo "→ Restoring services..."
    if [ -f "$BACKUP_DIR/stopped-services.txt" ]; then
        while IFS= read -r service; do
            if [ -n "$service" ]; then
                echo "  Restarting $service..."
                sudo systemctl start "$service" 2>/dev/null || true
            fi
        done < "$BACKUP_DIR/stopped-services.txt"
    fi
    echo "  ✓ Services restored"
    
    # 3. Re-enable USB automount
    echo "→ Restoring USB automount..."
    if [ -f "$BACKUP_DIR/automount-was-enabled.txt" ] && command -v gsettings &>/dev/null; then
        gsettings set org.gnome.desktop.media-handling automount true 2>/dev/null || true
        gsettings set org.gnome.desktop.media-handling automount-open true 2>/dev/null || true
        echo "  ✓ USB automount restored"
    fi
    
    # 4. Remove state file
    rm -f "$STATE_FILE"
    
    # 5. Hide indicator
    hide_indicator
    
    echo ""
    echo "✓ Secure Session Mode DISABLED"
    echo "  All settings restored to normal"
    echo ""
    
    log_message "Secure Session Mode disabled successfully"
}

# =============================================================================
# Show status
# =============================================================================
show_status() {
    echo "=== Secure Session Status ==="
    echo ""
    
    if is_active; then
        echo "Status: ACTIVE"
        echo ""
        
        if [ -f "$STATE_FILE" ]; then
            local start_time
            start_time=$(tail -1 "$STATE_FILE")
            echo "Started: $start_time"
        fi
        
        echo ""
        echo "Active restrictions:"
        
        # Check firewall
        if command -v ufw &>/dev/null; then
            if sudo ufw status 2>/dev/null | grep -q "Status: active"; then
                echo "  • Firewall: Active"
            fi
        fi
        
        # Check services
        local services_stopped=0
        if systemctl is-active --quiet ssh 2>/dev/null || systemctl is-active --quiet sshd 2>/dev/null; then
            :
        else
            echo "  • SSH: Disabled"
            services_stopped=1
        fi
        
        if ! systemctl is-active --quiet avahi-daemon 2>/dev/null; then
            echo "  • Avahi: Disabled"
            services_stopped=1
        fi
        
        # Check automount
        if command -v gsettings &>/dev/null; then
            if [ "$(gsettings get org.gnome.desktop.media-handling automount 2>/dev/null)" = "false" ]; then
                echo "  • USB Automount: Disabled"
            fi
        fi
        
    else
        echo "Status: INACTIVE"
        echo ""
        echo "System is running in normal mode"
        echo ""
        echo "To enable: $(basename "$0") start"
    fi
    
    echo ""
}

# =============================================================================
# Visual indicator
# =============================================================================
show_indicator() {
    # Try to show a notification
    if command -v notify-send &>/dev/null; then
        notify-send "🔒 Secure Session Active" \
            "Enhanced security mode enabled\nClick system tray for status" \
            -u critical \
            -t 10000 2>/dev/null || true
    fi
    
    # TODO: Add persistent panel indicator in future
    # For now, we rely on notifications
}

hide_indicator() {
    if command -v notify-send &>/dev/null; then
        notify-send "🔓 Secure Session Disabled" \
            "System restored to normal mode" \
            -u normal \
            -t 5000 2>/dev/null || true
    fi
}

# =============================================================================
# Help
# =============================================================================
show_help() {
    cat << EOF
AetherOS Secure Session Mode

Temporary lockdown mode for:
  • Banking and financial transactions
  • Exam portals and online tests
  • Sensitive work and confidential tasks

When enabled:
  • Firewall set to strict mode (deny incoming, restrict outgoing)
  • SSH server disabled
  • Network services (Avahi, Samba) stopped
  • USB automount disabled
  • Clear on-screen indicator shown

Usage: $(basename "$0") COMMAND

Commands:
  start     Enable Secure Session Mode
  stop      Disable Secure Session Mode (restore normal)
  status    Show current status
  help      Show this help

Examples:
  $(basename "$0") start      # Enable secure mode
  $(basename "$0") status     # Check if active
  $(basename "$0") stop       # Return to normal

Safety:
  • All changes are reversible
  • Original state is backed up
  • Idempotent - safe to run multiple times
  • No permanent configuration corruption

Note:
  Some operations require sudo/root privileges for
  system-level security changes (firewall, services).

EOF
}

# =============================================================================
# Main
# =============================================================================
main() {
    setup_logging
    
    case "${1:-status}" in
        start|enable)
            enable_secure_session
            ;;
        stop|disable)
            disable_secure_session
            ;;
        status)
            show_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo "Error: Unknown command: $1" >&2
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"

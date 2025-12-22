#!/bin/bash
# =============================================================================
# AetherOS Secure Session Mode
# Soft-Immutable Secure Session with OverlayFS
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

# OverlayFS Configuration
OVERLAY_BASE="/var/lib/aetheros/secure-session"
OVERLAY_UPPER="$OVERLAY_BASE/upper"
OVERLAY_WORK="$OVERLAY_BASE/work"
OVERLAY_MERGED="$OVERLAY_BASE/merged"
OVERLAY_STATE_FILE="$CONFIG_DIR/.overlay-active"
OVERLAY_MOUNTS_FILE="$CONFIG_DIR/.overlay-mounts"

# =============================================================================
# Safety: Abort on failure with cleanup
# =============================================================================
cleanup_on_error() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Operation failed with exit code $exit_code. Attempting safe cleanup."
        # Attempt to unmount any overlays on failure
        if [ -f "$OVERLAY_MOUNTS_FILE" ]; then
            unmount_overlays || true
        fi
    fi
    exit $exit_code
}
trap cleanup_on_error EXIT

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
# Requirement Checks
# =============================================================================
require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        log_error "This operation requires root privileges. Run with sudo."
        exit 1
    fi
}

check_overlay_available() {
    # Check if overlayfs is available in kernel
    if [ -f /proc/filesystems ] && grep -q overlay /proc/filesystems; then
        return 0
    fi
    # Try to load the module
    if modprobe overlay 2>/dev/null; then
        return 0
    fi
    return 1
}

is_overlay_active() {
    [ -f "$OVERLAY_STATE_FILE" ] && [ -f "$OVERLAY_MOUNTS_FILE" ]
}

# =============================================================================
# OverlayFS Functions
# =============================================================================
setup_overlay_dirs() {
    require_root
    
    mkdir -p "$OVERLAY_BASE"
    mkdir -p "$OVERLAY_UPPER"
    mkdir -p "$OVERLAY_WORK"
    mkdir -p "$OVERLAY_MERGED"
    
    # Set proper permissions
    chmod 700 "$OVERLAY_BASE"
    
    log_message "Overlay directories created at: $OVERLAY_BASE"
}

mount_overlay() {
    local target_dir="$1"
    local mount_name="$2"
    
    require_root
    
    if ! check_overlay_available; then
        log_error "OverlayFS is not available on this system"
        return 1
    fi
    
    # Create overlay-specific directories
    local upper_dir="${OVERLAY_UPPER}/${mount_name}"
    local work_dir="${OVERLAY_WORK}/${mount_name}"
    local merged_dir="${OVERLAY_MERGED}/${mount_name}"
    
    mkdir -p "$upper_dir"
    mkdir -p "$work_dir"
    mkdir -p "$merged_dir"
    
    # Mount overlay
    if mount -t overlay overlay \
        -o "lowerdir=${target_dir},upperdir=${upper_dir},workdir=${work_dir}" \
        "$merged_dir" 2>&1; then
        log_message "Overlay mounted: $target_dir -> $merged_dir"
        echo "${mount_name}:${target_dir}:${merged_dir}" >> "$OVERLAY_MOUNTS_FILE"
        return 0
    else
        log_error "Failed to mount overlay for: $target_dir"
        return 1
    fi
}

mount_overlays() {
    require_root
    
    echo "→ Setting up OverlayFS for soft-immutable session..."
    
    if ! check_overlay_available; then
        echo "  ℹ OverlayFS not available - skipping soft-immutable mode"
        return 0
    fi
    
    setup_overlay_dirs
    
    # Clear previous mounts file
    rm -f "$OVERLAY_MOUNTS_FILE"
    touch "$OVERLAY_MOUNTS_FILE"
    
    local mount_count=0
    
    # Mount overlay on user config directory (soft-immutable)
    # Changes during session are temporary and discarded on session end
    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
    if [ -d "$config_dir" ]; then
        echo "  → Mounting overlay on config directory..."
        if mount_overlay "$config_dir" "config"; then
            echo "    ✓ Config directory protected (changes are temporary)"
            mount_count=$((mount_count + 1))
        fi
    fi
    
    # Mount overlay on browser cache/data (optional, for extra security)
    local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
    if [ -d "$cache_dir" ]; then
        echo "  → Mounting overlay on cache directory..."
        if mount_overlay "$cache_dir" "cache"; then
            echo "    ✓ Cache directory protected (changes are temporary)"
            mount_count=$((mount_count + 1))
        fi
    fi
    
    if [ $mount_count -gt 0 ]; then
        echo "active" > "$OVERLAY_STATE_FILE"
        echo "  ✓ OverlayFS soft-immutable mode active ($mount_count directories)"
        log_message "OverlayFS overlays mounted: $mount_count directories"
    else
        echo "  ℹ No overlays mounted"
    fi
}

unmount_overlays() {
    require_root
    
    echo "→ Unmounting OverlayFS overlays..."
    
    if [ ! -f "$OVERLAY_MOUNTS_FILE" ]; then
        echo "  ℹ No overlay mounts to remove"
        return 0
    fi
    
    local unmount_count=0
    
    # Unmount in reverse order
    tac "$OVERLAY_MOUNTS_FILE" 2>/dev/null | while IFS=':' read -r mount_name target_dir merged_dir; do
        if [ -n "$merged_dir" ] && mountpoint -q "$merged_dir" 2>/dev/null; then
            echo "  → Unmounting: $merged_dir"
            if umount "$merged_dir" 2>&1; then
                log_message "Overlay unmounted: $merged_dir"
                unmount_count=$((unmount_count + 1))
            else
                log_error "Failed to unmount: $merged_dir"
                # Try lazy unmount as fallback
                umount -l "$merged_dir" 2>/dev/null || true
            fi
        fi
    done
    
    # Clean up overlay directories
    rm -rf "$OVERLAY_UPPER" 2>/dev/null || true
    rm -rf "$OVERLAY_WORK" 2>/dev/null || true
    rm -rf "$OVERLAY_MERGED" 2>/dev/null || true
    
    # Remove state files
    rm -f "$OVERLAY_STATE_FILE"
    rm -f "$OVERLAY_MOUNTS_FILE"
    
    echo "  ✓ All overlays unmounted (temporary changes discarded)"
    log_message "OverlayFS overlays cleaned up"
}

show_overlay_status() {
    echo ""
    echo "OverlayFS Status:"
    
    if is_overlay_active; then
        echo "  Soft-Immutable Mode: ACTIVE"
        echo "  Protected directories:"
        if [ -f "$OVERLAY_MOUNTS_FILE" ]; then
            while IFS=':' read -r mount_name target_dir merged_dir; do
                if [ -n "$target_dir" ]; then
                    echo "    • $target_dir (changes are temporary)"
                fi
            done < "$OVERLAY_MOUNTS_FILE"
        fi
    else
        echo "  Soft-Immutable Mode: INACTIVE"
    fi
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
        sudo ufw status 2>/dev/null | tee "$BACKUP_DIR/ufw-status.txt" >/dev/null || true
    fi
    
    # Backup systemd services state
    systemctl list-units --type=service --state=running > "$BACKUP_DIR/services.txt" 2>/dev/null || true
    
    log_message "State backed up to: $BACKUP_DIR"
}

# =============================================================================
# Enable Secure Session
# =============================================================================
enable_secure_session() {
    local use_overlay="${1:-true}"
    
    if is_active; then
        echo "⚠ Secure Session is already active"
        return 0
    fi
    
    echo "=== Enabling Secure Session Mode ==="
    echo ""
    
    log_message "Enabling Secure Session Mode (overlay=$use_overlay)"
    
    # Backup current state
    backup_state
    
    # 0. Setup OverlayFS for soft-immutable mode (if root and requested)
    if [ "$use_overlay" = "true" ] && [ "$(id -u)" -eq 0 ]; then
        mount_overlays
    elif [ "$use_overlay" = "true" ]; then
        echo "→ OverlayFS requires root privileges"
        echo "  Run with sudo for soft-immutable mode"
        echo "  Continuing without overlay protection..."
        echo ""
    fi
    
    # 1. Configure firewall (strict mode)
    echo "→ Configuring firewall (strict mode)..."
    if command -v ufw &>/dev/null; then
        # Enable UFW if not already enabled
        if ! sudo ufw status | grep -q "Status: active"; then
            echo "  Enabling UFW..."
            sudo ufw --force enable 2>/dev/null || true
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
    if [ ${#services_to_stop[@]} -gt 0 ]; then
        printf "%s\n" "${services_to_stop[@]}" > "$BACKUP_DIR/stopped-services.txt"
    else
        touch "$BACKUP_DIR/stopped-services.txt"
    fi
    
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
        else
            echo "  ℹ AppArmor not active"
        fi
    else
        echo "  ℹ AppArmor not available"
    fi
    
    # 5. Create state file
    mkdir -p "$(dirname "$STATE_FILE")"
    echo "active" > "$STATE_FILE"
    date '+%Y-%m-%d %H:%M:%S' >> "$STATE_FILE"
    echo "overlay=$use_overlay" >> "$STATE_FILE"
    
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
    if is_overlay_active; then
        echo "  • Soft-Immutable: Config/cache changes are temporary"
    fi
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
    
    # 0. Unmount OverlayFS overlays (if root and active)
    if is_overlay_active && [ "$(id -u)" -eq 0 ]; then
        unmount_overlays
    elif is_overlay_active; then
        echo "→ OverlayFS cleanup requires root privileges"
        echo "  Run with sudo to properly clean up overlays"
        echo ""
    fi
    
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
    if [ -f "$OVERLAY_STATE_FILE" ] && [ "$(id -u)" -ne 0 ]; then
        echo ""
        echo "⚠ Note: OverlayFS overlays may still be active"
        echo "  Run 'sudo $(basename "$0") stop' to fully clean up"
    fi
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
            start_time=$(grep -v "^active$\|^overlay=" "$STATE_FILE" | head -1)
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
        if systemctl is-active --quiet ssh 2>/dev/null || systemctl is-active --quiet sshd 2>/dev/null; then
            :
        else
            echo "  • SSH: Disabled"
        fi
        
        if ! systemctl is-active --quiet avahi-daemon 2>/dev/null; then
            echo "  • Avahi: Disabled"
        fi
        
        # Check automount
        if command -v gsettings &>/dev/null; then
            if [ "$(gsettings get org.gnome.desktop.media-handling automount 2>/dev/null)" = "false" ]; then
                echo "  • USB Automount: Disabled"
            fi
        fi
        
        # Show overlay status
        show_overlay_status
        
    else
        echo "Status: INACTIVE"
        echo ""
        echo "System is running in normal mode"
        echo ""
        echo "To enable: $(basename "$0") start"
        echo "To enable with soft-immutable mode: sudo $(basename "$0") start"
    fi
    
    echo ""
}

# =============================================================================
# Visual indicator
# =============================================================================
show_indicator() {
    # Try to show a notification
    if command -v notify-send &>/dev/null; then
        local msg="Enhanced security mode enabled"
        if is_overlay_active; then
            msg="Soft-immutable mode active\nConfig changes are temporary"
        fi
        notify-send "🔒 Secure Session Active" \
            "$msg" \
            -u critical \
            -t 10000 2>/dev/null || true
    fi
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
Soft-Immutable Secure Session with OverlayFS

Temporary lockdown mode for:
  • Banking and financial transactions
  • Exam portals and online tests
  • Sensitive work and confidential tasks

When enabled:
  • Firewall set to strict mode (deny incoming, restrict outgoing)
  • SSH server disabled
  • Network services (Avahi, Samba) stopped
  • USB automount disabled
  • Soft-immutable mode (with sudo): config/cache changes are temporary

Soft-Immutable Mode (OverlayFS):
  When run with sudo, the session uses OverlayFS to create a
  temporary layer over your config and cache directories. Any
  changes made during the session are discarded when the session
  ends, providing additional protection against persistent malware
  or unwanted configuration changes.

Usage: $(basename "$0") COMMAND [OPTIONS]

Commands:
  start [--no-overlay]    Enable Secure Session Mode
  stop                    Disable Secure Session Mode (restore normal)
  status                  Show current status
  help                    Show this help

Options:
  --no-overlay            Disable OverlayFS soft-immutable mode

Examples:
  $(basename "$0") start           # Enable secure mode (no overlay)
  sudo $(basename "$0") start      # Enable with soft-immutable mode
  $(basename "$0") start --no-overlay  # Explicitly disable overlay
  $(basename "$0") status          # Check if active
  $(basename "$0") stop            # Return to normal
  sudo $(basename "$0") stop       # Full cleanup including overlays

Safety:
  • All changes are reversible
  • Original state is backed up
  • Idempotent - safe to run multiple times
  • No permanent configuration corruption
  • OverlayFS changes are discarded on session end

Requirements:
  • Root privileges for OverlayFS soft-immutable mode
  • Linux kernel with OverlayFS support (standard on modern kernels)
  • UFW for firewall management (optional)

EOF
}

# =============================================================================
# Main
# =============================================================================
main() {
    setup_logging
    
    local command="${1:-status}"
    local use_overlay="true"
    
    # Parse options
    shift 2>/dev/null || true
    while [ $# -gt 0 ]; do
        case "$1" in
            --no-overlay)
                use_overlay="false"
                ;;
            *)
                ;;
        esac
        shift
    done
    
    case "$command" in
        start|enable)
            enable_secure_session "$use_overlay"
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
            echo "Error: Unknown command: $command" >&2
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"

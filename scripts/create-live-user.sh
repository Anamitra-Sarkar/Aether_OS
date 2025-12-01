#!/bin/bash
# =============================================================================
# AetherOS Live User Creation Script
# Creates the default user for live session
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
LIVE_USER="${LIVE_USER:-aether}"
LIVE_PASSWORD="${LIVE_PASSWORD:-aether}"
LIVE_FULLNAME="${LIVE_FULLNAME:-AetherOS User}"
LIVE_GROUPS="sudo,audio,video,plugdev,netdev,bluetooth,scanner,lpadmin"

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
# Check if running as root
# =============================================================================
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# =============================================================================
# Create Live User
# =============================================================================
create_user() {
    log "Creating live user: $LIVE_USER"
    
    # Check if user already exists
    if id "$LIVE_USER" &>/dev/null; then
        log "User $LIVE_USER already exists"
        return 0
    fi
    
    # Create the user
    useradd \
        --create-home \
        --shell /bin/bash \
        --comment "$LIVE_FULLNAME" \
        --groups "$LIVE_GROUPS" \
        "$LIVE_USER"
    
    # Set password
    echo "$LIVE_USER:$LIVE_PASSWORD" | chpasswd
    
    log "User created: $LIVE_USER"
}

# =============================================================================
# Configure Sudo Access
# =============================================================================
configure_sudo() {
    log "Configuring sudo access..."
    
    # Create sudoers.d file for passwordless sudo
    cat > "/etc/sudoers.d/$LIVE_USER" << EOF
# Allow live user to run sudo without password
$LIVE_USER ALL=(ALL) NOPASSWD:ALL
EOF
    
    chmod 440 "/etc/sudoers.d/$LIVE_USER"
    
    log "Sudo access configured"
}

# =============================================================================
# Setup User Environment
# =============================================================================
setup_environment() {
    log "Setting up user environment..."
    
    local home_dir="/home/$LIVE_USER"
    
    # Create necessary directories
    mkdir -p "$home_dir/.config"
    mkdir -p "$home_dir/.local/share"
    mkdir -p "$home_dir/Desktop"
    mkdir -p "$home_dir/Documents"
    mkdir -p "$home_dir/Downloads"
    mkdir -p "$home_dir/Music"
    mkdir -p "$home_dir/Pictures"
    mkdir -p "$home_dir/Videos"
    
    # Copy skeleton files
    if [[ -d /etc/skel ]]; then
        cp -rT /etc/skel "$home_dir" 2>/dev/null || true
    fi
    
    # Create desktop entry for installer
    if command -v calamares &>/dev/null; then
        cat > "$home_dir/Desktop/install-aetheros.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Install AetherOS
Comment=Install AetherOS to your computer
Exec=pkexec calamares
Icon=aetheros-logo
Terminal=false
Categories=System;
EOF
        chmod +x "$home_dir/Desktop/install-aetheros.desktop"
    fi
    
    # Create welcome document
    cat > "$home_dir/Desktop/WELCOME.txt" << EOF
Welcome to AetherOS!

Thank you for trying AetherOS. This is a live session where you can
explore the system without making any changes to your computer.

To install AetherOS:
- Double-click the "Install AetherOS" icon on the desktop
- Or run 'sudo calamares' from the terminal

Quick Tips:
- Press Super (Windows) key to open the application menu
- The dock at the bottom provides quick access to common apps
- Right-click the desktop for more options

Useful Commands:
- sudo /opt/aetheros/enable-zram.sh   # Enable zram swap
- sudo /opt/aetheros/system-tuning.sh # Apply performance tuning
- neofetch                             # Show system info

For more information, visit: https://github.com/aetheros

Enjoy AetherOS!
EOF
    
    # Fix ownership
    chown -R "$LIVE_USER:$LIVE_USER" "$home_dir"
    
    log "User environment configured"
}

# =============================================================================
# Configure Autologin
# =============================================================================
configure_autologin() {
    log "Configuring autologin..."
    
    # Configure SDDM autologin
    mkdir -p /etc/sddm.conf.d
    cat > /etc/sddm.conf.d/autologin.conf << EOF
[Autologin]
User=$LIVE_USER
Session=plasma
Relogin=false
EOF
    
    log "Autologin configured for SDDM"
}

# =============================================================================
# Setup First Run Wizard Trigger
# =============================================================================
setup_first_run() {
    log "Setting up first-run wizard trigger..."
    
    local home_dir="/home/$LIVE_USER"
    
    # Create autostart entry for first-run wizard
    mkdir -p "$home_dir/.config/autostart"
    
    if [[ -f /usr/share/aetheros/ui/first-run-wizard/first-run-wizard.desktop ]]; then
        cp /usr/share/aetheros/ui/first-run-wizard/first-run-wizard.desktop \
           "$home_dir/.config/autostart/"
    else
        cat > "$home_dir/.config/autostart/aetheros-first-run.desktop" << EOF
[Desktop Entry]
Type=Application
Name=AetherOS First Run
Comment=Configure AetherOS on first boot
Exec=/usr/share/aetheros/ui/first-run-wizard/run.sh
Icon=preferences-system
Terminal=false
OnlyShowIn=KDE;
X-KDE-autostart-condition=ksmserver:firstRun
EOF
    fi
    
    # Create first-run marker
    touch "$home_dir/.config/aetheros-first-run"
    
    chown -R "$LIVE_USER:$LIVE_USER" "$home_dir/.config"
    
    log "First-run wizard trigger configured"
}

# =============================================================================
# Main
# =============================================================================
main() {
    log "=== AetherOS Live User Creation ==="
    
    check_root
    create_user
    configure_sudo
    setup_environment
    configure_autologin
    setup_first_run
    
    log "=== Live User Creation Complete ==="
    log "Username: $LIVE_USER"
    log "Password: $LIVE_PASSWORD"
}

# Parse arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --user USERNAME    Set username (default: aether)"
        echo "  --password PASS    Set password (default: aether)"
        echo "  --help             Show this help"
        exit 0
        ;;
    --user)
        LIVE_USER="${2:-aether}"
        shift 2 || true
        ;;
    --password)
        LIVE_PASSWORD="${2:-aether}"
        shift 2 || true
        ;;
esac

main

#!/bin/bash
# =============================================================================
# AetherOS Chroot Setup Script
# Creates the base system using debootstrap and configures it
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CHROOT_DIR="${CHROOT_DIR:-$SCRIPT_DIR/chroot}"
UBUNTU_RELEASE="noble"
UBUNTU_MIRROR="${UBUNTU_MIRROR:-http://archive.ubuntu.com/ubuntu}"
ARCH="amd64"
PACKAGES_LIST="$SCRIPT_DIR/packages.list"
LOG_FILE="$SCRIPT_DIR/chroot-setup.log"

# =============================================================================
# Logging Functions
# =============================================================================
log() {
    local message
    message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$message" | tee -a "$LOG_FILE"
}

log_error() {
    local message
    message="[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1"
    echo "$message" | tee -a "$LOG_FILE" >&2
}

log_section() {
    log "=============================================="
    log "$1"
    log "=============================================="
}

# =============================================================================
# Cleanup Function
# =============================================================================
cleanup() {
    log "Cleaning up..."
    
    # Unmount filesystems in chroot
    if mountpoint -q "$CHROOT_DIR/dev/pts" 2>/dev/null; then
        umount "$CHROOT_DIR/dev/pts" || true
    fi
    if mountpoint -q "$CHROOT_DIR/dev" 2>/dev/null; then
        umount "$CHROOT_DIR/dev" || true
    fi
    if mountpoint -q "$CHROOT_DIR/proc" 2>/dev/null; then
        umount "$CHROOT_DIR/proc" || true
    fi
    if mountpoint -q "$CHROOT_DIR/sys" 2>/dev/null; then
        umount "$CHROOT_DIR/sys" || true
    fi
    if mountpoint -q "$CHROOT_DIR/run" 2>/dev/null; then
        umount "$CHROOT_DIR/run" || true
    fi
}

trap cleanup EXIT

# =============================================================================
# Check Prerequisites
# =============================================================================
check_prerequisites() {
    log_section "Checking Prerequisites"
    
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
    
    local required_commands=(debootstrap chroot mount)
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "Required command not found: $cmd"
            exit 1
        fi
    done
    
    if [[ ! -f "$PACKAGES_LIST" ]]; then
        log_error "Packages list not found: $PACKAGES_LIST"
        exit 1
    fi
    
    log "Prerequisites check passed"
}

# =============================================================================
# Parse Packages List
# =============================================================================
parse_packages() {
    local packages=""
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        line=$(echo "$line" | sed 's/#.*//' | xargs)
        if [[ -n "$line" ]]; then
            packages="$packages $line"
        fi
    done < "$PACKAGES_LIST"
    echo "$packages"
}

# =============================================================================
# Create Base System with Debootstrap
# =============================================================================
create_base_system() {
    log_section "Creating Base System with Debootstrap"
    
    if [[ -d "$CHROOT_DIR" ]]; then
        log "Removing existing chroot directory..."
        rm -rf "$CHROOT_DIR"
    fi
    
    mkdir -p "$CHROOT_DIR"
    
    log "Running debootstrap for Ubuntu $UBUNTU_RELEASE ($ARCH)..."
    debootstrap \
        --arch="$ARCH" \
        --variant=minbase \
        --components=main,restricted,universe,multiverse \
        "$UBUNTU_RELEASE" \
        "$CHROOT_DIR" \
        "$UBUNTU_MIRROR"
    
    log "Base system created successfully"
}

# =============================================================================
# Mount Filesystems for Chroot
# =============================================================================
mount_filesystems() {
    log_section "Mounting Filesystems"
    
    mount --bind /dev "$CHROOT_DIR/dev"
    mount --bind /dev/pts "$CHROOT_DIR/dev/pts"
    mount -t proc proc "$CHROOT_DIR/proc"
    mount -t sysfs sys "$CHROOT_DIR/sys"
    mount -t tmpfs tmpfs "$CHROOT_DIR/run"
    
    # Copy resolv.conf for network access
    cp /etc/resolv.conf "$CHROOT_DIR/etc/resolv.conf"
    
    log "Filesystems mounted"
}

# =============================================================================
# Configure APT Sources
# =============================================================================
configure_apt() {
    log_section "Configuring APT Sources"
    
    cat > "$CHROOT_DIR/etc/apt/sources.list" << EOF
# Ubuntu 24.04 LTS (Noble Numbat)
deb $UBUNTU_MIRROR $UBUNTU_RELEASE main restricted universe multiverse
deb $UBUNTU_MIRROR $UBUNTU_RELEASE-updates main restricted universe multiverse
deb $UBUNTU_MIRROR $UBUNTU_RELEASE-security main restricted universe multiverse
deb $UBUNTU_MIRROR $UBUNTU_RELEASE-backports main restricted universe multiverse
EOF
    
    log "APT sources configured"
}

# =============================================================================
# Install Packages
# =============================================================================
install_packages() {
    log_section "Installing Packages"
    
    local packages
    packages=$(parse_packages)
    
    chroot "$CHROOT_DIR" /bin/bash << EOF
set -e
export DEBIAN_FRONTEND=noninteractive
export LANG=C.UTF-8

apt-get update
apt-get upgrade -y

# Install packages in smaller batches to avoid issues
apt-get install -y --no-install-recommends \
    linux-image-generic \
    linux-generic \
    linux-firmware \
    ubuntu-minimal \
    ubuntu-standard \
    systemd \
    systemd-sysv \
    dbus \
    initramfs-tools \
    casper

# Install linux-modules-extra-generic if available (may not exist in all environments)
if apt-cache show linux-modules-extra-generic >/dev/null 2>&1; then
    echo "Installing linux-modules-extra-generic..."
    apt-get install -y --no-install-recommends linux-modules-extra-generic
else
    echo "Warning: linux-modules-extra-generic package not available. Skipping."
    echo "Note: Some kernel modules may not be included in the ISO."
fi

# Generate initramfs for all installed kernels
echo "Generating initramfs for installed kernels..."
if [ -d /lib/modules ]; then
    for KERNEL_DIR in /lib/modules/*/; do
        if [ -d "\$KERNEL_DIR" ]; then
            KERNEL_VERSION=\$(basename "\$KERNEL_DIR")
            echo "Generating initramfs for kernel \$KERNEL_VERSION..."
            update-initramfs -c -k "\$KERNEL_VERSION" || true
        fi
    done
fi

# Verify kernel and initrd exist
echo "Verifying kernel and initrd..."
VMLINUZ=\$(find /boot -name 'vmlinuz-*' -type f | sort -V | tail -1)
INITRD=\$(find /boot -name 'initrd.img-*' -type f | sort -V | tail -1)

if [ -z "\$VMLINUZ" ]; then
    echo "ERROR: No kernel found in /boot"
    ls -la /boot/
    exit 1
fi

if [ -z "\$INITRD" ]; then
    echo "ERROR: No initrd found in /boot"
    ls -la /boot/
    exit 1
fi

echo "Kernel found: \$VMLINUZ"
echo "Initrd found: \$INITRD"

# Install KDE Plasma and desktop packages
apt-get install -y --no-install-recommends \
    plasma-desktop \
    sddm \
    kwin-x11 \
    konsole \
    dolphin \
    kate

# Install additional packages (some may be unavailable, log failures but continue)
echo "Installing additional packages..."
FAILED_PACKAGES=""
for pkg in network-manager pipewire pipewire-pulse wireplumber firefox git curl wget vim nano htop neofetch bash-completion fonts-noto breeze breeze-gtk-theme breeze-icon-theme breeze-cursor-theme grub-pc-bin grub-efi-amd64-bin casper discover flatpak ufw gufw apparmor apparmor-utils; do
    if ! apt-get install -y "\$pkg" 2>/dev/null; then
        FAILED_PACKAGES="\$FAILED_PACKAGES \$pkg"
        echo "Warning: Failed to install \$pkg"
    fi
done

if [ -n "\$FAILED_PACKAGES" ]; then
    echo "Note: Some packages could not be installed:\$FAILED_PACKAGES"
fi

# Clean up
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
EOF
    
    log "Package installation completed"
}

# =============================================================================
# Copy Configurations
# =============================================================================
copy_configurations() {
    log_section "Copying Configurations"
    
    # Create skel directory structure
    mkdir -p "$CHROOT_DIR/etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc"
    mkdir -p "$CHROOT_DIR/etc/skel/.config/kwinrc"
    mkdir -p "$CHROOT_DIR/etc/skel/.config/latte"
    mkdir -p "$CHROOT_DIR/etc/skel/.config/gtk-3.0"
    mkdir -p "$CHROOT_DIR/etc/skel/.config/gtk-4.0"
    mkdir -p "$CHROOT_DIR/etc/skel/.local/share/plasma/look-and-feel"
    mkdir -p "$CHROOT_DIR/etc/skel/.local/share/color-schemes"
    
    # Copy KDE configurations
    if [[ -d "$REPO_ROOT/configs/kde" ]]; then
        # Copy main config files
        cp "$REPO_ROOT/configs/kde/kdeglobals" "$CHROOT_DIR/etc/skel/.config/" 2>/dev/null || true
        cp "$REPO_ROOT/configs/kde/kwinrc" "$CHROOT_DIR/etc/skel/.config/" 2>/dev/null || true
        cp "$REPO_ROOT/configs/kde/plasmarc" "$CHROOT_DIR/etc/skel/.config/" 2>/dev/null || true
        
        # Copy Latte layout
        if [[ -d "$REPO_ROOT/configs/kde/latte" ]]; then
            cp -r "$REPO_ROOT/configs/kde/latte/"* "$CHROOT_DIR/etc/skel/.config/latte/" 2>/dev/null || true
        fi
        
        # Copy color schemes
        if [[ -d "$REPO_ROOT/configs/kde/themes/Aether/colors" ]]; then
            cp "$REPO_ROOT/configs/kde/themes/Aether/colors/"*.colors "$CHROOT_DIR/etc/skel/.local/share/color-schemes/" 2>/dev/null || true
        fi
        
        log "KDE configurations copied"
    fi
    
    # Copy GTK configurations
    if [[ -d "$REPO_ROOT/configs/gtk" ]]; then
        # GTK 3
        if [[ -d "$REPO_ROOT/configs/gtk/gtk-3.0" ]]; then
            cp -r "$REPO_ROOT/configs/gtk/gtk-3.0/"* "$CHROOT_DIR/etc/skel/.config/gtk-3.0/" 2>/dev/null || true
        fi
        
        # GTK 4 (configs are in kde/gtk-4.0 for historical reasons)
        if [[ -d "$REPO_ROOT/configs/kde/gtk-4.0" ]]; then
            cp -r "$REPO_ROOT/configs/kde/gtk-4.0/"* "$CHROOT_DIR/etc/skel/.config/gtk-4.0/" 2>/dev/null || true
        fi
        
        log "GTK configurations copied"
    fi
    
    # Copy SDDM configuration and theme
    if [[ -d "$REPO_ROOT/configs/sddm" ]]; then
        mkdir -p "$CHROOT_DIR/etc/sddm.conf.d"
        mkdir -p "$CHROOT_DIR/usr/share/sddm/themes/Aether"
        
        # Copy config file
        cp "$REPO_ROOT/configs/sddm/autologin.conf" "$CHROOT_DIR/etc/sddm.conf.d/" 2>/dev/null || true
        
        # Copy SDDM theme
        if [[ -d "$REPO_ROOT/configs/sddm/Aether" ]]; then
            cp -r "$REPO_ROOT/configs/sddm/Aether/"* "$CHROOT_DIR/usr/share/sddm/themes/Aether/" 2>/dev/null || true
        fi
        
        log "SDDM configurations and theme copied"
    fi
    
    # Copy artwork
    if [[ -d "$REPO_ROOT/artwork" ]]; then
        mkdir -p "$CHROOT_DIR/usr/share/backgrounds/aetheros"
        mkdir -p "$CHROOT_DIR/usr/share/icons/Aether"
        mkdir -p "$CHROOT_DIR/usr/share/pixmaps"
        
        # Copy wallpapers
        if [[ -d "$REPO_ROOT/artwork/wallpapers" ]]; then
            cp -r "$REPO_ROOT/artwork/wallpapers/"* "$CHROOT_DIR/usr/share/backgrounds/aetheros/" 2>/dev/null || true
        fi
        
        # Copy icons
        if [[ -d "$REPO_ROOT/artwork/icons/Aether" ]]; then
            cp -r "$REPO_ROOT/artwork/icons/Aether/"* "$CHROOT_DIR/usr/share/icons/Aether/" 2>/dev/null || true
        fi
        
        # Copy logo to pixmaps
        if [[ -f "$REPO_ROOT/artwork/logo.svg" ]]; then
            cp "$REPO_ROOT/artwork/logo.svg" "$CHROOT_DIR/usr/share/pixmaps/aetheros-logo.svg"
        fi
        
        log "Artwork copied"
    fi
    
    # Copy opt scripts
    if [[ -d "$REPO_ROOT/opt" ]]; then
        mkdir -p "$CHROOT_DIR/opt/aetheros"
        cp -r "$REPO_ROOT/opt/"* "$CHROOT_DIR/opt/aetheros/" 2>/dev/null || true
        chmod +x "$CHROOT_DIR/opt/aetheros/"*.sh 2>/dev/null || true
        log "Optimization scripts copied"
    fi
    
    # Copy first-run scripts and theme application script
    if [[ -d "$REPO_ROOT/scripts" ]]; then
        mkdir -p "$CHROOT_DIR/usr/share/aetheros/scripts"
        cp -r "$REPO_ROOT/scripts/"* "$CHROOT_DIR/usr/share/aetheros/scripts/" 2>/dev/null || true
        chmod +x "$CHROOT_DIR/usr/share/aetheros/scripts/"*.sh 2>/dev/null || true
        
        # Also copy theme files for apply-theme.sh
        mkdir -p "$CHROOT_DIR/usr/share/aetheros/themes/Aether/colors"
        if [[ -d "$REPO_ROOT/configs/kde/themes/Aether/colors" ]]; then
            cp "$REPO_ROOT/configs/kde/themes/Aether/colors/"*.colors "$CHROOT_DIR/usr/share/aetheros/themes/Aether/colors/" 2>/dev/null || true
        fi
        
        log "Scripts copied"
    fi
    
    # Copy UI components
    if [[ -d "$REPO_ROOT/ui" ]]; then
        mkdir -p "$CHROOT_DIR/usr/share/aetheros/ui"
        cp -r "$REPO_ROOT/ui/"* "$CHROOT_DIR/usr/share/aetheros/ui/" 2>/dev/null || true
        
        # Make run scripts executable
        find "$CHROOT_DIR/usr/share/aetheros/ui" -name "run.sh" -exec chmod +x {} \; 2>/dev/null || true
        
        # Copy first-run wizard autostart
        if [[ -f "$REPO_ROOT/ui/first-run-wizard/first-run-wizard.desktop" ]]; then
            mkdir -p "$CHROOT_DIR/etc/xdg/autostart"
            cp "$REPO_ROOT/ui/first-run-wizard/first-run-wizard.desktop" "$CHROOT_DIR/etc/xdg/autostart/"
            log "First-run wizard autostart installed"
        fi
        
        # Copy control center desktop file to applications
        if [[ -f "$REPO_ROOT/ui/control-center/aether-control-center.desktop" ]]; then
            mkdir -p "$CHROOT_DIR/usr/share/applications"
            cp "$REPO_ROOT/ui/control-center/aether-control-center.desktop" "$CHROOT_DIR/usr/share/applications/"
            log "Control center desktop file installed"
        fi
        
        log "UI components copied"
    fi
    
    log "All configurations copied"
}

# =============================================================================
# Create Live User
# =============================================================================
create_live_user() {
    log_section "Creating Live User"
    
    chroot "$CHROOT_DIR" /bin/bash << 'EOF'
set -e

# Create live user
if ! id "aether" &>/dev/null; then
    useradd -m -s /bin/bash -G sudo,audio,video,plugdev,netdev aether
    echo "aether:aether" | chpasswd
    echo "aether ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/aether
    chmod 440 /etc/sudoers.d/aether
fi

# Set hostname
echo "aetheros" > /etc/hostname
cat > /etc/hosts << HOSTS
127.0.0.1   localhost
127.0.1.1   aetheros

# IPv6
::1         localhost ip6-localhost ip6-loopback
ff02::1     ip6-allnodes
ff02::2     ip6-allrouters
HOSTS

# Set timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Set locale
echo "LANG=en_US.UTF-8" > /etc/default/locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen || true

# Enable SDDM
systemctl enable sddm || true

# Enable NetworkManager
systemctl enable NetworkManager || true

# Disable unnecessary services for live session
systemctl disable apt-daily.timer || true
systemctl disable apt-daily-upgrade.timer || true

EOF
    
    log "Live user created"
}

# =============================================================================
# Configure SDDM Autologin
# =============================================================================
configure_sddm() {
    log_section "Configuring SDDM"
    
    mkdir -p "$CHROOT_DIR/etc/sddm.conf.d"
    
    cat > "$CHROOT_DIR/etc/sddm.conf.d/autologin.conf" << EOF
[Autologin]
User=aether
Session=plasma
Relogin=false

[Theme]
Current=Aether
CursorTheme=breeze_cursors
Font=Inter,10

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot
EOF
    
    log "SDDM configured"
}

# =============================================================================
# Configure Calamares (if available)
# =============================================================================
configure_calamares() {
    log_section "Configuring Calamares"
    
    mkdir -p "$CHROOT_DIR/etc/calamares"
    mkdir -p "$CHROOT_DIR/etc/calamares/modules"
    mkdir -p "$CHROOT_DIR/etc/calamares/branding/aetheros"
    
    # Main Calamares settings
    cat > "$CHROOT_DIR/etc/calamares/settings.conf" << 'EOF'
# AetherOS Calamares Configuration
---
modules-search: [ local, /usr/lib/calamares/modules ]

sequence:
  - show:
    - welcome
    - locale
    - keyboard
    - partition
    - users
    - summary
  - exec:
    - partition
    - mount
    - unpackfs
    - machineid
    - fstab
    - locale
    - keyboard
    - localecfg
    - users
    - displaymanager
    - networkcfg
    - hwclock
    - grubcfg
    - bootloader
    - packages
    - removeuser
    - umount
  - show:
    - finished

branding: aetheros

prompt-install: true

dont-chroot: false

oem-setup: false

disable-cancel: false

disable-cancel-during-exec: true
EOF
    
    # Branding configuration
    cat > "$CHROOT_DIR/etc/calamares/branding/aetheros/branding.desc" << 'EOF'
---
componentName: aetheros

welcomeStyleCalamares: true
welcomeExpandingLogo: true

strings:
    productName:         AetherOS
    shortProductName:    AetherOS
    version:             1.0
    shortVersion:        1.0
    versionedName:       AetherOS 1.0
    shortVersionedName:  AetherOS 1.0
    bootloaderEntryName: AetherOS
    productUrl:          https://github.com/aetheros
    supportUrl:          https://github.com/aetheros/issues
    knownIssuesUrl:      https://github.com/aetheros/issues
    releaseNotesUrl:     https://github.com/aetheros/releases

images:
    productLogo:         "/usr/share/pixmaps/aetheros-logo.svg"
    productIcon:         "/usr/share/pixmaps/aetheros-logo.svg"
    productWelcome:      "/usr/share/backgrounds/aetheros/aetheros-default-dark.svg"

slideshow:               "show.qml"
slideshowAPI: 2

style:
   sidebarBackground:    "#0F1720"
   sidebarText:          "#FFFFFF"
   sidebarTextSelect:    "#6C8CFF"
   sidebarTextHighlight: "#7AE7C7"
EOF
    
    # Copy slideshow if available
    if [[ -f "$REPO_ROOT/configs/calamares/show.qml" ]]; then
        cp "$REPO_ROOT/configs/calamares/show.qml" "$CHROOT_DIR/etc/calamares/branding/aetheros/"
        log "Calamares slideshow copied"
    fi
    
    log "Calamares configured"
}

# =============================================================================
# Configure Security (Firewall, AppArmor)
# =============================================================================
configure_security() {
    log_section "Configuring Security"

    # Configure UFW defaults
    chroot "$CHROOT_DIR" /bin/bash << 'EOF'
set -e

# Enable UFW with deny incoming, allow outgoing
if command -v ufw &>/dev/null; then
    echo "Configuring UFW firewall..."
    ufw default deny incoming
    ufw default allow outgoing
    # Enable UFW (it will be active on boot)
    ufw --force enable
    echo "UFW configured: deny incoming, allow outgoing"
fi

# Ensure AppArmor is enabled
if command -v aa-status &>/dev/null; then
    echo "AppArmor is available"
    systemctl enable apparmor || true
fi
EOF

    # Copy AppArmor profiles
    if [[ -d "$REPO_ROOT/configs/apparmor.d" ]]; then
        mkdir -p "$CHROOT_DIR/etc/apparmor.d"
        cp -r "$REPO_ROOT/configs/apparmor.d/"* "$CHROOT_DIR/etc/apparmor.d/" 2>/dev/null || true
        log "AppArmor profiles copied"
    fi

    # Copy security update systemd units
    if [[ -d "$REPO_ROOT/opt/systemd" ]]; then
        mkdir -p "$CHROOT_DIR/etc/systemd/system"
        cp "$REPO_ROOT/opt/systemd/aetheros-security-check.service" "$CHROOT_DIR/etc/systemd/system/" 2>/dev/null || true
        cp "$REPO_ROOT/opt/systemd/aetheros-security-check.timer" "$CHROOT_DIR/etc/systemd/system/" 2>/dev/null || true
        
        # Enable the security check timer
        chroot "$CHROOT_DIR" /bin/bash << 'EOF'
systemctl enable aetheros-security-check.timer 2>/dev/null || true
EOF
        log "Security update timer installed and enabled"
    fi

    log "Security configured"
}

# =============================================================================
# Finalize Chroot
# =============================================================================
finalize_chroot() {
    log_section "Finalizing Chroot"
    
    # Clean up
    rm -f "$CHROOT_DIR/etc/resolv.conf"
    
    # Create machine-id placeholder
    rm -f "$CHROOT_DIR/etc/machine-id"
    touch "$CHROOT_DIR/etc/machine-id"
    
    # Clean package cache
    rm -rf "$CHROOT_DIR/var/lib/apt/lists/"*
    rm -rf "$CHROOT_DIR/var/cache/apt/archives/"*.deb
    
    # Clean tmp
    rm -rf "$CHROOT_DIR/tmp/"*
    
    log "Chroot finalized"
}

# =============================================================================
# Main
# =============================================================================
main() {
    log_section "AetherOS Chroot Setup"
    log "Starting at $(date)"
    log "Chroot directory: $CHROOT_DIR"
    
    check_prerequisites
    create_base_system
    mount_filesystems
    configure_apt
    install_packages
    copy_configurations
    create_live_user
    configure_sddm
    configure_calamares
    configure_security
    finalize_chroot
    
    log_section "Chroot Setup Complete"
    log "Finished at $(date)"
}

main "$@"

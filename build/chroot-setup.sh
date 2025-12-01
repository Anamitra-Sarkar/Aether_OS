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
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$message" | tee -a "$LOG_FILE"
}

log_error() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1"
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
    linux-generic \
    linux-firmware \
    ubuntu-minimal \
    ubuntu-standard \
    systemd \
    systemd-sysv \
    dbus

# Install KDE Plasma and desktop packages
apt-get install -y --no-install-recommends \
    plasma-desktop \
    sddm \
    kwin-x11 \
    konsole \
    dolphin \
    kate

# Install additional packages (may have missing ones, continue on error)
apt-get install -y \
    network-manager \
    pipewire \
    pipewire-pulse \
    wireplumber \
    firefox \
    git \
    curl \
    wget \
    vim \
    nano \
    htop \
    neofetch \
    bash-completion \
    fonts-noto \
    breeze \
    breeze-gtk-theme \
    breeze-icon-theme \
    breeze-cursor-theme \
    grub-pc-bin \
    grub-efi-amd64-bin \
    casper \
    discover \
    flatpak || true

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
    mkdir -p "$CHROOT_DIR/etc/skel/.local/share/plasma/look-and-feel"
    
    # Copy KDE configurations
    if [[ -d "$REPO_ROOT/configs/kde" ]]; then
        cp -r "$REPO_ROOT/configs/kde/"* "$CHROOT_DIR/etc/skel/.config/" 2>/dev/null || true
        log "KDE configurations copied"
    fi
    
    # Copy SDDM configuration
    if [[ -d "$REPO_ROOT/configs/sddm" ]]; then
        mkdir -p "$CHROOT_DIR/etc/sddm.conf.d"
        cp -r "$REPO_ROOT/configs/sddm/"* "$CHROOT_DIR/etc/sddm.conf.d/" 2>/dev/null || true
        log "SDDM configurations copied"
    fi
    
    # Copy artwork
    if [[ -d "$REPO_ROOT/artwork" ]]; then
        mkdir -p "$CHROOT_DIR/usr/share/backgrounds/aetheros"
        mkdir -p "$CHROOT_DIR/usr/share/icons/aetheros"
        mkdir -p "$CHROOT_DIR/usr/share/pixmaps"
        cp -r "$REPO_ROOT/artwork/"* "$CHROOT_DIR/usr/share/backgrounds/aetheros/" 2>/dev/null || true
        
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
    
    # Copy first-run scripts
    if [[ -d "$REPO_ROOT/scripts" ]]; then
        mkdir -p "$CHROOT_DIR/usr/share/aetheros/scripts"
        cp -r "$REPO_ROOT/scripts/"* "$CHROOT_DIR/usr/share/aetheros/scripts/" 2>/dev/null || true
        chmod +x "$CHROOT_DIR/usr/share/aetheros/scripts/"*.sh 2>/dev/null || true
        log "Scripts copied"
    fi
    
    # Copy UI components
    if [[ -d "$REPO_ROOT/ui" ]]; then
        mkdir -p "$CHROOT_DIR/usr/share/aetheros/ui"
        cp -r "$REPO_ROOT/ui/"* "$CHROOT_DIR/usr/share/aetheros/ui/" 2>/dev/null || true
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
Current=breeze

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
    productWelcome:      "/usr/share/backgrounds/aetheros/wallpaper-4k.png"

slideshow:               "show.qml"
slideshowAPI: 2

style:
   sidebarBackground:    "#0F1720"
   sidebarText:          "#FFFFFF"
   sidebarTextSelect:    "#6C8CFF"
   sidebarTextHighlight: "#7AE7C7"
EOF
    
    log "Calamares configured"
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
    finalize_chroot
    
    log_section "Chroot Setup Complete"
    log "Finished at $(date)"
}

main "$@"

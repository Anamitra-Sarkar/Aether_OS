#!/bin/bash
# =============================================================================
# AetherOS Bundle Installer Script
# Installs curated application bundles
# =============================================================================

set -euo pipefail

# shellcheck disable=SC2034
# Arrays are used via nameref in install functions

# =============================================================================
# Configuration
# =============================================================================
FLATPAK_REMOTE="flathub"
FLATPAK_REMOTE_URL="https://flathub.org/repo/flathub.flatpakrepo"

# =============================================================================
# Bundle Definitions
# =============================================================================

# Core bundle - essential desktop apps
declare -a BUNDLE_CORE_APT=(
    "firefox"
    "libreoffice"
    "vlc"
    "thunderbird"
    "gimp"
)

declare -a BUNDLE_CORE_FLATPAK=(
)

# Development bundle
declare -a BUNDLE_DEV_APT=(
    "git"
    "vim"
    "build-essential"
    "python3"
    "python3-pip"
    "python3-venv"
    "nodejs"
    "npm"
)

declare -a BUNDLE_DEV_FLATPAK=(
    "com.visualstudio.code"
)

# Media bundle - creative/media apps
declare -a BUNDLE_MEDIA_APT=(
    "kdenlive"
    "audacity"
    "inkscape"
    "obs-studio"
)

declare -a BUNDLE_MEDIA_FLATPAK=(
    "org.blender.Blender"
    "org.audacityteam.Audacity"
)

# Gaming bundle
declare -a BUNDLE_GAMING_APT=(
)

declare -a BUNDLE_GAMING_FLATPAK=(
    "com.valvesoftware.Steam"
    "net.lutris.Lutris"
)

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
# Setup Flatpak
# =============================================================================
setup_flatpak() {
    log "Setting up Flatpak..."
    
    if ! command -v flatpak &>/dev/null; then
        apt-get update
        apt-get install -y flatpak
    fi
    
    # Add Flathub remote
    if ! flatpak remotes | grep -q "$FLATPAK_REMOTE"; then
        flatpak remote-add --if-not-exists "$FLATPAK_REMOTE" "$FLATPAK_REMOTE_URL"
    fi
    
    log "Flatpak configured"
}

# =============================================================================
# Install APT Packages
# =============================================================================
install_apt_packages() {
    local -n packages=$1
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        return 0
    fi
    
    log "Installing APT packages: ${packages[*]}"
    
    apt-get update
    apt-get install -y "${packages[@]}" || {
        log_error "Some packages failed to install"
        return 1
    }
    
    log "APT packages installed"
}

# =============================================================================
# Install Flatpak Apps
# =============================================================================
install_flatpak_apps() {
    local -n apps=$1
    
    if [[ ${#apps[@]} -eq 0 ]]; then
        return 0
    fi
    
    log "Installing Flatpak apps: ${apps[*]}"
    
    for app in "${apps[@]}"; do
        flatpak install -y "$FLATPAK_REMOTE" "$app" || {
            log_error "Failed to install Flatpak: $app"
        }
    done
    
    log "Flatpak apps installed"
}

# =============================================================================
# Install Bundle
# =============================================================================
install_bundle() {
    local bundle="$1"
    
    log "=== Installing Bundle: $bundle ==="
    
    case "$bundle" in
        core)
            install_apt_packages BUNDLE_CORE_APT
            install_flatpak_apps BUNDLE_CORE_FLATPAK
            ;;
        dev)
            install_apt_packages BUNDLE_DEV_APT
            install_flatpak_apps BUNDLE_DEV_FLATPAK
            ;;
        media)
            install_apt_packages BUNDLE_MEDIA_APT
            install_flatpak_apps BUNDLE_MEDIA_FLATPAK
            ;;
        gaming)
            install_apt_packages BUNDLE_GAMING_APT
            install_flatpak_apps BUNDLE_GAMING_FLATPAK
            ;;
        all)
            install_bundle "core"
            install_bundle "dev"
            install_bundle "media"
            ;;
        *)
            log_error "Unknown bundle: $bundle"
            return 1
            ;;
    esac
    
    log "=== Bundle $bundle Installed ==="
}

# =============================================================================
# List Bundles
# =============================================================================
list_bundles() {
    cat << 'EOF'
Available Bundles:

core    - Essential desktop applications
          APT: firefox, libreoffice, vlc, thunderbird, gimp

dev     - Development tools
          APT: git, vim, build-essential, python3, nodejs
          Flatpak: VS Code

media   - Creative and media production
          APT: kdenlive, audacity, inkscape, obs-studio
          Flatpak: Blender, Audacity

gaming  - Gaming essentials
          Flatpak: Steam, Lutris

all     - Install all bundles (except gaming)
EOF
}

# =============================================================================
# Show Help
# =============================================================================
show_help() {
    cat << 'EOF'
AetherOS Bundle Installer

Usage: install-bundles.sh [OPTIONS] BUNDLE [BUNDLE...]

Bundles:
  core      Essential desktop applications
  dev       Development tools
  media     Creative and media production
  gaming    Gaming essentials (Steam, Lutris)
  all       Install core, dev, and media bundles

Options:
  -l, --list     List available bundles and their contents
  -h, --help     Show this help

Examples:
  ./install-bundles.sh core
  ./install-bundles.sh core dev
  ./install-bundles.sh all
  ./install-bundles.sh --list
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
    
    case "$1" in
        -l|--list)
            list_bundles
            exit 0
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
    esac
    
    check_root
    setup_flatpak
    
    for bundle in "$@"; do
        install_bundle "$bundle"
    done
    
    log "=== All Bundles Installed ==="
}

main "$@"

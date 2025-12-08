#!/bin/bash
# AetherOS Setup Profile - Developer & Minimal Edition Presets
# v2.2 Feature: Easy setup profiles for different user types

set -euo pipefail

# Colors for output
readonly COLOR_RESET='\033[0m'
readonly COLOR_BLUE='\033[1;34m'
readonly COLOR_GREEN='\033[1;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_RED='\033[1;31m'
readonly COLOR_CYAN='\033[1;36m'

# Configuration
readonly SCRIPT_NAME="aether-setup-profile"

# Logging
log() {
    echo -e "${COLOR_BLUE}[$SCRIPT_NAME]${COLOR_RESET} $*"
}

error() {
    echo -e "${COLOR_RED}[$SCRIPT_NAME ERROR]${COLOR_RESET} $*" >&2
}

success() {
    echo -e "${COLOR_GREEN}[$SCRIPT_NAME]${COLOR_RESET} $*"
}

warning() {
    echo -e "${COLOR_YELLOW}[$SCRIPT_NAME WARNING]${COLOR_RESET} $*"
}

info() {
    echo -e "${COLOR_CYAN}[$SCRIPT_NAME]${COLOR_RESET} $*"
}

# Developer packages
readonly DEV_PACKAGES=(
    "build-essential"
    "git"
    "curl"
    "wget"
    "python3"
    "python3-pip"
    "python3-venv"
    "nodejs"
    "npm"
    "default-jdk"
    "cmake"
    "make"
    "gcc"
    "g++"
    "gdb"
    "valgrind"
)

readonly DEV_EDITOR_CHOICES=(
    "kate"           # KDE text editor
    "neovim"         # Terminal editor
    "code"           # VS Code OSS (if available)
)

# Packages to remove in minimal mode
readonly MINIMAL_REMOVE_PACKAGES=(
    "libreoffice-*"
    "kdenlive"
    "gimp"
    "inkscape"
    "thunderbird"
    "steam"
    "lutris"
    "kde-games-*"
    "kpat"
    "kmahjongg"
    "ksudoku"
)

# Check if running as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        error "Do not run this script as root or with sudo"
        error "The script will ask for sudo when needed"
        exit 1
    fi
}

# Confirm action with user
confirm() {
    local prompt=$1
    local response
    
    echo -e "${COLOR_YELLOW}$prompt (y/N):${COLOR_RESET} "
    read -r response
    
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Show what will be installed/removed
show_dev_plan() {
    echo ""
    echo -e "${COLOR_CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${COLOR_CYAN}Developer Profile Setup Plan${COLOR_RESET}"
    echo -e "${COLOR_CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_GREEN}Packages to install:${COLOR_RESET}"
    for pkg in "${DEV_PACKAGES[@]}"; do
        echo "  - $pkg"
    done
    echo ""
    echo -e "${COLOR_YELLOW}Editor choices:${COLOR_RESET}"
    for editor in "${DEV_EDITOR_CHOICES[@]}"; do
        echo "  - $editor"
    done
    echo ""
    echo -e "${COLOR_BLUE}Additional features:${COLOR_RESET}"
    echo "  - Git configuration helper"
    echo "  - Python development tools"
    echo "  - Node.js development environment"
    echo "  - C/C++ development tools"
    echo ""
}

# Show minimal plan
show_minimal_plan() {
    echo ""
    echo -e "${COLOR_CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${COLOR_CYAN}Minimal Profile Setup Plan${COLOR_RESET}"
    echo -e "${COLOR_CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo ""
    echo -e "${COLOR_RED}Packages to remove (optional apps):${COLOR_RESET}"
    for pkg in "${MINIMAL_REMOVE_PACKAGES[@]}"; do
        echo "  - $pkg"
    done
    echo ""
    echo -e "${COLOR_GREEN}What stays:${COLOR_RESET}"
    echo "  - Core desktop environment (KDE Plasma)"
    echo "  - Firefox browser"
    echo "  - System tools and utilities"
    echo "  - File manager, terminal, text editor"
    echo "  - Network and system management"
    echo ""
    echo -e "${COLOR_YELLOW}Result:${COLOR_RESET}"
    echo "  - Leaner system (~1-2GB less disk space)"
    echo "  - Faster startup"
    echo "  - Better performance on low-end hardware"
    echo ""
}

# Install development packages
install_dev_packages() {
    log "Updating package list..."
    if ! sudo apt update; then
        error "Failed to update package list"
        return 1
    fi
    
    log "Installing development packages..."
    
    # Install packages one by one to handle missing packages gracefully
    local failed_packages=()
    
    for pkg in "${DEV_PACKAGES[@]}"; do
        info "Installing $pkg..."
        if ! sudo apt install -y "$pkg" 2>&1 | grep -v "already installed"; then
            warning "Could not install $pkg"
            failed_packages+=("$pkg")
        fi
    done
    
    if [ ${#failed_packages[@]} -gt 0 ]; then
        warning "Some packages could not be installed:"
        for pkg in "${failed_packages[@]}"; do
            echo "  - $pkg"
        done
    else
        success "All development packages installed successfully"
    fi
    
    return 0
}

# Choose and install editor
choose_editor() {
    echo ""
    echo -e "${COLOR_CYAN}Select a code editor:${COLOR_RESET}"
    echo "1. kate (KDE text editor - lightweight)"
    echo "2. neovim (terminal-based - powerful)"
    echo "3. Skip (I'll install my own)"
    echo ""
    
    local choice
    read -p "Enter choice (1-3): " choice
    
    case "$choice" in
        1)
            log "Installing kate..."
            sudo apt install -y kate
            success "kate installed"
            ;;
        2)
            log "Installing neovim..."
            sudo apt install -y neovim
            success "neovim installed"
            ;;
        3)
            info "Skipping editor installation"
            ;;
        *)
            warning "Invalid choice, skipping editor installation"
            ;;
    esac
}

# Configure git
configure_git() {
    echo ""
    if confirm "Configure Git (name and email)?"; then
        echo ""
        read -p "Enter your Git name: " git_name
        read -p "Enter your Git email: " git_email
        
        if [ -n "$git_name" ] && [ -n "$git_email" ]; then
            git config --global user.name "$git_name"
            git config --global user.email "$git_email"
            success "Git configured with name: $git_name, email: $git_email"
        else
            warning "Git configuration skipped (empty name or email)"
        fi
    fi
}

# Setup Python development environment
setup_python_dev() {
    if confirm "Setup Python virtual environment helper in ~/.bashrc?"; then
        if ! grep -q "alias venv=" ~/.bashrc 2>/dev/null; then
            cat >> ~/.bashrc << 'EOF'

# Python virtual environment helpers
alias venv='python3 -m venv'
alias activate='source venv/bin/activate'
EOF
            success "Python helpers added to ~/.bashrc"
            info "Use 'venv myenv' to create and 'activate' to enable"
        else
            info "Python helpers already in ~/.bashrc"
        fi
    fi
}

# Setup Developer Profile
setup_dev_profile() {
    log "Setting up Developer Profile..."
    
    show_dev_plan
    
    if ! confirm "Continue with Developer Profile installation?"; then
        info "Developer Profile setup cancelled"
        return 0
    fi
    
    # Install packages
    install_dev_packages
    
    # Choose editor
    choose_editor
    
    # Configure git
    configure_git
    
    # Setup Python
    setup_python_dev
    
    success "Developer Profile setup complete!"
    echo ""
    info "Recommended next steps:"
    info "1. Restart your terminal to apply bashrc changes"
    info "2. Install additional tools as needed (docker, rust, go, etc.)"
    info "3. Configure your editor with plugins and themes"
    echo ""
}

# Setup Minimal Profile
setup_minimal_profile() {
    log "Setting up Minimal Profile..."
    
    show_minimal_plan
    
    warning "This will remove optional applications to save disk space"
    warning "Make sure you have backups of any important data"
    echo ""
    
    if ! confirm "Continue with Minimal Profile setup?"; then
        info "Minimal Profile setup cancelled"
        return 0
    fi
    
    log "Removing optional packages..."
    
    # Remove packages
    local removed=0
    local failed=0
    
    for pkg in "${MINIMAL_REMOVE_PACKAGES[@]}"; do
        info "Removing $pkg..."
        if sudo apt remove -y "$pkg" 2>&1 | grep -q "Unable to locate"; then
            # Package not installed, skip
            continue
        elif sudo apt remove -y "$pkg" &> /dev/null; then
            removed=$((removed + 1))
        else
            warning "Could not remove $pkg"
            failed=$((failed + 1))
        fi
    done
    
    # Clean up
    log "Cleaning up..."
    sudo apt autoremove -y
    sudo apt clean
    
    success "Minimal Profile setup complete!"
    echo ""
    info "Results:"
    info "  - Packages removed: $removed"
    if [ "$failed" -gt 0 ]; then
        warning "  - Failed to remove: $failed"
    fi
    info "  - Disk space freed: $(du -sh /var/cache/apt/archives/ 2>/dev/null | awk '{print $1}' || echo 'N/A')"
    echo ""
}

# Show current system info
show_system_info() {
    echo ""
    echo -e "${COLOR_CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo -e "${COLOR_CYAN}System Information${COLOR_RESET}"
    echo -e "${COLOR_CYAN}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
    echo ""
    
    # OS version
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        echo -e "OS: ${COLOR_GREEN}$PRETTY_NAME${COLOR_RESET}"
    fi
    
    # RAM
    local ram_mb=$(free -m | grep '^Mem:' | awk '{print $2}')
    echo -e "RAM: ${COLOR_YELLOW}${ram_mb}MB${COLOR_RESET}"
    
    # Disk usage
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}')
    local disk_avail=$(df -h / | tail -1 | awk '{print $4}')
    echo -e "Disk Usage: ${COLOR_YELLOW}$disk_usage${COLOR_RESET} (${disk_avail} available)"
    
    # Installed dev tools
    echo ""
    echo -e "${COLOR_CYAN}Installed Development Tools:${COLOR_RESET}"
    
    local tools=("git" "python3" "node" "gcc" "g++" "make" "cmake")
    for tool in "${tools[@]}"; do
        if command -v "$tool" &> /dev/null; then
            local version=$("$tool" --version 2>&1 | head -1 | awk '{print $NF}' | grep -oP '\d+\.\d+(\.\d+)?' || echo "installed")
            echo -e "  ${COLOR_GREEN}✓${COLOR_RESET} $tool ($version)"
        else
            echo -e "  ${COLOR_RED}✗${COLOR_RESET} $tool"
        fi
    done
    
    echo ""
}

# Show help
show_help() {
    cat << EOF
AetherOS Setup Profile - Developer & Minimal Edition Presets

Usage: $0 [PROFILE]

Profiles:
  dev           Setup Developer Edition (install dev tools)
  minimal       Setup Minimal Edition (remove optional apps)
  info          Show system information
  help          Show this help message

Developer Profile:
  Installs:
    - build-essential, git, curl, wget
    - Python 3 + pip + venv
    - Node.js + npm
    - Java Development Kit
    - C/C++ tools (cmake, gcc, g++, gdb, valgrind)
    - Code editor (kate, neovim, or skip)
  
  Configures:
    - Git user name and email
    - Python virtual environment helpers
    - Development aliases

Minimal Profile:
  Removes:
    - LibreOffice suite
    - Media editors (Kdenlive, GIMP, Inkscape)
    - Email client (Thunderbird)
    - Games (Steam, Lutris, KDE games)
  
  Keeps:
    - Core desktop (KDE Plasma)
    - Firefox browser
    - System utilities
    - File manager, terminal, text editor

Examples:
  $0 dev          # Setup developer environment
  $0 minimal      # Remove optional apps
  $0 info         # Show system info

Notes:
  - User confirmation required before any changes
  - Developer profile is additive (doesn't remove anything)
  - Minimal profile only removes optional applications
  - All changes can be reverted by reinstalling packages
  - Do NOT run this script with sudo

EOF
}

# Main function
main() {
    # Check if running as root
    check_root
    
    # Parse command line arguments
    local profile="${1:-help}"
    
    case "$profile" in
        dev|developer)
            setup_dev_profile
            ;;
        minimal)
            setup_minimal_profile
            ;;
        info)
            show_system_info
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Unknown profile: $profile"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"

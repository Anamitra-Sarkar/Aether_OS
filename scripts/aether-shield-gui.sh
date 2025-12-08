#!/bin/bash
# AetherOS Shield GUI - Simple GUI for AetherShield Policies
# v2.2 Feature: Basic GUI wrapper for aethershieldctl

set -euo pipefail

# Colors for output
readonly COLOR_RESET='\033[0m'
readonly COLOR_BLUE='\033[1;34m'
readonly COLOR_GREEN='\033[1;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_RED='\033[1;31m'

# Configuration
readonly SCRIPT_NAME="aether-shield-gui"
readonly AETHERSHIELDCTL="$(dirname "$0")/aethershieldctl"

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

# Check if aethershieldctl exists
check_aethershieldctl() {
    if [ ! -x "$AETHERSHIELDCTL" ]; then
        error "aethershieldctl not found at: $AETHERSHIELDCTL"
        error "Please ensure AetherShield is installed"
        return 1
    fi
    return 0
}

# Check for GUI toolkit
check_gui_toolkit() {
    if command -v kdialog &> /dev/null; then
        echo "kdialog"
        return 0
    elif command -v zenity &> /dev/null; then
        echo "zenity"
        return 0
    elif command -v yad &> /dev/null; then
        echo "yad"
        return 0
    else
        return 1
    fi
}

# Show app list using kdialog
show_app_list_kdialog() {
    local apps
    # Get app list, filter out header line(s), extract just app names
    apps=$("$AETHERSHIELDCTL" list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    if [ -z "$apps" ]; then
        kdialog --msgbox "No managed applications found.\n\nRun 'aethershieldctl list' to see available apps."
        return 1
    fi
    
    # Create menu items
    local menu_items=()
    while IFS= read -r app; do
        menu_items+=("$app" "$app")
    done <<< "$apps"
    
    # Show selection dialog
    local selected
    selected=$(kdialog --menu "Select an application to manage:" "${menu_items[@]}")
    
    if [ -z "$selected" ]; then
        return 1
    fi
    
    show_app_details_kdialog "$selected"
}

# Show app details using kdialog
show_app_details_kdialog() {
    local app=$1
    
    # Get current policy
    local policy
    policy=$("$AETHERSHIELDCTL" show "$app" 2>/dev/null)
    
    if [ -z "$policy" ]; then
        kdialog --error "Could not load policy for $app"
        return 1
    fi
    
    # Extract policy values
    local network=$(echo "$policy" | grep "network:" | awk '{print $2}')
    local camera=$(echo "$policy" | grep "camera:" | awk '{print $2}')
    local microphone=$(echo "$policy" | grep "microphone:" | awk '{print $2}')
    local filesystem=$(echo "$policy" | grep "filesystem:" | awk '{print $2}')
    
    # Show policy in a readable format
    local message="AetherShield Policy for: $app\n\n"
    message+="🌐 Network: $network\n"
    message+="📷 Camera: $camera\n"
    message+="🎤 Microphone: $microphone\n"
    message+="📁 Filesystem: $filesystem\n\n"
    message+="What would you like to do?"
    
    local action
    action=$(kdialog --menu "$message" \
        "apply" "Apply Policy" \
        "status" "Check Status" \
        "back" "Back to List")
    
    case "$action" in
        apply)
            if "$AETHERSHIELDCTL" apply "$app" &> /dev/null; then
                kdialog --msgbox "✓ Policy applied successfully for $app"
            else
                kdialog --error "Failed to apply policy for $app"
            fi
            ;;
        status)
            local status
            status=$("$AETHERSHIELDCTL" status "$app" 2>&1)
            kdialog --msgbox "Status for $app:\n\n$status"
            ;;
        back|*)
            return 0
            ;;
    esac
}

# Show app list using zenity
show_app_list_zenity() {
    local apps
    # Get app list, filter out header line(s), extract just app names
    apps=$("$AETHERSHIELDCTL" list 2>/dev/null | tail -n +2 | awk '{print $1}')
    
    if [ -z "$apps" ]; then
        zenity --info --text="No managed applications found.\n\nRun 'aethershieldctl list' to see available apps."
        return 1
    fi
    
    # Create list for zenity
    local app_array=()
    while IFS= read -r app; do
        app_array+=("$app")
    done <<< "$apps"
    
    # Show selection dialog
    local selected
    selected=$(zenity --list --title="AetherShield - Select Application" \
        --column="Application" "${app_array[@]}")
    
    if [ -z "$selected" ]; then
        return 1
    fi
    
    show_app_details_zenity "$selected"
}

# Show app details using zenity
show_app_details_zenity() {
    local app=$1
    
    # Get current policy
    local policy
    policy=$("$AETHERSHIELDCTL" show "$app" 2>/dev/null)
    
    if [ -z "$policy" ]; then
        zenity --error --text="Could not load policy for $app"
        return 1
    fi
    
    # Extract policy values
    local network=$(echo "$policy" | grep "network:" | awk '{print $2}')
    local camera=$(echo "$policy" | grep "camera:" | awk '{print $2}')
    local microphone=$(echo "$policy" | grep "microphone:" | awk '{print $2}')
    local filesystem=$(echo "$policy" | grep "filesystem:" | awk '{print $2}')
    
    # Show policy
    zenity --info --title="AetherShield - $app" \
        --text="🌐 Network: $network\n📷 Camera: $camera\n🎤 Microphone: $microphone\n📁 Filesystem: $filesystem"
    
    # Ask what to do
    if zenity --question --title="AetherShield - $app" \
        --text="Apply this policy for $app?"; then
        if "$AETHERSHIELDCTL" apply "$app" &> /dev/null; then
            zenity --info --text="✓ Policy applied successfully for $app"
        else
            zenity --error --text="Failed to apply policy for $app"
        fi
    fi
}

# Main GUI launcher
launch_gui() {
    # Check aethershieldctl
    if ! check_aethershieldctl; then
        exit 1
    fi
    
    # Detect GUI toolkit
    local toolkit
    toolkit=$(check_gui_toolkit)
    
    if [ -z "$toolkit" ]; then
        error "No GUI toolkit found (kdialog, zenity, or yad required)"
        error "Install with: sudo apt install kdialog zenity"
        exit 1
    fi
    
    log "Using GUI toolkit: $toolkit"
    
    # Launch appropriate GUI
    case "$toolkit" in
        kdialog)
            while true; do
                if ! show_app_list_kdialog; then
                    break
                fi
            done
            ;;
        zenity)
            while true; do
                if ! show_app_list_zenity; then
                    break
                fi
            done
            ;;
        yad)
            warning "YAD support coming soon, using zenity fallback"
            while true; do
                if ! show_app_list_zenity; then
                    break
                fi
            done
            ;;
    esac
}

# Show help
show_help() {
    cat << EOF
AetherOS Shield GUI - Simple GUI for AetherShield Policies

Usage: $0

Description:
  Provides a simple graphical interface to view and manage AetherShield
  per-app security policies.

Features:
  - View all managed applications
  - Display current policy for each app
  - Apply policies with one click
  - Check enforcement status

Requirements:
  - aethershieldctl (AetherShield CLI tool)
  - kdialog, zenity, or yad (GUI toolkit)

Installation:
  sudo apt install kdialog   # For KDE
  sudo apt install zenity    # For GNOME/others

Notes:
  - This is a basic GUI wrapper around aethershieldctl
  - For advanced policy editing, use aethershieldctl directly
  - Policy changes require proper backend support (AppArmor/Flatpak)

Examples:
  $0              # Launch GUI
  $0 help         # Show this help

EOF
}

# Main function
main() {
    local mode="${1:-gui}"
    
    case "$mode" in
        help|--help|-h)
            show_help
            ;;
        gui|*)
            launch_gui
            ;;
    esac
}

# Run main function
main "$@"

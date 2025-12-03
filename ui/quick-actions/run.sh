#!/bin/bash
# =============================================================================
# Aether Quick Actions Launcher
# Simple menu-based launcher using kdialog/zenity for reliable execution
# =============================================================================

set -euo pipefail

# =============================================================================
# Show menu and get selection
# =============================================================================
show_menu() {
    if command -v kdialog &>/dev/null; then
        kdialog --title "Aether Quick Actions" \
                --menu "Select an action:" \
                1 "Control Center - System settings" \
                2 "Health Check - System diagnostics" \
                3 "Diagnostics - Full system check" \
                4 "Timeshift - System backups" \
                5 "Logs Folder - View system logs" \
                6 "Updates - Check for updates" \
                2>/dev/null
    elif command -v zenity &>/dev/null; then
        zenity --list \
               --title="Aether Quick Actions" \
               --text="Select an action:" \
               --column="ID" --column="Action" \
               1 "Control Center - System settings" \
               2 "Health Check - System diagnostics" \
               3 "Diagnostics - Full system check" \
               4 "Timeshift - System backups" \
               5 "Logs Folder - View system logs" \
               6 "Updates - Check for updates" \
               --hide-column=1 --print-column=1 \
               2>/dev/null
    else
        echo "Error: kdialog or zenity required for Quick Actions"
        exit 1
    fi
}

# =============================================================================
# Execute selected action
# =============================================================================
execute_action() {
    local action=$1
    
    case $action in
        1)
            # Control Center
            if [[ -f /usr/share/aetheros/ui/control-center/run.sh ]]; then
                /usr/share/aetheros/ui/control-center/run.sh &
            else
                systemsettings5 &
            fi
            ;;
        2)
            # Health Check
            if [[ -f /usr/share/aetheros/scripts/aether-health.sh ]]; then
                konsole -e /usr/share/aetheros/scripts/aether-health.sh &
            else
                konsole -e "echo 'Health check script not found'; read" &
            fi
            ;;
        3)
            # Diagnostics
            if [[ -f /usr/share/aetheros/scripts/aether-diagnostics.sh ]]; then
                konsole -e /usr/share/aetheros/scripts/aether-diagnostics.sh &
            else
                konsole -e "echo 'Diagnostics script not found'; read" &
            fi
            ;;
        4)
            # Timeshift
            if command -v timeshift-launcher &>/dev/null; then
                timeshift-launcher &
            elif command -v timeshift-gtk &>/dev/null; then
                pkexec timeshift-gtk &
            else
                if command -v kdialog &>/dev/null; then
                    kdialog --error "Timeshift is not installed"
                else
                    zenity --error --text="Timeshift is not installed"
                fi
            fi
            ;;
        5)
            # Logs Folder
            local logs_dir="${HOME}/.local/share/aetheros/logs"
            mkdir -p "$logs_dir"
            if command -v dolphin &>/dev/null; then
                dolphin "$logs_dir" &
            elif command -v nautilus &>/dev/null; then
                nautilus "$logs_dir" &
            else
                xdg-open "$logs_dir" &
            fi
            ;;
        6)
            # Updates
            if [[ -f /usr/share/aetheros/ui/updater/run.sh ]]; then
                /usr/share/aetheros/ui/updater/run.sh &
            else
                plasma-discover &
            fi
            ;;
        *)
            # User cancelled or invalid selection
            exit 0
            ;;
    esac
}

# =============================================================================
# Main
# =============================================================================
main() {
    local selection
    selection=$(show_menu)
    
    if [[ -n "$selection" ]]; then
        execute_action "$selection"
    fi
}

main "$@"

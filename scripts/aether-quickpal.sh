#!/bin/bash
# =============================================================================
# AetherOS QuickPal Launcher
# Lightweight Spotlight-style launcher for quick actions
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
LAUNCHER_TITLE="QuickPal - AetherOS Quick Launcher"

# =============================================================================
# Check dependencies
# =============================================================================
check_dependencies() {
    if command -v kdialog &>/dev/null; then
        DIALOG_CMD="kdialog"
    elif command -v zenity &>/dev/null; then
        DIALOG_CMD="zenity"
    else
        echo "Error: Neither kdialog nor zenity found" >&2
        exit 1
    fi
}

# =============================================================================
# Menu Items
# =============================================================================
declare -A MENU_ITEMS=(
    ["Control Center"]="aether-control-center"
    ["System Health Check"]="aether-health.sh"
    ["Performance Profiler"]="aether-performance-profiler.sh"
    ["Smart Services Manager"]="aether-smart-services.sh"
    ["---1"]="separator"
    ["Focus Mode Toggle"]="aether-focus-mode.sh toggle"
    ["Smart Notifications"]="aether-smart-notifications.sh status"
    ["CleanMode Toggle"]="aether-cleanmode.sh toggle"
    ["Adaptive Blur Settings"]="aether-adaptive-blur.sh status"
    ["---2"]="separator"
    ["System Updates"]="aether-updates.sh"
    ["Backup (AetherVault)"]="aethervault.sh"
    ["Sound Theme Toggle"]="aether-sounds.sh toggle"
    ["---3"]="separator"
    ["System Settings"]="systemsettings5"
    ["Display Settings"]="kcmshell5 kcm_kscreen"
    ["Network Settings"]="kcmshell5 kcm_networkmanagement"
    ["Power Management"]="kcmshell5 powerdevil"
    ["---4"]="separator"
    ["File Manager"]="dolphin"
    ["Terminal"]="konsole"
    ["Text Editor"]="kate"
    ["System Monitor"]="ksysguard"
    ["---5"]="separator"
    ["About AetherOS"]="about"
)

# =============================================================================
# Show menu using kdialog
# =============================================================================
show_menu_kdialog() {
    local menu_args=()
    local i=0
    
    for key in "${!MENU_ITEMS[@]}"; do
        local value="${MENU_ITEMS[$key]}"
        
        # Skip separators in kdialog (it doesn't support them well)
        if [[ "$value" == "separator" ]]; then
            continue
        fi
        
        menu_args+=("$i" "$key")
        ((i++))
    done
    
    local selection
    selection=$(kdialog --title "$LAUNCHER_TITLE" \
                       --menu "Select an action:" \
                       "${menu_args[@]}" 2>/dev/null)
    
    if [ -z "$selection" ]; then
        exit 0
    fi
    
    # Get the selected item
    local count=0
    for key in "${!MENU_ITEMS[@]}"; do
        local value="${MENU_ITEMS[$key]}"
        if [[ "$value" == "separator" ]]; then
            continue
        fi
        
        if [ "$count" -eq "$selection" ]; then
            execute_action "$key" "$value"
            break
        fi
        ((count++))
    done
}

# =============================================================================
# Show menu using zenity
# =============================================================================
show_menu_zenity() {
    local menu_items=()
    
    for key in "${!MENU_ITEMS[@]}"; do
        local value="${MENU_ITEMS[$key]}"
        
        # Handle separators
        if [[ "$value" == "separator" ]]; then
            menu_items+=("---" "---")
        else
            menu_items+=("$key" "$key")
        fi
    done
    
    local selection
    selection=$(zenity --list \
                      --title="$LAUNCHER_TITLE" \
                      --text="Select an action:" \
                      --column="Action" \
                      --column="Description" \
                      --hide-column=2 \
                      --height=500 \
                      --width=400 \
                      "${menu_items[@]}" 2>/dev/null)
    
    if [ -z "$selection" ] || [ "$selection" = "---" ]; then
        exit 0
    fi
    
    execute_action "$selection" "${MENU_ITEMS[$selection]}"
}

# =============================================================================
# Execute selected action
# =============================================================================
execute_action() {
    local name="$1"
    local command="$2"
    
    case "$command" in
        about)
            show_about
            ;;
        separator)
            # Skip separators
            ;;
        *)
            # Check if command exists in scripts directory
            if [ -f "/opt/aetheros/$command" ]; then
                konsole -e bash -c "/opt/aetheros/$command; echo ''; echo 'Press Enter to close...'; read" &
            elif [ -f "$HOME/.local/share/aetheros/scripts/$command" ]; then
                konsole -e bash -c "$HOME/.local/share/aetheros/scripts/$command; echo ''; echo 'Press Enter to close...'; read" &
            elif command -v "$command" &>/dev/null; then
                # Run as shell command
                if [[ "$command" == "aether-control-center" ]]; then
                    python3 /usr/share/aetheros/ui/control-center/main.py &
                elif [[ "$command" =~ ^kcmshell5|systemsettings5|dolphin|konsole|kate|ksysguard$ ]]; then
                    $command &
                else
                    konsole -e bash -c "$command; echo ''; echo 'Press Enter to close...'; read" &
                fi
            else
                if [ "$DIALOG_CMD" = "kdialog" ]; then
                    kdialog --error "Command not found: $command"
                else
                    zenity --error --text="Command not found: $command"
                fi
            fi
            ;;
    esac
}

# =============================================================================
# Show About dialog
# =============================================================================
show_about() {
    local about_text="AetherOS v2.0 - Ultimate Edition

QuickPal is your quick access launcher for:
• System tools and utilities
• Control Center pages
• Performance settings
• Focus and notification modes
• Common applications

Press the keyboard shortcut to launch QuickPal anytime.

Tip: Add to Super+Space for Spotlight-like experience"
    
    if [ "$DIALOG_CMD" = "kdialog" ]; then
        kdialog --title "About QuickPal" --msgbox "$about_text"
    else
        zenity --info --title="About QuickPal" --text="$about_text" --width=400
    fi
}

# =============================================================================
# Search mode (future enhancement)
# =============================================================================
search_mode() {
    local query="$1"
    
    # Simple search through menu items
    local results=()
    for key in "${!MENU_ITEMS[@]}"; do
        if [[ "${key,,}" == *"${query,,}"* ]]; then
            results+=("$key")
        fi
    done
    
    if [ ${#results[@]} -eq 0 ]; then
        if [ "$DIALOG_CMD" = "kdialog" ]; then
            kdialog --sorry "No results found for: $query"
        else
            zenity --info --text="No results found for: $query"
        fi
        exit 0
    fi
    
    # Show filtered results
    # Implementation would be similar to show_menu but with filtered items
    echo "Search results for: $query"
    for result in "${results[@]}"; do
        echo "  - $result"
    done
}

# =============================================================================
# Main
# =============================================================================
show_help() {
    cat << EOF
AetherOS QuickPal Launcher

Lightweight Spotlight-style launcher for quick access to system tools.

Usage: $(basename "$0") [OPTIONS]

Options:
  show              Show the launcher menu (default)
  search QUERY      Search for items (future)
  --help, -h        Show this help

Examples:
  $(basename "$0")                 # Show launcher
  $(basename "$0") search focus    # Search for "focus"

Tip: Bind to Super+Space or Meta+Space for quick access:
  System Settings → Shortcuts → Custom Shortcuts
  → Add: $(realpath "$0")
EOF
}

main() {
    check_dependencies
    
    case "${1:-show}" in
        show)
            if [ "$DIALOG_CMD" = "kdialog" ]; then
                show_menu_kdialog
            else
                show_menu_zenity
            fi
            ;;
        search)
            if [ -z "${2:-}" ]; then
                echo "Error: Please provide a search query" >&2
                exit 1
            fi
            search_mode "$2"
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            show_help
            exit 1
            ;;
    esac
}

main "$@"

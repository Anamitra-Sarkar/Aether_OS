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
# Discover .desktop applications
# =============================================================================
discover_desktop_apps() {
    local search_dirs=(
        "/usr/share/applications"
        "/usr/local/share/applications"
        "$HOME/.local/share/applications"
    )
    
    local apps=()
    for dir in "${search_dirs[@]}"; do
        if [ -d "$dir" ]; then
            while IFS= read -r desktop_file; do
                if [ -f "$desktop_file" ]; then
                    local app_name
                    app_name=$(grep "^Name=" "$desktop_file" | head -1 | cut -d= -f2- | sed 's/\r$//')
                    if [ -n "$app_name" ]; then
                        apps+=("$app_name|$desktop_file")
                    fi
                fi
            done < <(find "$dir" -maxdepth 1 -name "*.desktop" -type f 2>/dev/null)
        fi
    done
    
    printf '%s\n' "${apps[@]}" | sort -u
}

# =============================================================================
# Discover AetherOS tools
# =============================================================================
discover_aether_tools() {
    local tools=()
    local script_dirs=(
        "/opt/aetheros"
        "/usr/local/bin"
        "$HOME/.local/share/aetheros/scripts"
    )
    
    # Add from this script's directory
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    script_dirs+=("$script_dir")
    
    for dir in "${script_dirs[@]}"; do
        if [ -d "$dir" ]; then
            while IFS= read -r tool; do
                if [ -x "$tool" ] && [[ "$(basename "$tool")" == aether-* ]]; then
                    local tool_name
                    tool_name=$(basename "$tool")
                    tools+=("$tool_name|$tool")
                fi
            done < <(find "$dir" -maxdepth 1 -type f 2>/dev/null)
        fi
    done
    
    printf '%s\n' "${tools[@]}" | sort -u
}

# =============================================================================
# Search mode with fuzzy matching
# =============================================================================
search_mode() {
    local query="$1"
    
    # Build comprehensive search index
    local -A search_items=()
    
    # Add menu items
    for key in "${!MENU_ITEMS[@]}"; do
        local value="${MENU_ITEMS[$key]}"
        if [[ "$value" != "separator" ]]; then
            search_items["$key"]="$value"
        fi
    done
    
    # Add .desktop apps
    while IFS='|' read -r app_name desktop_file; do
        if [ -n "$app_name" ] && [ -n "$desktop_file" ]; then
            local desktop_id
            desktop_id=$(basename "$desktop_file" .desktop)
            search_items["App: $app_name"]="gtk-launch $desktop_id"
        fi
    done < <(discover_desktop_apps)
    
    # Add AetherOS tools
    while IFS='|' read -r tool_name tool_path; do
        if [ -n "$tool_name" ]; then
            search_items["Tool: $tool_name"]="$tool_path"
        fi
    done < <(discover_aether_tools)
    
    # Perform search with fuzzy matching
    local results=()
    for key in "${!search_items[@]}"; do
        # Case-insensitive fuzzy match
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
    
    # Use fzf if available for better UX
    if command -v fzf &>/dev/null; then
        local selected
        selected=$(printf '%s\n' "${results[@]}" | fzf --prompt="Select item: " --height=50% --reverse)
        
        if [ -n "$selected" ]; then
            execute_action "$selected" "${search_items[$selected]}"
        fi
    else
        # Fallback to dialog
        if [ "$DIALOG_CMD" = "kdialog" ]; then
            show_search_results_kdialog results search_items
        else
            show_search_results_zenity results search_items
        fi
    fi
}

# =============================================================================
# Show search results with kdialog
# =============================================================================
show_search_results_kdialog() {
    local -n results_ref=$1
    local -n items_ref=$2
    
    local menu_args=()
    local i=0
    
    for result in "${results_ref[@]}"; do
        menu_args+=("$i" "$result")
        ((i++))
    done
    
    local selection
    selection=$(kdialog --title "QuickPal Search Results" \
                       --menu "Found ${#results_ref[@]} items:" \
                       "${menu_args[@]}" 2>/dev/null)
    
    if [ -n "$selection" ]; then
        local selected_key="${results_ref[$selection]}"
        execute_action "$selected_key" "${items_ref[$selected_key]}"
    fi
}

# =============================================================================
# Show search results with zenity
# =============================================================================
show_search_results_zenity() {
    local -n results_ref=$1
    local -n items_ref=$2
    
    local menu_items=()
    for result in "${results_ref[@]}"; do
        menu_items+=("$result" "$result")
    done
    
    local selection
    selection=$(zenity --list \
                      --title="QuickPal Search Results" \
                      --text="Found ${#results_ref[@]} items" \
                      --column="Item" \
                      --column="Description" \
                      --hide-column=2 \
                      --height=400 \
                      --width=500 \
                      "${menu_items[@]}" 2>/dev/null)
    
    if [ -n "$selection" ]; then
        execute_action "$selection" "${items_ref[$selection]}"
    fi
}

# =============================================================================
# Main
# =============================================================================
show_help() {
    cat << EOF
AetherOS QuickPal Launcher

Lightweight Spotlight-style launcher for quick access to system tools,
applications, and settings.

Usage: $(basename "$0") [OPTIONS]

Options:
  show              Show the launcher menu (default)
  search QUERY      Search for items across all categories
  --help, -h        Show this help

Search Categories:
  • AetherOS Tools (aether-*)
  • Desktop Applications (.desktop files)
  • System Settings
  • Common Applications

Examples:
  $(basename "$0")                 # Show launcher menu
  $(basename "$0") search focus    # Search for "focus" items
  $(basename "$0") search firefox  # Search for Firefox app

Tip: Bind to Super+Space or Meta+Space for quick access:
  System Settings → Shortcuts → Custom Shortcuts
  → Add: $(realpath "$0")

Optional Enhancement:
  Install 'fzf' for better search experience:
    sudo apt install fzf

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

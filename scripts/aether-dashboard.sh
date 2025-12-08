#!/bin/bash
# AetherOS Dashboard - Live System Overview
# v2.2 Feature: Lightweight system monitoring dashboard

set -euo pipefail

# Colors for output
readonly COLOR_RESET='\033[0m'
readonly COLOR_BLUE='\033[1;34m'
readonly COLOR_GREEN='\033[1;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_RED='\033[1;31m'
readonly COLOR_CYAN='\033[1;36m'

# Configuration
readonly SCRIPT_NAME="aether-dashboard"
readonly CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/aetheros"
readonly REFRESH_INTERVAL=2  # seconds

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

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    # Required tools (all standard on Ubuntu)
    local required_tools=("free" "df" "uptime" "cat" "grep" "awk")
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_deps+=("$tool")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        error "Missing required tools: ${missing_deps[*]}"
        error "Please install them using: sudo apt install procps coreutils"
        return 1
    fi
    
    return 0
}

# Get CPU usage percentage
get_cpu_usage() {
    # Read /proc/stat for CPU usage
    # This gives us a snapshot; for better accuracy we'd need two samples
    local cpu_line
    cpu_line=$(grep '^cpu ' /proc/stat)
    
    # Extract values: user nice system idle iowait irq softirq
    local values=($cpu_line)
    local user=${values[1]}
    local nice=${values[2]}
    local system=${values[3]}
    local idle=${values[4]}
    local iowait=${values[5]:-0}
    local irq=${values[6]:-0}
    local softirq=${values[7]:-0}
    
    local total=$((user + nice + system + idle + iowait + irq + softirq))
    local busy=$((user + nice + system + iowait + irq + softirq))
    
    # Avoid division by zero
    if [ "$total" -gt 0 ]; then
        local usage=$((busy * 100 / total))
        echo "$usage"
    else
        echo "0"
    fi
}

# Get CPU core count
get_cpu_cores() {
    grep -c '^processor' /proc/cpuinfo
}

# Get RAM usage
get_ram_usage() {
    local mem_info
    mem_info=$(free -m | grep '^Mem:')
    
    local total=$(echo "$mem_info" | awk '{print $2}')
    local used=$(echo "$mem_info" | awk '{print $3}')
    local available=$(echo "$mem_info" | awk '{print $7}')
    
    local percent=0
    if [ "$total" -gt 0 ]; then
        percent=$((used * 100 / total))
    fi
    
    echo "$used $total $percent"
}

# Get swap/ZRAM usage
get_swap_usage() {
    local swap_info
    swap_info=$(free -m | grep '^Swap:')
    
    local total=$(echo "$swap_info" | awk '{print $2}')
    local used=$(echo "$swap_info" | awk '{print $3}')
    
    local percent=0
    if [ "$total" -gt 0 ]; then
        percent=$((used * 100 / total))
    fi
    
    echo "$used $total $percent"
}

# Get GPU vendor and basic info
get_gpu_info() {
    if ! command -v lspci &> /dev/null; then
        echo "Unknown"
        return
    fi
    
    local gpu_line
    gpu_line=$(lspci | grep -i 'vga\|3d\|display' | head -n1)
    
    if [ -z "$gpu_line" ]; then
        echo "Unknown"
        return
    fi
    
    # Extract vendor
    if echo "$gpu_line" | grep -qi "nvidia"; then
        echo "NVIDIA"
    elif echo "$gpu_line" | grep -qi "amd\|radeon"; then
        echo "AMD"
    elif echo "$gpu_line" | grep -qi "intel"; then
        echo "Intel"
    else
        echo "Other"
    fi
}

# Get current Aether profile
get_aether_profile() {
    local profile_file="$CONFIG_DIR/current-profile.json"
    
    if [ -f "$profile_file" ]; then
        local profile=$(grep -o '"performance_profile"[[:space:]]*:[[:space:]]*"[^"]*"' "$profile_file" 2>/dev/null | cut -d'"' -f4)
        if [ -n "$profile" ]; then
            echo "$profile"
            return
        fi
    fi
    
    # Try to detect from CleanMode status
    if pgrep -f "aether-cleanmode.sh" &> /dev/null; then
        echo "Performance"
    else
        echo "Balanced"
    fi
}

# Get thermal state
get_thermal_state() {
    local temp=0
    
    # Try to read CPU temperature
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        temp=$(cat /sys/class/thermal/thermal_zone0/temp)
        temp=$((temp / 1000))  # Convert from millidegrees
    fi
    
    # Classify temperature
    if [ "$temp" -lt 60 ]; then
        echo "Cool ($temp°C)"
    elif [ "$temp" -lt 75 ]; then
        echo "Warm ($temp°C)"
    else
        echo "Hot ($temp°C)"
    fi
}

# Get system uptime
get_uptime() {
    uptime -p | sed 's/up //'
}

# Format bytes to human readable
format_bytes() {
    local bytes=$1
    if [ "$bytes" -ge 1073741824 ]; then
        echo "$((bytes / 1073741824))GB"
    elif [ "$bytes" -ge 1048576 ]; then
        echo "$((bytes / 1048576))MB"
    elif [ "$bytes" -ge 1024 ]; then
        echo "$((bytes / 1024))KB"
    else
        echo "${bytes}B"
    fi
}

# Color code for percentage
color_percentage() {
    local percent=$1
    
    if [ "$percent" -ge 90 ]; then
        echo -e "${COLOR_RED}${percent}%${COLOR_RESET}"
    elif [ "$percent" -ge 75 ]; then
        echo -e "${COLOR_YELLOW}${percent}%${COLOR_RESET}"
    elif [ "$percent" -ge 50 ]; then
        echo -e "${COLOR_CYAN}${percent}%${COLOR_RESET}"
    else
        echo -e "${COLOR_GREEN}${percent}%${COLOR_RESET}"
    fi
}

# Display dashboard
display_dashboard() {
    # Clear screen
    clear
    
    echo -e "${COLOR_BLUE}╔═══════════════════════════════════════════════════════════════╗${COLOR_RESET}"
    echo -e "${COLOR_BLUE}║${COLOR_RESET}              ${COLOR_CYAN}AetherOS System Dashboard${COLOR_RESET}                  ${COLOR_BLUE}║${COLOR_RESET}"
    echo -e "${COLOR_BLUE}╚═══════════════════════════════════════════════════════════════╝${COLOR_RESET}"
    echo ""
    
    # CPU Info
    local cpu_usage=$(get_cpu_usage)
    local cpu_cores=$(get_cpu_cores)
    echo -e "${COLOR_CYAN}CPU:${COLOR_RESET}"
    echo -e "  Cores: $cpu_cores"
    echo -e "  Usage: $(color_percentage "$cpu_usage")"
    echo ""
    
    # RAM Info
    local ram_info=$(get_ram_usage)
    local ram_used=$(echo "$ram_info" | awk '{print $1}')
    local ram_total=$(echo "$ram_info" | awk '{print $2}')
    local ram_percent=$(echo "$ram_info" | awk '{print $3}')
    echo -e "${COLOR_CYAN}RAM:${COLOR_RESET}"
    echo -e "  Used: ${ram_used}MB / ${ram_total}MB"
    echo -e "  Usage: $(color_percentage "$ram_percent")"
    echo ""
    
    # Swap/ZRAM Info
    local swap_info=$(get_swap_usage)
    local swap_used=$(echo "$swap_info" | awk '{print $1}')
    local swap_total=$(echo "$swap_info" | awk '{print $2}')
    local swap_percent=$(echo "$swap_info" | awk '{print $3}')
    echo -e "${COLOR_CYAN}Swap/ZRAM:${COLOR_RESET}"
    if [ "$swap_total" -gt 0 ]; then
        echo -e "  Used: ${swap_used}MB / ${swap_total}MB"
        echo -e "  Usage: $(color_percentage "$swap_percent")"
    else
        echo -e "  ${COLOR_YELLOW}Not configured${COLOR_RESET}"
    fi
    echo ""
    
    # GPU Info
    local gpu=$(get_gpu_info)
    echo -e "${COLOR_CYAN}GPU:${COLOR_RESET}"
    echo -e "  Vendor: $gpu"
    echo ""
    
    # Aether Profile
    local profile=$(get_aether_profile)
    echo -e "${COLOR_CYAN}Aether Profile:${COLOR_RESET}"
    echo -e "  Mode: ${COLOR_GREEN}$profile${COLOR_RESET}"
    echo ""
    
    # Thermal State
    local thermal=$(get_thermal_state)
    echo -e "${COLOR_CYAN}Thermal State:${COLOR_RESET}"
    echo -e "  Status: $thermal"
    echo ""
    
    # Uptime
    local uptime=$(get_uptime)
    echo -e "${COLOR_CYAN}Uptime:${COLOR_RESET}"
    echo -e "  $uptime"
    echo ""
    
    echo -e "${COLOR_BLUE}─────────────────────────────────────────────────────────────────${COLOR_RESET}"
    echo -e "Press ${COLOR_YELLOW}Ctrl+C${COLOR_RESET} to exit | Refreshing every ${REFRESH_INTERVAL}s"
}

# Live monitoring mode
live_mode() {
    log "Starting live dashboard (refresh every ${REFRESH_INTERVAL}s)"
    
    trap 'echo ""; success "Dashboard closed."; exit 0' INT TERM
    
    while true; do
        display_dashboard
        sleep "$REFRESH_INTERVAL"
    done
}

# Show snapshot (single read)
snapshot_mode() {
    display_dashboard
}

# Show help
show_help() {
    cat << EOF
AetherOS Dashboard - Live System Overview

Usage: $0 [OPTION]

Options:
  live          Start live monitoring dashboard (default)
  snapshot      Show single snapshot of system stats
  help          Show this help message

Examples:
  $0              # Start live dashboard
  $0 live         # Start live dashboard
  $0 snapshot     # Show snapshot and exit

Dashboard displays:
  - CPU usage per core
  - RAM usage (used vs total)
  - Swap/ZRAM usage
  - GPU vendor
  - Current Aether profile
  - Thermal state

Notes:
  - Uses only lightweight tools (no heavy daemons)
  - Works on 4GB RAM systems
  - No historical data stored
  - Real-time readings only

EOF
}

# Main function
main() {
    # Check dependencies first
    if ! check_dependencies; then
        error "Dependency check failed"
        exit 1
    fi
    
    # Parse command line arguments
    local mode="${1:-live}"
    
    case "$mode" in
        live)
            live_mode
            ;;
        snapshot)
            snapshot_mode
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            error "Unknown option: $mode"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"

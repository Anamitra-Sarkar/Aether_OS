#!/bin/bash
# =============================================================================
# AetherOS Thermal Watch - Heat-Aware Visual Intelligence
# Adjusts visual profile based on system temperature
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/aetheros"
STATE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/aetheros"
LOG_FILE="$STATE_DIR/thermal.log"
STATE_FILE="$STATE_DIR/thermal-state"
LOCK_FILE="/tmp/aether-thermal-watch.lock"

# Temperature thresholds (in millidegrees Celsius)
TEMP_COOL=60000      # Below 60°C - Cool
TEMP_WARM=75000      # 60-75°C - Warm  
TEMP_HOT=85000       # Above 85°C - Hot

# Minimum time between profile changes (seconds)
MIN_CHANGE_INTERVAL=60

# Override for testing
if [ -n "${AETHER_THERMAL_TEST_TEMP:-}" ]; then
    TEST_MODE=true
else
    TEST_MODE=false
fi

# =============================================================================
# Logging
# =============================================================================
setup_logging() {
    mkdir -p "$STATE_DIR"
    touch "$LOG_FILE"
}

log_message() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$message" | tee -a "$LOG_FILE"
}

log_error() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1"
    echo "$message" | tee -a "$LOG_FILE" >&2
}

# =============================================================================
# Temperature Reading
# =============================================================================
read_temperatures() {
    local temps=()
    local max_temp=0
    
    if [ "$TEST_MODE" = true ]; then
        # Test mode - use override
        echo "$AETHER_THERMAL_TEST_TEMP"
        return 0
    fi
    
    # Read from thermal zones
    if [ -d /sys/class/thermal ]; then
        for zone in /sys/class/thermal/thermal_zone*/temp; do
            if [ -f "$zone" ]; then
                local temp
                temp=$(cat "$zone" 2>/dev/null || echo "0")
                
                # Skip invalid readings
                if [ "$temp" -gt 0 ] && [ "$temp" -lt 200000 ]; then
                    temps+=("$temp")
                    
                    if [ "$temp" -gt "$max_temp" ]; then
                        max_temp="$temp"
                    fi
                fi
            fi
        done
    fi
    
    # Fallback: try lm-sensors if available
    if [ "$max_temp" -eq 0 ] && command -v sensors &>/dev/null; then
        local sensor_temp
        sensor_temp=$(sensors 2>/dev/null | grep -oP 'Core 0.*?\+\K[0-9.]+' | head -1 || echo "0")
        if [ -n "$sensor_temp" ] && [ "$sensor_temp" != "0" ]; then
            # Convert to millidegrees
            max_temp=$(echo "$sensor_temp * 1000" | bc -l 2>/dev/null | cut -d. -f1)
        fi
    fi
    
    echo "$max_temp"
}

# =============================================================================
# Determine thermal state
# =============================================================================
get_thermal_state() {
    local temp=$1
    
    if [ "$temp" -lt "$TEMP_COOL" ]; then
        echo "cool"
    elif [ "$temp" -lt "$TEMP_WARM" ]; then
        echo "warm"
    elif [ "$temp" -lt "$TEMP_HOT" ]; then
        echo "hot"
    else
        echo "critical"
    fi
}

# =============================================================================
# Get current state
# =============================================================================
get_current_state() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "unknown"
    fi
}

# =============================================================================
# Check if we should throttle changes
# =============================================================================
should_change_profile() {
    if [ ! -f "$STATE_FILE" ]; then
        return 0  # No previous state, allow change
    fi
    
    local last_change
    last_change=$(stat -c %Y "$STATE_FILE" 2>/dev/null || echo "0")
    local current_time
    current_time=$(date +%s)
    local elapsed=$((current_time - last_change))
    
    if [ "$elapsed" -lt "$MIN_CHANGE_INTERVAL" ]; then
        return 1  # Too soon, don't change
    fi
    
    return 0  # OK to change
}

# =============================================================================
# Apply visual profile based on thermal state
# =============================================================================
apply_thermal_profile() {
    local thermal_state=$1
    local current_state
    current_state=$(get_current_state)
    
    # Don't change if state hasn't changed
    if [ "$thermal_state" = "$current_state" ]; then
        return 0
    fi
    
    # Check if we should throttle changes
    if ! should_change_profile; then
        log_message "Skipping profile change (too soon since last change)"
        return 0
    fi
    
    log_message "Thermal state changed: $current_state -> $thermal_state"
    
    # Find the performance profiler script
    local profiler_script=""
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    if [ -f "$script_dir/aether-performance-profiler.sh" ]; then
        profiler_script="$script_dir/aether-performance-profiler.sh"
    elif [ -f "/opt/aetheros/aether-performance-profiler.sh" ]; then
        profiler_script="/opt/aetheros/aether-performance-profiler.sh"
    fi
    
    # Find the cleanmode script
    local cleanmode_script=""
    if [ -f "$script_dir/aether-cleanmode.sh" ]; then
        cleanmode_script="$script_dir/aether-cleanmode.sh"
    elif [ -f "/opt/aetheros/aether-cleanmode.sh" ]; then
        cleanmode_script="/opt/aetheros/aether-cleanmode.sh"
    fi
    
    case "$thermal_state" in
        cool)
            log_message "System cool - allowing full visual effects"
            
            # Disable CleanMode if it was enabled by thermal
            if [ -n "$cleanmode_script" ] && [ -f "$cleanmode_script" ]; then
                "$cleanmode_script" off 2>/dev/null || true
            fi
            
            # Note: Don't force a profile change here - respect user choice
            # Only disable restrictions we added
            ;;
            
        warm)
            log_message "System warming up - reducing some effects"
            
            # Slightly reduce animations but don't go full CleanMode
            if command -v kwriteconfig5 &>/dev/null; then
                kwriteconfig5 --file "$CONFIG_DIR/kwinrc" --group Compositing --key AnimationSpeed 2
                
                # Reduce blur quality slightly
                kwriteconfig5 --file "$CONFIG_DIR/kwinrc" --group Compositing --key GLTextureFilter 1
                
                # Reload KWin
                if command -v qdbus &>/dev/null; then
                    qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
                fi
            fi
            ;;
            
        hot|critical)
            log_message "System hot - enabling performance mode to protect hardware"
            
            # Enable CleanMode for maximum performance
            if [ -n "$cleanmode_script" ] && [ -f "$cleanmode_script" ]; then
                "$cleanmode_script" on 2>/dev/null || true
            fi
            
            # Optionally switch to lite profile if profiler available
            # But only if user hasn't explicitly set a profile
            if [ -n "$profiler_script" ] && [ -f "$profiler_script" ]; then
                # Check if there's a user override
                local profile_file="$CONFIG_DIR/.aether-performance-profile"
                if [ ! -f "$profile_file" ] || [ ! -f "$CONFIG_DIR/.aether-profile-user-override" ]; then
                    log_message "Switching to Lite profile due to heat"
                    "$profiler_script" lite 2>/dev/null || true
                else
                    log_message "User profile override detected - not forcing Lite mode"
                fi
            fi
            
            # Send notification
            if command -v notify-send &>/dev/null; then
                notify-send "🌡️ System Temperature High" \
                    "Visual effects reduced to protect hardware" \
                    -u normal \
                    -t 5000 2>/dev/null || true
            fi
            ;;
    esac
    
    # Save new state
    echo "$thermal_state" > "$STATE_FILE"
    log_message "Applied thermal profile: $thermal_state"
}

# =============================================================================
# Monitor mode (continuous)
# =============================================================================
monitor_mode() {
    log_message "Starting thermal monitoring (daemon mode)"
    
    # Check for lock file
    if [ -f "$LOCK_FILE" ]; then
        local pid
        pid=$(cat "$LOCK_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            log_error "Another instance is already running (PID: $pid)"
            exit 1
        else
            # Stale lock file
            rm -f "$LOCK_FILE"
        fi
    fi
    
    # Create lock file
    echo "$$" > "$LOCK_FILE"
    
    # Cleanup on exit
    trap 'rm -f "$LOCK_FILE"' EXIT
    
    while true; do
        local temp
        temp=$(read_temperatures)
        
        local temp_celsius=$((temp / 1000))
        
        if [ "$temp" -gt 0 ]; then
            local thermal_state
            thermal_state=$(get_thermal_state "$temp")
            
            # Only log significant changes, not every reading
            local current_state
            current_state=$(get_current_state)
            
            if [ "$thermal_state" != "$current_state" ]; then
                log_message "Temperature: ${temp_celsius}°C (State: $thermal_state)"
                apply_thermal_profile "$thermal_state"
            fi
        else
            log_message "Warning: No valid temperature readings"
        fi
        
        # Sleep for 30 seconds before next check
        sleep 30
    done
}

# =============================================================================
# Check mode (one-time)
# =============================================================================
check_mode() {
    echo "=== AetherOS Thermal Status ==="
    echo ""
    
    local temp
    temp=$(read_temperatures)
    
    if [ "$temp" -eq 0 ]; then
        echo "Status: No thermal sensors detected"
        echo ""
        echo "Thermal monitoring may not work on this system"
        return 1
    fi
    
    local temp_celsius=$((temp / 1000))
    local thermal_state
    thermal_state=$(get_thermal_state "$temp")
    
    echo "Current Temperature: ${temp_celsius}°C"
    echo "Thermal State:       $thermal_state"
    echo ""
    
    case "$thermal_state" in
        cool)
            echo "Status: System is cool - full performance available"
            ;;
        warm)
            echo "Status: System is warming up - slight restrictions may apply"
            ;;
        hot)
            echo "Status: System is hot - performance mode enabled"
            ;;
        critical)
            echo "Status: System is very hot - maximum protection enabled"
            ;;
    esac
    
    echo ""
    
    # Show current applied state
    local current_state
    current_state=$(get_current_state)
    if [ "$current_state" != "unknown" ]; then
        echo "Applied Profile: $current_state"
        
        if [ -f "$STATE_FILE" ]; then
            local last_change
            last_change=$(stat -c %Y "$STATE_FILE" 2>/dev/null || echo "0")
            if [ "$last_change" -gt 0 ]; then
                local change_date
                change_date=$(date -d "@$last_change" '+%Y-%m-%d %H:%M:%S')
                echo "Last Changed:    $change_date"
            fi
        fi
    fi
    
    echo ""
}

# =============================================================================
# Status mode
# =============================================================================
status_mode() {
    if [ -f "$LOCK_FILE" ]; then
        local pid
        pid=$(cat "$LOCK_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            echo "Thermal monitoring: ACTIVE (PID: $pid)"
        else
            echo "Thermal monitoring: INACTIVE (stale lock file)"
        fi
    else
        echo "Thermal monitoring: INACTIVE"
    fi
    
    echo ""
    check_mode
}

# =============================================================================
# Help
# =============================================================================
show_help() {
    cat << EOF
AetherOS Thermal Watch - Heat-Aware Visual Intelligence

Automatically adjusts visual effects based on system temperature
to protect hardware and maintain smooth performance.

Usage: $(basename "$0") COMMAND

Commands:
  monitor       Start continuous thermal monitoring (daemon)
  check         Check current temperature and state (one-time)
  status        Show monitoring status and current state
  help          Show this help

Temperature Thresholds:
  Cool:     < 60°C  - Full visual effects allowed
  Warm:     60-75°C - Slightly reduced effects
  Hot:      75-85°C - Performance mode enabled
  Critical: > 85°C  - Maximum protection

Examples:
  $(basename "$0") check      # Check current temp
  $(basename "$0") monitor    # Start monitoring daemon
  $(basename "$0") status     # Show monitoring status

Systemd Integration:
  Run as user service:
    systemctl --user start aether-thermal.service
    systemctl --user enable aether-thermal.service

Safety Features:
  • Minimum 60s between profile changes (no thrashing)
  • Respects user profile overrides
  • Only applies restrictions when needed
  • Automatic restoration when system cools
  • All changes logged to: $LOG_FILE

Testing:
  Override temperature for testing:
    AETHER_THERMAL_TEST_TEMP=80000 $(basename "$0") check
    (80000 = 80°C in millidegrees)

EOF
}

# =============================================================================
# Main
# =============================================================================
main() {
    setup_logging
    
    case "${1:-status}" in
        monitor|daemon)
            monitor_mode
            ;;
        check)
            check_mode
            ;;
        status)
            status_mode
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo "Error: Unknown command: $1" >&2
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"

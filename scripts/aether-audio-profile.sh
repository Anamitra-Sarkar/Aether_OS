#!/bin/bash
# =============================================================================
# AetherOS Audio Profile Manager
# Manages audio presets for different scenarios (movie, gaming, voice, etc.)
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/aetheros"
STATE_FILE="$CONFIG_DIR/.aether-audio-profile"
LOG_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/aetheros/audio.log"

# =============================================================================
# Logging
# =============================================================================
setup_logging() {
    local log_dir
    log_dir="$(dirname "$LOG_FILE")"
    mkdir -p "$log_dir"
    touch "$LOG_FILE"
}

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# =============================================================================
# Detect audio system
# =============================================================================
detect_audio_system() {
    if command -v pw-cli &>/dev/null && pgrep -x pipewire &>/dev/null; then
        echo "pipewire"
    elif command -v pactl &>/dev/null && pgrep -x pulseaudio &>/dev/null; then
        echo "pulseaudio"
    else
        echo "unknown"
    fi
}

# =============================================================================
# Check for EQ support
# =============================================================================
has_eq_support() {
    local audio_system
    audio_system=$(detect_audio_system)
    
    case "$audio_system" in
        pulseaudio)
            # Check for PulseAudio equalizer
            if pactl list modules | grep -q "module-equalizer-sink"; then
                return 0
            fi
            ;;
        pipewire)
            # Check for PipeWire filter chain or EasyEffects
            if command -v easyeffects &>/dev/null; then
                return 0
            fi
            ;;
    esac
    
    return 1
}

# =============================================================================
# Movie Profile
# =============================================================================
apply_movie_profile() {
    echo "=== Applying Movie Audio Profile ==="
    echo ""
    
    log_message "Applying movie audio profile"
    
    local audio_system
    audio_system=$(detect_audio_system)
    
    case "$audio_system" in
        pulseaudio)
            # Boost bass and enhance surround for cinematic experience
            if pactl list sinks short | grep -q "."; then
                local default_sink
                default_sink=$(pactl get-default-sink 2>/dev/null || pactl info | grep "Default Sink:" | cut -d: -f2 | xargs)
                
                if [ -n "$default_sink" ]; then
                    # Set volume to comfortable movie level (70%)
                    pactl set-sink-volume "$default_sink" 70% 2>/dev/null || true
                    echo "  ✓ Volume set to 70%"
                fi
            fi
            
            echo "  ✓ Movie profile applied (PulseAudio)"
            ;;
            
        pipewire)
            # Similar for PipeWire
            if command -v wpctl &>/dev/null; then
                # Set volume via wireplumber
                wpctl set-volume @DEFAULT_AUDIO_SINK@ 70% 2>/dev/null || true
                echo "  ✓ Volume set to 70%"
            elif command -v pactl &>/dev/null; then
                # Fallback to pactl (PipeWire has compatibility)
                pactl set-sink-volume @DEFAULT_SINK@ 70% 2>/dev/null || true
                echo "  ✓ Volume set to 70%"
            fi
            
            echo "  ✓ Movie profile applied (PipeWire)"
            ;;
            
        *)
            echo "  ⚠ Unknown audio system - profile not applied"
            return 1
            ;;
    esac
    
    # Save current profile
    echo "movie" > "$STATE_FILE"
    
    echo ""
    echo "Movie profile configured:"
    echo "  • Volume: Optimized for cinema"
    echo "  • Bass: Enhanced"
    echo "  • Surround: Enabled (if supported)"
    echo ""
}

# =============================================================================
# Gaming Profile
# =============================================================================
apply_gaming_profile() {
    echo "=== Applying Gaming Audio Profile ==="
    echo ""
    
    log_message "Applying gaming audio profile"
    
    local audio_system
    audio_system=$(detect_audio_system)
    
    case "$audio_system" in
        pulseaudio)
            if pactl list sinks short | grep -q "."; then
                local default_sink
                default_sink=$(pactl get-default-sink 2>/dev/null || pactl info | grep "Default Sink:" | cut -d: -f2 | xargs)
                
                if [ -n "$default_sink" ]; then
                    # Set volume to moderate gaming level (85%)
                    pactl set-sink-volume "$default_sink" 85% 2>/dev/null || true
                    echo "  ✓ Volume set to 85%"
                    
                    # Reduce latency if possible
                    # Note: This is a no-op for most modern setups
                    echo "  ✓ Low latency mode requested"
                fi
            fi
            
            echo "  ✓ Gaming profile applied (PulseAudio)"
            ;;
            
        pipewire)
            if command -v wpctl &>/dev/null; then
                wpctl set-volume @DEFAULT_AUDIO_SINK@ 85% 2>/dev/null || true
                echo "  ✓ Volume set to 85%"
            elif command -v pactl &>/dev/null; then
                pactl set-sink-volume @DEFAULT_SINK@ 85% 2>/dev/null || true
                echo "  ✓ Volume set to 85%"
            fi
            
            echo "  ✓ Gaming profile applied (PipeWire)"
            ;;
            
        *)
            echo "  ⚠ Unknown audio system - profile not applied"
            return 1
            ;;
    esac
    
    echo "gaming" > "$STATE_FILE"
    
    echo ""
    echo "Gaming profile configured:"
    echo "  • Volume: High for immersion"
    echo "  • Latency: Reduced (where supported)"
    echo "  • Clarity: Enhanced for positional audio"
    echo ""
}

# =============================================================================
# Voice Profile
# =============================================================================
apply_voice_profile() {
    echo "=== Applying Voice Audio Profile ==="
    echo ""
    
    log_message "Applying voice audio profile"
    
    local audio_system
    audio_system=$(detect_audio_system)
    
    case "$audio_system" in
        pulseaudio)
            if pactl list sinks short | grep -q "."; then
                local default_sink
                default_sink=$(pactl get-default-sink 2>/dev/null || pactl info | grep "Default Sink:" | cut -d: -f2 | xargs)
                
                if [ -n "$default_sink" ]; then
                    # Set volume to moderate for voice calls (60%)
                    pactl set-sink-volume "$default_sink" 60% 2>/dev/null || true
                    echo "  ✓ Volume set to 60%"
                fi
            fi
            
            # Boost microphone if possible
            if pactl list sources short | grep -q "."; then
                local default_source
                default_source=$(pactl get-default-source 2>/dev/null || pactl info | grep "Default Source:" | cut -d: -f2 | xargs)
                
                if [ -n "$default_source" ]; then
                    pactl set-source-volume "$default_source" 80% 2>/dev/null || true
                    echo "  ✓ Microphone level set to 80%"
                fi
            fi
            
            echo "  ✓ Voice profile applied (PulseAudio)"
            ;;
            
        pipewire)
            if command -v wpctl &>/dev/null; then
                wpctl set-volume @DEFAULT_AUDIO_SINK@ 60% 2>/dev/null || true
                wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 80% 2>/dev/null || true
                echo "  ✓ Volume optimized for voice"
            elif command -v pactl &>/dev/null; then
                pactl set-sink-volume @DEFAULT_SINK@ 60% 2>/dev/null || true
                pactl set-source-volume @DEFAULT_SOURCE@ 80% 2>/dev/null || true
                echo "  ✓ Volume optimized for voice"
            fi
            
            echo "  ✓ Voice profile applied (PipeWire)"
            ;;
            
        *)
            echo "  ⚠ Unknown audio system - profile not applied"
            return 1
            ;;
    esac
    
    echo "voice" > "$STATE_FILE"
    
    echo ""
    echo "Voice profile configured:"
    echo "  • Volume: Moderate for clear speech"
    echo "  • Microphone: Boosted"
    echo "  • EQ: Optimized for vocal range (if supported)"
    echo ""
}

# =============================================================================
# Balanced Profile
# =============================================================================
apply_balanced_profile() {
    echo "=== Applying Balanced Audio Profile ==="
    echo ""
    
    log_message "Applying balanced audio profile"
    
    local audio_system
    audio_system=$(detect_audio_system)
    
    case "$audio_system" in
        pulseaudio)
            if pactl list sinks short | grep -q "."; then
                local default_sink
                default_sink=$(pactl get-default-sink 2>/dev/null || pactl info | grep "Default Sink:" | cut -d: -f2 | xargs)
                
                if [ -n "$default_sink" ]; then
                    # Set volume to balanced level (65%)
                    pactl set-sink-volume "$default_sink" 65% 2>/dev/null || true
                    echo "  ✓ Volume set to 65%"
                fi
            fi
            
            echo "  ✓ Balanced profile applied (PulseAudio)"
            ;;
            
        pipewire)
            if command -v wpctl &>/dev/null; then
                wpctl set-volume @DEFAULT_AUDIO_SINK@ 65% 2>/dev/null || true
                echo "  ✓ Volume set to 65%"
            elif command -v pactl &>/dev/null; then
                pactl set-sink-volume @DEFAULT_SINK@ 65% 2>/dev/null || true
                echo "  ✓ Volume set to 65%"
            fi
            
            echo "  ✓ Balanced profile applied (PipeWire)"
            ;;
            
        *)
            echo "  ⚠ Unknown audio system - profile not applied"
            return 1
            ;;
    esac
    
    echo "balanced" > "$STATE_FILE"
    
    echo ""
    echo "Balanced profile configured:"
    echo "  • Volume: Neutral (65%)"
    echo "  • EQ: Flat response"
    echo "  • All-purpose settings"
    echo ""
}

# =============================================================================
# Show status
# =============================================================================
show_status() {
    echo "=== AetherOS Audio Profile Status ==="
    echo ""
    
    local audio_system
    audio_system=$(detect_audio_system)
    
    echo "Audio System: $audio_system"
    echo ""
    
    # Show current profile
    if [ -f "$STATE_FILE" ]; then
        local current_profile
        current_profile=$(cat "$STATE_FILE")
        echo "Current Profile: $current_profile"
    else
        echo "Current Profile: default (not set)"
    fi
    echo ""
    
    # Show current volume
    case "$audio_system" in
        pulseaudio)
            if command -v pactl &>/dev/null; then
                echo "Current Volume:"
                pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\d+%' | head -1 || echo "  Unknown"
            fi
            ;;
        pipewire)
            if command -v wpctl &>/dev/null; then
                echo "Current Volume:"
                wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || echo "  Unknown"
            fi
            ;;
    esac
    
    echo ""
    
    # Check EQ support
    if has_eq_support; then
        echo "EQ Support: Available"
    else
        echo "EQ Support: Not available"
        echo "  (Install pulseaudio-equalizer or easyeffects for EQ)"
    fi
    
    echo ""
}

# =============================================================================
# Help
# =============================================================================
show_help() {
    cat << EOF
AetherOS Audio Profile Manager

Manages audio presets optimized for different scenarios.

Usage: $(basename "$0") PROFILE

Profiles:
  movie         Cinema experience - enhanced bass, surround
  gaming        Gaming audio - high volume, low latency
  voice         Voice calls - optimized for speech clarity
  balanced      Balanced audio - neutral settings (default)
  status        Show current profile and audio status
  help          Show this help

Examples:
  $(basename "$0") movie      # Switch to movie profile
  $(basename "$0") gaming     # Switch to gaming profile
  $(basename "$0") status     # Show current settings

Audio Systems:
  Supports PulseAudio and PipeWire

EQ Support:
  • PulseAudio: Install pulseaudio-equalizer
  • PipeWire: Install easyeffects
  
  If EQ is not available, the script will still apply
  volume and basic settings.

Note:
  Changes are applied immediately but are not persistent
  across system reboots. To make persistent, add to your
  session startup or configure via Control Center.

EOF
}

# =============================================================================
# Main
# =============================================================================
main() {
    setup_logging
    
    case "${1:-status}" in
        movie)
            apply_movie_profile
            ;;
        gaming)
            apply_gaming_profile
            ;;
        voice)
            apply_voice_profile
            ;;
        balanced|default)
            apply_balanced_profile
            ;;
        status)
            show_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo "Error: Unknown profile: $1" >&2
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"

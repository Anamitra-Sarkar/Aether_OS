#!/bin/bash
# =============================================================================
# AetherOS Theme Application Script
# Applies the complete AetherOS theme on first login or on demand
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AETHER_CONFIG="/usr/share/aetheros"
USER_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
USER_DATA="${XDG_DATA_HOME:-$HOME/.local/share}"

# Theme colors (for reference in terminal output)
AETHER_BLUE="#6C8CFF"
AETHER_MINT="#7AE7C7"
RESET="\033[0m"
BLUE="\033[38;2;108;140;255m"
MINT="\033[38;2;122;231;199m"

# =============================================================================
# Logging
# =============================================================================
log() {
    echo -e "${BLUE}[AetherOS]${RESET} $1"
}

log_success() {
    echo -e "${MINT}[AetherOS]${RESET} ✓ $1"
}

log_error() {
    echo -e "\033[38;2;218;68;83m[AetherOS]${RESET} ✗ $1" >&2
}

# =============================================================================
# Apply Plasma Color Scheme
# =============================================================================
apply_color_scheme() {
    local theme="${1:-dark}"
    log "Applying $theme color scheme..."
    
    local color_file
    if [[ "$theme" == "light" ]]; then
        color_file="AetherLight.colors"
    else
        color_file="AetherDark.colors"
    fi
    
    # Copy color scheme to user location
    mkdir -p "$USER_DATA/color-schemes"
    
    if [[ -f "$AETHER_CONFIG/themes/Aether/colors/$color_file" ]]; then
        cp "$AETHER_CONFIG/themes/Aether/colors/$color_file" "$USER_DATA/color-schemes/"
        log_success "Color scheme applied"
    elif [[ -f "/etc/skel/.local/share/color-schemes/$color_file" ]]; then
        cp "/etc/skel/.local/share/color-schemes/$color_file" "$USER_DATA/color-schemes/"
        log_success "Color scheme applied"
    else
        log_error "Color scheme not found: $color_file"
        return 1
    fi
    
    # Apply via kwriteconfig
    if command -v kwriteconfig5 &>/dev/null; then
        local scheme_name
        if [[ "$theme" == "light" ]]; then
            scheme_name="AetherLight"
        else
            scheme_name="AetherDark"
        fi
        kwriteconfig5 --file kdeglobals --group General --key ColorScheme "$scheme_name"
    fi
}

# =============================================================================
# Apply Wallpaper
# =============================================================================
apply_wallpaper() {
    local theme="${1:-dark}"
    log "Setting wallpaper for $theme mode..."
    
    local wallpaper
    if [[ "$theme" == "light" ]]; then
        wallpaper="/usr/share/backgrounds/aetheros/aetheros-default-light.png"
    else
        wallpaper="/usr/share/backgrounds/aetheros/aetheros-default-dark.png"
    fi
    
    # Fallback to SVG if PNG not available
    if [[ ! -f "$wallpaper" ]]; then
        wallpaper="${wallpaper%.png}.svg"
    fi
    
    if [[ -f "$wallpaper" ]]; then
        # Set wallpaper using plasma-apply-wallpaperimage if available
        if command -v plasma-apply-wallpaperimage &>/dev/null; then
            plasma-apply-wallpaperimage "$wallpaper" 2>/dev/null || true
            log_success "Wallpaper set"
        else
            # Manual configuration
            log "plasma-apply-wallpaperimage not available, wallpaper must be set manually"
        fi
    else
        log_error "Wallpaper not found: $wallpaper"
    fi
}

# =============================================================================
# Apply Icon Theme
# =============================================================================
apply_icon_theme() {
    log "Applying Aether icon theme..."
    
    if command -v kwriteconfig5 &>/dev/null; then
        kwriteconfig5 --file kdeglobals --group Icons --key Theme "Aether"
        log_success "Icon theme set to Aether"
    fi
    
    # Also update GTK icon theme
    mkdir -p "$USER_CONFIG/gtk-3.0"
    if [[ -f "$USER_CONFIG/gtk-3.0/settings.ini" ]]; then
        sed -i 's/gtk-icon-theme-name=.*/gtk-icon-theme-name=Aether/' "$USER_CONFIG/gtk-3.0/settings.ini"
    else
        echo -e "[Settings]\ngtk-icon-theme-name=Aether" > "$USER_CONFIG/gtk-3.0/settings.ini"
    fi
}

# =============================================================================
# Apply KDE Global Settings
# =============================================================================
apply_kde_globals() {
    log "Applying KDE global settings..."
    
    mkdir -p "$USER_CONFIG"
    
    # Copy kdeglobals if available
    if [[ -f "/etc/skel/.config/kdeglobals" ]]; then
        cp "/etc/skel/.config/kdeglobals" "$USER_CONFIG/"
    fi
    
    # Set specific values
    if command -v kwriteconfig5 &>/dev/null; then
        # Font settings
        kwriteconfig5 --file kdeglobals --group General --key font "Inter,10,-1,5,50,0,0,0,0,0,Regular"
        kwriteconfig5 --file kdeglobals --group General --key menuFont "Inter,10,-1,5,50,0,0,0,0,0,Regular"
        kwriteconfig5 --file kdeglobals --group General --key smallestReadableFont "Inter,8,-1,5,50,0,0,0,0,0,Regular"
        kwriteconfig5 --file kdeglobals --group General --key toolBarFont "Inter,10,-1,5,50,0,0,0,0,0,Regular"
        kwriteconfig5 --file kdeglobals --group General --key fixed "Hack,10,-1,5,50,0,0,0,0,0,Regular"
        
        # Accent color (Aether Blue in RGB)
        kwriteconfig5 --file kdeglobals --group General --key AccentColor "108,140,255"
        
        # Animation speed
        kwriteconfig5 --file kdeglobals --group KDE --key AnimationDurationFactor "0.5"
        
        log_success "KDE global settings applied"
    fi
}

# =============================================================================
# Apply KWin Settings
# =============================================================================
apply_kwin_settings() {
    log "Applying KWin settings..."
    
    if [[ -f "/etc/skel/.config/kwinrc" ]]; then
        cp "/etc/skel/.config/kwinrc" "$USER_CONFIG/"
    fi
    
    if command -v kwriteconfig5 &>/dev/null; then
        # Enable blur
        kwriteconfig5 --file kwinrc --group Plugins --key blurEnabled true
        kwriteconfig5 --file kwinrc --group "Effect-Blur" --key BlurStrength 6
        kwriteconfig5 --file kwinrc --group "Effect-Blur" --key NoiseStrength 0
        
        # Animation speed
        kwriteconfig5 --file kwinrc --group Compositing --key AnimationSpeed 3
        
        # Enable slide effect
        kwriteconfig5 --file kwinrc --group Plugins --key slideEnabled true
        kwriteconfig5 --file kwinrc --group "Effect-Slide" --key Duration 200
        
        log_success "KWin settings applied"
    fi
}

# =============================================================================
# Apply GTK Theme
# =============================================================================
apply_gtk_theme() {
    local theme="${1:-dark}"
    log "Applying GTK theme for $theme mode..."
    
    # GTK 3
    mkdir -p "$USER_CONFIG/gtk-3.0"
    
    local gtk_theme
    if [[ "$theme" == "light" ]]; then
        gtk_theme="Breeze"
    else
        gtk_theme="Breeze-Dark"
    fi
    
    # Copy settings.ini
    if [[ -f "/etc/skel/.config/gtk-3.0/settings.ini" ]]; then
        cp "/etc/skel/.config/gtk-3.0/settings.ini" "$USER_CONFIG/gtk-3.0/"
    fi
    
    # Copy custom CSS
    if [[ -f "/etc/skel/.config/gtk-3.0/gtk.css" ]]; then
        cp "/etc/skel/.config/gtk-3.0/gtk.css" "$USER_CONFIG/gtk-3.0/"
    fi
    
    # Update GTK theme name
    if [[ -f "$USER_CONFIG/gtk-3.0/settings.ini" ]]; then
        sed -i "s/gtk-theme-name=.*/gtk-theme-name=$gtk_theme/" "$USER_CONFIG/gtk-3.0/settings.ini"
        
        if [[ "$theme" == "light" ]]; then
            sed -i "s/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=0/" "$USER_CONFIG/gtk-3.0/settings.ini"
        else
            sed -i "s/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=1/" "$USER_CONFIG/gtk-3.0/settings.ini"
        fi
    fi
    
    # GTK 4
    mkdir -p "$USER_CONFIG/gtk-4.0"
    if [[ -f "/etc/skel/.config/gtk-4.0/gtk.css" ]]; then
        cp "/etc/skel/.config/gtk-4.0/gtk.css" "$USER_CONFIG/gtk-4.0/"
    fi
    
    log_success "GTK theme applied"
}

# =============================================================================
# Apply Latte Dock Layout
# =============================================================================
apply_latte_layout() {
    log "Applying Latte Dock layout..."
    
    # Check if Latte is installed
    if ! command -v latte-dock &>/dev/null; then
        log "Latte Dock not installed, skipping"
        return 0
    fi
    
    mkdir -p "$USER_CONFIG/latte"
    
    # Copy layout file
    if [[ -f "/etc/skel/.config/latte/AetherOS.layout.latte" ]]; then
        cp "/etc/skel/.config/latte/AetherOS.layout.latte" "$USER_CONFIG/latte/"
    fi
    
    # Import layout
    if [[ -f "$USER_CONFIG/latte/AetherOS.layout.latte" ]]; then
        latte-dock --import-layout "$USER_CONFIG/latte/AetherOS.layout.latte" 2>/dev/null || true
        log_success "Latte Dock layout applied"
    else
        log "Latte layout file not found"
    fi
}

# =============================================================================
# Restart Plasma Shell
# =============================================================================
restart_plasma() {
    log "Restarting Plasma shell to apply changes..."
    
    if command -v kquitapp5 &>/dev/null && command -v kstart5 &>/dev/null; then
        kquitapp5 plasmashell 2>/dev/null || true
        sleep 1
        kstart5 plasmashell 2>/dev/null &
        log_success "Plasma shell restarted"
    else
        log "Please log out and log back in to apply all changes"
    fi
}

# =============================================================================
# Show Help
# =============================================================================
show_help() {
    echo "AetherOS Theme Application Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --dark          Apply dark theme (default)"
    echo "  --light         Apply light theme"
    echo "  --colors        Apply color scheme only"
    echo "  --wallpaper     Apply wallpaper only"
    echo "  --icons         Apply icon theme only"
    echo "  --gtk           Apply GTK theme only"
    echo "  --latte         Apply Latte Dock layout only"
    echo "  --no-restart    Don't restart Plasma shell"
    echo "  --help          Show this help"
    echo ""
    echo "Examples:"
    echo "  $0              Apply full dark theme"
    echo "  $0 --light      Apply full light theme"
    echo "  $0 --dark --no-restart"
}

# =============================================================================
# Main
# =============================================================================
main() {
    local theme="dark"
    local apply_all=true
    local restart=true
    local apply_colors=false
    local apply_wallpaper_only=false
    local apply_icons_only=false
    local apply_gtk_only=false
    local apply_latte_only=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dark)
                theme="dark"
                shift
                ;;
            --light)
                theme="light"
                shift
                ;;
            --colors)
                apply_all=false
                apply_colors=true
                shift
                ;;
            --wallpaper)
                apply_all=false
                apply_wallpaper_only=true
                shift
                ;;
            --icons)
                apply_all=false
                apply_icons_only=true
                shift
                ;;
            --gtk)
                apply_all=false
                apply_gtk_only=true
                shift
                ;;
            --latte)
                apply_all=false
                apply_latte_only=true
                shift
                ;;
            --no-restart)
                restart=false
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    echo ""
    log "╔═══════════════════════════════════════╗"
    log "║     AetherOS Theme Application        ║"
    log "╚═══════════════════════════════════════╝"
    echo ""
    log "Applying ${theme} theme..."
    echo ""
    
    if [[ "$apply_all" == true ]]; then
        apply_color_scheme "$theme"
        apply_kde_globals
        apply_kwin_settings
        apply_wallpaper "$theme"
        apply_icon_theme
        apply_gtk_theme "$theme"
        apply_latte_layout
    else
        [[ "$apply_colors" == true ]] && apply_color_scheme "$theme"
        [[ "$apply_wallpaper_only" == true ]] && apply_wallpaper "$theme"
        [[ "$apply_icons_only" == true ]] && apply_icon_theme
        [[ "$apply_gtk_only" == true ]] && apply_gtk_theme "$theme"
        [[ "$apply_latte_only" == true ]] && apply_latte_layout
    fi
    
    if [[ "$restart" == true && "$apply_all" == true ]]; then
        restart_plasma
    fi
    
    echo ""
    log_success "Theme application complete!"
    echo ""
}

main "$@"

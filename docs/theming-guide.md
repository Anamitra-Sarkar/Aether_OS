# AetherOS Theming Guide

This guide explains how to customize the appearance of AetherOS, including KDE Plasma, GTK applications, and system components.

## Table of Contents

1. [Overview](#overview)
2. [KDE Plasma Theming](#kde-plasma-theming)
3. [GTK Theming](#gtk-theming)
4. [Icon Themes](#icon-themes)
5. [Cursor Themes](#cursor-themes)
6. [SDDM Theming](#sddm-theming)
7. [Creating Custom Themes](#creating-custom-themes)

## Overview

AetherOS uses a unified design language across all components:

- **KDE Plasma**: Breeze-based theme with custom colors
- **GTK Apps**: Custom CSS overrides for consistency
- **Icons**: Breeze icons with accent color support
- **Fonts**: Inter as the default system font

### Design Philosophy

1. **Consistency**: Same colors and spacing across all apps
2. **Polish**: Smooth animations and attention to detail
3. **Accessibility**: High contrast, scalable UI, keyboard navigation
4. **Performance**: Lightweight effects, optimized rendering

## KDE Plasma Theming

### Theme Components

KDE Plasma themes consist of several components:

| Component | Location | Purpose |
|-----------|----------|---------|
| Color Scheme | `~/.local/share/color-schemes/` | Application colors |
| Plasma Theme | `~/.local/share/plasma/desktops/` | Desktop widgets |
| Window Decoration | KWin settings | Window borders |
| Icons | `~/.local/share/icons/` | System icons |
| Cursors | `~/.local/share/icons/` | Mouse cursors |

### Key Configuration Files

#### kdeglobals

Located at `~/.config/kdeglobals`, this file controls system-wide settings:

```ini
[General]
AccentColor=108,140,255
ColorScheme=BreezeClassic
font=Inter,10,-1,5,50,0,0,0,0,0,Regular

[KDE]
AnimationDurationFactor=0.5
widgetStyle=kvantum-dark
```

#### kwinrc

Located at `~/.config/kwinrc`, controls window manager behavior:

```ini
[Compositing]
AnimationSpeed=3
Backend=OpenGL
GLCore=true

[Effect-Blur]
BlurStrength=6
NoiseStrength=0

[Plugins]
blurEnabled=true
slideEnabled=true
```

#### plasmarc

Located at `~/.config/plasmarc`, controls Plasma shell:

```ini
[Theme]
name=default

[KDE]
AnimationDurationFactor=0.5
```

### Customizing Colors

AetherOS uses these primary colors:

```ini
# Primary Accent (Aether Blue)
AccentColor=108,140,255  # #6C8CFF

# Secondary Accent (Soft Mint)  
SecondaryColor=122,231,199  # #7AE7C7

# Dark Background
BackgroundNormal=15,23,32  # #0F1720

# Surface Color
SurfaceColor=16,19,23  # #101317
```

To change the accent color:

1. Open System Settings → Appearance → Colors
2. Select "Use accent color from current color scheme"
3. Or set a custom accent color

### Animation Settings

Control animation speed in `kwinrc`:

```ini
[Compositing]
# Lower = faster animations
# 0 = instant
# 4 = default
# 10 = slow
AnimationSpeed=3
```

For reduced motion:

```ini
[KDE]
AnimationDurationFactor=0
```

## GTK Theming

### GTK 4 CSS

AetherOS includes a custom GTK 4 stylesheet at `~/.config/gtk-4.0/gtk.css`:

```css
/* AetherOS GTK Theme Override */

@define-color accent_color #6C8CFF;
@define-color accent_secondary #7AE7C7;
@define-color bg_color #0F1720;
@define-color surface_color #101317;
@define-color text_color #E5E7EB;

window {
    background-color: @bg_color;
    color: @text_color;
}

button {
    border-radius: 10px;
    transition: all 150ms cubic-bezier(0.22, 1, 0.36, 1);
}

button:hover {
    background: alpha(@accent_color, 0.2);
}
```

### GTK 3 Settings

Configure GTK 3 in `~/.config/gtk-3.0/settings.ini`:

```ini
[Settings]
gtk-theme-name=Breeze-Dark
gtk-icon-theme-name=breeze-dark
gtk-font-name=Inter 10
gtk-cursor-theme-name=breeze_cursors
gtk-application-prefer-dark-theme=true
```

## Icon Themes

### Default Icons

AetherOS uses Breeze icons with these additions:

- Custom application icons in `/usr/share/icons/aetheros/`
- Symbolic icons for system actions
- Scalable SVG icons for all sizes

### Icon Locations

| Priority | Location | Scope |
|----------|----------|-------|
| 1 | `~/.local/share/icons/` | User |
| 2 | `/usr/share/icons/` | System |
| 3 | `/usr/share/pixmaps/` | Legacy |

### Creating Custom Icons

Icons should be SVG format and include these sizes:

```
icons/hicolor/
├── 16x16/apps/
├── 24x24/apps/
├── 32x32/apps/
├── 48x48/apps/
├── 64x64/apps/
├── 128x128/apps/
├── 256x256/apps/
└── scalable/apps/
```

## Cursor Themes

### Default Cursor

AetherOS uses Breeze cursors by default.

### Cursor Configuration

Set cursor theme in multiple locations for compatibility:

```bash
# KDE
~/.config/kcminputrc

# GTK
~/.config/gtk-3.0/settings.ini

# X11
~/.Xresources
```

## SDDM Theming

### Theme Location

SDDM themes are stored in `/usr/share/sddm/themes/`.

### Configuration

SDDM configuration at `/etc/sddm.conf.d/`:

```ini
[Theme]
Current=breeze
CursorTheme=breeze_cursors
Font=Inter,10

[General]
HaltCommand=/usr/bin/systemctl poweroff
RebootCommand=/usr/bin/systemctl reboot
```

### Custom Theme Elements

To create a custom SDDM theme:

1. Create theme directory: `/usr/share/sddm/themes/aetheros/`
2. Add required files:
   - `theme.conf` - Theme metadata
   - `Main.qml` - Main QML interface
   - `Background.qml` - Background component
   - `metadata.desktop` - Desktop entry

## Creating Custom Themes

### Plasma Theme

1. Create directory structure:

```bash
mkdir -p ~/.local/share/plasma/desktops/mytheme/
cd ~/.local/share/plasma/desktops/mytheme/
```

2. Create `metadata.desktop`:

```ini
[Desktop Entry]
Name=My Theme
Comment=A custom theme
Type=DataEngineService

[Containment]
Type=Desktop
```

3. Add SVG assets and colors file

### Color Scheme

1. Create color scheme file:

```bash
~/.local/share/color-schemes/MyColors.colors
```

2. Define colors:

```ini
[ColorEffects:Disabled]
Color=56,56,56
ColorAmount=0
ColorEffect=0

[ColorEffects:Inactive]
ChangeSelectionColor=true
ColorAmount=0.025
ColorEffect=2

[Colors:Button]
BackgroundNormal=49,54,59
ForegroundNormal=239,240,241

[Colors:Selection]
BackgroundNormal=108,140,255
ForegroundNormal=255,255,255

[Colors:View]
BackgroundNormal=27,30,32
ForegroundNormal=239,240,241

[Colors:Window]
BackgroundNormal=42,46,50
ForegroundNormal=239,240,241

[General]
ColorScheme=MyColors
Name=My Colors
```

### Kvantum Theme

For Qt applications not using Plasma theme:

1. Install Kvantum:

```bash
sudo apt install qt5-style-kvantum
```

2. Create theme at `~/.config/Kvantum/MyTheme/`

3. Configure in Kvantum Manager

## Quick Customization Tips

### Change Accent Color

```bash
# Edit kdeglobals
kwriteconfig5 --file kdeglobals --group General --key AccentColor "255,100,100"
```

### Change Font

```bash
# Edit kdeglobals
kwriteconfig5 --file kdeglobals --group General --key font "Inter,11,-1,5,50,0,0,0,0,0,Regular"
```

### Reset to Defaults

```bash
# Remove user configurations
rm -rf ~/.config/plasma*
rm -rf ~/.config/kwin*
rm -rf ~/.local/share/plasma/
```

## Switching to Stock Theme

If you want to switch back to a stock Ubuntu/KDE theme:

### Quick Method

```bash
# Reset to Breeze Dark
kwriteconfig5 --file kdeglobals --group General --key ColorScheme "BreezeClassic"
kwriteconfig5 --file kdeglobals --group Icons --key Theme "breeze"
kwriteconfig5 --file kdeglobals --group KDE --key LookAndFeelPackage "org.kde.breezedark.desktop"

# Restart Plasma
kquitapp5 plasmashell && kstart5 plasmashell
```

### Full Reset

```bash
# Remove AetherOS theme files
rm -f ~/.local/share/color-schemes/AetherDark.colors
rm -f ~/.local/share/color-schemes/AetherLight.colors
rm -rf ~/.config/latte/AetherOS.layout.latte

# Reset to defaults
rm -f ~/.config/kdeglobals
rm -f ~/.config/plasmarc
rm -f ~/.config/kwinrc
rm -rf ~/.config/gtk-3.0/gtk.css
rm -rf ~/.config/gtk-4.0/gtk.css

# Restart Plasma
kquitapp5 plasmashell && kstart5 plasmashell
```

### GTK Reset

```bash
# Reset GTK settings
echo "[Settings]
gtk-theme-name=Breeze-Dark
gtk-icon-theme-name=breeze-dark
gtk-font-name=Noto Sans 10
gtk-cursor-theme-name=breeze_cursors
gtk-application-prefer-dark-theme=1" > ~/.config/gtk-3.0/settings.ini

rm -f ~/.config/gtk-3.0/gtk.css
rm -f ~/.config/gtk-4.0/gtk.css
```

## Troubleshooting

### Theme Not Applying

1. Log out and log back in
2. Run: `kquitapp5 plasmashell && kstart5 plasmashell`
3. Check file permissions

### GTK Apps Look Different

1. Ensure GTK theme is set correctly
2. Install `kde-gtk-config` for better integration
3. Apply settings in System Settings → Application Style

### Icons Not Showing

1. Update icon cache: `gtk-update-icon-cache ~/.local/share/icons/mytheme/`
2. Check icon theme setting
3. Verify icon files exist

### Latte Dock Not Starting

1. Check if Latte is installed: `which latte-dock`
2. Try starting manually: `latte-dock --layout AetherOS`
3. Check logs: `journalctl --user -u plasma-latte_dock`

## AetherOS Theme Assets

### Location of Theme Files

| Asset | System Location | User Location |
|-------|----------------|---------------|
| Color Schemes | `/usr/share/aetheros/themes/Aether/colors/` | `~/.local/share/color-schemes/` |
| Wallpapers | `/usr/share/backgrounds/aetheros/` | `~/.local/share/wallpapers/` |
| Icons | `/usr/share/icons/Aether/` | `~/.local/share/icons/Aether/` |
| SDDM Theme | `/usr/share/sddm/themes/Aether/` | N/A |
| Latte Layout | `/etc/skel/.config/latte/` | `~/.config/latte/` |
| GTK CSS | `/etc/skel/.config/gtk-3.0/` | `~/.config/gtk-3.0/` |

### Using the Theme Application Script

AetherOS includes a script to quickly apply or switch themes:

```bash
# Apply dark theme (default)
/usr/share/aetheros/scripts/apply-theme.sh

# Apply light theme
/usr/share/aetheros/scripts/apply-theme.sh --light

# Apply only specific components
/usr/share/aetheros/scripts/apply-theme.sh --wallpaper --dark
/usr/share/aetheros/scripts/apply-theme.sh --icons
/usr/share/aetheros/scripts/apply-theme.sh --gtk --light
```

## Resources

- [KDE Theming Documentation](https://develop.kde.org/docs/plasma/theme/)
- [GTK CSS Reference](https://docs.gtk.org/gtk4/css-properties.html)
- [Kvantum Theming](https://github.com/tsujan/Kvantum)
- [Design Tokens](design_tokens.md)

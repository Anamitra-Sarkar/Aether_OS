# AetherOS Plasma Theme Configuration

This directory contains KDE Plasma theme configurations for AetherOS.

## Structure

- `aether-light/` - Light theme variant with Aether Blue accent
- `aether-dark/` - Dark theme variant with deep space colors

## Theme Variants

### Aether Light
- **Primary Accent**: `#6C8CFF` (Aether Blue)
- **Secondary Accent**: `#7AE7C7` (Soft Mint)
- **Background**: `#F6F8FA`
- **Surface**: `#FFFFFF`

### Aether Dark
- **Primary Accent**: `#6C8CFF` (Aether Blue)
- **Secondary Accent**: `#7AE7C7` (Soft Mint)
- **Background**: `#0F1720`
- **Surface**: `#101317`

## Installation

These themes are automatically installed during AetherOS build process.
The themes are copied to `/usr/share/plasma/desktoptheme/` in the chroot environment.

## Related Configuration

- KDE color schemes: `configs/kde/themes/Aether/colors/`
- SDDM theme: `configs/sddm/`
- GTK theme: `configs/gtk/`

## v2.0 Features

This directory is prepared for AetherOS v2.0 Ultimate Edition, which includes:

- **Adaptive Blur System**: High Blur Mode for strong GPUs, Frosted Lite for older hardware
- **Smart Shadows**: macOS-level window depth with subtle hover elevation
- **Aether Neon Design**: Blue-Mint halo on focusable elements with liquid switches
- **CleanMode**: One-toggle performance mode for low-end hardware

See `docs/design-architecture.md` for technical implementation details.

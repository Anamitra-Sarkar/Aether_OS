# Changelog

All notable changes to AetherOS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0-alpha] - 2024-12-01

### Added
- **Complete Desktop Environment**
  - KDE Plasma desktop with Wayland by default (X11 fallback)
  - Latte Dock with bottom-centered, auto-hide dock layout
  - Pinned apps: Dolphin, Firefox, Konsole, Kate, Discover

- **AetherOS Theme Pack**
  - Dark and Light color schemes with Aether Blue (#6C8CFF) accent
  - Custom wallpapers (default light/dark, geometric, nebula variants)
  - Breeze-based icon theme with Aether colors
  - SDDM login theme with centered login card and branding
  - GTK 3/4 theme integration for consistent app appearance
  - Kvantum theme support

- **First-Run Wizard**
  - Welcome screen with feature highlights
  - Theme selection (Light/Dark/Auto)
  - Privacy settings (telemetry disabled by default)
  - Optional: Flatpak + Flathub setup
  - Optional: App bundle installation

- **Aether Control Center**
  - Quick toggles for Wi-Fi, Bluetooth, Night Light, Focus Mode
  - Volume and Brightness sliders
  - Power profile switcher (Balanced/Performance/Power Saver)
  - Direct link to System Settings

- **System Optimization**
  - ZRAM swap configuration (25-50% of RAM)
  - Sysctl tuning for desktop responsiveness
  - Baloo indexer disabled by default
  - Journal size limits
  - I/O scheduler optimization for SSDs
  - Service trimmer for unnecessary background services

- **App Bundles**
  - Core bundle: Firefox, LibreOffice, VLC, Thunderbird, GIMP
  - Dev bundle: Git, VS Code (Flatpak), Python, Node.js
  - Media bundle: Kdenlive, Audacity, Inkscape, OBS, Blender
  - Gaming bundle: Steam, Lutris

- **Installer**
  - Calamares with AetherOS branding
  - Guided and manual partitioning
  - LUKS encryption support

- **Build System**
  - Fully automated ISO build script
  - Ubuntu 24.04 LTS (Noble Numbat) base
  - Hybrid BIOS/UEFI bootable ISO
  - Minimal build mode for faster CI testing

- **Testing**
  - QEMU boot test script with screenshot capture
  - UI sanity check script
  - GitHub Actions CI pipeline

- **Documentation**
  - Developer guide
  - Theming guide
  - Design tokens reference

### Known Issues
- Latte Dock may need manual start on first boot (`latte-dock --layout AetherOS`)
- Some Flatpak packages in bundles may require manual Flathub setup
- QEMU boot test requires KVM support for reasonable speed
- Night Light toggle in Control Center is a placeholder (uses system settings)

### Technical Notes
- Based on Ubuntu 24.04 LTS (Noble Numbat)
- Uses linux-generic kernel
- PipeWire for audio
- NetworkManager for network management
- SDDM display manager with autologin for live session

---

## Future Plans

### [0.2.0] - Planned
- Full Calamares slideshow
- Additional wallpapers and icon variants
- Performance improvements
- Bug fixes from alpha feedback
- Expanded accessibility features

### [0.3.0] - Planned
- Additional app integrations
- More power management options
- Custom kernel options
- ARM64 support exploration

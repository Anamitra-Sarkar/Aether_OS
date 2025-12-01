# Changelog

All notable changes to AetherOS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0-alpha] - 2025-12-01

### Added

- **Stability & Error Handling**
  - `aether-health.sh` - System health check script
  - Error logging for Control Center and First-Run Wizard
  - Logs stored in `~/.local/share/aetheros/logs/`

- **Security Hardening**
  - UFW firewall enabled by default (deny incoming, allow outgoing)
  - `gufw` GUI for firewall management
  - `aether-security-update.sh` for security-only updates
  - Weekly security update check timer
  - AppArmor profile for Firefox browser
  - AppArmor enabled by default

- **Window Management & Gestures**
  - Windows 11-style window tiling (drag to edges/corners)
  - Keyboard shortcuts: Meta+Arrow for half-tiling
  - Quarter-tiling with Meta+Ctrl+Arrow
  - Workspace switching: Ctrl+Alt+Left/Right
  - Direct desktop access: Meta+1-4
  - Overview: Meta+Tab or Meta+W
  - Touchpad gestures for Wayland (3-finger swipe for workspaces/overview)
  - Full shortcuts documentation in `docs/shortcuts.md`

- **Control Center v2 (System Hub)**
  - **System Overview**: OS info, hardware summary, quick toggles
  - **Network & Security**: Connection status, firewall management
  - **Appearance**: Theme and accent color selection
  - **Power & Performance**: Power profile switching, ZRAM status
  - **Maintenance**: Health check, Timeshift, cache cleaning, logs

- **Update Management**
  - `aether-updates.sh` - Check APT and Flatpak updates
  - Aether Updater UI with update summary
  - Buttons for update all, security only, or open Discover
  - Desktop launcher for Aether Updater

- **Backups & AetherVault**
  - `aethervault.sh` - Home directory backup tool using rsync
  - Smart exclusions (caches, node_modules, Steam games, etc.)
  - Dry-run mode for preview
  - Comprehensive `docs/backup-guide.md`

- **Performance Improvements**
  - Tiered ZRAM sizing:
    - ≤4GB RAM: 75% ZRAM
    - 4-8GB RAM: 50% ZRAM
    - >8GB RAM: 25% ZRAM
  - `aether-power-mode.sh` for CLI power profile switching
  - Integration with power-profiles-daemon (TLP fallback)

- **UX Polish**
  - Enhanced First-Run Wizard with step indicators
  - Polished welcome screen with version badge
  - Screenshot shortcuts (Print, Meta+Print, Meta+Shift+Print)
  - "Report a Problem" launcher linking to GitHub Issues

### Changed
- Control Center expanded from quick settings to full system hub
- First-Run Wizard window size increased for better layout
- Improved error messages in all scripts

### Security
- Default firewall: deny incoming, allow outgoing
- AppArmor enforcing for Firefox
- Weekly security update checks with notifications

### Documentation
- Added `docs/shortcuts.md` - keyboard shortcut reference
- Added `docs/backup-guide.md` - backup and restore guide
- Updated `docs/dev-guide.md` with security and performance sections
- Updated `README.md` roadmap and version to 0.2

---

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

### [0.3.0] - Planned
- Full Calamares slideshow
- Additional wallpapers and icon variants
- Expanded accessibility features
- ARM64 support exploration

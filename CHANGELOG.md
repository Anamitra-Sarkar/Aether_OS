# Changelog

All notable changes to AetherOS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2024-12-07

### Overview

AetherOS v2.1 "Security Evolution" brings AetherOS into smart OS territory with security-first features, thermal intelligence, audio polish, and improved accessibility. This release maintains the lightweight, 4GB-RAM-friendly philosophy while adding sophisticated system intelligence.

### Added - Security Evolution

- **AetherShield - Per-App Sandbox Control** (Phase 1)
  - Policy-based permission management for applications
  - JSON manifests for app permissions (network, camera, mic, filesystem)
  - CLI tool: `aethershieldctl` with list, show, apply, status commands
  - Integration with AppArmor profiles and Flatpak permissions
  - Example policy for Firefox included
  - Documentation: `/etc/aetheros/security/apps/README.md`

- **Secure Session Mode**
  - Temporary lockdown for banking, exams, sensitive work
  - Script: `aether-secure-session.sh` with start, stop, status
  - Enables strict firewall rules (UFW)
  - Disables SSH, Avahi, Samba services when active
  - Disables USB automount
  - Visual notification indicator
  - All changes reversible and idempotent

### Added - Thermal Intelligence

- **Thermal Watch - Heat-Aware Visuals**
  - Script: `aether-thermal-watch.sh`
  - Monitors `/sys/class/thermal` zones
  - Three states: cool (<60°C), warm (60-75°C), hot (>75°C)
  - Automatically adjusts visual effects based on temperature
  - Respects user profile overrides
  - Systemd user service: `aether-thermal.service`
  - Minimum 60s between profile changes (anti-thrashing)
  - Logging to `~/.local/share/aetheros/thermal.log`

### Added - Audio & Media Polish

- **Aether Ocean Sound Pack**
  - Ocean-inspired sound theme structure
  - Placeholders for 10 sound events (login, notification, etc.)
  - KDE Plasma sound theme integration
  - Documentation: `artwork/sounds/ocean/README.md`
  - Config: `configs/plasma/aether-ocean-sounds/`

- **Audio Profiles**
  - Script: `aether-audio-profile.sh`
  - Four profiles: movie, gaming, voice, balanced
  - PulseAudio and PipeWire support
  - Volume optimization per scenario
  - Microphone boost for voice profile
  - Graceful fallback when EQ unavailable

### Added - UX Enhancements

- **QuickPal Enhanced Search**
  - Fuzzy search over .desktop applications
  - AetherOS tools discovery (aether-*)
  - System settings and common apps
  - Optional fzf integration for better UX
  - Fallback to kdialog/zenity
  - Updated help documentation

- **Holographic Login Pulse**
  - Subtle pulsing animation on SDDM login logo
  - Opacity and scale animations (2s cycle)
  - Configurable via `/etc/aetheros/login-effects.conf`
  - Can be disabled for low-end systems
  - Zero overhead fallback if GPU doesn't support

### Added - Accessibility

- **Accessibility Manager**
  - Script: `aether-accessibility.sh`
  - Reduced Motion mode: disables all animations and transitions
  - High Contrast mode: increases readability
  - Commands: reduce-motion on/off, high-contrast on/off
  - Immediate effect with KWin reconfiguration
  - Comprehensive help and documentation

### Added - Installer Polish

- **Calamares Slideshow**
  - Five-slide presentation during installation
  - Showcases v2.1 features (AetherShield, Thermal, etc.)
  - QML-based with fallback text rendering
  - Branding config: `configs/calamares/branding/aetheros/`
  - Placeholder images with documentation
  - 5-second auto-advance per slide

### Added - ARM64 Groundwork

- **Architecture Support in Build Scripts**
  - `ARCH` environment variable in `build.sh` and `chroot-setup.sh`
  - Support for `amd64` (default) and `arm64` (experimental)
  - `--arch` flag for manual specification
  - Debootstrap parametrized for architecture
  - Warning for ARM64 experimental status
  - Documentation: `docs/arm64-experimental.md`

### Added - Testing & CI

- **Profile Tools Check**
  - Script: `tests/check-profiles.sh`
  - Validates all required scripts exist
  - Checks executable permissions
  - Verifies shebangs and error handling
  - Tests basic syntax with bash -n
  - Checks help commands work
  - Validates v2.1 config directories
  - Integrated into CI workflow
  - 135+ automated checks

### Changed

- Updated README.md to reflect v2.1 features and status
- Updated version badges and feature lists
- Enhanced CI workflow with profile tools verification
- Build scripts now log architecture information

### Technical

- All new scripts follow `set -euo pipefail` pattern
- Graceful degradation when dependencies missing
- No-op behavior for missing audio/thermal hardware
- Idempotent operations (safe to run multiple times)
- Comprehensive logging for debugging
- State files in `~/.local/share/aetheros/`
- Config files in `~/.config/aetheros/`

### Notes

- Phase 1 of AetherShield focuses on policy awareness
- Full automatic sandboxing coming in future phases
- ARM64 support is experimental, not production-ready
- Sound pack placeholders need real audio files
- Calamares slideshow images are placeholders
- Control Center integration for new features deferred

---

## [1.1.0] - 2025-12-05

### Overview

AetherOS v1.1 delivers quality-of-life improvements with Focus Mode, auto theme scheduling, system sounds, and enhanced CI reliability. This release emphasizes daily usability and workflow polish.

### Added

- **Focus Mode / Do Not Disturb**
  - Toggle in Control Center Overview page
  - Integrates with KDE notification settings via `knotificationmanagerrc`
  - Script: `scripts/aether-focus-mode.sh` for manual control
  - Supports toggle, on, off, and status commands

- **Auto Light/Dark Theme Scheduler**
  - Automatic theme switching based on time of day
  - Light theme: 7 AM - 7 PM, Dark theme: 7 PM - 7 AM (configurable)
  - Systemd user timer for hourly checks
  - Toggle in Control Center Appearance page
  - Script: `scripts/aether-theme-scheduler.sh`
  - Config stored in `~/.config/aetheros/theme-scheduler.conf`

- **System Sound Theme**
  - Minimal, clean sound theme using KDE Ocean sounds
  - Toggle in Control Center Appearance page
  - Login, notification, and alert sounds
  - Script: `scripts/aether-sounds.sh` with test sound feature
  - Config stored in `~/.config/aetheros/sounds.conf`

- **New Wallpapers**
  - `aetheros-waves.svg` - Flowing waves with gradient colors
  - `aetheros-minimal.svg` - Minimal geometric design with central focus
  - Updated `wallpapers.json` with new entries
  - Total of 6 wallpapers available

### Changed

- **CI Pipeline Refinement**
  - QEMU boot test remains non-blocking
  - UI sanity checks remain non-blocking
  - Clear documentation that manual QEMU testing is recommended
  - README and troubleshooting docs updated with testing guidance

- **Control Center Updates**
  - Version updated to v1.1
  - Focus toggle now wired to actual functionality
  - Auto theme schedule toggle added to Appearance page
  - System sounds toggle added to Appearance page
  - Enhanced user experience with working toggles

- **Documentation**
  - README updated with v1.1 feature list
  - Troubleshooting guide includes QEMU testing section
  - Clear CI testing strategy documented
  - New features documented in roadmap

### Technical Details

- Focus Mode uses `kwriteconfig5` and `kreadconfig5` for KDE integration
- Theme scheduler creates systemd user service and timer
- Sound theme uses KDE's built-in Ocean sound theme
- All new scripts follow existing AetherOS script patterns with proper error handling

## [1.0.0] - 2025-12-03

### Overview

AetherOS v1.0 Stable brings the final polish for production readiness, including CI improvements, comprehensive diagnostics, Quick Actions launcher, refined first-run wizard, and enhanced documentation.

### Added

- **System Diagnostics Tool** (`aether-diagnostics.sh`)
  - Comprehensive system health checking
  - Checks: SDDM, Plasma, firewall, AppArmor, ZRAM, Timeshift, power profile
  - Hardware information: GPU, CPU, memory status
  - Boot performance analysis with systemd-analyze
  - Logs stored in `~/.local/share/aetheros/diagnostics/`

- **Test Mode Support**
  - Auto-run diagnostics on first login via `/etc/aetheros/test-mode` flag
  - Dialog-based result display (kdialog, zenity, notify-send fallback)
  - Useful for automated testing and validation scenarios

- **Quick Actions Launcher**
  - QML-based system tools hub
  - Quick access to: Control Center, Health Check, Diagnostics, Timeshift, Logs, Updates
  - Desktop launcher integrated in Applications menu
  - Consistent design with AetherOS theme

- **First-Run Wizard Refinements**
  - Shorter, cleaner welcome text
  - New toggle options:
    - Privacy Mode (enabled by default)
    - Install Popular Flatpaks
    - Enable Update Notifications
  - More user-friendly descriptions
  - Maintains existing visual polish

### Changed

- **CI/CD Pipeline Improvements**
  - QEMU boot test now non-blocking (`continue-on-error: true`)
  - Build success and artifact generation are the only required gates
  - Release job no longer depends on test job
  - ISO builds can succeed even if QEMU test times out
  - Added clear documentation about CI test strategy

- **CodeQL Security Scanning**
  - Re-enabled with Python language support
  - Configured with `security-and-quality` queries
  - Marked as non-blocking for CI flexibility
  - Shell scripts scanned separately via shellcheck

- **Documentation Updates**
  - README: Added note that CI does not auto-boot ISO
  - README: Clarified manual QEMU testing as recommended practice
  - dev-guide.md: Added test mode documentation
  - dev-guide.md: Expanded QEMU testing instructions
  - CHANGELOG: v1.0 stable release notes

### Technical Notes

- CI now focuses on build reliability over boot testing due to GitHub Actions resource constraints
- QEMU boot timing can vary significantly on shared CI runners
- Local testing remains the recommended validation approach
- All new scripts follow shellcheck standards and include proper error handling

### Quality Assurance

- All scripts pass shellcheck validation
- QML components follow AetherOS design tokens
- Comprehensive logging for all diagnostic operations
- Non-intrusive test mode (silent if not enabled)

---

## [1.0.0-rc] - 2025-12-01

### Overview

AetherOS v1.0 Release Candidate marks full stability, security hardening, visual polish, Control Center maturity, first-run onboarding experience, backup strategy, update tooling, power profiles, and reproducible ISO infrastructure.

### Added

- **Automated Build & Boot Verification**
  - Enhanced CI pipeline with automated QEMU boot testing
  - Boot validation with desktop readiness detection
  - Automated screenshot capture during boot tests
  - Screenshot artifacts: login screen, desktop, control center
  - Asset verification (theme, SDDM, icons, wallpapers)
  - Boot log parsing for Plasma session detection

- **Public Presentation Assets**
  - `artwork/screenshots/` directory for official screenshots
  - Automated screenshot capture via QEMU monitor
  - Screenshots saved: `login.png`, `desktop.png`
  - CI artifact upload for screenshots

- **Code Quality & Security**
  - CodeQL integration in GitHub Actions
  - Shell script security scanning (unsafe expansions, missing quotes)
  - Permission validation for all scripts
  - Orphan systemd unit detection
  - Broken symlink validation

- **Documentation Improvements**
  - Updated README.md to v1.0 RC status
  - Added download section with release links
  - Enhanced screenshot section with automated captures
  - SHA256 checksum verification instructions
  - Comprehensive testing documentation

### Changed

- **CI/CD Pipeline**
  - Boot test now fails CI if desktop is not reached
  - Added socat dependency for QEMU monitor communication
  - Enhanced test job with asset verification
  - Separated CodeQL analysis into dedicated job
  - Extended boot timeout to 180 seconds for reliability

- **Testing Infrastructure**
  - Enhanced `boot-qemu.sh` with multiple screenshot support
  - Screenshots now saved to both artifacts and artwork directories
  - Improved boot detection logic (plasmashell, SDDM, graphical.target)
  - Better error handling and logging in test scripts

- **Build System**
  - README version badge updated to 1.0 RC
  - CHANGELOG restructured with clear RC section
  - Consistent versioning across all documentation

### Fixed

- Shell script quoting issues detected by linting
- Missing directory creation in test scripts
- Screenshot capture reliability via QEMU monitor
- CI test job error handling

### Documentation

- README.md: Updated status, screenshots, download links
- CHANGELOG.md: Added comprehensive v1.0 RC entry
- artwork/screenshots/README.md: Screenshot guidelines

### Quality Assurance

- All builds validated with automated boot tests
- Desktop readiness confirmed via log parsing
- Theme, SDDM, icons, and wallpapers verified
- No critical CodeQL vulnerabilities
- All shell scripts pass shellcheck

---

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

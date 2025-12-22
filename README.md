# AetherOS

<p align="center">
  <img src="artwork/logo.svg" alt="AetherOS Logo" width="128" height="128">
</p>

<p align="center">
  <strong>A beautiful, ultra-smooth, Ubuntu LTS-based desktop distribution</strong>
</p>

<p align="center">
  <em>Status: v2.3 - Intelligence Systems</em>
</p>

<p align="center">
  <a href="#overview">Overview</a> •
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#building">Building</a> •
  <a href="#testing">Testing</a> •
  <a href="#installation">Installation</a> •
  <a href="#default-applications">Default Apps</a> •
  <a href="#troubleshooting">Troubleshooting</a> •
  <a href="#roadmap">Roadmap</a> •
  <a href="#contributing">Contributing</a>
</p>

<p align="center">
  <img src="https://img.shields.io/github/actions/workflow/status/Anamitra-Sarkar/Aether_OS/build.yml?label=Build&style=flat-square">
  <img src="https://img.shields.io/github/license/Anamitra-Sarkar/Aether_OS?style=flat-square">
  <img src="https://img.shields.io/badge/version-2.3-blue?style=flat-square">
  <img src="https://img.shields.io/badge/base-Ubuntu%2024.04%20LTS-orange?style=flat-square">
</p>

---

## Overview

**AetherOS** is a modern, user-focused Linux desktop built on **Ubuntu 24.04 LTS**.
It combines:

* macOS-like elegance
* Windows-style familiarity
* Linux freedom and performance

The mission is simple:

> **Deliver a polished, consistent, fast, privacy-respecting desktop OS that looks and feels premium — without bloat, telemetry, or proprietary lock-ins.**

---

## Features

### 🎨 Ultimate Aesthetic Upgrade (v2.0)

* **Adaptive Blur System**: Automatically adjusts blur effects based on GPU capabilities
  - High Blur Mode for powerful GPUs (RTX, RX 6000+, Intel Xe)
  - Frosted Lite Mode for mid-range GPUs (Intel HD 4000-6000)
  - Automatic GPU detection and optimization

* **CleanMode Toggle**: One-click performance mode for low-end hardware
  - Disables animations, blur, and heavy effects
  - Perfect for 4GB RAM systems and older laptops

* **Aether Neon Design**: Blue-Mint accent colors with modern design tokens
  - Enhanced plasma themes (light & dark)
  - macOS-level window depth and shadows

### ⚡ Performance Intelligence (v2.0)

* **Auto Performance Profiler**: Detects hardware and applies optimal settings
  - MaxMode: 16GB+ RAM, high-end GPU
  - Balanced: 8-12GB RAM, mid-range GPU  
  - LiteMode: 4GB RAM, integrated GPU

* **Smart Service Manager**: Auto-manages system services based on hardware
  - Disables Bluetooth if no hardware present
  - Disables CUPS if no printer detected
  - Manages indexing based on document count
  - Saves 50-150MB RAM on typical systems

* **Adaptive ZRAM**: Intelligent swap compression
  - 33% ratio on 4GB RAM (conservative)
  - 50% ratio on 6GB RAM (balanced)
  - 75% ratio on 8GB+ RAM (maximum benefit)
  - Uses LZ4 algorithm (fastest compression)

### 🧠 Intelligent Desktop Behavior (v2.0)

* **Focus Mode 2.0**: Enhanced Do Not Disturb
  - Auto-activates during fullscreen apps
  - Scheduled mode for study/work hours
  - Manual toggle with status checking

* **Smart Notifications**: Context-aware notification muting
  - Automatically mutes during gaming (Steam, Lutris)
  - Mutes during fullscreen videos (YouTube, Netflix, VLC)
  - Mutes during presentations and meetings (Zoom, Teams)

* **QuickPal Launcher**: Spotlight-style quick access (Enhanced in v2.1)
  - Launch system tools and settings
  - Toggle performance modes
  - Access Control Center pages
  - **NEW**: Fuzzy search across all apps and tools
  - **NEW**: Optional fzf integration for better UX

* **Profile Sync**: Save and restore preferences in one click
  - Theme, wallpaper, performance settings
  - JSON-based with automatic backups
  - Named profiles (work, personal, gaming)

### 🔒 Security Evolution (v2.1)

* **AetherShield**: Per-app sandbox policy management
  - Control network, camera, microphone, filesystem access
  - Integration with AppArmor and Flatpak
  - CLI tool: `aethershieldctl`
  - Phase 1: Policy awareness and partial enforcement

* **Secure Session Mode**: Lockdown for sensitive tasks
  - Strict firewall rules
  - Disable SSH and network services
  - Disable USB automount
  - Visual indicator when active
  - Perfect for banking, exams, confidential work

* **Thermal Watch**: Heat-aware visual intelligence
  - Monitors system temperature
  - Automatically adjusts visual effects
  - Prevents overheating on weak hardware
  - Respects user overrides

### 🎵 Audio & Media Polish (v2.1)

* **Aether Ocean Sound Pack**: Calming ocean-inspired sounds
  - Custom notification sounds
  - Login/logout audio
  - Device connect/disconnect feedback

* **Audio Profiles**: Optimized for different scenarios
  - Movie: Enhanced bass, surround sound
  - Gaming: High volume, low latency
  - Voice: Clear speech, boosted microphone
  - Balanced: Neutral settings

### 🖥️ Modern Desktop

* KDE Plasma on Wayland (with seamless X11 fallback)
* Latte Dock with polished layout
* **Custom SDDM login theme** with holographic pulse effect (v2.1)
* First-Run Wizard for easy setup
* **NEW**: Calamares slideshow during installation

### ♿ Accessibility (Enhanced in v2.1)

* **Reduced Motion Mode**: One-click animation disabling
* **High Contrast Mode**: Better readability
* High-DPI support
* Keyboard navigation optimized
* Screen reader compatible

### 🧩 Intelligence Systems (v2.3)

* **Threat Surface Scanner**: Offline security visibility
  - Fast, deterministic security assessment
  - Scans for exposed services, SUID binaries, permission risks
  - Risk rating with exact remediation steps
  - JSON output for automation
  - CLI: `aether-threat-scan`

* **Boot Intelligence Engine**: Learn and optimize boot time
  - Analyzes systemd boot metrics
  - Intelligently disables slow, non-essential services
  - Never touches boot-critical services
  - Full transparency with rollback capability
  - CLI: `aether-boot-optimize`

* **Dynamic CPU Governor**: Context-aware performance scaling
  - Rule-based governor selection (no ML)
  - Considers battery, thermal state, load, foreground app
  - Manual override support
  - Supports Intel, AMD, ARM CPUs
  - CLI: `aether-cpu-governor`

* **Desktop Recovery**: Wayland crash containment
  - Auto-detects and recovers from compositor/shell crashes
  - Preserves running applications
  - Fallback to X11 after repeated failures
  - Never forces logout or kills apps
  - CLI: `aether-desktop-recovery`

See [docs/INTELLIGENCE-SYSTEMS.md](docs/INTELLIGENCE-SYSTEMS.md) for detailed documentation.

### 🔐 Privacy-Focused

* Telemetry disabled by default
* No mandatory proprietary binaries
* Local-first processing
* No cloud dependencies

---

## Design Tokens

| Token            | Light                   | Dark      |
| ---------------- | ----------------------- | --------- |
| Primary Accent   | `#6C8CFF` (Aether Blue) | `#6C8CFF` |
| Secondary Accent | `#7AE7C7` (Soft Mint)   | `#7AE7C7` |
| Background       | `#F6F8FA`               | `#0F1720` |
| Surface          | `#FFFFFF`               | `#101317` |

* **Font**: Inter (system) — fallback Noto Sans
* **Corner Radius**: 10–12px
* **Motion Curve**: `cubic-bezier(0.22, 1, 0.36, 1)`
* **Animation Durations**:

  * Base: 150ms
  * Modal: 220ms

---

## Screenshots

### Desktop

![AetherOS Desktop](artwork/screenshots/desktop.png)

*Beautiful, modern desktop with KDE Plasma and Aether theme*

### Login Screen

![AetherOS Login](artwork/screenshots/login.png)

*Elegant SDDM login with Aether branding*

> **Note**: Screenshots are automatically captured during CI builds. See [artwork/screenshots/](artwork/screenshots/) for more images.

---

## Prerequisites

Run the build on an **Ubuntu 24.04 host**:

```bash
sudo apt update
sudo apt install -y \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-pc-bin \
    grub-efi-amd64-bin \
    mtools \
    dosfstools \
    qemu-system-x86 \
    qemu-utils \
    git \
    isolinux \
    syslinux-common
```

---

# Building

## Quick Build

```bash
# Clone the repository
git clone https://github.com/Anamitra-Sarkar/Aether_OS.git
cd Aether_OS

# Build the ISO
sudo ./build/build.sh

# Output: build/artifacts/aetheros.iso
```

## Minimal Build (faster test ISO)

```bash
sudo ./build/build.sh --minimal
```

## Build Artifacts

After success:

* `build/artifacts/aetheros.iso`
* `build/artifacts/aetheros.iso.sha256`

---

# Testing

## CI Testing Strategy

CI focuses on:
- ✅ ISO build success
- ✅ Checksum generation
- ✅ CodeQL security scanning (Python)
- ✅ Asset validation (themes, icons, wallpapers)

QEMU boot tests and UI sanity checks are **optional and non-blocking** in CI due to resource constraints. This ensures the workflow stays green when builds succeed.

## Manual QEMU Testing (Recommended)

To validate the ISO boots correctly, run locally:

```bash
./tests/boot-qemu.sh build/artifacts/aetheros.iso
```

This will:
1. Boot the ISO with 4GB RAM (configurable via `RAM=` env var)
2. Verify desktop session starts
3. Save screenshot to `tests/artifacts/desktop.png`
4. Exit 0 on success

**Note:** Local QEMU testing is the recommended way to fully validate the OS before release.

## UI Sanity Check

```bash
./tests/ui-sanity.sh
```

---

# Download

## Latest Stable Release

📥 **[Download AetherOS v2.1 ISO](https://github.com/Anamitra-Sarkar/Aether_OS/releases/latest)**

- **File**: `aetheros.iso.xz` (compressed ISO)
- **Checksum**: `aetheros.iso.xz.sha256`
- **Size**: ~2.8 GB (compressed), ~3.2 GB (extracted)
- **Requirements**: 4GB RAM minimum, 8GB recommended

**Extraction**:
```bash
xz -d aetheros.iso.xz
# Verify checksum
sha256sum -c aetheros.iso.xz.sha256
```

---

# Installation

1. Download the latest ISO from:
   **[https://github.com/Anamitra-Sarkar/Aether_OS/releases](https://github.com/Anamitra-Sarkar/Aether_OS/releases)**
2. Verify the SHA256 checksum:
   ```bash
   sha256sum -c aetheros.iso.sha256
   ```
3. Flash ISO to USB via:

   * Balena Etcher
   * Ventoy
   * `dd if=aetheros.iso of=/dev/sdX bs=4M status=progress`
4. Boot from USB and follow the Calamares installer

---

# Default Applications

| Category        | Application        |
| --------------- | ------------------ |
| Browser         | Firefox            |
| Office          | LibreOffice        |
| Media Player    | VLC                |
| Image Editor    | GIMP               |
| Video Editor    | Kdenlive           |
| Email           | Thunderbird        |
| Software Center | Discover + Flatpak |
| Backup          | Timeshift          |

---

# Troubleshooting

Having issues? Check our comprehensive troubleshooting guide:

📖 **[Troubleshooting Guide](docs/troubleshooting.md)**

Common topics covered:
- Display & GPU issues (nomodeset, X11/Wayland switching)
- Desktop environment problems (restart Plasma, reset settings)
- Login issues (restart SDDM, password reset)
- Performance optimization
- Network troubleshooting

**Quick Commands:**
```bash
# Restart desktop
killall plasmashell && plasmashell &

# Restart login manager
sudo systemctl restart sddm

# Run system health check
sudo /opt/aetheros/aether-health.sh

# v2.0 Tools
aether-performance-profiler.sh auto    # Auto-detect and optimize
aether-cleanmode.sh toggle             # Toggle performance mode
aether-focus-mode.sh status            # Check Focus Mode
aether-profile-sync.sh save            # Save preferences

# v2.1 Security & Session
aethershieldctl list                   # Show app policies
aethershieldctl show firefox           # View specific app policy
aether-secure-session.sh status        # Check secure session
aether-secure-session.sh start         # Enable lockdown mode

# v2.1 Thermal & Performance
aether-thermal-watch.sh check          # Check thermal status
aether-thermal-watch.sh monitor        # Run thermal monitoring
aether-performance-profiler.sh auto    # Auto performance tuning

# v2.1 QuickPal & Profiles
aether-quickpal.sh                     # Launch QuickPal search
aether-profile-sync.sh save myprofile  # Save named profile
aether-profile-sync.sh load myprofile  # Restore profile

# v2.1 Audio
aether-audio-profile.sh gaming         # Set gaming audio profile
aether-audio-profile.sh movie          # Set movie audio profile
aether-audio-profile.sh voice          # Set voice call profile

# v2.1 Accessibility
aether-accessibility.sh reduce-motion on   # Disable animations
aether-accessibility.sh high-contrast on   # Enable high contrast
```

---

# Roadmap

## v0.1 Alpha ✅
* [x] Fix kernel/initrd bundle for ISO build pipeline
* [x] AetherOS Theme Pack (light/dark, icons, wallpapers)
* [x] Custom SDDM Login Theme
* [x] Aether Control Center (Quick Settings, Power, Night Light)
* [x] First-Run Wizard (theme, privacy, app bundles)
* [x] App Bundles (Core, Dev, Media, Gaming)
* [x] Performance optimization scripts (zram, sysctl tuning)
* [x] Calamares installer branding theme
* [x] Build system with CI/CD pipeline

## v0.2 ✅
* [x] **Stability & Error Handling**
  - System health check script (`aether-health.sh`)
  - Error logging for UI components
* [x] **Security Hardening**
  - UFW firewall enabled by default
  - AppArmor profiles for Firefox
  - Security update notifications
* [x] **Window Management**
  - Windows 11-style tiling (Meta+Arrow)
  - Workspace shortcuts (Ctrl+Alt+Arrow)
  - Touchpad gestures for Wayland
* [x] **Control Center v2**
  - System Overview, Network, Appearance, Power, Maintenance pages
* [x] **Update Management**
  - Aether Updater UI
  - APT and Flatpak update checking
* [x] **Backups**
  - AetherVault home directory backup
  - Timeshift integration
* [x] **Performance**
  - Tiered ZRAM (75%/50%/25% based on RAM)
  - Power profile switching

## v1.1 ✅
* [x] **CI Pipeline Cleanup**
  - QEMU boot test made non-blocking
  - Focus on build success, checksums, and security scanning
  - Manual QEMU testing recommended for validation
* [x] **Focus Mode / Do Not Disturb**
  - Toggle in Control Center
  - Integrates with KDE notification settings
* [x] **Auto Light/Dark Theme Schedule**
  - Automatic theme switching based on time of day
  - Light theme: 7 AM - 7 PM, Dark theme: 7 PM - 7 AM
  - Systemd timer for automation
* [x] **System Sound Theme**
  - Minimal, clean sound theme (Ocean)
  - Toggle in Control Center
  - Login, notification, and alert sounds
* [x] **Aether Quick Actions**
  - Shell-based menu launcher (kdialog/zenity)
  - Quick access to Control Center, Health Check, Backups, Updates
* [x] **New Wallpapers**
  - Added Aether Waves and Aether Minimal wallpapers
  - Total of 6 wallpapers available

## v2.0 - Ultimate Edition (Current) ✅
* [x] **CI Fixes**
  - Fixed theme asset validation
  - QEMU boot test made truly optional with environment guard
  - CI passes without blocking on optional tests

* [x] **Ultimate Aesthetic Upgrade**
  - Adaptive Blur System (High/Frosted/Off modes)
  - CleanMode toggle for low-end hardware
  - Enhanced Plasma themes with Aether Neon design tokens
  - Smart shadows and layer depth (theme integration)

* [x] **Performance Intelligence**
  - Auto Performance Profiler (MaxMode/Balanced/LiteMode)
  - Smart Service Manager (auto-disable unused services)
  - Adaptive ZRAM rebalancing (75%/50%/33% with LZ4)

* [x] **Intelligent Desktop Behavior**
  - Focus Mode 2.0 with auto-activation for fullscreen apps
  - Focus Mode scheduling (study mode)
  - Smart Notifications (gaming/video/meeting detection)

* [x] **Utilities & User Comfort**
  - QuickPal Spotlight-style launcher
  - Profile Sync system (save/restore preferences)

* [x] **Branding & Visual Identity**
  - New wallpaper pack (Waves Dark, Neon Flow, Gradient Minimal)
  - Total of 9 wallpapers now available

* [x] **Documentation**
  - Updated README with v2.0 features
  - Created design-architecture.md
  - Documented all new systems and scripts

## v2.1 - Security Evolution (Current) ✅
* [x] **Security Evolution**
  - AetherShield CLI + app policy manifests (`aethershieldctl`)
  - Secure Session Mode for sensitive tasks
* [x] **Audio & Media Polish**
  - Aether Ocean sound pack (ocean-inspired sounds)
  - Audio profiles (Movie/Gaming/Voice/Balanced)
* [x] **Enhanced Features**
  - Thermal Watch (heat-aware visual intelligence)
  - Holographic login pulse effect
  - QuickPal enhanced with fuzzy search
* [x] **System Improvements**
  - Full Calamares slideshow during installation
  - Expanded accessibility features (Reduced Motion, High Contrast)
  - ARM64 support exploration (experimental)

## v2.2 - HyperPolish (Current) ✅
* [x] **System Transparency**
  - Aether Dashboard (live system overview: CPU, RAM, GPU, thermal)
  - Real-time monitoring without heavy daemons
* [x] **Mode Switching**
  - Game Mode (performance optimization for gaming)
  - Creator Mode (optimized for content creation)
  - Easy one-command mode switching
* [x] **Setup Profiles**
  - Developer Edition preset (install dev tools)
  - Minimal Edition preset (remove optional apps)
  - User-friendly setup experience
* [x] **Download Experience**
  - User-friendly download page (website/download.html)
  - Upload instructions for maintainers
  - No-cost hosting strategy documented
* [x] **GUI Enhancements**
  - AetherShield GUI (basic policy viewer)
  - kdialog/zenity integration

## v2.3 (Planned)
* [ ] **Enhanced GUI**
  - Full AetherShield GUI with policy editing
  - Thermal monitoring dashboard in Control Center
  - Audio profile selector GUI
* [ ] **ARM64 Support**
  - Complete ARM64 testing and optimization
  - Raspberry Pi 4/5 support
  - Touch-friendly interface options

---

# Contributing

Contributions are welcome!

Please read:

* [`docs/dev-guide.md`](docs/dev-guide.md)
* [`docs/theming-guide.md`](docs/theming-guide.md)

Suggestions, patches, branding ideas, performance improvements — all appreciated.

---

# License

This project is licensed under the **Apache License 2.0**.
See the file: [`LICENSE`](LICENSE)

---

## Acknowledgments

* Ubuntu / Canonical
* KDE Community
* Linux open-source ecosystem

---

<p align="center">
  Made with ❤️ for everyone who wants a clean, modern, beautiful Linux desktop.
</p>

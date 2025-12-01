# AetherOS

<p align="center">
  <img src="artwork/logo.svg" alt="AetherOS Logo" width="128" height="128">
</p>

<p align="center">
  <strong>A beautiful, ultra-smooth, Ubuntu LTS-based desktop distribution</strong>
</p>

<p align="center">
  <em>Status: v1.0 Release Candidate</em>
</p>

<p align="center">
  <a href="#overview">Overview</a> •
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#building">Building</a> •
  <a href="#testing">Testing</a> •
  <a href="#installation">Installation</a> •
  <a href="#default-applications">Default Apps</a> •
  <a href="#roadmap">Roadmap</a> •
  <a href="#contributing">Contributing</a>
</p>

<p align="center">
  <img src="https://img.shields.io/github/actions/workflow/status/Anamitra-Sarkar/Aether_OS/build.yml?label=Build&style=flat-square">
  <img src="https://img.shields.io/github/license/Anamitra-Sarkar/Aether_OS?style=flat-square">
  <img src="https://img.shields.io/badge/version-1.0%20RC-blue?style=flat-square">
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

* 🎨 **Beautiful Design**
  Custom KDE Plasma theme, refined visuals, translucent shell panels, unified iconography, and handcrafted design tokens.

* ⚡ **Optimized Performance**
  zram swap, preload, tuned sysctls, disabled unnecessary services, trimmed indexing, and smart defaults for snappy responsiveness.

* 🖥️ **Modern Desktop**
  KDE Plasma on Wayland (with seamless X11 fallback), Latte Dock, and a polished layout inspired by macOS and Windows.

* 🔧 **First-Run Wizard**
  Friendly onboarding with privacy-first defaults, theme selection, app bundles, Flatpak setup, and optional codecs.

* ♿ **Accessible**
  High-DPI, reduced motion mode, UI scaling presets, screen reader support, and shortcut-oriented navigation.

* 🔒 **Privacy-Focused**
  Telemetry disabled by default, no mandatory proprietary binaries, and deliberate transparency in system behavior.

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

## QEMU Boot Test

```bash
./tests/boot-qemu.sh build/artifacts/aetheros.iso
```

This will:

1. Boot the ISO with 4GB RAM
2. Verify desktop session
3. Save screenshot to:
   `tests/artifacts/desktop.png`
4. Exit 0 on success

## UI Sanity Check

```bash
./tests/ui-sanity.sh
```

---

# Download

## Latest Stable Release

📥 **[Download AetherOS v1.0 RC ISO](https://github.com/Anamitra-Sarkar/Aether_OS/releases/latest)**

- **File**: `aetheros.iso`
- **Size**: ~2.5 GB
- **Checksum**: Included as `aetheros.iso.sha256`
- **Requirements**: 2GB RAM minimum, 4GB recommended

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

## v0.2 (Current) ✅
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

## v0.3 (Planned)
* [ ] Full Calamares slideshow
* [ ] Additional wallpapers and icon variants
* [ ] Expanded accessibility features
* [ ] ARM64 support exploration

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

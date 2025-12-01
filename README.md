# AetherOS

<p align="center">
  <img src="artwork/logo.svg" alt="AetherOS Logo" width="128" height="128">
</p>

<p align="center">
  <strong>A beautiful, ultra-smooth, Ubuntu LTS-based desktop distribution</strong>
</p>

<p align="center">
  <em>Status: v0.1 Alpha</em>
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
  <img src="https://img.shields.io/badge/version-0.1%20Alpha-blue?style=flat-square">
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

*Initial UI previews will be added after the first successful ISO boot.*
(QEMU desktop screenshots automatically saved to `tests/artifacts/`)

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

# Installation

1. Download the latest ISO from:
   **[https://github.com/Anamitra-Sarkar/Aether_OS/releases](https://github.com/Anamitra-Sarkar/Aether_OS/releases)**
2. Flash ISO to USB via:

   * Balena Etcher
   * Ventoy
   * `dd`
3. Boot and follow the Calamares installer

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

## v0.1 Alpha (Current) ✅
* [x] Fix kernel/initrd bundle for ISO build pipeline
* [x] AetherOS Theme Pack (light/dark, icons, wallpapers)
* [x] Custom SDDM Login Theme
* [x] Aether Control Center (Quick Settings, Power, Night Light)
* [x] First-Run Wizard (theme, privacy, app bundles)
* [x] App Bundles (Core, Dev, Media, Gaming)
* [x] Performance optimization scripts (zram, sysctl tuning)
* [x] Calamares installer branding theme
* [x] Build system with CI/CD pipeline

## v0.2 (Planned)
* [ ] Full Calamares slideshow
* [ ] Additional wallpapers and icon variants
* [ ] Bug fixes from alpha feedback
* [ ] Expanded accessibility features
* [ ] Performance improvements

## v0.3 (Future)
* [ ] Additional app integrations
* [ ] More power management options
* [ ] Custom kernel options
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

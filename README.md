# AetherOS

<p align="center">
  <img src="artwork/logo.svg" alt="AetherOS Logo" width="128" height="128">
</p>

<p align="center">
  <strong>A beautiful, ultra-smooth, Ubuntu LTS-based desktop distribution</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#installation">Installation</a> •
  <a href="#building">Building</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## Overview

**AetherOS** is a consumer-grade desktop Linux distribution built on Ubuntu 24.04 LTS. It delivers a polished, snappy experience with macOS-like aesthetics and Windows-like familiarity. The goal is to feel more refined than existing alternatives while remaining fully open source and reproducible.

## Features

- 🎨 **Beautiful Design** — Refined KDE Plasma desktop with custom Breeze-derived theme, unified iconography, and consistent design tokens
- ⚡ **Optimized Performance** — zram swap, preload, tuned sysctls, disabled unnecessary services for a snappy experience
- 🖥️ **Modern Desktop** — KDE Plasma on Wayland (with X11 fallback), Latte Dock, and a polished control center
- 📦 **Flexible Packaging** — APT for system packages + Flatpak (Flathub) for optional apps
- 🔧 **First-Run Wizard** — Friendly setup experience with privacy-first defaults
- ♿ **Accessible** — High-DPI support, keyboard navigation, reduced-motion toggle, screen reader support
- 🔒 **Privacy-Focused** — Telemetry disabled by default, no proprietary components required

## Design Tokens

| Token | Light | Dark |
|-------|-------|------|
| Primary Accent | `#6C8CFF` (Aether Blue) | `#6C8CFF` |
| Secondary Accent | `#7AE7C7` (Soft Mint) | `#7AE7C7` |
| Background | `#F6F8FA` | `#0F1720` |
| Surface | `#FFFFFF` | `#101317` |

- **Typography**: Inter (system default), fallback Noto Sans
- **UI Radius**: 10–12px rounded corners
- **Animation**: 150ms base, 220ms modal, cubic-bezier(0.22, 1, 0.36, 1)

## Prerequisites

To build AetherOS, you need an Ubuntu 24.04 host with the following packages:

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

## Building

### Quick Build

```bash
# Clone the repository
git clone https://github.com/your-org/aetheros.git
cd aetheros

# Build the ISO (requires sudo)
sudo ./build/build.sh

# Output: build/artifacts/aetheros.iso
```

### Minimal Build (for testing)

```bash
sudo ./build/build.sh --minimal
```

### Build Artifacts

After a successful build, you'll find:
- `build/artifacts/aetheros.iso` — Bootable ISO image
- `build/artifacts/aetheros.iso.sha256` — SHA256 checksum

## Testing

### QEMU Boot Test

```bash
./tests/boot-qemu.sh build/artifacts/aetheros.iso
```

This will:
1. Boot the ISO in QEMU with 4GB RAM
2. Wait for desktop to become ready
3. Save a screenshot to `tests/artifacts/desktop.png`
4. Exit with code 0 on success

### UI Sanity Checks

```bash
./tests/ui-sanity.sh
```

## Installation

1. Download the latest ISO from [Releases](https://github.com/your-org/aetheros/releases)
2. Create a bootable USB using Balena Etcher, Ventoy, or `dd`
3. Boot from USB and follow the Calamares installer

## Default Applications

| Category | Application |
|----------|-------------|
| Browser | Firefox |
| Office | LibreOffice |
| Video Player | VLC |
| Image Editor | GIMP |
| Video Editor | Kdenlive |
| Email | Thunderbird |
| Software Center | Discover + Flatpak |
| System Backup | Timeshift |

## Contributing

We welcome contributions! Please read our [Developer Guide](docs/dev-guide.md) and [Theming Guide](docs/theming-guide.md).

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Ubuntu and Canonical for the excellent LTS base
- KDE Team for Plasma and KWin
- The open source community for countless contributions

---

<p align="center">Made with ❤️ by the AetherOS Team</p>

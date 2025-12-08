# AetherOS Developer Guide

Welcome to the AetherOS Developer Guide! This document provides everything you need to know to contribute to AetherOS development.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Repository Structure](#repository-structure)
3. [Building AetherOS](#building-aetheros)
4. [Testing](#testing)
5. [Contributing](#contributing)
6. [Coding Standards](#coding-standards)

## Getting Started

### Prerequisites

To develop AetherOS, you need an Ubuntu 24.04 (Noble Numbat) host system with the following packages:

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
    syslinux-common \
    qtbase5-dev \
    qtdeclarative5-dev \
    qml-module-qtquick2 \
    qml-module-qtquick-controls2 \
    qml-module-qtquick-layouts \
    qml-module-qtquick-window2
```

### Clone the Repository

```bash
git clone https://github.com/your-org/aetheros.git
cd aetheros
```

## Repository Structure

```
aetheros/
├── .github/workflows/    # CI/CD pipelines
├── artwork/              # Logos, wallpapers, icons
├── build/                # Build scripts and configuration
│   ├── build.sh          # Main build script
│   ├── chroot-setup.sh   # Chroot environment setup
│   ├── packages.list     # System packages to install
│   └── hooks/            # Build hooks
├── configs/              # System configurations
│   ├── kde/              # KDE Plasma configs
│   ├── sddm/             # SDDM login manager
│   ├── calamares/        # Installer configuration
│   └── first-run/        # First-run wizard defaults
├── docs/                 # Documentation
├── opt/                  # System optimization scripts
│   ├── enable-zram.sh
│   ├── system-tuning.sh
│   └── service-trimmer.sh
├── scripts/              # Helper scripts
│   ├── create-live-user.sh
│   ├── configure-first-run.sh
│   └── install-bundles.sh
├── tests/                # Test scripts
│   ├── boot-qemu.sh
│   └── ui-sanity.sh
└── ui/                   # QML UI components
    ├── control-center/
    └── first-run-wizard/
```

## Building AetherOS

### Quick Build

The simplest way to build AetherOS is:

```bash
sudo ./build/build.sh
```

This will:
1. Create a chroot environment using debootstrap
2. Install all packages from `packages.list`
3. Copy configurations and artwork
4. Create a squashfs filesystem
5. Assemble the bootable ISO

The output will be in `build/artifacts/aetheros.iso`.

### Minimal Build

For faster testing, use the minimal build mode:

```bash
sudo ./build/build.sh --minimal
```

This uses lighter compression and produces a smaller, faster-to-build ISO.

### Build Steps Explained

#### 1. Chroot Setup (`chroot-setup.sh`)

Creates the base system:

```bash
# Uses debootstrap to create Ubuntu base
debootstrap --arch=amd64 noble ./chroot http://archive.ubuntu.com/ubuntu

# Installs packages
apt-get install $(cat packages.list)

# Copies configurations
cp -r configs/kde/* /etc/skel/.config/
cp -r artwork/* /usr/share/backgrounds/aetheros/
```

#### 2. Build ISO (`build.sh`)

Assembles the final ISO:

```bash
# Create squashfs
mksquashfs chroot/ iso/casper/filesystem.squashfs

# Copy kernel and initrd
cp chroot/boot/vmlinuz-* iso/casper/vmlinuz
cp chroot/boot/initrd.img-* iso/casper/initrd

# Create ISO with xorriso
xorriso -as mkisofs -o aetheros.iso iso/
```

## Testing

### QEMU Boot Test

Test the ISO in a virtual machine:

```bash
./tests/boot-qemu.sh build/artifacts/aetheros.iso
```

This will:
- Boot the ISO in QEMU with 4GB RAM
- Wait for the desktop to become ready
- Take a screenshot
- Exit with code 0 on success

**Note:** This test is optional in CI (marked as `continue-on-error: true`) due to resource constraints and timing variability on GitHub-hosted runners. It is highly recommended for local testing and manual validation.

### Test Mode Flag

For automated testing scenarios, you can enable test mode:

```bash
# Enable test mode (as root)
sudo mkdir -p /etc/aetheros
sudo touch /etc/aetheros/test-mode

# On first login, diagnostics will run automatically
# The test-mode script will display results in a dialog
```

This is useful for:
- Automated test environments
- CI systems with GUI access
- Manual validation after installation

To disable test mode:
```bash
sudo rm /etc/aetheros/test-mode
```

### UI Sanity Checks

Run lightweight system checks:

```bash
./tests/ui-sanity.sh
```

This verifies:
- System files exist
- Required commands are available
- Services are enabled
- Configuration is correct

### Manual Testing

For interactive testing:

```bash
# Start QEMU with VNC
qemu-system-x86_64 \
    -enable-kvm \
    -m 4096 \
    -smp 2 \
    -cdrom build/artifacts/aetheros.iso \
    -boot d \
    -display vnc=:0

# Connect with VNC viewer
vncviewer localhost:5900
```

## Contributing

### Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Make your changes
4. Run tests: `./tests/ui-sanity.sh`
5. Commit with a descriptive message
6. Push and create a pull request

### Commit Message Format

Follow the conventional commits format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Maintenance

Examples:
```
feat(build): add minimal build mode for faster CI
fix(config): correct SDDM autologin configuration
docs: update developer guide with testing section
```

### Pull Request Guidelines

- Keep PRs focused on a single change
- Include tests for new features
- Update documentation as needed
- Ensure the build passes
- Request review from maintainers

## Coding Standards

### Bash Scripts

- Use `set -euo pipefail` at the start
- Quote all variables: `"$VAR"`
- Use `[[` for conditionals (Bash-specific)
- Add logging functions
- Make scripts idempotent

```bash
#!/bin/bash
set -euo pipefail

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

main() {
    log "Starting..."
    # Your code here
    log "Done"
}

main "$@"
```

### QML

- Use meaningful property names
- Define colors as properties at the top
- Use anchors for layout when possible
- Add comments for complex logic

```qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    // Design tokens
    readonly property color accentColor: "#6C8CFF"
    readonly property int animDuration: 150
    
    Rectangle {
        anchors.fill: parent
        color: accentColor
        
        Behavior on color {
            ColorAnimation { duration: animDuration }
        }
    }
}
```

### Configuration Files

- Use comments to explain non-obvious settings
- Group related settings together
- Use consistent formatting
- Document any customizations

## Troubleshooting

### Build Issues

**Problem**: `debootstrap` fails to download packages

**Solution**: Check your internet connection and try a different mirror:
```bash
export UBUNTU_MIRROR=http://mirrors.kernel.org/ubuntu
sudo ./build/build.sh
```

**Problem**: `mksquashfs` runs out of memory

**Solution**: Use lighter compression:
```bash
mksquashfs chroot/ filesystem.squashfs -comp gzip
```

### Testing Issues

**Problem**: QEMU fails to start with KVM

**Solution**: Run without KVM (slower but works):
```bash
qemu-system-x86_64 -m 4096 -cdrom aetheros.iso
```

**Problem**: Desktop doesn't appear

**Solution**: Check the serial log:
```bash
cat /tmp/qemu-serial.log
```

## Security

### Firewall (UFW)

AetherOS comes with UFW (Uncomplicated Firewall) enabled by default:
- Deny incoming connections
- Allow outgoing connections

To manage the firewall:
```bash
# Check status
sudo ufw status

# Open a port
sudo ufw allow 22/tcp

# Use GUI
gufw
```

### AetherShield (v2.1)

Per-app sandbox policy management system:

```bash
# List managed applications
aethershieldctl list

# View app policy
aethershieldctl show firefox

# Apply policy restrictions
aethershieldctl apply firefox

# Check enforcement status
aethershieldctl status firefox
```

**Policy Manifest Location**: `/etc/aetheros/security/apps/`

**Features**:
- JSON-based app policies
- Control network, camera, microphone, filesystem access
- AppArmor and Flatpak integration
- Phase 1: Policy awareness + partial enforcement

### Secure Session Mode (v2.1)

Lock down your system for sensitive tasks:

```bash
# Enable secure mode
aether-secure-session.sh start

# Check status
aether-secure-session.sh status

# Return to normal
aether-secure-session.sh stop
```

**When Active**:
- Strict firewall rules (deny incoming)
- SSH server disabled
- Network services stopped
- USB automount disabled
- Visual indicator shown

### Security Updates

AetherOS includes automatic security update checking:

**Timer**: `aetheros-security-check.timer`
- Runs weekly on Monday at 9:00 AM
- Checks for security updates and notifies user
- Does not auto-install by default

**Manual commands**:
```bash
# Check for security updates
sudo /usr/share/aetheros/scripts/aether-security-update.sh check

# List available security updates
sudo /usr/share/aetheros/scripts/aether-security-update.sh list

# Install security updates
sudo /usr/share/aetheros/scripts/aether-security-update.sh install
```

### AppArmor

AppArmor is enabled by default for sandboxing applications:
```bash
# Check AppArmor status
sudo aa-status

# View loaded profiles
sudo aa-status --profiles
```

## Performance & Boot Optimization

### ZRAM Configuration

AetherOS uses tiered ZRAM sizing based on available RAM:

| RAM | ZRAM Size |
|-----|-----------|
| ≤ 4GB | 75% of RAM |
| 4-8GB | 50% of RAM |
| > 8GB | 25% of RAM |

ZRAM uses zstd compression and is set with higher priority (100) than disk swap.

```bash
# Check ZRAM status
/opt/aetheros/enable-zram.sh --status

# Re-enable if needed
sudo /opt/aetheros/enable-zram.sh
```

### Power Profiles

Control power mode via CLI:
```bash
# Check current profile
aether-power-mode.sh --status

# Set profiles
aether-power-mode.sh --battery      # Power saver
aether-power-mode.sh --balanced     # Balanced (default)
aether-power-mode.sh --performance  # Maximum performance
```

### Boot Time Analysis

To analyze boot performance:
```bash
# Overall boot time
systemd-analyze

# Per-service breakdown
systemd-analyze blame | head -20

# Critical path
systemd-analyze critical-chain
```

### Boot Optimizations Applied

AetherOS includes these boot optimizations:

1. **Disabled unneeded timers**:
   - `apt-daily.timer` - daily apt updates disabled
   - `apt-daily-upgrade.timer` - auto-upgrade disabled

2. **Journal limits**:
   - Maximum 100MB system journal
   - Compressed storage

3. **Preload enabled**:
   - Preloads frequently used applications

4. **I/O scheduler optimized**:
   - mq-deadline for SSDs
   - bfq for HDDs

5. **Baloo disabled**:
   - File indexing disabled by default (user can enable)

### Thermal Watch (v2.1)

Heat-aware visual intelligence system:

```bash
# Check current temperature and state
aether-thermal-watch.sh check

# Run monitoring daemon
aether-thermal-watch.sh monitor

# Enable as systemd service
systemctl --user enable --now aether-thermal.service
```

**Thermal States**:
- **Cool** (<60°C): Full visual effects
- **Warm** (60-75°C): Reduced effects
- **Hot** (>75°C): Performance mode activated

### Audio Profiles (v2.1)

Optimize audio for different scenarios:

```bash
# Set profile
aether-audio-profile.sh movie      # Enhanced bass, surround sound
aether-audio-profile.sh gaming     # High volume, low latency
aether-audio-profile.sh voice      # Clear speech, boosted mic
aether-audio-profile.sh balanced   # Neutral settings (default)

# Check current profile
aether-audio-profile.sh status
```

### Accessibility Features (v2.1)

```bash
# Disable animations (Reduced Motion Mode)
aether-accessibility.sh reduce-motion on

# Enable high contrast
aether-accessibility.sh high-contrast on

# Check current settings
aether-accessibility.sh status
```

### Monitoring Performance

```bash
# System health check
/usr/share/aetheros/scripts/aether-health.sh

# Memory usage
free -h

# Swap usage (including zram)
swapon --show

# CPU governor
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

## Backup & Recovery

AetherOS provides comprehensive backup solutions for both system and user data.

### Quick Reference

For detailed backup instructions, see **[Backup Guide](backup-guide.md)**.

**System Backup (Timeshift)**:
```bash
# Create system snapshot
sudo timeshift --create --comments "Before update"

# List snapshots
sudo timeshift --list

# Restore from snapshot
sudo timeshift --restore
```

**User Data Backup (AetherVault)**:
```bash
# Backup home directory
/usr/share/aetheros/scripts/aethervault.sh /path/to/backup

# Dry run (preview what will be backed up)
/usr/share/aetheros/scripts/aethervault.sh /path/to/backup --dry-run

# Restore
rsync -av --progress /path/to/backup/ ~/
```

**Best Practice**: Create a Timeshift snapshot before:
- System updates
- Installing new software
- Modifying system configurations
- Testing new features

## Resources

- [Ubuntu Packaging Guide](https://packaging.ubuntu.com/)
- [KDE Plasma Development](https://develop.kde.org/docs/plasma/)
- [Calamares Documentation](https://calamares.io/docs/)
- [GRUB Manual](https://www.gnu.org/software/grub/manual/)
- [AetherOS Backup Guide](backup-guide.md)
- [AetherOS Shortcuts](shortcuts.md)
- [AetherOS Theming Guide](theming-guide.md)

## Getting Help

- Create an issue on GitHub
- Join our community chat
- Check existing documentation

Happy contributing! 🚀

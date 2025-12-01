# AetherOS Release Process

This document outlines the process for creating a new release of AetherOS.

## Release Checklist

### Pre-Release Validation

- [ ] All CI builds pass successfully
- [ ] Boot test completes without errors
- [ ] UI sanity tests pass
- [ ] No critical CodeQL warnings
- [ ] All shell scripts pass shellcheck
- [ ] Documentation is up-to-date

### Version Updates

- [ ] Update version in `README.md`
- [ ] Update version badge in `README.md`
- [ ] Add entry to `CHANGELOG.md`
- [ ] Update version in UI components:
  - [ ] `ui/first-run-wizard/main.qml`
  - [ ] `ui/first-run-wizard/WelcomeStep.qml`
  - [ ] `ui/control-center/main.qml`

### Build & Test

1. **Build the ISO**:
   ```bash
   sudo ./build/build.sh
   ```

2. **Verify build artifacts**:
   ```bash
   ls -lh build/artifacts/aetheros.iso
   sha256sum build/artifacts/aetheros.iso
   ```

3. **Run boot test**:
   ```bash
   ./tests/boot-qemu.sh build/artifacts/aetheros.iso
   ```

4. **Run sanity checks**:
   ```bash
   ./tests/ui-sanity.sh
   ```

5. **Verify screenshots were captured**:
   ```bash
   ls -lh artwork/screenshots/
   ```

### Create GitHub Release

1. **Tag the release**:
   ```bash
   git tag -a v1.0.0-rc -m "AetherOS v1.0 Release Candidate"
   git push origin v1.0.0-rc
   ```

2. **Create release on GitHub**:
   - Go to https://github.com/Anamitra-Sarkar/Aether_OS/releases/new
   - Select the tag: `v1.0.0-rc`
   - Title: `AetherOS v1.0 Release Candidate`
   - Description: Use the template below

3. **Upload artifacts**:
   - `build/artifacts/aetheros.iso`
   - `build/artifacts/aetheros.iso.sha256`
   - Screenshots from `artwork/screenshots/`

### Release Notes Template

```markdown
# AetherOS v1.0 Release Candidate

AetherOS v1.0 RC marks full stability, security hardening, visual polish, Control Center maturity, first-run onboarding experience, backup strategy, update tooling, power profiles, and reproducible ISO infrastructure.

## 🎉 What's New

### Core Features
- ✨ Beautiful KDE Plasma desktop with custom Aether theme
- 🚀 Optimized performance with ZRAM and tuned sysctls
- 🔒 Privacy-focused with firewall enabled by default
- 🛡️ Security hardening with AppArmor profiles
- 🎨 First-run wizard for easy setup
- 💾 Backup tools (Timeshift + AetherVault)
- ⚡ Power profile management
- 🔄 Update management UI

### System Specifications
- **Base**: Ubuntu 24.04 LTS (Noble Numbat)
- **Kernel**: Linux 6.8
- **Desktop**: KDE Plasma 5.27 on Wayland
- **Display Manager**: SDDM
- **Default Apps**: Firefox, LibreOffice, VLC, GIMP, Thunderbird

### Requirements
- **Minimum**: 2GB RAM, 20GB disk space
- **Recommended**: 4GB RAM, 40GB disk space, UEFI firmware
- **Architecture**: x86_64 (AMD64)

## 📥 Download

### ISO Image
- **File**: `aetheros.iso`
- **Size**: ~2.5 GB
- **SHA256**: See `aetheros.iso.sha256`

### Verification

```bash
sha256sum -c aetheros.iso.sha256
```

### Installation

1. Download the ISO
2. Verify the checksum
3. Create bootable USB:
   ```bash
   sudo dd if=aetheros.iso of=/dev/sdX bs=4M status=progress
   ```
4. Boot from USB and follow the installer

## 📸 Screenshots

*See attached images for desktop, login screen, and Control Center*

## 🔧 Known Issues

- Latte Dock may require manual start on first boot
- Some Flatpak packages may require Flathub setup
- QEMU boot test requires KVM for reasonable speed

## 📚 Documentation

- [Developer Guide](https://github.com/Anamitra-Sarkar/Aether_OS/blob/main/docs/dev-guide.md)
- [Backup Guide](https://github.com/Anamitra-Sarkar/Aether_OS/blob/main/docs/backup-guide.md)
- [Theming Guide](https://github.com/Anamitra-Sarkar/Aether_OS/blob/main/docs/theming-guide.md)
- [Keyboard Shortcuts](https://github.com/Anamitra-Sarkar/Aether_OS/blob/main/docs/shortcuts.md)

## 🙏 Acknowledgments

Special thanks to:
- Ubuntu / Canonical
- KDE Community
- All contributors and testers

## 📝 Changelog

See [CHANGELOG.md](https://github.com/Anamitra-Sarkar/Aether_OS/blob/main/CHANGELOG.md) for detailed changes.

---

**Note**: This is a Release Candidate. While stable for daily use, please report any issues on GitHub.
```

## Post-Release Tasks

- [ ] Update README.md download links to point to the release
- [ ] Announce release on social media / community channels
- [ ] Monitor GitHub issues for feedback
- [ ] Plan next version based on feedback

## Release Cadence

### Version Numbering

AetherOS follows semantic versioning:
- **Major** (1.x.x): Major features, breaking changes
- **Minor** (x.1.x): New features, enhancements
- **Patch** (x.x.1): Bug fixes, security updates

### Release Types

- **RC (Release Candidate)**: Feature-complete, ready for testing
- **Stable**: Production-ready, fully tested
- **LTS**: Long-term support (based on Ubuntu LTS)

### Typical Timeline

- **Alpha**: Early development, major features incomplete
- **Beta**: Feature-complete, testing phase
- **RC**: Release candidate, final testing
- **Stable**: Production release
- **Maintenance**: Bug fixes and security updates

## Emergency Hotfix Process

For critical security issues or major bugs:

1. Create hotfix branch from release tag
2. Fix the issue
3. Test thoroughly
4. Create patch release (e.g., v1.0.1)
5. Update CHANGELOG with security advisory if applicable

## Support Policy

- **Current Release**: Full support
- **Previous Release**: Security updates only (6 months)
- **Older Releases**: Community support only

Based on Ubuntu 24.04 LTS, AetherOS v1.0 will receive:
- Security updates: Until April 2029
- Feature updates: 12 months from release

## Contact

- **Issues**: https://github.com/Anamitra-Sarkar/Aether_OS/issues
- **Discussions**: https://github.com/Anamitra-Sarkar/Aether_OS/discussions

---

**Maintained by**: Anamitra Sarkar  
**License**: Apache License 2.0

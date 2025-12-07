# ARM64 Support (Experimental)

**Status**: Experimental / Not Production Ready

AetherOS v2.1 includes groundwork for ARM64 (aarch64) architecture support.
This is **not yet fully tested** and should be considered experimental.

## Current Status

### What Works
- ✅ Build scripts are architecture-aware
- ✅ `ARCH` variable can be set to `arm64`
- ✅ Debootstrap will use ARM64 packages
- ✅ No hardcoded `amd64` references in core build scripts

### What's Not Tested
- ❌ Full ISO creation for ARM64
- ❌ Boot process on ARM64 hardware
- ❌ Hardware compatibility testing
- ❌ Performance profiling on ARM64
- ❌ GPU detection for ARM SoCs

### What's Not Yet Implemented
- ❌ ARM64-specific bootloader configuration
- ❌ ARM64 device tree support
- ❌ SoC-specific optimizations
- ❌ ARM64 installer images

## Building for ARM64

### Prerequisites

You need:
- ARM64 system or cross-compilation environment
- `debootstrap` with ARM64 support
- QEMU user emulation (for x86_64 hosts)

### Method 1: Native ARM64 Build

On an ARM64 system:

```bash
cd build
sudo ARCH=arm64 ./build.sh
```

### Method 2: Cross-compilation (x86_64 host)

Install QEMU user emulation:

```bash
sudo apt install qemu-user-static binfmt-support
```

Then build:

```bash
cd build
sudo ARCH=arm64 ./build.sh
```

This will use QEMU to emulate ARM64 during the chroot phase.

## Supported Hardware (Theoretical)

Based on Ubuntu 24.04 LTS ARM64 support:

### Tested Platforms (Ubuntu)
- Raspberry Pi 4 & 5
- Raspberry Pi 400
- NVIDIA Jetson series
- Apple Silicon (via virtualization)
- AWS Graviton instances

### Should Work (Untested in AetherOS)
- Ampere Altra
- Amazon EC2 A1 instances
- Oracle Cloud ARM instances
- Generic ARM64 servers

## Known Limitations

1. **KDE Plasma Performance**: Heavy on ARM SoCs with limited GPU
2. **Thermal Management**: May need SoC-specific tuning
3. **Power Management**: Not optimized for ARM power states
4. **Display Output**: Limited testing on ARM GPU drivers
5. **SDDM Theme**: May not render well on low-power GPUs

## Testing Checklist

If you want to help test ARM64 support:

- [ ] ISO builds successfully
- [ ] ISO boots on target hardware
- [ ] Display works (console and GUI)
- [ ] Network connectivity works
- [ ] Audio works
- [ ] Thermal management doesn't overheat
- [ ] Performance is acceptable
- [ ] Installer (Calamares) works
- [ ] KDE Plasma is stable
- [ ] All AetherOS scripts work

## Performance Expectations

### Raspberry Pi 4 (4GB/8GB)
- Should work with **LiteMode** forced on
- Expect reduced visual effects
- CleanMode recommended
- Adaptive blur should be disabled

### Raspberry Pi 5
- Should work with **Balanced** profile
- Modest visual effects possible
- May handle light blur

### Server ARM64 (Graviton, Altra)
- Should work well for headless/server use
- GUI performance depends on GPU availability
- Virtual GPU performance varies

## Contributing

To help with ARM64 support:

1. Test on real hardware
2. Report boot/build issues
3. Submit SoC-specific configurations
4. Help optimize thermal management
5. Test performance profiles

## Roadmap

Future ARM64 improvements (post-v2.1):

- [ ] Create ARM64 installer images
- [ ] Add device tree support
- [ ] Optimize for popular SoCs
- [ ] Test on Raspberry Pi hardware
- [ ] Create ARM64-specific profiles
- [ ] Document SoC-specific quirks
- [ ] Full CI testing for ARM64

## References

- Ubuntu ARM64 Support: https://ubuntu.com/download/server/arm
- Raspberry Pi Ubuntu: https://ubuntu.com/raspberry-pi
- ARM64 on AWS: https://aws.amazon.com/ec2/graviton/

## Warning

**Do not use ARM64 builds in production yet.**

This is experimental work to prepare the codebase for future ARM64
support. Wait for official ARM64 releases before deploying to
production systems.

## Help Wanted

If you have ARM64 hardware and want to help:
- Open an issue with your hardware details
- Share build logs and test results
- Submit fixes for ARM64-specific issues

---

*Last Updated: v2.1 (2024)*

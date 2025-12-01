# AetherOS Screenshots

This directory contains official screenshots for AetherOS documentation and promotional materials.

## Automated Screenshots

The following screenshots are automatically captured during CI boot tests:

- `login.png` - SDDM login screen
- `desktop.png` - Default desktop after boot
- `control-center.png` - Aether Control Center (requires manual capture)

## Capturing Screenshots

Screenshots are automatically captured by the boot test script:

```bash
./tests/boot-qemu.sh build/artifacts/aetheros.iso
```

This will save screenshots to this directory during the boot validation process.

## Manual Capture

For interactive screenshots (like Control Center), use:

1. Boot the ISO in QEMU or on real hardware
2. Navigate to the desired screen
3. Press `Print` or use `Meta+Shift+Print` for region capture
4. Save the screenshot to this directory

## Guidelines

- Use PNG format for all screenshots
- Capture at 1920x1080 resolution when possible
- Ensure the theme is set to the default Aether theme
- Remove any personal information or test data
- Use descriptive filenames (e.g., `desktop-dark.png`, `installer-step2.png`)

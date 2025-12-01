# AetherOS Artwork

This directory contains all artwork assets for AetherOS.

## Directory Structure

```
artwork/
├── logo.svg                    # Main AetherOS logo (128x128)
├── wallpaper-4k.svg           # Legacy wallpaper (deprecated)
├── wallpapers/                 # Wallpaper collection
│   ├── aetheros-default-light.svg
│   ├── aetheros-default-dark.svg
│   ├── aetheros-geometric.svg
│   ├── aetheros-nebula.svg
│   └── wallpapers.json        # Wallpaper metadata
├── icons/                      # Custom icon theme
│   └── Aether/
│       ├── index.theme        # Icon theme definition
│       └── scalable/          # SVG icons
│           ├── apps/          # Application icons
│           └── places/        # Folder/location icons
└── README.md
```

## Design Guidelines

### Colors

| Name | Hex | RGB | Usage |
|------|-----|-----|-------|
| Aether Blue | `#6C8CFF` | `rgb(108, 140, 255)` | Primary accent |
| Soft Mint | `#7AE7C7` | `rgb(122, 231, 199)` | Secondary accent |
| Dark Background | `#0F1720` | `rgb(15, 23, 32)` | Dark mode bg |
| Dark Surface | `#101317` | `rgb(16, 19, 23)` | Dark mode cards |
| Light Background | `#F6F8FA` | `rgb(246, 248, 250)` | Light mode bg |
| Light Surface | `#FFFFFF` | `rgb(255, 255, 255)` | Light mode cards |

### Logo Usage

The logo should be used on:
- Boot splash screen
- Login screen (SDDM)
- About dialogs
- Application launcher
- Installer branding

**Do not:**
- Stretch or distort the logo
- Use low resolution versions when high-res is available
- Add drop shadows or effects that alter the design

### Wallpapers

#### Default Wallpapers
- `aetheros-default-light.svg` - Soft gradient for light theme
- `aetheros-default-dark.svg` - Dark theme with subtle glows

#### Extra Wallpapers
- `aetheros-geometric.svg` - Minimal geometric pattern
- `aetheros-nebula.svg` - Abstract space/nebula style

#### Exporting Wallpapers

To export SVG wallpapers to PNG for best quality:

```bash
# Using Inkscape
inkscape --export-type=png --export-width=3840 --export-height=2160 input.svg

# Using rsvg-convert
rsvg-convert -w 3840 -h 2160 input.svg > output.png
```

### Icons

The Aether icon theme is based on Breeze but recolored to match the AetherOS palette.

#### Creating New Icons

1. Use SVG format
2. Follow the Breeze icon guidelines for shapes
3. Use Aether Blue (`#6C8CFF`) as the primary color
4. Use Soft Mint (`#7AE7C7`) for highlights
5. Export at multiple sizes or use scalable SVG

#### Icon Sizes

Icons should be provided in these sizes:
- 16x16 - Small icons
- 24x24 - Panel icons
- 32x32 - Menu icons
- 48x48 - Application icons
- 64x64 - Large icons
- 128x128 - App grid
- 256x256 - About dialogs
- scalable - SVG for all sizes

## License

All artwork in this directory is licensed under CC BY-SA 4.0 unless otherwise noted.
Original content created for AetherOS project.

## Creating Derivative Works

When creating new artwork:
1. Follow the color palette in `docs/design_tokens.md`
2. Use rounded corners (10-12px radius) for UI elements
3. Maintain consistency with existing elements
4. Export in appropriate formats (SVG for scalable, PNG for raster)
5. Test on both light and dark backgrounds

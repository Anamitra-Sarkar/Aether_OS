# AetherOS Calamares Slideshow Images

This directory contains images for the Calamares installer slideshow.

## Required Images

The slideshow should have 5-7 slides showing:

1. **Welcome** (`slide1-welcome.png`)
   - AetherOS logo and tagline
   - Brief introduction to the OS
   - Size: 800x600 or 1920x1080

2. **Design & Performance** (`slide2-design.png`)
   - Screenshot of the desktop
   - Highlight: Adaptive blur, CleanMode, visual profiles
   - Show the beautiful UI

3. **Focus Mode & Profiles** (`slide3-focus.png`)
   - Focus Mode interface
   - Performance Profiler
   - Smart notifications

4. **Security & Backups** (`slide4-security.png`)
   - AetherShield icon/interface
   - Secure Session Mode
   - AetherVault backup

5. **Community / Open Source** (`slide5-community.png`)
   - Open source logos
   - GitHub link
   - Thank you message

## Image Specifications

- **Format**: PNG (with transparency) or JPG
- **Resolution**: 800x600 (minimum), 1920x1080 (recommended)
- **Aspect Ratio**: 4:3 or 16:9
- **File Size**: < 500KB per image (optimize for fast loading)
- **Color Space**: sRGB

## Creating Placeholder Images

For development/testing, create simple placeholder images:

```bash
# Using ImageMagick
convert -size 1920x1080 xc:blue -pointsize 72 -fill white \
  -gravity center -annotate +0+0 "Welcome to AetherOS" \
  slide1-welcome.png

convert -size 1920x1080 xc:cyan -pointsize 72 -fill white \
  -gravity center -annotate +0+0 "Design & Performance" \
  slide2-design.png

# Continue for all slides...
```

Or use a design tool like:
- GIMP
- Inkscape
- Figma (export to PNG)

## Integration

The slideshow is configured in:
- `configs/calamares/branding/aetheros/branding.desc`
- `configs/calamares/branding/aetheros/show.qml`

Images are referenced in the `show.qml` file and displayed during
the installation process.

## Tips

- Keep text minimal and readable
- Use AetherOS brand colors (blue-mint accent)
- Show actual screenshots where possible
- Ensure images are high quality but not too large
- Test on different screen resolutions

## Current Status

**Placeholders**: The current files are placeholders and should be replaced
with actual designed slides before release.

To add real images:
1. Design the slides according to specifications
2. Export to PNG format
3. Optimize file size: `optipng slide*.png`
4. Replace placeholder files
5. Test in Calamares installer

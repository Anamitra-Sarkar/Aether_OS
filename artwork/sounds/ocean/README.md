# Aether Ocean Sound Pack

A calming, ocean-inspired sound theme for AetherOS.

## Sound Files

This directory contains placeholder sound files for the Aether Ocean theme:

- `login.ogg` - Login sound (gentle wave)
- `logout.ogg` - Logout sound (receding wave)
- `notification.ogg` - Notification sound (water droplet)
- `message.ogg` - Message received (soft chime)
- `alert.ogg` - Alert/warning sound (bell buoy)
- `error.ogg` - Error sound (deeper tone)
- `device-connect.ogg` - Device connected (positive tone)
- `device-disconnect.ogg` - Device disconnected (negative tone)
- `screenshot.ogg` - Screenshot captured (camera shutter)
- `trash.ogg` - Item moved to trash (paper rustling)

## File Format

All sound files should be:
- Format: OGG Vorbis (preferred) or WAV
- Sample rate: 44.1 kHz or 48 kHz
- Bit depth: 16-bit
- Channels: Stereo or Mono
- Duration: 0.5-2 seconds (keep it short!)

## Integration

The sound theme is integrated with KDE Plasma via:
- `configs/plasma/aether-ocean-sounds/` - KDE sound theme configuration
- System Settings → Appearance → System Sounds

## Placeholders

Current files are placeholders. To add real sounds:

1. Create/obtain ocean-themed sound files
2. Convert to OGG format: `ffmpeg -i input.wav -c:a libvorbis -q:a 6 output.ogg`
3. Place in this directory
4. Test with: `aplay output.ogg` or `paplay output.ogg`

## Volume Guidelines

Keep sounds subtle:
- Peak amplitude: -6 dB to -3 dB
- Average level: -12 dB to -9 dB
- No harsh frequencies or sudden spikes

## License

All sounds should be:
- Original creations, OR
- Public domain, OR
- Licensed under CC0, CC-BY, or compatible license

Include attribution in SOUNDS-LICENSE.txt if required.

## Control

Users can control sound themes via:
- System Settings → Appearance → System Sounds
- AetherOS Control Center → Audio → Sound Theme
- `aether-sounds.sh toggle` - Quick on/off toggle

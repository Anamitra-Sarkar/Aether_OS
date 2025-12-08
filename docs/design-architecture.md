# AetherOS v2.0 Design Architecture

## Overview

AetherOS v2.0 "Ultimate Edition" represents a major evolution in design philosophy, focusing on adaptive performance, intelligent automation, and premium aesthetics while maintaining excellent performance on 4GB RAM systems.

## Core Design Principles

### 1. Adaptive Performance First
Every visual feature has a performance-aware variant:
- **High-end systems**: Full effects, maximum quality
- **Mid-range systems**: Balanced effects, good quality
- **Low-end systems**: Minimal effects, maximum performance

### 2. Intelligence by Default
The system adapts automatically to:
- Hardware capabilities
- User context (gaming, presenting, working)
- System load and thermal state
- Time of day and usage patterns

### 3. One-Click Everything
Complex system operations should be:
- Single command
- Self-contained
- Reversible
- Well-documented

## Architecture Components

### Visual System

#### Adaptive Blur System
**Script**: `scripts/aether-adaptive-blur.sh`

Three blur modes based on GPU detection:

```
High Blur Mode (strong GPUs)
├── BlurStrength: 15
├── NoiseStrength: 2
└── Algorithm: GPU-accelerated

Frosted Lite (mid-range GPUs)
├── BlurStrength: 8
├── NoiseStrength: 0
└── Algorithm: Optimized

Off Mode (weak GPUs / CleanMode)
└── Disabled completely
```

**Detection logic**:
- RTX, RX 6000+, Intel Xe → High
- HD 4000-6000, older dedicated → Frosted
- Everything else → Frosted (safe default)

#### CleanMode
**Script**: `scripts/aether-cleanmode.sh`

One-toggle performance optimization:
- Disables all animations
- Removes blur effects
- Simplifies shadows
- Reduces compositor overhead

**Target hardware**: Intel HD 3000 and below, 4GB RAM systems, VMs

#### Theme System
**Location**: `configs/plasma/`

Two variants:
- `aether-light/`: Light theme with Aether Blue accent
- `aether-dark/`: Dark theme with deep space colors

Both support:
- Adaptive blur integration
- Smart shadow rendering
- Neon accent highlights (Blue-Mint)

### Performance Intelligence

#### Auto Performance Profiler
**Script**: `scripts/aether-performance-profiler.sh`

Hardware detection and profile selection:

```
Detection Flow:
1. Check RAM size
2. Detect CPU generation
3. Identify GPU tier
4. Select optimal profile

Profiles:
├── MaxMode (16GB+ RAM, high GPU)
├── Balanced (8-12GB RAM, mid GPU)
└── LiteMode (≤4GB RAM, integrated GPU)
```

**Profile actions**:
- MaxMode: Enable all effects, high animation speed
- Balanced: Moderate effects, normal animations
- LiteMode: Enable CleanMode, minimal animations

#### Smart Service Manager
**Script**: `scripts/aether-smart-services.sh`

Automatically manages services based on hardware:

| Service | Condition | Action |
|---------|-----------|--------|
| bluetooth | Hardware present | Enable |
| cups | Printer detected | Enable |
| avahi | Network services needed | Enable |
| baloo | Large doc collection | Enable |

**Benefits**:
- Reduced RAM usage (~50-150MB saved)
- Faster boot times
- Better battery life

#### ZRAM Configuration
**Script**: `opt/enable-zram.sh`

Adaptive swap compression:

```
RAM Size    ZRAM Ratio    Algorithm
≤4GB        33%           LZ4 (fastest)
4-6GB       50%           LZ4
≥8GB        75%           LZ4
```

**Why LZ4**: 
- Fastest compression/decompression
- Lower CPU overhead
- Better for real-time usage

### Intelligent Desktop Behavior

#### Focus Mode 2.0
**Script**: `scripts/aether-focus-mode.sh`

Enhanced Do Not Disturb with:

1. **Auto-activation on fullscreen**
   - Detects fullscreen apps
   - Automatically enables DND
   - Restores when exiting fullscreen

2. **Scheduled mode (Study Mode)**
   ```bash
   aether-focus-mode.sh schedule 09:00 17:00
   ```
   - Automatically enables during hours
   - Useful for work/study routines

3. **Manual toggle**
   - Quick on/off control
   - Status checking

#### Smart Notifications
**Script**: `scripts/aether-smart-notifications.sh`

Automatic notification muting during:

| Context | Detection Method |
|---------|------------------|
| Gaming | Steam, Lutris, Wine processes |
| Video watching | YouTube, Netflix, VLC in fullscreen |
| Presenting | Impress, PowerPoint, screen sharing |
| Meetings | Zoom, Teams, Meet, Webex |

**Monitoring**:
- 10-second poll interval
- Window title detection
- Process monitoring
- Fullscreen state checking

### User Comfort Features

#### QuickPal Launcher
**Script**: `scripts/aether-quickpal.sh`

Spotlight-style quick launcher:

```
Categories:
├── System Tools
│   ├── Control Center
│   ├── Performance Profiler
│   └── Smart Services
├── Performance Modes
│   ├── Focus Mode
│   ├── Smart Notifications
│   └── CleanMode
├── System Settings
│   ├── Display
│   ├── Network
│   └── Power
└── Applications
    ├── File Manager
    ├── Terminal
    └── System Monitor
```

**Implementation**:
- Uses kdialog (KDE) or zenity (fallback)
- Keyboard shortcut support
- Search functionality (future)

#### Profile Sync
**Script**: `scripts/aether-profile-sync.sh`

Save/restore system preferences:

```json
{
  "theme": "AetherDark",
  "performance_profile": "balanced",
  "blur_mode": "frosted",
  "cleanmode": false,
  "focus_auto_fullscreen": true,
  "smart_notifications": true,
  "animation_speed": 3,
  "timestamp": "2024-12-06T16:00:00Z",
  "version": "2.0"
}
```

**Backup system**:
- Automatic backup on save
- Timestamped files
- Multiple named profiles

## Visual Design Tokens

### Colors

#### Light Theme
```scss
$primary: #6C8CFF;      // Aether Blue
$secondary: #7AE7C7;    // Soft Mint
$background: #F6F8FA;   // Light gray
$surface: #FFFFFF;      // Pure white
```

#### Dark Theme
```scss
$primary: #6C8CFF;      // Aether Blue
$secondary: #7AE7C7;    // Soft Mint
$background: #0F1720;   // Deep space
$surface: #101317;      // Dark surface
```

### Typography
- **Primary font**: Inter
- **Fallback**: Noto Sans
- **Sizes**: 10-16pt (system UI)

### Spacing
- **Base unit**: 8px
- **Corner radius**: 10-12px
- **Padding**: 12-16px

### Motion
- **Curve**: `cubic-bezier(0.22, 1, 0.36, 1)` (smooth ease-out)
- **Durations**:
  - Base: 150ms
  - Modal: 220ms
  - Page transition: 300ms

## Performance Targets

### RAM Usage
| System RAM | Target Usage | With ZRAM |
|------------|--------------|-----------|
| 4GB        | ≤2.5GB       | +1.3GB swap |
| 8GB        | ≤4GB         | +4GB swap |
| 16GB       | ≤6GB         | +12GB swap |

### Boot Time
- **Target**: <30 seconds to desktop
- **With SSD**: <20 seconds
- **Live USB**: <60 seconds

### Animation Performance
- **Target FPS**: 60fps minimum
- **CleanMode**: Disabled for instant response
- **High mode**: GPU-accelerated effects

## Security Features (v2.1)

### AetherShield
**Script**: `scripts/aethershieldctl`

Per-app sandbox policy management:

```
Architecture:
├── Policy Manifests (JSON)
│   └── /etc/aetheros/security/apps/
├── CLI Tool (aethershieldctl)
│   ├── list - Show all managed apps
│   ├── show - View app policy
│   ├── apply - Apply policy restrictions
│   └── status - Check enforcement status
└── Backend Integration
    ├── AppArmor profiles
    ├── Flatpak permissions
    └── UFW firewall rules
```

**Policy Structure**:
```json
{
  "name": "firefox",
  "network": "allow",
  "camera": "deny",
  "microphone": "ask",
  "filesystem": "home"
}
```

**Phase 1 Status**:
- ✅ Policy awareness
- ✅ CLI tool
- ⚠️ Partial enforcement (AppArmor/Flatpak ready)
- 🔮 Full sandboxing (Phase 2)

### Secure Session Mode
**Script**: `scripts/aether-secure-session.sh`

Enhanced security toggle for sensitive tasks:

**When Active**:
- Strict firewall rules (UFW: deny all incoming)
- SSH server disabled
- Network services stopped (Avahi, Samba)
- USB automount disabled
- Visual notification indicator
- All changes reversible

**Use Cases**:
- Online banking
- Exam portals
- Confidential work
- Security-critical tasks

### Thermal Watch
**Script**: `scripts/aether-thermal-watch.sh`

Heat-aware visual intelligence:

```
Temperature States:
├── Cool (<60°C)
│   └── Full visual effects
├── Warm (60-75°C)
│   └── Reduced effects
└── Hot (>75°C)
    └── Performance mode (CleanMode)
```

**Safety Features**:
- Minimum 60s between changes (anti-thrashing)
- Respects user profile overrides
- Automatic restoration when cooling
- Comprehensive logging

**Systemd Integration**:
```bash
systemctl --user enable --now aether-thermal.service
```

### Audio Profiles (v2.1)
**Script**: `scripts/aether-audio-profile.sh`

Scenario-optimized audio presets:

| Profile | Bass | Volume | Latency | Microphone |
|---------|------|--------|---------|------------|
| Movie | Enhanced | Medium | Normal | Low boost |
| Gaming | Balanced | High | Low | Normal |
| Voice | Reduced | Medium | Normal | High boost |
| Balanced | Neutral | Medium | Normal | Normal |

**Implementation**: PulseAudio/PipeWire configuration

### Accessibility Enhancements (v2.1)
**Script**: `scripts/aether-accessibility.sh`

Inclusive design features:

**Reduced Motion Mode**:
- Disables all animations
- Removes blur effects
- Simplifies transitions
- Helpful for vestibular disorders

**High Contrast Mode**:
- Increases text readability
- Reduces transparency
- Better color contrast
- Low vision support

## Testing Strategy

### Manual Testing
1. **Performance testing** on real hardware
   - 4GB RAM laptop (critical)
   - 8GB RAM desktop (baseline)
   - 16GB+ workstation (premium)

2. **GPU compatibility**
   - Intel HD Graphics 3000-6000
   - NVIDIA GTX 900 series+
   - AMD RX 400 series+

3. **Feature validation**
   - Each script individually
   - Integration between scripts
   - Profile save/restore

### CI Testing
- ISO build validation
- Asset presence checks
- Script syntax validation (shellcheck)
- Security scanning (CodeQL)

**Note**: QEMU boot tests are optional due to resource constraints. Manual testing recommended for full validation.

## Completed in v2.1

1. ✅ **Thermal Watch**: Dynamic visual adjustment based on CPU temperature
2. ✅ **Audio Profiles**: Movie, Gaming, Voice, Balanced presets
3. ✅ **Holographic Login**: Animated SDDM logo with pulse effect
4. ✅ **Enhanced QuickPal**: Fuzzy search, app launching (with optional fzf)
5. ✅ **AetherShield**: Per-app security policies (Phase 1)
6. ✅ **Secure Session Mode**: Lockdown for sensitive tasks
7. ✅ **Accessibility**: Reduced Motion & High Contrast modes
8. ✅ **Calamares Slideshow**: Installation feature walkthrough
9. ✅ **Aether Ocean**: Custom sound pack

## Future Enhancements (v2.2+)

### Planned for v2.2
1. **Aether Dashboard**: Live system overview (CPU, RAM, GPU, thermal)
2. **AetherShield GUI**: Visual policy management
3. **Game Mode**: Performance optimization for gaming
4. **Creator Mode**: Optimized for content creation
5. **Dev/Minimal Presets**: Easy setup profiles
6. **Website Enhancement**: Download page and upload docs

### Under Consideration (v2.3+)
1. **AI-assisted optimization**: Learn user patterns
2. **Network-aware features**: Adjust based on bandwidth
3. **Multi-monitor optimization**: Per-display settings
4. **Battery mode enhancements**: Even more aggressive power saving
5. **ARM64 full support**: Complete testing and optimization

## Contributing

When contributing to the design:

1. **Performance first**: Every feature must work on 4GB RAM
2. **Adaptive approach**: Provide high/mid/low variants
3. **One-click access**: Complex features need simple toggles
4. **Document everything**: Architecture, usage, edge cases

## References

- [AetherOS README](../README.md)
- [Theming Guide](theming-guide.md)
- [Development Guide](dev-guide.md)
- [Design Tokens](design_tokens.md)

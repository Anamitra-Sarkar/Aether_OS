# AetherOS Keyboard Shortcuts

Quick reference for AetherOS keyboard shortcuts and gestures.

## Window Management

### Window Tiling (Windows 11-style)

| Shortcut | Action |
|----------|--------|
| `Meta + Left` | Tile window to left half |
| `Meta + Right` | Tile window to right half |
| `Meta + Up` | Maximize window |
| `Meta + Down` | Minimize window |
| `Meta + Ctrl + Left` | Tile to top-left quarter |
| `Meta + Ctrl + Right` | Tile to top-right quarter |
| `Meta + Ctrl + Shift + Left` | Tile to bottom-left quarter |
| `Meta + Ctrl + Shift + Right` | Tile to bottom-right quarter |

### Window Actions

| Shortcut | Action |
|----------|--------|
| `Alt + F4` | Close window |
| `Meta + Shift + F` | Toggle fullscreen |
| `Meta + M` | Move window (use arrow keys) |
| `Meta + R` | Resize window (use arrow keys) |

## Workspaces & Overview

### Workspace Navigation

| Shortcut | Action |
|----------|--------|
| `Ctrl + Alt + Left` | Previous desktop |
| `Ctrl + Alt + Right` | Next desktop |
| `Meta + 1` | Switch to Desktop 1 |
| `Meta + 2` | Switch to Desktop 2 |
| `Meta + 3` | Switch to Desktop 3 |
| `Meta + 4` | Switch to Desktop 4 |

### Move Window to Desktop

| Shortcut | Action |
|----------|--------|
| `Meta + Shift + 1` | Move window to Desktop 1 |
| `Meta + Shift + 2` | Move window to Desktop 2 |
| `Meta + Shift + 3` | Move window to Desktop 3 |
| `Meta + Shift + 4` | Move window to Desktop 4 |

### Overview & Switching

| Shortcut | Action |
|----------|--------|
| `Meta + Tab` | Overview (show all windows) |
| `Meta + W` | Expose all windows |
| `Alt + Tab` | Switch windows |
| `Alt + Shift + Tab` | Switch windows (reverse) |
| `Meta + D` | Show desktop |

## System

### Session

| Shortcut | Action |
|----------|--------|
| `Meta` | Open application launcher |
| `Meta + L` | Lock screen |
| `Meta + Shift + Q` | Log out |
| `Meta + V` | Clipboard manager |

### Screenshots

| Shortcut | Action |
|----------|--------|
| `Print` | Full screen screenshot |
| `Meta + Print` | Active window screenshot |
| `Meta + Shift + Print` | Region screenshot |

## Touchpad Gestures (Wayland)

AetherOS supports touchpad gestures on Wayland:

| Gesture | Action |
|---------|--------|
| 3-finger swipe up | Overview / Mission Control |
| 3-finger swipe down | Show desktop |
| 3-finger swipe left/right | Switch workspace |
| 4-finger swipe up | Desktop grid |
| Pinch in | Zoom out |
| Pinch out | Zoom in |

**Note**: Gestures require a compatible touchpad and Wayland session.

## Window Snapping with Mouse

You can also snap windows by dragging them:

- **Drag to edge**: Tile to half screen
- **Drag to corner**: Tile to quarter screen
- **Double-click titlebar**: Maximize/restore
- **Drag maximized window**: Un-maximize and move

## Customization

To customize shortcuts:

1. Open **System Settings**
2. Navigate to **Shortcuts**
3. Find and modify any shortcut

Or edit `~/.config/kglobalshortcutsrc` directly.

---

*AetherOS v0.2 - Designed for both keyboard-first power users and trackpad-friendly casual users.*

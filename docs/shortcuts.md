# AetherOS Keyboard Shortcuts

Quick reference for keyboard shortcuts and touchpad gestures in AetherOS.

> **Note**: `Meta` key = Windows key / Command key / Super key

---

## Window Management

### Window Tiling (Windows 11-style)

Snap windows to different parts of the screen for efficient multitasking.

| Shortcut | Action |
|----------|--------|
| `Meta + Left` | Tile window to left half |
| `Meta + Right` | Tile window to right half |
| `Meta + Up` | Maximize window |
| `Meta + Down` | Minimize window |

### Quarter Tiling

For advanced window layouts, tile windows to screen quarters.

| Shortcut | Action |
|----------|--------|
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

**Mouse Shortcuts:**
- **Drag to edge**: Tile to half screen
- **Drag to corner**: Tile to quarter screen
- **Double-click titlebar**: Maximize/restore
- **Drag maximized window**: Un-maximize and move

---

## Workspaces & Overview

### Workspace Navigation

Switch between virtual desktops for better organization.

| Shortcut | Action |
|----------|--------|
| `Ctrl + Alt + Left` | Previous desktop |
| `Ctrl + Alt + Right` | Next desktop |
| `Meta + 1` | Switch to Desktop 1 |
| `Meta + 2` | Switch to Desktop 2 |
| `Meta + 3` | Switch to Desktop 3 |
| `Meta + 4` | Switch to Desktop 4 |

### Move Windows Between Desktops

| Shortcut | Action |
|----------|--------|
| `Meta + Shift + 1` | Move window to Desktop 1 |
| `Meta + Shift + 2` | Move window to Desktop 2 |
| `Meta + Shift + 3` | Move window to Desktop 3 |
| `Meta + Shift + 4` | Move window to Desktop 4 |

### Overview & Window Switching

| Shortcut | Action |
|----------|--------|
| `Meta + Tab` | Overview (show all windows) |
| `Meta + W` | Expose all windows on current desktop |
| `Alt + Tab` | Switch between windows |
| `Alt + Shift + Tab` | Switch windows (reverse order) |
| `Meta + D` | Show desktop (minimize all windows) |

---

## Screenshots

Capture your screen with these shortcuts.

| Shortcut | Action |
|----------|--------|
| `Print` | Screenshot (full screen) |
| `Meta + Print` | Screenshot (active window) |
| `Meta + Shift + Print` | Screenshot (region/area selection) |

**Screenshots are saved to:** `~/Pictures/Screenshots/`

---

## System & Launcher

### Application & System Controls

| Shortcut | Action |
|----------|--------|
| `Meta` | Open application launcher |
| `Meta + E` | Open file manager (Dolphin) |
| `Ctrl + Alt + T` | Open terminal (Konsole) |
| `Meta + L` | Lock screen |
| `Meta + Shift + Q` | Log out |
| `Meta + V` | Open clipboard manager |

### Control Center

Launch the Aether Control Center from:
- Application launcher (search "Control Center")
- Dock or taskbar
- Or via terminal: `aether-control-center`

---

## Touchpad Gestures (Wayland)

AetherOS supports modern touchpad gestures on Wayland sessions for a macOS-like experience.

| Gesture | Action |
|---------|--------|
| **3-finger swipe up** | Overview / Mission Control |
| **3-finger swipe down** | Show desktop |
| **3-finger swipe left** | Switch to previous workspace |
| **3-finger swipe right** | Switch to next workspace |
| **4-finger swipe up** | Desktop grid view |
| **Pinch in** | Zoom out |
| **Pinch out** | Zoom in |

**Requirements:**
- Compatible touchpad
- Wayland session (default in AetherOS)
- Gestures may need to be enabled in System Settings → Input Devices → Touchpad

**Note:** X11 session has limited gesture support. Switch to Wayland for full gesture functionality.

---

## Customization

### How to Customize Shortcuts

**Method 1: System Settings (GUI)**
1. Open **System Settings** (`Meta`, search "System Settings")
2. Navigate to **Shortcuts** section
3. Find the action you want to customize
4. Click on the current shortcut and press your desired key combination
5. Click **Apply**

**Method 2: Edit Configuration File**

Advanced users can edit the shortcuts configuration directly:
```bash
nano ~/.config/kglobalshortcutsrc
```

**Note:** Changes may require logging out and back in to take effect.

---

## Quick Reference Card

### Most Used Shortcuts

| Category | Shortcut | Action |
|----------|----------|--------|
| **Launcher** | `Meta` | Application launcher |
| **File Manager** | `Meta + E` | Open Dolphin |
| **Terminal** | `Ctrl + Alt + T` | Open Konsole |
| **Window Snap** | `Meta + Left/Right` | Tile window to half |
| **Maximize** | `Meta + Up` | Maximize window |
| **Workspaces** | `Ctrl + Alt + Left/Right` | Switch desktops |
| **Overview** | `Meta + Tab` | Show all windows |
| **Screenshot** | `Print` | Full screen capture |
| **Lock** | `Meta + L` | Lock screen |
| **Close** | `Alt + F4` | Close window |

---

## Tips for Keyboard-First Workflow

1. **Learn workspace shortcuts** - Keep different projects on different desktops
2. **Use window tiling** - Organize side-by-side without dragging
3. **Master Alt+Tab** - Quickly switch between recent applications
4. **Lock with Meta+L** - Quick security when stepping away
5. **Use Meta+E for files** - Faster than clicking through menus

---

**AetherOS v1.0** - Designed for keyboard power users and trackpad enthusiasts alike.

For more help, see [Troubleshooting Guide](troubleshooting.md) or visit our [GitHub repository](https://github.com/Anamitra-Sarkar/Aether_OS).


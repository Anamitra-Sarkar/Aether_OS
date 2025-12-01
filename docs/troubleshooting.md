# AetherOS Troubleshooting Guide

This guide helps you resolve common issues with AetherOS.

---

## Table of Contents

- [Display & Graphics Issues](#display--graphics-issues)
- [Desktop Environment Issues](#desktop-environment-issues)
- [Login Issues](#login-issues)
- [Performance Issues](#performance-issues)
- [Network Issues](#network-issues)
- [Getting Help](#getting-help)

---

## Display & Graphics Issues

### Boot with nomodeset (GPU Driver Issues)

If you experience black screen, display corruption, or boot failures due to GPU issues:

1. **During boot**, when the GRUB menu appears, press `E` to edit boot parameters
2. Find the line starting with `linux` (usually contains `/boot/vmlinuz`)
3. Add `nomodeset` to the end of that line:
   ```
   linux /boot/vmlinuz-... root=... ro quiet splash nomodeset
   ```
4. Press `Ctrl+X` or `F10` to boot with these parameters

**To make it permanent:**

```bash
sudo nano /etc/default/grub
```

Find the line:
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
```

Change it to:
```
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash nomodeset"
```

Update GRUB:
```bash
sudo update-grub
```

### Switch to X11 from Wayland

If you experience issues with Wayland (screen sharing, some apps not working):

1. **At login screen (SDDM)**, click your username
2. Click the **session icon** (usually bottom-left corner)
3. Select **"Plasma (X11)"** instead of "Plasma (Wayland)"
4. Enter your password and log in

**To make X11 the default:**

```bash
# Edit SDDM configuration
sudo nano /etc/sddm.conf.d/plasma-wayland.conf
```

Change:
```ini
[General]
DisplayServer=wayland
```

To:
```ini
[General]
DisplayServer=x11
```

Or remove the file entirely to use system default (X11):
```bash
sudo rm /etc/sddm.conf.d/plasma-wayland.conf
```

### Adjust Display Resolution or Scaling

If text is too small or too large:

1. Open **System Settings** (`Meta` key, search "System Settings")
2. Go to **Display and Monitor** → **Display Configuration**
3. Adjust **Scale** (100%, 125%, 150%, 200%)
4. Click **Apply**

---

## Desktop Environment Issues

### Restart Plasma Desktop

If the desktop becomes unresponsive or panels disappear:

**Method 1: Using keyboard**
```bash
# Press Ctrl+Alt+F2 to switch to TTY
# Log in with your username and password
killall plasmashell
DISPLAY=:0 plasmashell &
# Press Ctrl+Alt+F1 to return to desktop
```

**Method 2: Using Konsole**
```bash
killall plasmashell && plasmashell &
```

### Reset Plasma Settings to Defaults

If your desktop is broken or heavily misconfigured:

**⚠️ Warning:** This will reset all your Plasma customizations!

```bash
# Backup your current config
mkdir -p ~/plasma-backup
cp -r ~/.config/plasma* ~/plasma-backup/
cp -r ~/.local/share/plasma* ~/plasma-backup/

# Remove Plasma configuration
rm -rf ~/.config/plasma*
rm -rf ~/.local/share/plasma*

# Restart Plasma
killall plasmashell && plasmashell &
```

### Panels or Widgets Missing

1. **Right-click** on the desktop → **Add Panel** → Choose your panel type
2. **Right-click** on panel → **Add Widgets** → Add back widgets you need
3. Common widgets:
   - Application Launcher
   - Task Manager
   - System Tray
   - Digital Clock

---

## Login Issues

### Restart SDDM (Login Manager)

If the login screen is frozen or not working:

**Method 1: From desktop (if you can access it)**
```bash
sudo systemctl restart sddm
```

**Method 2: From TTY (if login screen is completely broken)**
1. Press `Ctrl+Alt+F2` to switch to text mode
2. Log in with your username and password
3. Run:
   ```bash
   sudo systemctl restart sddm
   ```
4. Press `Ctrl+Alt+F1` to return to login screen

### Cannot Log In (Wrong Password or User Issues)

**Reset password from TTY:**
1. Press `Ctrl+Alt+F2`
2. Log in as your user (if you can) or use recovery mode
3. Reset password:
   ```bash
   sudo passwd YOUR_USERNAME
   ```
4. Return to login: `Ctrl+Alt+F1`

**Fix home directory permissions:**
```bash
sudo chown -R YOUR_USERNAME:YOUR_USERNAME /home/YOUR_USERNAME
```

---

## Performance Issues

### System Running Slow

**1. Check ZRAM status:**
```bash
sudo swapon --show
```

**2. Check system resources:**
```bash
htop  # or top
```

**3. Restart performance services:**
```bash
sudo systemctl restart zram-config
```

**4. Clear package cache:**
```bash
sudo apt clean
sudo apt autoclean
sudo apt autoremove
```

**5. Disable unneeded startup applications:**
1. Open **System Settings** → **Autostart**
2. Disable applications you don't need at startup

### High CPU Usage

**Check what's using CPU:**
```bash
htop
# Press F6, sort by CPU%
```

**Restart problematic service:**
```bash
systemctl --user restart SERVICE_NAME
```

---

## Network Issues

### Wi-Fi Not Working

**1. Check NetworkManager status:**
```bash
sudo systemctl status NetworkManager
```

**2. Restart NetworkManager:**
```bash
sudo systemctl restart NetworkManager
```

**3. Check if Wi-Fi is blocked:**
```bash
rfkill list
```

**4. Unblock Wi-Fi if blocked:**
```bash
sudo rfkill unblock wifi
```

### Bluetooth Not Working

**1. Check Bluetooth status:**
```bash
sudo systemctl status bluetooth
```

**2. Restart Bluetooth:**
```bash
sudo systemctl restart bluetooth
```

**3. Enable Bluetooth:**
```bash
bluetoothctl
# In bluetoothctl:
power on
agent on
default-agent
```

---

## Getting Help

### Run System Health Check

AetherOS includes a health check tool:

```bash
sudo /opt/aetheros/aether-health.sh
```

This will check:
- System services
- Disk space
- Memory usage
- Configuration files

### Collect System Information

When asking for help, include this information:

```bash
# OS version
cat /etc/os-release

# Kernel version
uname -a

# Desktop environment version
plasmashell --version

# Graphics info
lspci | grep -i vga
lspci | grep -i nvidia

# System logs (last 50 lines)
journalctl -b -n 50
```

### Check Logs

**View system logs:**
```bash
journalctl -b  # Current boot logs
journalctl -b -1  # Previous boot logs
journalctl -xe  # Recent errors
```

**View Plasma logs:**
```bash
cat ~/.xsession-errors
```

**View SDDM logs:**
```bash
sudo journalctl -u sddm
```

### Community Support

- **GitHub Issues**: [https://github.com/Anamitra-Sarkar/Aether_OS/issues](https://github.com/Anamitra-Sarkar/Aether_OS/issues)
- **Documentation**: [https://github.com/Anamitra-Sarkar/Aether_OS/tree/main/docs](https://github.com/Anamitra-Sarkar/Aether_OS/tree/main/docs)

### Emergency Boot Options

If AetherOS won't boot:

1. **Boot to recovery mode:**
   - In GRUB menu, select "Advanced options"
   - Choose recovery mode
   
2. **Boot from live USB:**
   - Boot from AetherOS installation media
   - Choose "Try AetherOS" instead of "Install"
   - Mount your installed system and fix issues

3. **Check disk integrity:**
   ```bash
   # First, identify your partition
   lsblk  # or use: sudo fdisk -l
   
   # Then check the filesystem
   sudo fsck /dev/sdXY  # Replace XY with your partition (e.g., sda1, nvme0n1p1)
   ```

---

## Common Command Reference

| Task | Command |
|------|---------|
| Restart desktop | `killall plasmashell && plasmashell &` |
| Restart login manager | `sudo systemctl restart sddm` |
| Restart NetworkManager | `sudo systemctl restart NetworkManager` |
| Check system logs | `journalctl -xe` |
| Update system | `sudo apt update && sudo apt upgrade` |
| Clean package cache | `sudo apt clean && sudo apt autoremove` |
| Check disk space | `df -h` |
| Check memory usage | `free -h` |
| List running services | `systemctl list-units --type=service --state=running` |

---

**AetherOS v1.0** - For more help, visit our [GitHub repository](https://github.com/Anamitra-Sarkar/Aether_OS).

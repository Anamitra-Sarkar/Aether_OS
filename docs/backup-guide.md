# AetherOS Backup Guide

This guide covers the backup and restore options available in AetherOS.

## Overview

AetherOS provides two complementary backup solutions:

| Tool | Purpose | What it backs up |
|------|---------|------------------|
| **Timeshift** | System snapshots | Root filesystem, system files, apps |
| **AetherVault** | User data backup | Home directory, documents, settings |

**Recommendation**: Use both for complete protection.

## Timeshift - System Snapshots

Timeshift creates snapshots of your system that let you roll back if something goes wrong (bad update, broken config, etc.).

### Opening Timeshift

1. Open **Control Center** → **Maintenance** → **System Snapshots**
2. Or run: `sudo timeshift-gtk`

### Default Configuration

AetherOS pre-configures Timeshift with sensible defaults:

- **Mode**: RSYNC (works on all filesystems)
- **Schedule**: Weekly snapshots
- **Retention**: Keep 3 weekly snapshots

### Creating a Snapshot

1. Open Timeshift
2. Click **Create**
3. Wait for the snapshot to complete
4. Add a comment describing the snapshot

### Restoring from a Snapshot

1. Open Timeshift
2. Select a snapshot from the list
3. Click **Restore**
4. Follow the prompts
5. Reboot when complete

### Tips

- Create a snapshot before major updates
- Create a snapshot before installing new software
- Use comments to remember why you made each snapshot

## AetherVault - User Data Backup

AetherVault backs up your home directory to an external drive or network location.

### Quick Start

```bash
# Backup to external drive
aethervault.sh backup /mnt/external

# Preview what would be backed up (dry run)
aethervault.sh dry-run /mnt/external

# List existing backups
aethervault.sh list /mnt/external
```

### What Gets Backed Up

✅ **Included:**
- Documents, Pictures, Music, Videos
- Desktop files
- Configuration files (.config/)
- Application data
- SSH keys and GPG keys
- Browser bookmarks and profiles

❌ **Excluded (by default):**
- Cache directories
- Trash
- Package manager caches (npm, cargo, etc.)
- Steam games
- Temporary files
- Download folder ISOs

### Using AetherVault

#### First Backup

1. Connect an external drive
2. Find the mount point (usually `/run/media/USERNAME/DRIVE_NAME`)
3. Run: `aethervault.sh backup /run/media/USERNAME/DRIVE_NAME`
4. Wait for the backup to complete

#### Subsequent Backups

AetherVault uses rsync with `--delete`, so subsequent backups are:
- **Fast**: Only changed files are copied
- **Complete**: Deleted files are removed from backup
- **Reliable**: Uses checksums to verify data

#### Customizing Exclusions

To exclude additional files/folders:

```bash
# View current exclusions
aethervault.sh excludes

# Edit exclusions
nano ~/.local/share/aetheros/logs/aethervault-exclude.txt
```

Add patterns like:
```
MyLargeGameFolder
*.log
secret-project
```

### Restoring from AetherVault

**Warning**: Restoring will overwrite existing files!

```bash
# Preview restore (dry run)
rsync -avh --dry-run /mnt/external/aethervault-USERNAME/ $HOME/

# Restore to home (be careful!)
rsync -avh /mnt/external/aethervault-USERNAME/ $HOME/

# Restore to different location (safer)
rsync -avh /mnt/external/aethervault-USERNAME/ ~/restored-backup/
```

## Comparison: Timeshift vs AetherVault

| Feature | Timeshift | AetherVault |
|---------|-----------|-------------|
| Backs up system | ✅ | ❌ |
| Backs up home | ❌ (by default) | ✅ |
| External drives | Possible | Designed for |
| Encryption | No | Use encrypted drive |
| Incremental | ✅ (rsync mode) | ✅ |
| Easy rollback | ✅ | Manual |

## Best Practices

### Daily/Weekly Routine

1. **Weekly**: Let Timeshift create automatic snapshots
2. **Before updates**: Create a manual Timeshift snapshot
3. **Weekly/Monthly**: Run AetherVault to external drive

### Backup Strategy

```
[System Changes] → Timeshift snapshot
[Personal Data]  → AetherVault to external drive
[Critical Data]  → Also use cloud backup (Nextcloud, etc.)
```

### External Drive Recommendations

- Use a dedicated backup drive
- Consider encryption (LUKS) for sensitive data
- Label your drives clearly
- Store offsite periodically for disaster recovery

## Troubleshooting

### Timeshift: "No space left"

- Reduce the number of retained snapshots
- Use a larger partition for snapshots
- Exclude unnecessary directories

### AetherVault: Backup takes too long

- Exclude large directories (games, downloads)
- Check for unnecessary files in home
- Use `dry-run` to preview what's being backed up

### AetherVault: "Permission denied"

- Check drive is mounted with write permissions
- For NTFS drives: `sudo mount -o rw,uid=$(id -u) /dev/sdX1 /mnt/external`

## Related Tools

- **Discover** → Updates (for keeping system updated)
- **Control Center** → Maintenance (quick access to tools)
- **KDE Plasma Vault** (for encrypted folders)

## Getting Help

- AetherVault log: `~/.local/share/aetheros/logs/aethervault.log`
- Timeshift log: `/var/log/timeshift/`
- Report issues: https://github.com/aetheros/issues

---

*AetherOS v0.2 - Keep your data safe with regular backups!*

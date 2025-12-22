# AetherShield App Policy Manifests

This directory contains security policy manifests for applications managed by AetherShield's Strict Enforcement Engine.

## Manifest Format

Each application has a JSON manifest file with the following structure:

```json
{
  "name": "Application Name",
  "id": "app-identifier",
  "executable": "/path/to/executable",
  "network": true/false,
  "camera": true/false,
  "microphone": true/false,
  "filesystem": "home" | "limited" | "read-only",
  "ipc": "allowed" | "restricted",
  "apparmor_profile": "/etc/apparmor.d/aethershield/app-id",
  "flatpak_app_id": "org.example.App",
  "description": "Brief description",
  "permissions": {
    "network": {
      "enabled": true,
      "description": "Explanation"
    },
    ...
  }
}
```

## Permission Levels

### Network
- `true`: Application can access network
- `false`: Network access blocked (strict mode: DENIED)

### Camera / Microphone
- `true`: Access to camera/microphone allowed
- `false`: Access denied (strict mode: DENIED)

### Filesystem
- `home`: Full access to user's home directory
- `limited`: Access only to specific paths (e.g., Downloads, app config)
- `read-only`: Read-only access to home directory

### IPC (Inter-Process Communication)
- `allowed`: D-Bus and IPC access permitted
- `restricted`: D-Bus and IPC access denied

## Strict Enforcement Mode

When strict enforcement is enabled (`aethershieldctl enable`):

1. **Default Behavior**: DENY unless explicitly allowed
2. **AppArmor Integration**: Dynamic profile generation and loading
3. **Flatpak Synchronization**: Permissions synced with AetherShield policies
4. **Conflict Resolution**: AetherShield > Flatpak defaults (deterministic)

## Usage

Use `aethershieldctl` to manage app policies:

```bash
# Enable strict enforcement mode
aethershieldctl enable

# Enforce a specific app's policy
aethershieldctl enforce firefox

# Enforce all policies
aethershieldctl enforce-all

# List all managed apps
aethershieldctl list

# Show policy for an app
aethershieldctl show firefox

# Check enforcement status
aethershieldctl status firefox

# Generate AppArmor profile
aethershieldctl generate-profile firefox

# Sync Flatpak permissions
aethershieldctl sync-flatpak firefox

# Disable enforcement
aethershieldctl disable
```

## Adding New Apps

1. Create a new JSON manifest file: `appname.json`
2. Define all required fields including `executable` path
3. Test with: `aethershieldctl show appname`
4. Enable enforcement: `aethershieldctl enable`
5. Apply with: `aethershieldctl enforce appname`

## AppArmor Profiles

Generated profiles are stored in:
- `/etc/apparmor.d/aethershield/`

Profiles are:
- Namespaced per application (`aethershield.app-id`)
- Reloadable without reboot
- Generated dynamically from policy manifests

## Requirements

- `jq` for policy parsing
- `apparmor` for kernel-level enforcement
- `flatpak` for container-level enforcement
- Root privileges for AppArmor profile loading

# AetherShield App Policy Manifests

This directory contains security policy manifests for applications managed by AetherShield.

## Manifest Format

Each application has a JSON manifest file with the following structure:

```json
{
  "name": "Application Name",
  "id": "app-identifier",
  "network": true/false,
  "camera": true/false,
  "microphone": true/false,
  "filesystem": "home" | "limited" | "read-only",
  "apparmor_profile": "/path/to/apparmor/profile",
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
- `false`: Network access blocked

### Camera / Microphone
- `true`: Access to camera/microphone allowed
- `false`: Access denied (default for privacy)

### Filesystem
- `home`: Full access to user's home directory
- `limited`: Access only to specific paths (e.g., Downloads)
- `read-only`: Read-only access to home directory

## Integration

AetherShield uses these manifests to:
1. Configure AppArmor profiles (where available)
2. Set Flatpak permissions (for Flatpak apps)
3. Apply firejail sandboxing (where appropriate)

## Usage

Use `aethershieldctl` to manage app policies:

```bash
# List all managed apps
aethershieldctl list

# Show policy for an app
aethershieldctl show firefox

# Apply policy
aethershieldctl apply firefox

# Check status
aethershieldctl status firefox
```

## Adding New Apps

1. Create a new JSON manifest file: `appname.json`
2. Define all required fields
3. Test with: `aethershieldctl show appname`
4. Apply with: `aethershieldctl apply appname`

## Notes

- Policies are opt-in by default
- No app is broken by default enforcement
- Phase 1 focuses on policy description + partial enforcement
- Full automatic sandboxing will come in future phases

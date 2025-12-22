# AetherOS Intelligence Systems Documentation

## Version 2.3 - Intelligence Systems Release

This release introduces four tightly integrated subsystems that provide AetherOS with self-awareness capabilities for security, boot behavior, CPU performance, and desktop stability.

---

## 1. Threat Surface Scanner (`aether-threat-scan`)

### Purpose
Fast, offline, deterministic assessment of system security exposure without performing penetration testing or network activity.

### Usage

```bash
# Run basic scan
aether-threat-scan

# Output as JSON
aether-threat-scan --json

# Save JSON report
aether-threat-scan --json > security-report.json
```

### Features
- **Open & Listening Services**: Detects services exposed on non-loopback interfaces
- **SUID/SGID Binaries**: Identifies non-standard privileged binaries
- **Filesystem Permissions**: Checks for world-writable system files
- **Configuration Weaknesses**: Detects insecure systemd units, SSH configs, Docker sockets

### Output
- Overall risk rating (Low/Medium/High)
- Categorized findings with explanations
- Exact remediation commands for each issue
- JSON format support for automation

### Performance
- Completes in under 5 seconds on SSD systems
- No internet access required
- No CVE databases needed
- Passive inspection only

### Exit Codes
- `0`: No critical issues (Low risk)
- `1`: Medium risk findings present
- `2`: High risk findings present

---

## 2. Boot Time Intelligence Engine (`aether-boot-optimize`)

### Purpose
Learn from boot behavior and intelligently optimize startup time without compromising system stability.

### Usage

```bash
# Check current status
aether-boot-optimize status

# Profile boot metrics
aether-boot-optimize profile

# Analyze optimization opportunities
aether-boot-optimize analyze

# Preview changes (dry run)
aether-boot-optimize optimize --dry-run

# Apply optimizations (requires sudo)
sudo aether-boot-optimize optimize

# Generate detailed report
aether-boot-optimize report

# Rollback changes (requires sudo)
sudo aether-boot-optimize rollback
```

### Features
- **Boot Profiling**: Collects systemd-analyze metrics
- **Intelligent Optimization**: Identifies and disables slow, non-essential services
- **Safety Guarantees**: Never modifies boot-critical services
- **Full Transparency**: Generates detailed reports with rollback instructions
- **Reversibility**: One-command rollback of all changes

### Protected Services (Never Modified)
- Display managers (SDDM, GDM, LightDM)
- Network stack (NetworkManager)
- Desktop essentials (D-Bus, polkit, logind)
- Audio stack (PulseAudio, PipeWire)
- Input devices
- Security services

### Workflow
1. Profile boot metrics (automatic on first run)
2. Analyze to identify opportunities
3. Use dry-run to preview changes
4. Apply optimizations with sudo
5. Reboot to measure improvements
6. Generate report to document changes

---

## 3. Dynamic CPU Governor Controller (`aether-cpu-governor`)

### Purpose
Ensure CPU performance scales predictably and intelligently based on real-time context using rule-based logic.

### Usage

```bash
# Check current status and context
aether-cpu-governor status

# Auto-select optimal governor (requires sudo)
sudo aether-cpu-governor auto

# Manually set governor (requires sudo)
sudo aether-cpu-governor set performance
sudo aether-cpu-governor set powersave
sudo aether-cpu-governor set schedutil

# List available governors
aether-cpu-governor list
```

### Features
- **Context Detection**: Battery state, thermal state, foreground app category, CPU load
- **Rule-Based Selection**: Deterministic governor mapping (no ML)
- **Manual Override**: Lock to specific governor until cleared
- **Cross-Platform**: Supports Intel, AMD, and ARM CPUs (where cpufreq is available)

### Governor Selection Rules

| Condition | Governor | Reason |
|-----------|----------|--------|
| High temperature (>85°C) | `powersave` | Thermal protection |
| Gaming/high load on AC | `performance` | Maximum performance |
| Gaming/high load on battery | `schedutil`/`ondemand` | Balanced performance |
| Idle on battery | `powersave` | Power saving |
| Battery with activity | `schedutil` | Efficient scaling |
| AC normal usage | `schedutil` | Dynamic scaling |

### Manual Override
```bash
# Lock to performance mode
sudo aether-cpu-governor set performance

# Return to automatic mode
sudo aether-cpu-governor auto
```

Override persists until manually cleared with `auto` command.

---

## 4. Wayland Crash Containment & Desktop Recovery (`aether-desktop-recovery`)

### Purpose
Detect and recover from compositor/shell crashes without session loss or forcing user logout.

### Usage

```bash
# Check current status
aether-desktop-recovery status

# View recovery logs
aether-desktop-recovery log

# Manually restart shell
aether-desktop-recovery restart-shell

# Manually restart compositor
aether-desktop-recovery restart-compositor

# Reset crash history and re-enable Wayland
aether-desktop-recovery reset

# Run in monitor mode (systemd service)
aether-desktop-recovery monitor
```

### Features
- **Automatic Crash Detection**: Monitors compositor and desktop shell processes
- **Intelligent Restart**: Auto-restarts with rate limiting (max 3 crashes/hour)
- **Fallback to X11**: Switches to X11 after repeated failures
- **Application Preservation**: Never kills user applications
- **Single Notification**: One notification per incident (no spam)

### Systemd Service
The desktop recovery monitor runs as a user systemd service:

```bash
# Enable the service (done automatically during installation)
systemctl --user enable aether-desktop-recovery.service

# Start the service
systemctl --user start aether-desktop-recovery.service

# Check service status
systemctl --user status aether-desktop-recovery.service
```

### Recovery Behavior
1. Detects compositor/shell crash
2. Records crash timestamp
3. Checks crash count in last hour
4. If under threshold: Attempts automatic restart
5. If over threshold: Initiates X11 fallback
6. Sends single notification per incident
7. Logs all actions

### Crash Threshold
- Maximum 3 crashes per hour
- Fallback to X11 if threshold exceeded
- Reset history with `aether-desktop-recovery reset`

### Hard Constraints (Enforced)
- ✅ Never restarts display manager automatically
- ✅ Never kills user applications
- ✅ Never creates login loops
- ✅ All actions logged

---

## Integration

### Installation
All tools are automatically installed during AetherOS build:
- Scripts: `/usr/share/aetheros/scripts/`
- Systemd services: `/etc/systemd/user/` (for user services)
- No additional configuration required

### CLI Naming Conventions
All tools follow the `aether-*` naming pattern:
- `aether-threat-scan`
- `aether-boot-optimize`
- `aether-cpu-governor`
- `aether-desktop-recovery`

### Logging
All tools use consistent logging:
- Location: `~/.local/share/aetheros/<tool-name>/`
- Format: ISO 8601 timestamps
- Level: INFO, WARN, ERROR, SUCCESS

### Testing
All tools are verified by the CLI tools test suite:
```bash
cd tests
./check-cli-tools.sh
```

---

## Design Principles

### 1. Offline First
- No internet access required
- No cloud dependencies
- No external APIs

### 2. Deterministic Behavior
- Rule-based logic (no ML/AI)
- Predictable outputs
- Reproducible results

### 3. Safety & Reversibility
- All changes are reversible
- Boot-critical services protected
- Dry-run modes available
- Backup before modification

### 4. Transparency
- Detailed explanations for all actions
- Clear remediation steps
- Comprehensive logging
- User-visible reports

### 5. Minimal Privilege
- Read-only operations don't require root
- Clear indication when sudo needed
- No background telemetry

---

## Common Workflows

### Security Audit Workflow
```bash
# Run security scan
aether-threat-scan

# Generate JSON report for automation
aether-threat-scan --json > ~/security-audit.json

# Review and remediate high-risk findings
# (Follow remediation commands from output)
```

### Boot Optimization Workflow
```bash
# Check current boot time
aether-boot-optimize status

# Analyze opportunities
aether-boot-optimize analyze

# Preview changes
aether-boot-optimize optimize --dry-run

# Apply optimizations
sudo aether-boot-optimize optimize

# Reboot and check improvements
sudo reboot

# After reboot, generate report
aether-boot-optimize report
```

### CPU Governor Automation
```bash
# Check current state
aether-cpu-governor status

# Enable automatic selection (set up once)
sudo aether-cpu-governor auto

# For gaming sessions, manually override
sudo aether-cpu-governor set performance

# Return to automatic mode after gaming
sudo aether-cpu-governor auto
```

### Desktop Recovery Setup
```bash
# Enable automatic monitoring (done during installation)
systemctl --user enable aether-desktop-recovery.service
systemctl --user start aether-desktop-recovery.service

# Monitor status
aether-desktop-recovery status

# If Wayland was disabled after crashes, reset when ready
aether-desktop-recovery reset
```

---

## Troubleshooting

### Threat Scanner shows no findings
This is expected on a well-configured system. The scanner looks for common misconfigurations and exposures.

### Boot optimizer finds no targets
Your system is already well-optimized. This typically means few slow services are running.

### CPU governor shows "unknown"
Your system may not support cpufreq (common in VMs). The tool will still work on physical hardware with supported CPUs.

### Desktop recovery not monitoring
1. Check if service is running: `systemctl --user status aether-desktop-recovery.service`
2. Check logs: `aether-desktop-recovery log`
3. Ensure you're in a graphical session

---

## Future Enhancements

Potential improvements for future releases:
- Threat scanner: Additional security checks (kernel parameters, AppArmor profiles)
- Boot optimizer: More sophisticated service dependency analysis
- CPU governor: Support for per-core governor selection
- Desktop recovery: Support for more compositors (Weston, Hyprland)

---

## Version History

### v2.3 (Current)
- Initial release of intelligence systems
- Four integrated subsystems
- Comprehensive CLI tooling
- Full offline operation

---

For more information, see the main README.md and individual tool help commands (`--help` flag).

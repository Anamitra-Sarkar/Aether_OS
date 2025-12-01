#!/bin/bash
# =============================================================================
# AetherOS System Tuning Script
# Applies performance optimizations for a snappy desktop experience
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
SWAPPINESS=10
VFS_CACHE_PRESSURE=50
DIRTY_RATIO=10
DIRTY_BACKGROUND_RATIO=5

# =============================================================================
# Logging
# =============================================================================
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

# =============================================================================
# Check if running as root
# =============================================================================
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
}

# =============================================================================
# Apply Sysctl Settings
# =============================================================================
apply_sysctl_settings() {
    log "Applying sysctl optimizations..."
    
    # Create sysctl config file
    cat > /etc/sysctl.d/99-aetheros-tuning.conf << EOF
# AetherOS System Tuning
# Generated on $(date)

# VM Settings for desktop responsiveness
vm.swappiness = ${SWAPPINESS}
vm.vfs_cache_pressure = ${VFS_CACHE_PRESSURE}
vm.dirty_ratio = ${DIRTY_RATIO}
vm.dirty_background_ratio = ${DIRTY_BACKGROUND_RATIO}

# Improve file watching (for IDEs and file managers)
fs.inotify.max_user_watches = 524288
fs.inotify.max_user_instances = 1024

# Network optimizations
net.core.rmem_default = 1048576
net.core.rmem_max = 16777216
net.core.wmem_default = 1048576
net.core.wmem_max = 16777216
net.core.optmem_max = 65536
net.ipv4.tcp_rmem = 4096 1048576 2097152
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1

# Security settings
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 1
kernel.yama.ptrace_scope = 1
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
EOF
    
    # Apply immediately
    sysctl -p /etc/sysctl.d/99-aetheros-tuning.conf || true
    
    log "Sysctl settings applied"
}

# =============================================================================
# Enable fstrim Timer
# =============================================================================
enable_fstrim() {
    log "Enabling fstrim timer for SSD optimization..."
    
    if systemctl list-unit-files | grep -q fstrim.timer; then
        systemctl enable fstrim.timer
        systemctl start fstrim.timer || true
        log "fstrim timer enabled"
    else
        log "fstrim timer not available"
    fi
}

# =============================================================================
# Configure Preload
# =============================================================================
configure_preload() {
    log "Configuring preload..."
    
    if command -v preload &>/dev/null; then
        systemctl enable preload || true
        systemctl start preload || true
        log "Preload enabled"
    else
        log "Preload not installed"
    fi
}

# =============================================================================
# Configure Baloo (KDE Indexer)
# =============================================================================
configure_baloo() {
    log "Configuring Baloo file indexer..."
    
    # Create default baloo configuration to disable indexing by default
    mkdir -p /etc/skel/.config
    
    cat > /etc/skel/.config/baloofilerc << 'EOF'
[Basic Settings]
Indexing-Enabled=false

[General]
dbVersion=2
exclude filters=*~,*.part,*.tmp,*.o,*.a,*.la,*.lo,*.loT,*.moc,moc_*.cpp,qrc_*.cpp,ui_*.h,cmake_install.cmake,CMakeCache.txt,CTestTestfile.cmake,libtool,config.status,config.log,*.git,*.svn,*.hg
exclude filters version=8
only basic indexing=true
EOF
    
    log "Baloo configured (disabled by default)"
}

# =============================================================================
# Disable Apport (Crash Reporter)
# =============================================================================
disable_apport() {
    log "Disabling apport crash reporter..."
    
    if [[ -f /etc/default/apport ]]; then
        sed -i 's/enabled=1/enabled=0/' /etc/default/apport
        log "Apport disabled"
    fi
    
    if systemctl is-active --quiet apport; then
        systemctl stop apport || true
        systemctl disable apport || true
    fi
}

# =============================================================================
# Optimize I/O Scheduler
# =============================================================================
optimize_io_scheduler() {
    log "Optimizing I/O scheduler..."
    
    # Create udev rule for I/O scheduler
    cat > /etc/udev/rules.d/60-ioscheduler.rules << 'EOF'
# Use mq-deadline for NVMe SSDs
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="mq-deadline"

# Use mq-deadline for SATA SSDs
ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"

# Use bfq for HDDs
ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
EOF
    
    log "I/O scheduler rules created"
}

# =============================================================================
# Configure Journal
# =============================================================================
configure_journal() {
    log "Configuring systemd journal..."
    
    mkdir -p /etc/systemd/journald.conf.d
    
    cat > /etc/systemd/journald.conf.d/aetheros.conf << 'EOF'
[Journal]
# Limit journal size to 100MB
SystemMaxUse=100M
SystemKeepFree=100M
RuntimeMaxUse=50M
MaxFileSec=1week
Compress=yes
EOF
    
    systemctl restart systemd-journald || true
    
    log "Journal configured"
}

# =============================================================================
# Enable Early OOM (if available)
# =============================================================================
enable_earlyoom() {
    log "Configuring early OOM killer..."
    
    if command -v earlyoom &>/dev/null || [[ -f /usr/bin/earlyoom ]]; then
        systemctl enable earlyoom || true
        systemctl start earlyoom || true
        log "EarlyOOM enabled"
    else
        # Create OOM prevention script
        cat > /opt/aetheros/oom-check.sh << 'SCRIPT'
#!/bin/bash
# AetherOS OOM Prevention Script
# Clears caches if available memory falls below 256MB

MEM_AVAIL=$(awk '/MemAvailable/{print int($2/1024)}' /proc/meminfo)

if [ "$MEM_AVAIL" -lt 256 ]; then
    logger -t aetheros-oom "Low memory detected (${MEM_AVAIL}MB), clearing caches"
    sync
    echo 1 > /proc/sys/vm/drop_caches
fi
SCRIPT
        chmod +x /opt/aetheros/oom-check.sh
        
        # Create cron job
        cat > /etc/cron.d/aetheros-oom-prevention << 'EOF'
# AetherOS OOM Prevention - Check memory every 5 minutes
*/5 * * * * root /opt/aetheros/oom-check.sh
EOF
        log "Basic OOM prevention configured"
    fi
}

# =============================================================================
# Show Current Settings
# =============================================================================
show_status() {
    log "=== Current System Settings ==="
    
    echo ""
    echo "VM Settings:"
    echo "  vm.swappiness = $(cat /proc/sys/vm/swappiness)"
    echo "  vm.vfs_cache_pressure = $(cat /proc/sys/vm/vfs_cache_pressure)"
    echo "  vm.dirty_ratio = $(cat /proc/sys/vm/dirty_ratio)"
    echo "  vm.dirty_background_ratio = $(cat /proc/sys/vm/dirty_background_ratio)"
    
    echo ""
    echo "Memory Status:"
    free -h
    
    echo ""
    echo "Active Timers:"
    systemctl list-timers --no-pager | head -10
}

# =============================================================================
# Main
# =============================================================================
main() {
    log "=== AetherOS System Tuning ==="
    
    check_root
    
    apply_sysctl_settings
    enable_fstrim
    configure_preload
    configure_baloo
    disable_apport
    optimize_io_scheduler
    configure_journal
    enable_earlyoom
    
    show_status
    
    log "=== System Tuning Complete ==="
}

# Parse arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help    Show this help"
        echo "  --status  Show current system settings"
        exit 0
        ;;
    --status)
        show_status
        exit 0
        ;;
    *)
        main
        ;;
esac

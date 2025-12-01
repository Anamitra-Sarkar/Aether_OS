#!/bin/bash
# =============================================================================
# AetherOS ZRAM Enable Script
# Configures zram swap for improved performance
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
ZRAM_SIZE_PERCENT=25
ZRAM_DEVICE="/dev/zram0"
ZRAM_ALGORITHM="zstd"

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
# Calculate ZRAM Size
# =============================================================================
calculate_zram_size() {
    local total_ram_kb
    total_ram_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    
    local total_ram_mb=$((total_ram_kb / 1024))
    local zram_size_mb=$((total_ram_mb * ZRAM_SIZE_PERCENT / 100))
    
    # Minimum 256MB, maximum 8GB for zram
    if [[ $zram_size_mb -lt 256 ]]; then
        zram_size_mb=256
    elif [[ $zram_size_mb -gt 8192 ]]; then
        zram_size_mb=8192
    fi
    
    # For low-memory systems (<=2GB), use 50%
    if [[ $total_ram_mb -le 2048 ]]; then
        zram_size_mb=$((total_ram_mb * 50 / 100))
        log "Low memory system detected (${total_ram_mb}MB), using 50% for zram"
    fi
    
    echo "$zram_size_mb"
}

# =============================================================================
# Check if zram is already enabled
# =============================================================================
check_zram_status() {
    if [[ -e "$ZRAM_DEVICE" ]] && swapon --show | grep -q zram; then
        log "ZRAM is already enabled"
        swapon --show | grep zram
        return 0
    fi
    return 1
}

# =============================================================================
# Load zram module
# =============================================================================
load_zram_module() {
    log "Loading zram module..."
    
    if ! lsmod | grep -q zram; then
        modprobe zram num_devices=1
    fi
    
    if [[ ! -e "$ZRAM_DEVICE" ]]; then
        log_error "ZRAM device not created"
        exit 1
    fi
    
    log "ZRAM module loaded"
}

# =============================================================================
# Configure ZRAM
# =============================================================================
configure_zram() {
    local zram_size_mb
    zram_size_mb=$(calculate_zram_size)
    local zram_size_bytes=$((zram_size_mb * 1024 * 1024))
    
    log "Configuring ZRAM with ${zram_size_mb}MB..."
    
    # Reset zram device if it exists
    if [[ -e "$ZRAM_DEVICE" ]]; then
        swapoff "$ZRAM_DEVICE" 2>/dev/null || true
        echo 1 > /sys/block/zram0/reset 2>/dev/null || true
    fi
    
    # Set compression algorithm
    if [[ -f /sys/block/zram0/comp_algorithm ]]; then
        if grep -q "$ZRAM_ALGORITHM" /sys/block/zram0/comp_algorithm; then
            echo "$ZRAM_ALGORITHM" > /sys/block/zram0/comp_algorithm
            log "Using compression algorithm: $ZRAM_ALGORITHM"
        else
            log "Using default compression algorithm"
        fi
    fi
    
    # Set disk size
    echo "$zram_size_bytes" > /sys/block/zram0/disksize
    
    # Format as swap
    mkswap "$ZRAM_DEVICE"
    
    log "ZRAM configured: ${zram_size_mb}MB"
}

# =============================================================================
# Enable ZRAM Swap
# =============================================================================
enable_zram_swap() {
    log "Enabling ZRAM swap..."
    
    # Enable with higher priority than disk swap
    swapon -p 100 "$ZRAM_DEVICE"
    
    log "ZRAM swap enabled"
}

# =============================================================================
# Create systemd service for persistence
# =============================================================================
create_systemd_service() {
    local service_file="/etc/systemd/system/aetheros-zram.service"
    
    if [[ -f "$service_file" ]]; then
        log "Systemd service already exists"
        return 0
    fi
    
    log "Creating systemd service..."
    
    cat > "$service_file" << 'EOF'
[Unit]
Description=AetherOS ZRAM Swap Configuration
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/opt/aetheros/enable-zram.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable aetheros-zram.service
    
    log "Systemd service created and enabled"
}

# =============================================================================
# Show Status
# =============================================================================
show_status() {
    log "=== ZRAM Status ==="
    
    if [[ -e /sys/block/zram0/comp_algorithm ]]; then
        echo "Algorithm: $(cat /sys/block/zram0/comp_algorithm | grep -o '\[.*\]' | tr -d '[]')"
    fi
    
    if [[ -e /sys/block/zram0/disksize ]]; then
        local disksize_bytes
        disksize_bytes=$(cat /sys/block/zram0/disksize)
        local disksize_mb=$((disksize_bytes / 1024 / 1024))
        echo "Disk Size: ${disksize_mb}MB"
    fi
    
    echo ""
    echo "=== Swap Status ==="
    swapon --show
    
    echo ""
    echo "=== Memory Status ==="
    free -h
}

# =============================================================================
# Main
# =============================================================================
main() {
    log "=== AetherOS ZRAM Configuration ==="
    
    check_root
    
    # Check if already enabled
    if check_zram_status; then
        show_status
        exit 0
    fi
    
    load_zram_module
    configure_zram
    enable_zram_swap
    
    # Only create service if not running from live session
    if [[ ! -f /run/live/medium ]]; then
        create_systemd_service
    fi
    
    show_status
    
    log "=== ZRAM Configuration Complete ==="
}

# Parse arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help    Show this help"
        echo "  --status  Show current ZRAM status"
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

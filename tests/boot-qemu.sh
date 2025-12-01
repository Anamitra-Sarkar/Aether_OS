#!/bin/bash
# =============================================================================
# AetherOS QEMU Boot Test
# Boots the ISO in QEMU and validates that the desktop is ready
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
ARTIFACTS_DIR="$SCRIPT_DIR/artifacts"
SCREENSHOTS_DIR="$REPO_ROOT/artwork/screenshots"
ISO_PATH="${1:-$SCRIPT_DIR/../build/artifacts/aetheros.iso}"
ISO_BASENAME="$(basename "$ISO_PATH")"
TIMEOUT=${TIMEOUT:-120}
RAM="${RAM:-4096}"
CPUS="${CPUS:-2}"
VNC_PORT="${VNC_PORT:-5900}"
SCREENSHOT_FILE="$ARTIFACTS_DIR/desktop.png"

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
# Check Prerequisites
# =============================================================================
check_prerequisites() {
    log "Checking prerequisites..."
    
    if ! command -v qemu-system-x86_64 &>/dev/null; then
        log_error "qemu-system-x86_64 not found"
        log "Install with: apt install qemu-system-x86"
        exit 1
    fi
    
    if [[ ! -f "$ISO_PATH" ]]; then
        log_error "ISO not found: $ISO_PATH"
        exit 1
    fi
    
    mkdir -p "$ARTIFACTS_DIR"
    mkdir -p "$SCREENSHOTS_DIR"
    
    log "Prerequisites OK"
}

# =============================================================================
# Start QEMU
# =============================================================================
start_qemu() {
    log "Starting QEMU..."
    log "  ISO: $ISO_PATH"
    log "  RAM: ${RAM}MB"
    log "  CPUs: $CPUS"
    log "  Timeout: ${TIMEOUT}s"
    
    # Start QEMU in background with VNC
    qemu-system-x86_64 \
        -enable-kvm \
        -m "$RAM" \
        -smp "$CPUS" \
        -cdrom "$ISO_PATH" \
        -boot d \
        -display vnc=:0 \
        -monitor unix:/tmp/qemu-monitor.sock,server,nowait \
        -serial file:/tmp/qemu-serial.log \
        -device virtio-vga-gl \
        -device virtio-net-pci,netdev=net0 \
        -netdev user,id=net0 \
        -name "AetherOS Test" \
        -daemonize \
        2>/dev/null || {
            # Try without KVM if it fails
            log "KVM not available, using software emulation (slower)"
            qemu-system-x86_64 \
                -m "$RAM" \
                -smp "$CPUS" \
                -cdrom "$ISO_PATH" \
                -boot d \
                -display vnc=:0 \
                -monitor unix:/tmp/qemu-monitor.sock,server,nowait \
                -serial file:/tmp/qemu-serial.log \
                -device virtio-vga \
                -device virtio-net-pci,netdev=net0 \
                -netdev user,id=net0 \
                -name "AetherOS Test" \
                -daemonize
        }
    
    QEMU_PID=$(pgrep -f "qemu-system.*$ISO_BASENAME" | head -1 || true)
    
    if [[ -z "$QEMU_PID" ]]; then
        log_error "Failed to start QEMU"
        exit 1
    fi
    
    log "QEMU started (PID: $QEMU_PID)"
}

# =============================================================================
# Wait for Desktop
# =============================================================================
wait_for_desktop() {
    log "Waiting for desktop to become ready..."
    
    local start_time
    start_time=$(date +%s)
    local current_time
    local elapsed
    
    while true; do
        current_time=$(date +%s)
        elapsed=$((current_time - start_time))
        
        if [[ $elapsed -ge $TIMEOUT ]]; then
            log_error "Timeout waiting for desktop (${TIMEOUT}s)"
            return 1
        fi
        
        # Check if QEMU is still running
        if ! pgrep -f "qemu-system.*$ISO_BASENAME" &>/dev/null; then
            log_error "QEMU process died"
            return 1
        fi
        
        # Check serial log for boot progress
        if [[ -f /tmp/qemu-serial.log ]]; then
            if grep -q "plasmashell" /tmp/qemu-serial.log 2>/dev/null || \
               grep -q "sddm" /tmp/qemu-serial.log 2>/dev/null || \
               grep -q "graphical.target" /tmp/qemu-serial.log 2>/dev/null; then
                log "Desktop indicators found in boot log"
                # Wait a bit more for desktop to stabilize
                sleep 10
                return 0
            fi
        fi
        
        log "Waiting... (${elapsed}s / ${TIMEOUT}s)"
        sleep 5
    done
}

# =============================================================================
# Take Screenshot
# =============================================================================
take_screenshot() {
    local output_file="${1:-$SCREENSHOT_FILE}"
    log "Taking screenshot to $output_file..."
    
    # Try to use QEMU monitor to screendump (most reliable for QEMU)
    if [[ -S /tmp/qemu-monitor.sock ]]; then
        if command -v socat &>/dev/null; then
            echo "screendump $output_file" | socat - UNIX-CONNECT:/tmp/qemu-monitor.sock 2>/dev/null || true
        fi
    fi
    
    if [[ -f "$output_file" ]]; then
        log "Screenshot saved: $output_file"
        return 0
    else
        log "Could not capture screenshot via QEMU monitor"
        # Note: Screenshot capture requires QEMU monitor support
        # CI will handle missing screenshots gracefully
        return 1
    fi
}

# =============================================================================
# Capture Multiple Screenshots
# =============================================================================
capture_screenshots() {
    log "Capturing screenshots for presentation..."
    
    # Wait a moment for desktop to stabilize
    sleep 5
    
    # Capture login screen (if visible)
    take_screenshot "$SCREENSHOTS_DIR/login.png" || true
    
    # Wait for desktop to fully load
    sleep 10
    
    # Capture desktop
    take_screenshot "$SCREENSHOTS_DIR/desktop.png" || true
    take_screenshot "$ARTIFACTS_DIR/desktop.png" || true
    
    # Note: control-center.png would require automated interaction
    # For now, we'll document this as a manual step
    log "Screenshots captured (login, desktop)"
    log "Note: control-center.png requires manual capture"
}

# =============================================================================
# Cleanup
# =============================================================================
cleanup() {
    log "Cleaning up..."
    
    # Kill QEMU - use broader pattern to catch any QEMU instance we started
    if pgrep -f "qemu-system.*-cdrom" &>/dev/null; then
        pkill -f "qemu-system.*-cdrom" || true
    fi
    
    # Clean up temp files
    rm -f /tmp/qemu-monitor.sock
    rm -f /tmp/qemu-serial.log
}

trap cleanup EXIT

# =============================================================================
# Show Help
# =============================================================================
show_help() {
    cat << 'EOF'
AetherOS QEMU Boot Test

Usage: boot-qemu.sh [ISO_PATH]

Arguments:
  ISO_PATH    Path to the ISO file (default: ../build/artifacts/aetheros.iso)

Environment Variables:
  TIMEOUT     Boot timeout in seconds (default: 120)
  RAM         RAM in MB (default: 4096)
  CPUS        Number of CPUs (default: 2)
  VNC_PORT    VNC port (default: 5900)

Examples:
  ./boot-qemu.sh
  ./boot-qemu.sh ../build/artifacts/aetheros.iso
  TIMEOUT=180 RAM=8192 ./boot-qemu.sh
EOF
}

# =============================================================================
# Main
# =============================================================================
main() {
    case "${1:-}" in
        --help|-h)
            show_help
            exit 0
            ;;
    esac
    
    log "=== AetherOS QEMU Boot Test ==="
    
    check_prerequisites
    start_qemu
    
    if wait_for_desktop; then
        capture_screenshots
        log "=== Boot Test PASSED ==="
        exit 0
    else
        take_screenshot "$ARTIFACTS_DIR/boot-failure.png"
        log "=== Boot Test FAILED ==="
        exit 1
    fi
}

main "$@"

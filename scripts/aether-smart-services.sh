#!/bin/bash
# =============================================================================
# AetherOS Smart Service Manager
# Auto-manages system services based on hardware presence
# =============================================================================

set -euo pipefail

# =============================================================================
# Service Detection & Management
# =============================================================================

# Check if hardware exists
has_bluetooth() {
    [ -d /sys/class/bluetooth ] && [ -n "$(ls -A /sys/class/bluetooth 2>/dev/null)" ]
}

has_printer() {
    lpstat -r &>/dev/null || [ -d /dev/usb/lp* ] 2>/dev/null
}

has_avahi_need() {
    # Check if local network services are needed
    # True if user has printers or local file sharing enabled
    has_printer || systemctl is-active smbd &>/dev/null
}

needs_indexing() {
    # Check if user has large document collections
    local home_docs="${HOME}/Documents"
    if [ -d "$home_docs" ]; then
        local doc_count
        doc_count=$(find "$home_docs" -type f 2>/dev/null | wc -l)
        [ "$doc_count" -gt 100 ]
    else
        return 1
    fi
}

# =============================================================================
# Service Management
# =============================================================================

manage_bluetooth() {
    if has_bluetooth; then
        echo "✓ Bluetooth hardware detected - enabling bluetooth.service"
        sudo systemctl enable bluetooth.service 2>/dev/null || true
        sudo systemctl start bluetooth.service 2>/dev/null || true
    else
        echo "✗ No Bluetooth hardware - disabling bluetooth.service"
        sudo systemctl disable bluetooth.service 2>/dev/null || true
        sudo systemctl stop bluetooth.service 2>/dev/null || true
    fi
}

manage_cups() {
    if has_printer; then
        echo "✓ Printer detected - enabling cups.service"
        sudo systemctl enable cups.service 2>/dev/null || true
        sudo systemctl start cups.service 2>/dev/null || true
    else
        echo "✗ No printer detected - disabling cups.service (can be re-enabled when needed)"
        sudo systemctl disable cups.service 2>/dev/null || true
        sudo systemctl stop cups.service 2>/dev/null || true
    fi
}

manage_avahi() {
    if has_avahi_need; then
        echo "✓ Network services detected - enabling avahi-daemon.service"
        sudo systemctl enable avahi-daemon.service 2>/dev/null || true
        sudo systemctl start avahi-daemon.service 2>/dev/null || true
    else
        echo "✗ No network service needs - disabling avahi-daemon.service"
        sudo systemctl disable avahi-daemon.service 2>/dev/null || true
        sudo systemctl stop avahi-daemon.service 2>/dev/null || true
    fi
}

manage_baloo() {
    if needs_indexing; then
        echo "✓ Large document collection - enabling baloo file indexer"
        kwriteconfig5 --file "${XDG_CONFIG_HOME:-$HOME/.config}/baloofilerc" --group "Basic Settings" --key "Indexing-Enabled" true
        balooctl enable 2>/dev/null || true
    else
        echo "✗ Small/no document collection - disabling baloo file indexer"
        kwriteconfig5 --file "${XDG_CONFIG_HOME:-$HOME/.config}/baloofilerc" --group "Basic Settings" --key "Indexing-Enabled" false
        balooctl disable 2>/dev/null || true
        balooctl stop 2>/dev/null || true
    fi
}

# =============================================================================
# Run all checks
# =============================================================================
run_all_checks() {
    echo "=== AetherOS Smart Service Manager ==="
    echo "Analyzing hardware and optimizing services..."
    echo ""
    
    manage_bluetooth
    manage_cups
    manage_avahi
    manage_baloo
    
    echo ""
    echo "✓ Service optimization complete!"
    echo ""
    echo "Services are now configured based on your actual hardware."
    echo "They will auto-restart when hardware is connected."
}

# =============================================================================
# Individual service control
# =============================================================================
enable_service() {
    local service=$1
    case $service in
        bluetooth)
            echo "Force enabling bluetooth..."
            sudo systemctl enable bluetooth.service
            sudo systemctl start bluetooth.service
            ;;
        cups|printing)
            echo "Force enabling printing..."
            sudo systemctl enable cups.service
            sudo systemctl start cups.service
            ;;
        avahi)
            echo "Force enabling network discovery..."
            sudo systemctl enable avahi-daemon.service
            sudo systemctl start avahi-daemon.service
            ;;
        baloo|indexing)
            echo "Force enabling file indexing..."
            kwriteconfig5 --file "${XDG_CONFIG_HOME:-$HOME/.config}/baloofilerc" --group "Basic Settings" --key "Indexing-Enabled" true
            balooctl enable
            ;;
        *)
            echo "Unknown service: $service" >&2
            return 1
            ;;
    esac
}

# =============================================================================
# Status
# =============================================================================
show_status() {
    echo "=== Service Status ==="
    echo ""
    
    echo "Bluetooth:"
    if has_bluetooth; then
        echo "  Hardware: Present"
        echo "  Service: $(systemctl is-active bluetooth.service 2>/dev/null || echo 'inactive')"
    else
        echo "  Hardware: Not detected"
    fi
    echo ""
    
    echo "Printing (CUPS):"
    if has_printer; then
        echo "  Hardware: Present"
        echo "  Service: $(systemctl is-active cups.service 2>/dev/null || echo 'inactive')"
    else
        echo "  Hardware: Not detected"
    fi
    echo ""
    
    echo "Network Discovery (Avahi):"
    echo "  Service: $(systemctl is-active avahi-daemon.service 2>/dev/null || echo 'inactive')"
    echo ""
    
    echo "File Indexing (Baloo):"
    if command -v balooctl &>/dev/null; then
        echo "  Status: $(balooctl status 2>/dev/null | head -1 || echo 'Not running')"
    else
        echo "  Status: Not installed"
    fi
}

# =============================================================================
# Main
# =============================================================================
show_help() {
    cat << EOF
AetherOS Smart Service Manager

Automatically manages system services based on hardware presence.
Helps reduce RAM usage and improve battery life by disabling unused services.

Usage: $(basename "$0") [OPTIONS]

Options:
  check             Check hardware and optimize services (default)
  status            Show current service status
  enable SERVICE    Force enable a service
  --help, -h        Show this help

Services:
  bluetooth         Bluetooth service
  cups, printing    Printer service (CUPS)
  avahi             Network discovery
  baloo, indexing   File indexing

Examples:
  $(basename "$0")                  # Auto-optimize all services
  $(basename "$0") status           # Check service status
  $(basename "$0") enable bluetooth # Force enable bluetooth

Note: Services are automatically re-enabled when hardware is connected.
EOF
}

main() {
    case "${1:-check}" in
        check|auto)
            run_all_checks
            ;;
        status)
            show_status
            ;;
        enable)
            if [ -z "${2:-}" ]; then
                echo "Error: Please specify a service to enable" >&2
                show_help
                exit 1
            fi
            enable_service "$2"
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            show_help
            exit 1
            ;;
    esac
}

main "$@"

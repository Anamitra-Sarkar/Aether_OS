#!/bin/bash
# =============================================================================
# AetherVault - User Home Backup Script
# Simple, reliable backup of user home directory using rsync
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
VERSION="0.2.0"
LOG_DIR="$HOME/.local/share/aetheros/logs"
LOG_FILE="${LOG_DIR}/aethervault.log"
EXCLUDE_FILE="${LOG_DIR}/aethervault-exclude.txt"

# Default excludes - caches, temp files, large media caches
DEFAULT_EXCLUDES=(
    ".cache"
    ".local/share/Trash"
    ".local/share/baloo"
    ".thumbnails"
    ".npm/_cacache"
    ".cargo/registry"
    ".rustup"
    "node_modules"
    "__pycache__"
    "*.pyc"
    ".gradle"
    ".m2/repository"
    "snap/*/*/.cache"
    ".steam/steam/steamapps"
    ".local/share/Steam/steamapps"
    "Downloads/*.iso"
    "Downloads/*.img"
    ".mozilla/firefox/*/cache2"
    ".config/google-chrome/*/Cache"
    ".config/chromium/*/Cache"
    "*.tmp"
    "*.temp"
    "*~"
    ".Trash-*"
)

# =============================================================================
# Colors
# =============================================================================
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
RESET="\033[0m"

# =============================================================================
# Logging
# =============================================================================
log() {
    local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo -e "$message"
    mkdir -p "$LOG_DIR"
    echo "$message" >> "$LOG_FILE" 2>/dev/null || true
}

log_error() {
    log "${RED}[ERROR]${RESET} $1"
}

log_success() {
    log "${GREEN}[SUCCESS]${RESET} $1"
}

log_info() {
    log "${BLUE}[INFO]${RESET} $1"
}

log_warn() {
    log "${YELLOW}[WARN]${RESET} $1"
}

# =============================================================================
# Create Exclude File
# =============================================================================
create_exclude_file() {
    mkdir -p "$LOG_DIR"
    
    # Create exclude file from defaults
    printf '%s\n' "${DEFAULT_EXCLUDES[@]}" > "$EXCLUDE_FILE"
    
    log_info "Exclude file created: $EXCLUDE_FILE"
}

# =============================================================================
# Validate Destination
# =============================================================================
validate_destination() {
    local dest="$1"
    
    if [[ ! -d "$dest" ]]; then
        log_error "Destination does not exist: $dest"
        echo "Please create the directory first or mount the external drive."
        return 1
    fi
    
    if [[ ! -w "$dest" ]]; then
        log_error "Cannot write to destination: $dest"
        echo "Please check permissions."
        return 1
    fi
    
    # Check available space
    local available
    available=$(df -B1 "$dest" | awk 'NR==2 {print $4}')
    local home_size
    home_size=$(du -sb "$HOME" 2>/dev/null | awk '{print $1}' || echo 0)
    
    if [[ "$available" -lt "$home_size" ]]; then
        log_warn "Destination may not have enough space"
        log_warn "Available: $(numfmt --to=iec "$available"), Home size: $(numfmt --to=iec "$home_size")"
        echo -n "Continue anyway? [y/N] "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
    
    return 0
}

# =============================================================================
# Run Backup
# =============================================================================
run_backup() {
    local dest="$1"
    local dry_run="${2:-false}"
    
    # Create backup subdirectory with username
    local backup_dir="$dest/aethervault-$(whoami)"
    
    log_info "Starting AetherVault backup..."
    log_info "Source: $HOME"
    log_info "Destination: $backup_dir"
    
    # Ensure exclude file exists
    if [[ ! -f "$EXCLUDE_FILE" ]]; then
        create_exclude_file
    fi
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    # Build rsync command
    local rsync_opts="-avh --progress --delete --exclude-from=$EXCLUDE_FILE"
    
    if [[ "$dry_run" == "true" ]]; then
        rsync_opts="$rsync_opts --dry-run"
        log_info "DRY RUN - no changes will be made"
    fi
    
    # Run rsync
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════${RESET}"
    echo -e "${CYAN}Starting backup...${RESET}"
    echo -e "${CYAN}═══════════════════════════════════════════${RESET}"
    echo ""
    
    # shellcheck disable=SC2086
    if rsync $rsync_opts "$HOME/" "$backup_dir/" 2>&1 | tee -a "$LOG_FILE"; then
        log_success "Backup completed successfully!"
        
        # Save metadata
        cat > "$backup_dir/.aethervault-meta" << EOF
AetherVault Backup
==================
Date: $(date)
User: $(whoami)
Hostname: $(hostname)
Source: $HOME
Version: $VERSION
EOF
        
        echo ""
        echo -e "${GREEN}✓ Backup complete!${RESET}"
        echo "  Location: $backup_dir"
        echo "  Log: $LOG_FILE"
        
        return 0
    else
        log_error "Backup failed!"
        return 1
    fi
}

# =============================================================================
# List Backups
# =============================================================================
list_backups() {
    local dest="$1"
    local backup_dir="$dest/aethervault-$(whoami)"
    
    if [[ ! -d "$backup_dir" ]]; then
        log_info "No backups found in: $dest"
        return 0
    fi
    
    echo ""
    echo -e "${CYAN}AetherVault Backup${RESET}"
    echo "Location: $backup_dir"
    echo ""
    
    if [[ -f "$backup_dir/.aethervault-meta" ]]; then
        cat "$backup_dir/.aethervault-meta"
    fi
    
    echo ""
    echo "Size: $(du -sh "$backup_dir" 2>/dev/null | awk '{print $1}')"
}

# =============================================================================
# Restore Backup (list only for safety)
# =============================================================================
show_restore_instructions() {
    local backup_dir="$1"
    
    echo ""
    echo -e "${YELLOW}Restore Instructions${RESET}"
    echo "===================="
    echo ""
    echo "To restore your backup, use rsync:"
    echo ""
    echo "  # Preview (dry run):"
    echo "  rsync -avh --dry-run $backup_dir/ \$HOME/"
    echo ""
    echo "  # Actual restore (OVERWRITES existing files):"
    echo "  rsync -avh $backup_dir/ \$HOME/"
    echo ""
    echo "WARNING: Restoring will overwrite files in your home directory."
    echo "Consider restoring to a different location first to review."
}

# =============================================================================
# Show Help
# =============================================================================
show_help() {
    cat << EOF
AetherVault - AetherOS Home Backup Tool
Version: $VERSION

Usage: aethervault.sh [COMMAND] [DESTINATION]

Commands:
  backup DEST     Backup home directory to DEST
  dry-run DEST    Preview backup without making changes  
  list DEST       List existing backups
  restore DEST    Show restore instructions
  excludes        Show/edit exclude patterns

Options:
  --help          Show this help

Examples:
  ./aethervault.sh backup /mnt/external
  ./aethervault.sh backup /run/media/user/USB_DRIVE
  ./aethervault.sh dry-run ~/Backups
  ./aethervault.sh list /mnt/external

What gets backed up:
  - All files in your home directory
  - Configuration files (.config, etc.)
  - Documents, Pictures, Music, Videos

What is excluded (by default):
  - Caches (.cache, browser caches)
  - Trash
  - Package caches (npm, cargo, etc.)
  - Steam games
  - Temporary files

Log file: $LOG_FILE
Exclude list: $EXCLUDE_FILE
EOF
}

# =============================================================================
# Main
# =============================================================================
main() {
    local command="${1:-}"
    local dest="${2:-}"
    
    case "$command" in
        --help|-h|"")
            show_help
            exit 0
            ;;
        backup)
            if [[ -z "$dest" ]]; then
                log_error "Destination required"
                echo "Usage: aethervault.sh backup /path/to/destination"
                exit 1
            fi
            validate_destination "$dest" || exit 1
            run_backup "$dest" false
            ;;
        dry-run)
            if [[ -z "$dest" ]]; then
                log_error "Destination required"
                exit 1
            fi
            validate_destination "$dest" || exit 1
            run_backup "$dest" true
            ;;
        list)
            if [[ -z "$dest" ]]; then
                log_error "Destination required"
                exit 1
            fi
            list_backups "$dest"
            ;;
        restore)
            if [[ -z "$dest" ]]; then
                log_error "Backup location required"
                exit 1
            fi
            show_restore_instructions "$dest/aethervault-$(whoami)"
            ;;
        excludes)
            if [[ ! -f "$EXCLUDE_FILE" ]]; then
                create_exclude_file
            fi
            echo "Exclude patterns file: $EXCLUDE_FILE"
            echo ""
            cat "$EXCLUDE_FILE"
            echo ""
            echo "Edit this file to customize exclusions."
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"

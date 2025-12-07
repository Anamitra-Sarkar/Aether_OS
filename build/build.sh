#!/bin/bash
# =============================================================================
# AetherOS Build Script
# Creates a bootable ISO from the chroot environment
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CHROOT_DIR="$SCRIPT_DIR/chroot"
ARTIFACTS_DIR="$SCRIPT_DIR/artifacts"
ISO_DIR="$SCRIPT_DIR/iso"
ISO_NAME="aetheros.iso"
ISO_LABEL="AetherOS"
LOG_FILE="$SCRIPT_DIR/build.log"
MINIMAL_MODE=false

# Architecture support (ARM64 groundwork for v2.1)
ARCH="${ARCH:-amd64}"
# Supported: amd64 (x86_64), arm64 (aarch64)
# Note: ARM64 support is experimental and not fully tested yet

# =============================================================================
# Parse Arguments
# =============================================================================
while [[ $# -gt 0 ]]; do
    case $1 in
        --minimal)
            MINIMAL_MODE=true
            shift
            ;;
        --chroot-dir)
            CHROOT_DIR="$2"
            shift 2
            ;;
        --arch)
            ARCH="$2"
            shift 2
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --minimal      Build minimal ISO for testing"
            echo "  --chroot-dir   Specify chroot directory"
            echo "  --arch ARCH    Target architecture (amd64 or arm64, default: amd64)"
            echo "  --help         Show this help"
            echo ""
            echo "Environment Variables:"
            echo "  ARCH           Set target architecture (amd64 or arm64)"
            echo ""
            echo "Examples:"
            echo "  $0                    # Build for amd64 (default)"
            echo "  $0 --arch arm64       # Build for ARM64 (experimental)"
            echo "  ARCH=arm64 $0         # Build for ARM64 via environment"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate architecture
case "$ARCH" in
    amd64|x86_64)
        ARCH="amd64"
        ;;
    arm64|aarch64)
        ARCH="arm64"
        log "WARNING: ARM64 support is experimental and not fully tested"
        ;;
    *)
        log_error "Unsupported architecture: $ARCH"
        log_error "Supported: amd64, arm64"
        exit 1
        ;;
esac

# =============================================================================
# Logging Functions
# =============================================================================
log() {
    local message
    message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$message" | tee -a "$LOG_FILE"
}

log_error() {
    local message
    message="[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1"
    echo "$message" | tee -a "$LOG_FILE" >&2
}

log_section() {
    log "=============================================="
    log "$1"
    log "=============================================="
}

# =============================================================================
# Cleanup Function
# =============================================================================
cleanup() {
    log "Cleaning up temporary files..."
    # Cleanup handled by trap
}

trap cleanup EXIT

# =============================================================================
# Check Prerequisites
# =============================================================================
check_prerequisites() {
    log_section "Checking Prerequisites"
    
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root"
        exit 1
    fi
    
    local required_commands=(mksquashfs xorriso grub-mkrescue)
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "Required command not found: $cmd"
            log "Install with: apt install squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin"
            exit 1
        fi
    done
    
    log "Prerequisites check passed"
}

# =============================================================================
# Setup Chroot
# =============================================================================
setup_chroot() {
    log_section "Setting Up Chroot"
    
    if [[ ! -d "$CHROOT_DIR" ]] || [[ ! -f "$CHROOT_DIR/etc/os-release" ]]; then
        log "Chroot not found, running chroot-setup.sh..."
        "$SCRIPT_DIR/chroot-setup.sh"
    else
        log "Using existing chroot at $CHROOT_DIR"
    fi
    
    log "Chroot ready"
}

# =============================================================================
# Prepare ISO Directory Structure
# =============================================================================
prepare_iso_structure() {
    log_section "Preparing ISO Directory Structure"
    
    # Clean previous build
    rm -rf "$ISO_DIR"
    mkdir -p "$ISO_DIR"/{casper,isolinux,boot/grub}
    mkdir -p "$ARTIFACTS_DIR"
    
    log "ISO directory structure created"
}

# =============================================================================
# Create Squashfs Filesystem
# =============================================================================
create_squashfs() {
    log_section "Creating Squashfs Filesystem"
    
    local squashfs_opts="-comp xz -Xbcj x86"
    
    if [[ "$MINIMAL_MODE" == true ]]; then
        log "Using minimal compression for faster build"
        squashfs_opts="-comp gzip"
    fi
    
    log "Creating squashfs (this may take a while)..."
    # shellcheck disable=SC2086
    mksquashfs "$CHROOT_DIR" "$ISO_DIR/casper/filesystem.squashfs" \
        $squashfs_opts \
        -e boot \
        -e proc \
        -e sys \
        -e dev \
        -e run \
        -e tmp \
        -noappend \
        -progress
    
    # Calculate filesystem size
    du -sx --block-size=1 "$CHROOT_DIR" | cut -f1 > "$ISO_DIR/casper/filesystem.size"
    
    log "Squashfs created successfully"
}

# =============================================================================
# Copy Kernel and Initrd
# =============================================================================
copy_kernel() {
    log_section "Copying Kernel and Initrd"
    
    # Find kernel and initrd
    local kernel
    local initrd
    
    log "Searching for kernel in $CHROOT_DIR/boot..."
    kernel=$(find "$CHROOT_DIR/boot" -name 'vmlinuz-*' -type f 2>/dev/null | sort -V | tail -1)
    initrd=$(find "$CHROOT_DIR/boot" -name 'initrd.img-*' -type f 2>/dev/null | sort -V | tail -1)
    
    # Debug: show boot directory contents
    if [[ -z "$kernel" ]] || [[ -z "$initrd" ]]; then
        log "Contents of $CHROOT_DIR/boot:"
        ls -la "$CHROOT_DIR/boot/" 2>&1 | tee -a "$LOG_FILE" || true
    fi
    
    if [[ -z "$kernel" ]]; then
        log_error "Kernel not found in chroot/boot"
        log_error "Expected: vmlinuz-* files in $CHROOT_DIR/boot"
        log_error "Please ensure linux-image-generic is installed in the chroot"
        exit 1
    fi
    
    if [[ -z "$initrd" ]]; then
        log_error "Initrd not found in chroot/boot"
        log_error "Expected: initrd.img-* files in $CHROOT_DIR/boot"
        log_error "Please ensure initramfs-tools is installed and update-initramfs was run"
        exit 1
    fi
    
    cp "$kernel" "$ISO_DIR/casper/vmlinuz"
    cp "$initrd" "$ISO_DIR/casper/initrd"
    
    log "Kernel: $(basename "$kernel") ($(du -h "$kernel" | cut -f1))"
    log "Initrd: $(basename "$initrd") ($(du -h "$initrd" | cut -f1))"
}

# =============================================================================
# Create GRUB Configuration
# =============================================================================
create_grub_config() {
    log_section "Creating GRUB Configuration"
    
    cat > "$ISO_DIR/boot/grub/grub.cfg" << 'EOF'
# AetherOS GRUB Configuration

set timeout=10
set default=0

# Load video modules
insmod all_video
insmod gfxterm
insmod png

# Set graphics mode
set gfxmode=auto
terminal_output gfxterm

# Colors
set menu_color_normal=white/black
set menu_color_highlight=black/light-cyan

menuentry "AetherOS - Live Session" {
    linux /casper/vmlinuz boot=casper quiet splash ---
    initrd /casper/initrd
}

menuentry "AetherOS - Live Session (Safe Graphics)" {
    linux /casper/vmlinuz boot=casper nomodeset quiet splash ---
    initrd /casper/initrd
}

menuentry "AetherOS - Live Session (Debug)" {
    linux /casper/vmlinuz boot=casper debug ---
    initrd /casper/initrd
}

menuentry "Check disc for defects" {
    linux /casper/vmlinuz boot=casper integrity-check quiet splash ---
    initrd /casper/initrd
}

menuentry "Memory test" {
    linux16 /boot/memtest86+.bin
}

menuentry "Boot from first hard disk" {
    set root=(hd0)
    chainloader +1
}
EOF
    
    log "GRUB configuration created"
}

# =============================================================================
# Create ISOLINUX Configuration (Legacy BIOS)
# =============================================================================
create_isolinux_config() {
    log_section "Creating ISOLINUX Configuration"
    
    # Copy ISOLINUX files
    if [[ -d /usr/lib/ISOLINUX ]]; then
        cp /usr/lib/ISOLINUX/isolinux.bin "$ISO_DIR/isolinux/"
        cp /usr/lib/ISOLINUX/isohdpfx.bin "$ISO_DIR/isolinux/" 2>/dev/null || true
    fi
    
    if [[ -d /usr/lib/syslinux/modules/bios ]]; then
        cp /usr/lib/syslinux/modules/bios/ldlinux.c32 "$ISO_DIR/isolinux/" 2>/dev/null || true
        cp /usr/lib/syslinux/modules/bios/libutil.c32 "$ISO_DIR/isolinux/" 2>/dev/null || true
        cp /usr/lib/syslinux/modules/bios/libcom32.c32 "$ISO_DIR/isolinux/" 2>/dev/null || true
        cp /usr/lib/syslinux/modules/bios/menu.c32 "$ISO_DIR/isolinux/" 2>/dev/null || true
        cp /usr/lib/syslinux/modules/bios/vesamenu.c32 "$ISO_DIR/isolinux/" 2>/dev/null || true
    fi
    
    cat > "$ISO_DIR/isolinux/isolinux.cfg" << 'EOF'
DEFAULT vesamenu.c32
TIMEOUT 100
PROMPT 0
MENU TITLE AetherOS Boot Menu
MENU BACKGROUND splash.png
MENU COLOR border 30;44 #40ffffff #00000000 std
MENU COLOR title 1;36;44 #ff6c8cff #00000000 std
MENU COLOR sel 7;37;40 #e0ffffff #206c8cff all
MENU COLOR unsel 37;44 #50ffffff #00000000 std

LABEL live
    MENU LABEL AetherOS - Live Session
    KERNEL /casper/vmlinuz
    APPEND initrd=/casper/initrd boot=casper quiet splash ---

LABEL live-safe
    MENU LABEL AetherOS - Safe Graphics
    KERNEL /casper/vmlinuz
    APPEND initrd=/casper/initrd boot=casper nomodeset quiet splash ---

LABEL live-debug
    MENU LABEL AetherOS - Debug Mode
    KERNEL /casper/vmlinuz
    APPEND initrd=/casper/initrd boot=casper debug ---

LABEL hd
    MENU LABEL Boot from Hard Disk
    LOCALBOOT 0x80
EOF
    
    log "ISOLINUX configuration created"
}

# =============================================================================
# Create Manifest
# =============================================================================
create_manifest() {
    log_section "Creating Package Manifest"
    
    chroot "$CHROOT_DIR" dpkg-query -W --showformat='${Package} ${Version}\n' \
        > "$ISO_DIR/casper/filesystem.manifest" 2>/dev/null || true
    
    # Create manifest for live session removal
    cp "$ISO_DIR/casper/filesystem.manifest" \
       "$ISO_DIR/casper/filesystem.manifest-desktop" 2>/dev/null || true
    
    log "Manifest created"
}

# =============================================================================
# Create Disk Info
# =============================================================================
create_disk_info() {
    log_section "Creating Disk Info"
    
    mkdir -p "$ISO_DIR/.disk"
    
    echo "AetherOS 1.0 - $(date +%Y%m%d)" > "$ISO_DIR/.disk/info"
    touch "$ISO_DIR/.disk/base_installable"
    echo "full_cd/single" > "$ISO_DIR/.disk/cd_type"
    echo "$ISO_LABEL" > "$ISO_DIR/.disk/release_notes_url"
    
    log "Disk info created"
}

# =============================================================================
# Create EFI Boot Image
# =============================================================================
create_efi_image() {
    log_section "Creating EFI Boot Image"
    
    mkdir -p "$ISO_DIR/EFI/BOOT"
    
    # Copy EFI files from chroot
    if [[ -f "$CHROOT_DIR/usr/lib/grub/x86_64-efi/monolithic/grubx64.efi" ]]; then
        cp "$CHROOT_DIR/usr/lib/grub/x86_64-efi/monolithic/grubx64.efi" \
           "$ISO_DIR/EFI/BOOT/BOOTx64.EFI"
    elif [[ -f "/usr/lib/grub/x86_64-efi/monolithic/grubx64.efi" ]]; then
        cp "/usr/lib/grub/x86_64-efi/monolithic/grubx64.efi" \
           "$ISO_DIR/EFI/BOOT/BOOTx64.EFI"
    else
        # Generate EFI image using grub-mkimage
        grub-mkimage \
            -o "$ISO_DIR/EFI/BOOT/BOOTx64.EFI" \
            -p /boot/grub \
            -O x86_64-efi \
            fat iso9660 part_gpt part_msdos normal boot linux \
            configfile loopback chain efifwsetup efi_gop efi_uga \
            ls search search_label search_fs_uuid search_fs_file \
            gfxterm gfxterm_background gfxterm_menu test all_video \
            loadenv exfat ext2 ntfs btrfs hfsplus udf 2>/dev/null || true
    fi
    
    # Copy GRUB config for EFI
    cp "$ISO_DIR/boot/grub/grub.cfg" "$ISO_DIR/EFI/BOOT/grub.cfg" 2>/dev/null || true
    
    # Create EFI image for ISO
    local efi_img="$ISO_DIR/boot/grub/efi.img"
    mkdir -p "$(dirname "$efi_img")"
    
    # Create FAT filesystem for EFI
    dd if=/dev/zero of="$efi_img" bs=1M count=4
    mkfs.vfat "$efi_img"
    
    # Mount and copy EFI files
    local efi_mount
    efi_mount=$(mktemp -d)
    mount "$efi_img" "$efi_mount"
    mkdir -p "$efi_mount/EFI/BOOT"
    
    if [[ -f "$ISO_DIR/EFI/BOOT/BOOTx64.EFI" ]]; then
        cp "$ISO_DIR/EFI/BOOT/BOOTx64.EFI" "$efi_mount/EFI/BOOT/"
    fi
    
    if [[ -f "$ISO_DIR/boot/grub/grub.cfg" ]]; then
        cp "$ISO_DIR/boot/grub/grub.cfg" "$efi_mount/EFI/BOOT/"
    fi
    
    umount "$efi_mount"
    rmdir "$efi_mount"
    
    log "EFI boot image created"
}

# =============================================================================
# Create ISO
# =============================================================================
create_iso() {
    log_section "Creating ISO Image"
    
    local iso_path="$ARTIFACTS_DIR/$ISO_NAME"
    
    # Get the path to isohdpfx.bin
    local isohdpfx=""
    if [[ -f "$ISO_DIR/isolinux/isohdpfx.bin" ]]; then
        isohdpfx="$ISO_DIR/isolinux/isohdpfx.bin"
    elif [[ -f /usr/lib/ISOLINUX/isohdpfx.bin ]]; then
        isohdpfx="/usr/lib/ISOLINUX/isohdpfx.bin"
    fi
    
    log "Creating bootable ISO..."
    
    xorriso -as mkisofs \
        -iso-level 3 \
        -full-iso9660-filenames \
        -volid "$ISO_LABEL" \
        -output "$iso_path" \
        -eltorito-boot isolinux/isolinux.bin \
        -eltorito-catalog isolinux/boot.cat \
        -no-emul-boot \
        -boot-load-size 4 \
        -boot-info-table \
        --eltorito-alt-boot \
        -e boot/grub/efi.img \
        -no-emul-boot \
        -isohybrid-gpt-basdat \
        ${isohdpfx:+-isohybrid-mbr "$isohdpfx"} \
        -append_partition 2 0xef "$ISO_DIR/boot/grub/efi.img" \
        "$ISO_DIR" 2>&1 | tee -a "$LOG_FILE" || {
            # Fallback to simpler xorriso command if advanced options fail
            log "Advanced xorriso failed, trying simpler approach..."
            xorriso -as mkisofs \
                -iso-level 3 \
                -volid "$ISO_LABEL" \
                -output "$iso_path" \
                -b isolinux/isolinux.bin \
                -c isolinux/boot.cat \
                -no-emul-boot \
                -boot-load-size 4 \
                -boot-info-table \
                "$ISO_DIR"
        }
    
    # Generate checksum
    log "Generating SHA256 checksum..."
    (cd "$ARTIFACTS_DIR" && sha256sum "$ISO_NAME" > "${ISO_NAME}.sha256")
    
    log "ISO created: $iso_path"
    log "Size: $(du -h "$iso_path" | cut -f1)"
}

# =============================================================================
# Print Summary
# =============================================================================
print_summary() {
    log_section "Build Summary"
    
    log "ISO Location: $ARTIFACTS_DIR/$ISO_NAME"
    log "ISO Size: $(du -h "$ARTIFACTS_DIR/$ISO_NAME" | cut -f1)"
    log "SHA256: $(cat "$ARTIFACTS_DIR/${ISO_NAME}.sha256")"
    log ""
    log "To test the ISO:"
    log "  ./tests/boot-qemu.sh $ARTIFACTS_DIR/$ISO_NAME"
    log ""
    log "To write to USB:"
    log "  sudo dd if=$ARTIFACTS_DIR/$ISO_NAME of=/dev/sdX bs=4M status=progress"
}

# =============================================================================
# Main
# =============================================================================
main() {
    log_section "AetherOS Build"
    log "Starting at $(date)"
    log "Architecture: $ARCH"
    log "Minimal mode: $MINIMAL_MODE"
    
    check_prerequisites
    setup_chroot
    prepare_iso_structure
    create_squashfs
    copy_kernel
    create_grub_config
    create_isolinux_config
    create_manifest
    create_disk_info
    create_efi_image
    create_iso
    print_summary
    
    log_section "Build Complete"
    log "Finished at $(date)"
}

main "$@"

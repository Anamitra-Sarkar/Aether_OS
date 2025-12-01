#!/bin/bash
# =============================================================================
# AetherOS Build Validation Script
# Validates that all required files and configurations are present
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

VALIDATION_PASSED=0
VALIDATION_FAILED=0

# =============================================================================
# Logging
# =============================================================================
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_pass() {
    echo "[PASS] $1"
    VALIDATION_PASSED=$((VALIDATION_PASSED + 1))
}

log_fail() {
    echo "[FAIL] $1"
    VALIDATION_FAILED=$((VALIDATION_FAILED + 1))
}

log_section() {
    echo ""
    echo "=============================================="
    echo "$1"
    echo "=============================================="
}

# =============================================================================
# Validation Functions
# =============================================================================

validate_directory_structure() {
    log_section "Validating Directory Structure"
    
    local required_dirs=(
        "artwork"
        "artwork/icons"
        "artwork/wallpapers"
        "artwork/screenshots"
        "build"
        "configs"
        "configs/kde"
        "configs/sddm"
        "docs"
        "opt"
        "scripts"
        "tests"
        "ui"
        "ui/control-center"
        "ui/first-run-wizard"
        "ui/updater"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [[ -d "$REPO_ROOT/$dir" ]]; then
            log_pass "Directory exists: $dir"
        else
            log_fail "Directory missing: $dir"
        fi
    done
}

validate_build_files() {
    log_section "Validating Build Files"
    
    local required_files=(
        "build/build.sh"
        "build/chroot-setup.sh"
        "build/packages.list"
    )
    
    for file in "${required_files[@]}"; do
        if [[ -f "$REPO_ROOT/$file" ]]; then
            log_pass "File exists: $file"
            
            # Check if executable
            if [[ -x "$REPO_ROOT/$file" ]] || [[ "$file" == *.list ]]; then
                log_pass "File is executable or data: $file"
            else
                log_fail "File not executable: $file"
            fi
        else
            log_fail "File missing: $file"
        fi
    done
}

validate_ui_components() {
    log_section "Validating UI Components"
    
    local required_ui_files=(
        "ui/control-center/main.qml"
        "ui/first-run-wizard/main.qml"
        "ui/updater/main.qml"
    )
    
    for file in "${required_ui_files[@]}"; do
        if [[ -f "$REPO_ROOT/$file" ]]; then
            log_pass "UI file exists: $file"
            
            # Check for version strings
            if grep -q "v1.0 RC\|Version 1.0" "$REPO_ROOT/$file"; then
                log_pass "Version string updated in: $file"
            else
                log_fail "Version string not updated in: $file"
            fi
        else
            log_fail "UI file missing: $file"
        fi
    done
}

validate_documentation() {
    log_section "Validating Documentation"
    
    local required_docs=(
        "README.md"
        "CHANGELOG.md"
        "LICENSE"
        "docs/dev-guide.md"
        "docs/backup-guide.md"
        "docs/theming-guide.md"
        "docs/shortcuts.md"
        "docs/release-process.md"
    )
    
    for doc in "${required_docs[@]}"; do
        if [[ -f "$REPO_ROOT/$doc" ]]; then
            log_pass "Documentation exists: $doc"
        else
            log_fail "Documentation missing: $doc"
        fi
    done
    
    # Check README for v1.0 RC
    if grep -q "v1.0 Release Candidate\|v1.0 RC" "$REPO_ROOT/README.md"; then
        log_pass "README version updated to v1.0 RC"
    else
        log_fail "README version not updated"
    fi
}

validate_artwork() {
    log_section "Validating Artwork"
    
    local required_artwork=(
        "artwork/logo.svg"
        "artwork/wallpaper-4k.svg"
    )
    
    for art in "${required_artwork[@]}"; do
        if [[ -f "$REPO_ROOT/$art" ]]; then
            log_pass "Artwork exists: $art"
        else
            log_fail "Artwork missing: $art"
        fi
    done
    
    # Check for icons directory
    if [[ -d "$REPO_ROOT/artwork/icons/Aether" ]]; then
        log_pass "Aether icon theme directory exists"
    else
        log_fail "Aether icon theme directory missing"
    fi
    
    # Check for wallpapers
    if [[ -d "$REPO_ROOT/artwork/wallpapers" ]] && [[ -n "$(ls -A "$REPO_ROOT/artwork/wallpapers" 2>/dev/null)" ]]; then
        log_pass "Wallpapers directory exists and has content"
    else
        log_fail "Wallpapers directory empty or missing"
    fi
}

validate_scripts() {
    log_section "Validating Scripts"
    
    # Check all shell scripts have execute permission
    while IFS= read -r -d '' script; do
        if [[ -x "$script" ]]; then
            log_pass "Script executable: ${script#$REPO_ROOT/}"
        else
            log_fail "Script not executable: ${script#$REPO_ROOT/}"
        fi
    done < <(find "$REPO_ROOT" -name "*.sh" -type f ! -path "*/node_modules/*" ! -path "*/.git/*" -print0)
}

validate_ci_config() {
    log_section "Validating CI Configuration"
    
    if [[ -f "$REPO_ROOT/.github/workflows/build.yml" ]]; then
        log_pass "CI workflow exists"
        
        # Check for important CI steps
        if grep -q "boot-qemu.sh" "$REPO_ROOT/.github/workflows/build.yml"; then
            log_pass "CI includes boot test"
        else
            log_fail "CI missing boot test"
        fi
        
        if grep -q "ui-sanity.sh" "$REPO_ROOT/.github/workflows/build.yml"; then
            log_pass "CI includes sanity checks"
        else
            log_fail "CI missing sanity checks"
        fi
        
        if grep -q "codeql" "$REPO_ROOT/.github/workflows/build.yml"; then
            log_pass "CI includes CodeQL"
        else
            log_fail "CI missing CodeQL"
        fi
    else
        log_fail "CI workflow missing"
    fi
}

validate_version_consistency() {
    log_section "Validating Version Consistency"
    
    local version_files=(
        "README.md"
        "CHANGELOG.md"
        "ui/control-center/main.qml"
        "ui/first-run-wizard/WelcomeStep.qml"
    )
    
    local inconsistent=0
    
    for file in "${version_files[@]}"; do
        if [[ -f "$REPO_ROOT/$file" ]]; then
            if grep -q "1.0.*RC\|v1.0.*RC\|Version 1.0" "$REPO_ROOT/$file"; then
                log_pass "Version consistent in: $file"
            else
                log_fail "Version inconsistent in: $file"
                inconsistent=1
            fi
        fi
    done
    
    if [[ $inconsistent -eq 0 ]]; then
        log_pass "All versions consistent (v1.0 RC)"
    fi
}

check_for_placeholders() {
    log_section "Checking for Placeholders"
    
    # Search for TODO, FIXME, etc in UI files (excluding QML placeholderText property)
    if grep -rn "TODO\|FIXME\|XXX\|HACK\|coming soon" "$REPO_ROOT/ui/" | grep -v "placeholderText:" &>/dev/null; then
        log_fail "Found placeholder text or TODO markers in UI"
        grep -rn "TODO\|FIXME\|XXX\|HACK\|coming soon" "$REPO_ROOT/ui/" | grep -v "placeholderText:" | head -5
    else
        log_pass "No placeholders or TODO markers in UI"
    fi
}

# =============================================================================
# Print Summary
# =============================================================================
print_summary() {
    log_section "Validation Summary"
    
    echo ""
    echo "Passed: $VALIDATION_PASSED"
    echo "Failed: $VALIDATION_FAILED"
    echo ""
    
    if [[ $VALIDATION_FAILED -eq 0 ]]; then
        echo "✅ All validations passed!"
        return 0
    else
        echo "❌ Some validations failed. Please review the output above."
        return 1
    fi
}

# =============================================================================
# Main
# =============================================================================
main() {
    log_section "AetherOS Build Validation"
    log "Starting validation at $(date)"
    
    validate_directory_structure
    validate_build_files
    validate_ui_components
    validate_documentation
    validate_artwork
    validate_scripts
    validate_ci_config
    validate_version_consistency
    check_for_placeholders
    
    print_summary
}

main "$@"

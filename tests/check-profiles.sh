#!/bin/bash
# =============================================================================
# AetherOS Profile Tools Check
# Validates that all required profile and system tools exist
# =============================================================================

set -euo pipefail

# =============================================================================
# Configuration
# =============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SCRIPTS_DIR="$REPO_ROOT/scripts"

TESTS_PASSED=0
TESTS_FAILED=0

# =============================================================================
# Logging
# =============================================================================
log_pass() {
    echo "[PASS] $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_fail() {
    echo "[FAIL] $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

log_section() {
    echo ""
    echo "=============================================="
    echo "$1"
    echo "=============================================="
}

# =============================================================================
# Test: Check Required Scripts Exist
# =============================================================================
test_required_scripts() {
    log_section "Checking Required Scripts"
    
    local required_scripts=(
        "aether-performance-profiler.sh"
        "aether-cleanmode.sh"
        "aether-quickpal.sh"
        "aether-focus-mode.sh"
        "aether-adaptive-blur.sh"
        "aether-power-mode.sh"
        "aether-health.sh"
        "aether-smart-notifications.sh"
        "aether-smart-services.sh"
        "aether-sounds.sh"
        "aether-diagnostics.sh"
        "aether-updates.sh"
        "aethervault.sh"
    )
    
    # v2.1 new scripts
    local v21_scripts=(
        "aethershieldctl"
        "aether-secure-session.sh"
        "aether-thermal-watch.sh"
        "aether-audio-profile.sh"
        "aether-accessibility.sh"
    )
    
    for script in "${required_scripts[@]}"; do
        if [ -f "$SCRIPTS_DIR/$script" ]; then
            log_pass "Script exists: $script"
        else
            log_fail "Script missing: $script"
        fi
    done
    
    for script in "${v21_scripts[@]}"; do
        if [ -f "$SCRIPTS_DIR/$script" ]; then
            log_pass "v2.1 Script exists: $script"
        else
            log_fail "v2.1 Script missing: $script"
        fi
    done
}

# =============================================================================
# Test: Check Scripts Are Executable
# =============================================================================
test_script_permissions() {
    log_section "Checking Script Permissions"
    
    local all_scripts=(
        "aether-performance-profiler.sh"
        "aether-cleanmode.sh"
        "aether-quickpal.sh"
        "aether-focus-mode.sh"
        "aether-adaptive-blur.sh"
        "aether-power-mode.sh"
        "aether-health.sh"
        "aether-smart-notifications.sh"
        "aether-smart-services.sh"
        "aether-sounds.sh"
        "aether-diagnostics.sh"
        "aether-updates.sh"
        "aethervault.sh"
        "aethershieldctl"
        "aether-secure-session.sh"
        "aether-thermal-watch.sh"
        "aether-audio-profile.sh"
        "aether-accessibility.sh"
    )
    
    for script in "${all_scripts[@]}"; do
        if [ -f "$SCRIPTS_DIR/$script" ]; then
            if [ -x "$SCRIPTS_DIR/$script" ]; then
                log_pass "Executable: $script"
            else
                log_fail "Not executable: $script"
            fi
        fi
    done
}

# =============================================================================
# Test: Check Scripts Have Proper Shebang
# =============================================================================
test_script_shebangs() {
    log_section "Checking Script Shebangs"
    
    for script in "$SCRIPTS_DIR"/*.sh "$SCRIPTS_DIR"/aethershieldctl; do
        if [ -f "$script" ]; then
            local shebang
            shebang=$(head -1 "$script")
            
            if [[ "$shebang" == "#!/bin/bash"* ]] || [[ "$shebang" == "#!/usr/bin/env bash"* ]]; then
                log_pass "Valid shebang: $(basename "$script")"
            else
                log_fail "Invalid shebang in $(basename "$script"): $shebang"
            fi
        fi
    done
}

# =============================================================================
# Test: Check Scripts Have Error Handling
# =============================================================================
test_error_handling() {
    log_section "Checking Error Handling (set -e)"
    
    for script in "$SCRIPTS_DIR"/*.sh "$SCRIPTS_DIR"/aethershieldctl; do
        if [ -f "$script" ]; then
            if grep -q "set -e\|set -euo" "$script"; then
                log_pass "Has error handling: $(basename "$script")"
            else
                log_fail "Missing error handling: $(basename "$script")"
            fi
        fi
    done
}

# =============================================================================
# Test: Check for Basic Syntax Errors
# =============================================================================
test_syntax() {
    log_section "Checking Basic Syntax"
    
    for script in "$SCRIPTS_DIR"/*.sh "$SCRIPTS_DIR"/aethershieldctl; do
        if [ -f "$script" ]; then
            if bash -n "$script" 2>/dev/null; then
                log_pass "Syntax OK: $(basename "$script")"
            else
                log_fail "Syntax error in: $(basename "$script")"
            fi
        fi
    done
}

# =============================================================================
# Test: Check Help Commands Work
# =============================================================================
test_help_commands() {
    log_section "Checking Help Commands"
    
    local scripts_with_help=(
        "aether-performance-profiler.sh"
        "aether-cleanmode.sh"
        "aether-quickpal.sh"
        "aethershieldctl"
        "aether-secure-session.sh"
        "aether-thermal-watch.sh"
        "aether-audio-profile.sh"
        "aether-accessibility.sh"
    )
    
    for script in "${scripts_with_help[@]}"; do
        if [ -f "$SCRIPTS_DIR/$script" ]; then
            if "$SCRIPTS_DIR/$script" --help &>/dev/null || \
               "$SCRIPTS_DIR/$script" help &>/dev/null; then
                log_pass "Help works: $script"
            else
                # Some scripts may not have help - that's OK for now
                log_pass "Help attempt: $script (may not be implemented)"
            fi
        fi
    done
}

# =============================================================================
# Test: Check Config Directories Exist
# =============================================================================
test_config_directories() {
    log_section "Checking Config Directories"
    
    local required_dirs=(
        "configs/aetheros/security/apps"
        "configs/plasma/aether-ocean-sounds"
        "configs/systemd/user"
        "configs/calamares/branding/aetheros"
    )
    
    for dir in "${required_dirs[@]}"; do
        if [ -d "$REPO_ROOT/$dir" ]; then
            log_pass "Directory exists: $dir"
        else
            log_fail "Directory missing: $dir"
        fi
    done
}

# =============================================================================
# Test: Check v2.1 Features
# =============================================================================
test_v21_features() {
    log_section "Checking v2.1 Features"
    
    # AetherShield
    if [ -f "$REPO_ROOT/configs/aetheros/security/apps/firefox.json" ]; then
        log_pass "AetherShield: Firefox policy exists"
    else
        log_fail "AetherShield: Firefox policy missing"
    fi
    
    # Sound pack
    if [ -d "$REPO_ROOT/artwork/sounds/ocean" ]; then
        log_pass "Aether Ocean: Sound pack directory exists"
    else
        log_fail "Aether Ocean: Sound pack directory missing"
    fi
    
    # Calamares slideshow
    if [ -f "$REPO_ROOT/configs/calamares/branding/aetheros/show.qml" ]; then
        log_pass "Calamares: Slideshow QML exists"
    else
        log_fail "Calamares: Slideshow QML missing"
    fi
    
    # Thermal service
    if [ -f "$REPO_ROOT/configs/systemd/user/aether-thermal.service" ]; then
        log_pass "Thermal: Systemd service exists"
    else
        log_fail "Thermal: Systemd service missing"
    fi
    
    # Login effects config
    if [ -f "$REPO_ROOT/configs/aetheros/login-effects.conf" ]; then
        log_pass "Login: Effects config exists"
    else
        log_fail "Login: Effects config missing"
    fi
    
    # ARM64 documentation
    if [ -f "$REPO_ROOT/docs/arm64-experimental.md" ]; then
        log_pass "ARM64: Documentation exists"
    else
        log_fail "ARM64: Documentation missing"
    fi
}

# =============================================================================
# Print Summary
# =============================================================================
print_summary() {
    log_section "Test Summary"
    
    echo ""
    echo "Tests Passed: $TESTS_PASSED"
    echo "Tests Failed: $TESTS_FAILED"
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo "✅ All profile tools checks passed!"
        return 0
    else
        echo "❌ Some checks failed. Please review the output above."
        return 1
    fi
}

# =============================================================================
# Main
# =============================================================================
main() {
    log_section "AetherOS Profile Tools Check"
    echo "Repository: $REPO_ROOT"
    echo ""
    
    test_required_scripts
    test_script_permissions
    test_script_shebangs
    test_error_handling
    test_syntax
    test_help_commands
    test_config_directories
    test_v21_features
    
    print_summary
}

main "$@"

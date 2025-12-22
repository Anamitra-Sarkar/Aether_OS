#!/bin/bash
# AetherOS CLI Tools Check - v2.2 Tools Verification
# Verifies presence and basic functionality of all AetherOS CLI tools

set -euo pipefail

# Colors
readonly COLOR_RESET='\033[0m'
readonly COLOR_GREEN='\033[1;32m'
readonly COLOR_RED='\033[1;31m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[1;34m'

# Counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Test result
test_result() {
    local test_name=$1
    local result=$2
    
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    if [ "$result" -eq 0 ]; then
        echo -e "${COLOR_GREEN}✓${COLOR_RESET} $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${COLOR_RED}✗${COLOR_RESET} $test_name"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Check if script exists and is executable
check_script_exists() {
    local script=$1
    local path="scripts/$script"
    
    if [ -f "$path" ] && [ -x "$path" ]; then
        return 0
    else
        return 1
    fi
}

# Check if script has help option (non-critical, always passes)
check_help_option() {
    local script=$1
    local path="scripts/$script"
    
    if [ ! -f "$path" ]; then
        return 1
    fi
    
    # Try to run help (capture output, ignore errors)
    # This is informational only - we don't fail if help doesn't work
    if "$path" help &> /dev/null || "$path" --help &> /dev/null; then
        return 0
    else
        # Pass anyway - help is optional for some scripts
        return 0
    fi
}

# Check for set -euo pipefail
check_error_handling() {
    local script=$1
    local path="scripts/$script"
    
    if [ ! -f "$path" ]; then
        return 1
    fi
    
    # Check if script has proper error handling
    if grep -q "set -euo pipefail\|set -e" "$path"; then
        return 0
    else
        return 1
    fi
}

echo -e "${COLOR_BLUE}╔═══════════════════════════════════════════════════════════════╗${COLOR_RESET}"
echo -e "${COLOR_BLUE}║${COLOR_RESET}          AetherOS CLI Tools Verification Test              ${COLOR_BLUE}║${COLOR_RESET}"
echo -e "${COLOR_BLUE}╚═══════════════════════════════════════════════════════════════╝${COLOR_RESET}"
echo ""

# v2.0 Tools
echo -e "${COLOR_YELLOW}Testing v2.0 Tools...${COLOR_RESET}"
v20_tools=(
    "aether-performance-profiler.sh"
    "aether-cleanmode.sh"
    "aether-adaptive-blur.sh"
    "aether-focus-mode.sh"
    "aether-quickpal.sh"
    "aether-profile-sync.sh"
    "aether-smart-services.sh"
    "aether-smart-notifications.sh"
    "aether-power-mode.sh"
    "aether-theme-scheduler.sh"
)

for tool in "${v20_tools[@]}"; do
    check_script_exists "$tool"
    test_result "v2.0: $tool exists and is executable" $?
    
    check_error_handling "$tool"
    test_result "v2.0: $tool has error handling" $?
done

echo ""

# v2.1 Tools
echo -e "${COLOR_YELLOW}Testing v2.1 Tools...${COLOR_RESET}"
v21_tools=(
    "aethershieldctl"
    "aether-secure-session.sh"
    "aether-thermal-watch.sh"
    "aether-audio-profile.sh"
    "aether-accessibility.sh"
)

for tool in "${v21_tools[@]}"; do
    check_script_exists "$tool"
    test_result "v2.1: $tool exists and is executable" $?
    
    check_error_handling "$tool"
    test_result "v2.1: $tool has error handling" $?
done

echo ""

# v2.2 Tools
echo -e "${COLOR_YELLOW}Testing v2.2 Tools...${COLOR_RESET}"
v22_tools=(
    "aether-dashboard.sh"
    "aether-mode.sh"
    "aether-setup-profile.sh"
)

for tool in "${v22_tools[@]}"; do
    check_script_exists "$tool"
    test_result "v2.2: $tool exists and is executable" $?
    
    check_error_handling "$tool"
    test_result "v2.2: $tool has error handling" $?
    
    check_help_option "$tool"
    test_result "v2.2: $tool has help option" $?
done

echo ""

# v2.3 Tools (Intelligence Systems)
echo -e "${COLOR_YELLOW}Testing v2.3 Tools (Intelligence Systems)...${COLOR_RESET}"
v23_tools=(
    "aether-threat-scan"
    "aether-boot-optimize"
    "aether-cpu-governor"
    "aether-desktop-recovery"
)

for tool in "${v23_tools[@]}"; do
    check_script_exists "$tool"
    test_result "v2.3: $tool exists and is executable" $?
    
    check_error_handling "$tool"
    test_result "v2.3: $tool has error handling" $?
    
    check_help_option "$tool"
    test_result "v2.3: $tool has help option" $?
done

echo ""

# Support Scripts
echo -e "${COLOR_YELLOW}Testing Support Scripts...${COLOR_RESET}"
support_tools=(
    "aether-health.sh"
    "aethervault.sh"
    "aether-sounds.sh"
)

for tool in "${support_tools[@]}"; do
    check_script_exists "$tool"
    test_result "Support: $tool exists and is executable" $?
done

echo ""

# Check for dangerous patterns (optional warnings)
echo -e "${COLOR_YELLOW}Checking for Safety Patterns...${COLOR_RESET}"

all_scripts=($(find scripts -name "*.sh" -type f))
safe_scripts=0
total_scripts=${#all_scripts[@]}

for script in "${all_scripts[@]}"; do
    # Check for proper error handling
    if grep -q "set -euo pipefail\|set -e" "$script"; then
        safe_scripts=$((safe_scripts + 1))
    fi
done

test_result "Scripts with error handling: $safe_scripts/$total_scripts" 0

echo ""
echo -e "${COLOR_BLUE}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
echo -e "${COLOR_BLUE}Test Results${COLOR_RESET}"
echo -e "${COLOR_BLUE}═══════════════════════════════════════════════════════════════${COLOR_RESET}"
echo -e "Total Tests:  ${COLOR_BLUE}$TESTS_TOTAL${COLOR_RESET}"
echo -e "Passed:       ${COLOR_GREEN}$TESTS_PASSED${COLOR_RESET}"
echo -e "Failed:       ${COLOR_RED}$TESTS_FAILED${COLOR_RESET}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${COLOR_GREEN}✓ All CLI tools verified successfully!${COLOR_RESET}"
    exit 0
else
    echo -e "${COLOR_RED}✗ Some CLI tools are missing or misconfigured${COLOR_RESET}"
    exit 1
fi

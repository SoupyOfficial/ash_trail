#!/bin/bash
# E2E Test Runner — default platform: iOS
# Uses an iOS simulator by default. Use this script for consistent iOS E2E runs.
#
# Usage: ./scripts/run_e2e_tests.sh [options] [test_file]
#
# Options:
#   --list-devices    List available iOS simulators
#   --full-isolation  Uninstall app from simulator before run, then reinstall (clean state)
#   --clean           Same as --full-isolation
#
# Examples:
#   ./scripts/run_e2e_tests.sh                           # Run all E2E tests on iOS
#   ./scripts/run_e2e_tests.sh app_e2e_test.dart         # Run specific test file
#   ./scripts/run_e2e_tests.sh --full-isolation          # Run with clean simulator state
#   ./scripts/run_e2e_tests.sh --list-devices            # List available iOS simulators

set -e

# Ensure we run from project root (script is in scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  AshTrail iOS E2E Test Runner${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# Handle --list-devices flag
if [ "$1" == "--list-devices" ]; then
    echo -e "${YELLOW}Available iOS Simulators:${NC}"
    xcrun simctl list devices available | grep -E "iPhone|iPad"
    exit 0
fi

# Parse optional --full-isolation / --clean
FULL_ISOLATION=""
while [ "$1" == "--full-isolation" ] || [ "$1" == "--clean" ]; do
    FULL_ISOLATION="--full-isolation"
    shift
done

# patrol 3.15.2 requires patrol_cli 3.5 or 3.6 (see compatibility table)
export PATH="$HOME/.pub-cache/bin:/Volumes/Jacob-SSD/BuildCache/pub-cache/bin:$PATH"
if ! command -v patrol &> /dev/null; then
    echo -e "${YELLOW}Patrol CLI not found. Installing patrol_cli 3.6.0...${NC}"
    dart pub global activate patrol_cli 3.6.0
    echo -e "${YELLOW}If 'patrol' still not found, add the path shown above to your PATH.${NC}"
else
    echo -e "${BLUE}Ensuring patrol_cli 3.6.0 (required for patrol 3.15.2)...${NC}"
    dart pub global activate patrol_cli 3.6.0
fi

# Ensure dependencies are up to date
echo -e "${BLUE}📦 Checking dependencies...${NC}"
flutter pub get

# Find an available iOS simulator
echo -e "${BLUE}📱 Finding iOS simulator...${NC}"
DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone 15" | head -1 | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}' || true)

if [ -z "$DEVICE_ID" ]; then
    # Fallback to any available iPhone
    DEVICE_ID=$(xcrun simctl list devices available | grep "iPhone" | head -1 | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}' || true)
fi

if [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}❌ No iOS simulator found. Please install Xcode and iOS simulators.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Using simulator: $DEVICE_ID${NC}"

# Check if simulator is already booted
BOOTED=$(xcrun simctl list devices | grep "$DEVICE_ID" | grep -c "Booted" || true)
if [ "$BOOTED" -eq 0 ]; then
    echo -e "${BLUE}🚀 Booting iOS simulator...${NC}"
    xcrun simctl boot "$DEVICE_ID" || true
    sleep 5
fi

# Determine test file (default: Patrol E2E as primary runner)
if [ -n "$1" ]; then
    TEST_FILE="integration_test/$1"
    if [ ! -f "$TEST_FILE" ]; then
        TEST_FILE="$1"
    fi
else
    # Default to Patrol E2E test (primary E2E runner for iOS simulator)
    TEST_FILE="integration_test/app_e2e_test.dart"
fi

if [ -n "$FULL_ISOLATION" ]; then
    echo -e "${BLUE}Using full isolation (clean simulator state)...${NC}"
fi

echo -e "${BLUE}🧪 Running E2E tests: $TEST_FILE${NC}"
echo ""

# Check if test file uses Patrol
if grep -q "patrol" "$TEST_FILE" 2>/dev/null; then
    # Use Patrol for patrol-based tests
    if command -v patrol &> /dev/null; then
        echo -e "${BLUE}Using Patrol test runner...${NC}"
        
        # Pre-build the Pods_Runner_RunnerUITests framework (workaround for implicit dependency not building)
        echo -e "${BLUE}🔧 Pre-building Pods-Runner-RunnerUITests framework...${NC}"
        cd ios && xcodebuild -project Pods/Pods.xcodeproj \
            -target "Pods-Runner-RunnerUITests" \
            -configuration Debug \
            -sdk iphonesimulator \
            -quiet \
            BUILD_DIR="../build/ios_integ/Build" \
            CONFIGURATION_BUILD_DIR="../build/ios_integ/Build/Products/Debug-iphonesimulator" \
            2>&1 | tail -5
        cd ..
        echo -e "${GREEN}✅ Pods-Runner-RunnerUITests framework built${NC}"
        
        patrol test \
            --target "$TEST_FILE" \
            --device "$DEVICE_ID" \
            --debug \
            $FULL_ISOLATION \
            --verbose \
            && echo -e "${GREEN}✅ Patrol tests passed!${NC}" \
            || {
                echo -e "${YELLOW}⚠️ Patrol tests failed${NC}"
                exit 1
            }
    else
        echo -e "${RED}❌ Test file requires Patrol but Patrol CLI is not installed${NC}"
        exit 1
    fi
else
    # Use flutter drive for standard integration tests
    echo -e "${BLUE}Using flutter drive test runner...${NC}"
    flutter drive \
        --driver=test_driver/integration_test.dart \
        --target="$TEST_FILE" \
        --device-id="$DEVICE_ID" \
        --no-pub \
        && echo -e "${GREEN}✅ Integration tests passed!${NC}" \
        || {
            echo -e "${RED}❌ Integration tests failed${NC}"
            exit 1
        }
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  E2E Test Run Complete${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"

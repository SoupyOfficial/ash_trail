#!/bin/bash
# E2E Test Runner for iOS Simulator
# Usage: ./scripts/run_e2e_tests.sh [test_file]
#
# Examples:
#   ./scripts/run_e2e_tests.sh                           # Run all E2E tests
#   ./scripts/run_e2e_tests.sh app_e2e_test.dart         # Run specific test file
#   ./scripts/run_e2e_tests.sh --list-devices            # List available simulators

set -e

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

# Check if Patrol CLI is installed
if ! command -v patrol &> /dev/null; then
    echo -e "${YELLOW}Patrol CLI not found. Installing...${NC}"
    dart pub global activate patrol_cli
    export PATH="$PATH:$HOME/.pub-cache/bin"
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

# Determine test file
if [ -n "$1" ]; then
    TEST_FILE="integration_test/$1"
    if [ ! -f "$TEST_FILE" ]; then
        TEST_FILE="$1"
    fi
else
    # Default to comprehensive test which uses standard flutter integration test
    TEST_FILE="integration_test/comprehensive_e2e_test.dart"
fi

echo -e "${BLUE}🧪 Running E2E tests: $TEST_FILE${NC}"
echo ""

# Check if test file uses Patrol
if grep -q "patrol" "$TEST_FILE" 2>/dev/null; then
    # Use Patrol for patrol-based tests
    if command -v patrol &> /dev/null; then
        echo -e "${BLUE}Using Patrol test runner...${NC}"
        patrol test \
            --target "$TEST_FILE" \
            --device "$DEVICE_ID" \
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

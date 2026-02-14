#!/bin/bash

# Comprehensive screenshot capture script
# Navigates through all app screens and captures screenshots for Figma
# Usage: ./scripts/capture_all_screens.sh [device-id]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

DEVICE_ID="${1:-}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SCREENSHOT_DIR="screenshots/flutter/$TIMESTAMP"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Comprehensive Screenshot Capture for Figma${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found${NC}"
    exit 1
fi

# List devices
echo -e "${BLUE}Available devices:${NC}"
flutter devices
echo ""

# Get device ID
if [ -z "$DEVICE_ID" ]; then
    # Try to find iOS simulator first
    DEVICE_ID=$(flutter devices | grep -i "simulator" | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}' | head -1)
    
    if [ -z "$DEVICE_ID" ]; then
        DEVICE_ID=$(flutter devices | grep -E '^[^ ]+ •' | head -1 | awk '{print $1}')
    fi
    
    if [ -z "$DEVICE_ID" ]; then
        echo -e "${RED}❌ No devices found${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}Using device: $DEVICE_ID${NC}"
echo ""

# Create output directory
mkdir -p "$SCREENSHOT_DIR"
echo -e "${BLUE}Screenshots will be saved to:${NC}"
echo -e "${GREEN}$SCREENSHOT_DIR${NC}"
echo ""

# Method 1: Use integration test (recommended)
echo -e "${BLUE}Method 1: Automated Navigation (Recommended)${NC}"
echo -e "${YELLOW}This will run an integration test that navigates through all screens${NC}"
echo ""
read -p "Run automated navigation test? (y/n): " run_test

if [[ "$run_test" == "y" ]]; then
    echo ""
    echo -e "${BLUE}Running integration test for screenshot capture...${NC}"
    echo -e "${YELLOW}This may take 1-2 minutes...${NC}"
    echo ""
    
    # Run the integration test
    flutter drive \
        --driver=test_driver/integration_test.dart \
        --target=integration_test/figma_screenshot_capture.dart \
        -d "$DEVICE_ID" \
        2>&1 | tee "$PROJECT_ROOT/build/logs/flutter_screenshot.log"
    
    # Check for screenshots in integration_test/screenshots/
    if [ -d "integration_test/screenshots" ]; then
        echo ""
        echo -e "${GREEN}✅ Screenshots captured by integration test${NC}"
        echo -e "${BLUE}Moving screenshots to organized directory...${NC}"
        
        # Move screenshots to our organized directory
        mv integration_test/screenshots/*.png "$SCREENSHOT_DIR/" 2>/dev/null || true
        
        # Also check for flutter_*.png files in current directory
        if ls flutter_*.png 1> /dev/null 2>&1; then
            mv flutter_*.png "$SCREENSHOT_DIR/" 2>/dev/null || true
        fi
        
        echo -e "${GREEN}✅ Screenshots organized in: $SCREENSHOT_DIR${NC}"
    fi
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Method 2: Manual Capture Guide${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}If automated capture didn't work, follow these steps:${NC}"
echo ""
echo -e "${GREEN}1. Start your app:${NC}"
echo -e "   flutter run -d $DEVICE_ID"
echo ""
echo -e "${GREEN}2. Wait for app to fully load${NC}"
echo ""
echo -e "${GREEN}3. Navigate to each screen and capture:${NC}"
echo ""

# Define all screens
declare -A SCREENS=(
    ["home"]="Home Screen (tap Home in bottom nav)"
    ["analytics"]="Analytics Screen (tap Analytics in bottom nav)"
    ["history"]="History Screen (tap History in bottom nav)"
    ["logging"]="Logging Screen (tap Log in bottom nav)"
    ["accounts"]="Accounts Screen (tap account icon in app bar)"
    ["export"]="Export Screen (navigate from menu)"
    ["profile"]="Profile Screen (navigate from menu)"
)

for screen in "${!SCREENS[@]}"; do
    description="${SCREENS[$screen]}"
    echo -e "${BLUE}   $screen.png${NC} - $description"
    echo -e "   ${YELLOW}   Command:${NC} flutter screenshot -d $DEVICE_ID $SCREENSHOT_DIR/$screen.png"
    echo ""
done

echo -e "${GREEN}4. After capturing all screens:${NC}"
echo -e "   ./scripts/prepare_figma_import.sh"
echo ""

# Check if app is running
if pgrep -f "flutter run" > /dev/null; then
    echo -e "${GREEN}✅ App appears to be running${NC}"
    echo ""
    echo -e "${YELLOW}You can now manually navigate and capture screenshots${NC}"
    echo -e "${YELLOW}Or wait for the integration test to complete${NC}"
else
    echo -e "${YELLOW}⚠️  App is not running. Start it with:${NC}"
    echo -e "   ${GREEN}flutter run -d $DEVICE_ID${NC}"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Screenshot directory: $SCREENSHOT_DIR${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"

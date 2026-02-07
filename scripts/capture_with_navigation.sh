#!/bin/bash

# Script to capture screenshots with proper app navigation
# This ensures the app is fully loaded and navigates through all screens

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
echo -e "${BLUE}  Screenshot Capture with Full Navigation${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found${NC}"
    exit 1
fi

# Get device
if [ -z "$DEVICE_ID" ]; then
    DEVICE_ID=$(flutter devices | grep -i "simulator" | grep -oE '[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}' | head -1)
    if [ -z "$DEVICE_ID" ]; then
        DEVICE_ID=$(flutter devices | grep -E '^[^ ]+ •' | head -1 | awk '{print $1}')
    fi
fi

if [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}❌ No devices found${NC}"
    exit 1
fi

echo -e "${GREEN}Using device: $DEVICE_ID${NC}"
mkdir -p "$SCREENSHOT_DIR"
echo -e "${BLUE}Screenshots directory: $SCREENSHOT_DIR${NC}"
echo ""

# Check if app is running
if ! pgrep -f "flutter run.*$DEVICE_ID" > /dev/null; then
    echo -e "${YELLOW}Starting Flutter app...${NC}"
    echo -e "${BLUE}This will take 30-60 seconds. Please wait...${NC}"
    echo ""
    
    # Start app in background
    mkdir -p "$PROJECT_ROOT/build/logs"
    flutter run -d "$DEVICE_ID" > "$PROJECT_ROOT/build/logs/flutter_app.log" 2>&1 &
    APP_PID=$!
    
    # Wait for app to start
    echo -e "${YELLOW}Waiting for app to initialize (30 seconds)...${NC}"
    sleep 30
    
    # Check if app started
    if ! kill -0 $APP_PID 2>/dev/null; then
        echo -e "${RED}❌ App failed to start. Check build/logs/flutter_app.log${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ App is running${NC}"
else
    echo -e "${GREEN}✅ App is already running${NC}"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Manual Navigation Instructions${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Please navigate to each screen in your app and press Enter${NC}"
echo -e "${YELLOW}when ready to capture. The script will wait for your input.${NC}"
echo ""

# Define screens with navigation instructions
declare -A SCREENS=(
    ["01_home"]="Home Screen - Main screen (should be visible by default)"
    ["02_analytics"]="Analytics Screen - Tap 'Analytics' in bottom navigation"
    ["03_history"]="History Screen - Tap 'History' in bottom navigation"
    ["04_logging"]="Logging Screen - Tap 'Log' in bottom navigation"
    ["05_accounts"]="Accounts Screen - Tap account icon in app bar"
    ["06_export"]="Export Screen - Navigate from menu if available"
    ["07_profile"]="Profile Screen - Navigate from menu if available"
)

for screen in "${!SCREENS[@]}"; do
    description="${SCREENS[$screen]}"
    screen_name="${screen#*_}"  # Remove number prefix
    
    echo -e "${BLUE}───────────────────────────────────────────────${NC}"
    echo -e "${GREEN}Screen: $screen_name${NC}"
    echo -e "${YELLOW}$description${NC}"
    echo ""
    read -p "Navigate to this screen, then press Enter to capture... "
    
    # Wait a moment for screen to settle
    sleep 1
    
    # Capture screenshot
    echo -e "${BLUE}Capturing screenshot...${NC}"
    
    if flutter screenshot -d "$DEVICE_ID" "$SCREENSHOT_DIR/${screen_name}.png" 2>&1 | grep -q "Screenshot written"; then
        # Check for flutter_*.png in current directory
        LATEST=$(ls -t flutter_*.png 2>/dev/null | head -1)
        if [ -n "$LATEST" ] && [ -f "$LATEST" ]; then
            mv "$LATEST" "$SCREENSHOT_DIR/${screen_name}.png"
            echo -e "${GREEN}✅ Captured: ${screen_name}.png${NC}"
        elif [ -f "$SCREENSHOT_DIR/${screen_name}.png" ]; then
            echo -e "${GREEN}✅ Captured: ${screen_name}.png${NC}"
        else
            echo -e "${YELLOW}⚠️  Screenshot may be in current directory${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Could not capture automatically${NC}"
        echo -e "${YELLOW}   Please use: Cmd+S in simulator or device screenshot${NC}"
        echo -e "${YELLOW}   Save to: $SCREENSHOT_DIR/${screen_name}.png${NC}"
    fi
    
    echo ""
done

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Screenshot capture complete!${NC}"
echo -e "${BLUE}Screenshots saved to: $SCREENSHOT_DIR${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Review screenshots: ${GREEN}ls -lh $SCREENSHOT_DIR${NC}"
echo -e "2. Prepare for Figma: ${GREEN}./scripts/prepare_figma_import.sh${NC}"
echo -e "3. Import to Figma using the generated guide"
echo ""

# Cleanup
if [ ! -z "$APP_PID" ]; then
    echo -e "${YELLOW}App is still running (PID: $APP_PID)${NC}"
    echo -e "${YELLOW}Press Ctrl+C in the app terminal to stop, or:${NC}"
    echo -e "${YELLOW}kill $APP_PID${NC}"
fi

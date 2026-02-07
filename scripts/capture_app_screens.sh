#!/bin/bash

# Reliable screenshot capture that ensures app is actually open and visible
# Usage: ./scripts/capture_app_screens.sh [device-id]

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
echo -e "${BLUE}  App Screenshot Capture (Ensures App is Open)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

mkdir -p "$SCREENSHOT_DIR"

# Step 1: Build and install app
echo -e "${BLUE}Step 1: Building and installing app...${NC}"
flutter build ios --simulator --no-codesign 2>&1 | tail -5
echo ""

# Step 2: Install on simulator
echo -e "${BLUE}Step 2: Installing app on simulator...${NC}"
xcrun simctl install "$DEVICE_ID" build/ios/iphonesimulator/Runner.app 2>&1 | grep -v "^$" || echo "App installed (or already installed)"
echo ""

# Step 3: Launch app directly on simulator
echo -e "${BLUE}Step 3: Launching app on simulator...${NC}"
# Try to get bundle ID from Info.plist
BUNDLE_ID=$(plutil -extract CFBundleIdentifier raw ios/Runner/Info.plist 2>/dev/null || echo "com.example.ashTrail")

xcrun simctl launch "$DEVICE_ID" "$BUNDLE_ID" 2>&1 || {
    echo -e "${YELLOW}Could not launch via simctl, will use flutter run instead${NC}"
    echo -e "${BLUE}Starting app with flutter run...${NC}"
    echo -e "${YELLOW}This will open the app. Please wait for it to fully load...${NC}"
    mkdir -p "$PROJECT_ROOT/build/logs"
    flutter run -d "$DEVICE_ID" > "$PROJECT_ROOT/build/logs/flutter_app.log" 2>&1 &
    APP_PID=$!
    echo -e "${YELLOW}Waiting 45 seconds for app to fully load and render...${NC}"
    sleep 45
    echo -e "${GREEN}App should be running now${NC}"
}

# Step 4: Bring simulator to front and wait
echo -e "${BLUE}Step 4: Ensuring simulator is in focus...${NC}"
open -a Simulator 2>/dev/null || true
sleep 2

# Step 5: Wait for app to be visible
echo -e "${YELLOW}Waiting 5 more seconds for app UI to render...${NC}"
sleep 5

# Step 6: Capture screenshots with verification
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Capturing Screenshots${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}IMPORTANT: Make sure the Ash Trail app is visible on screen${NC}"
echo -e "${YELLOW}If you see the home screen, tap the Ash Trail app icon to open it${NC}"
echo ""

read -p "Is the Ash Trail app currently visible and open? (y/n): " app_visible

if [[ "$app_visible" != "y" ]]; then
    echo -e "${YELLOW}Please open the Ash Trail app manually, then press Enter...${NC}"
    read -p "Press Enter when app is open and visible... "
fi

# Capture initial screen
echo ""
echo -e "${BLUE}Capturing current screen...${NC}"
flutter screenshot -d "$DEVICE_ID" "$SCREENSHOT_DIR/01_initial.png" 2>&1 | grep -E "(Screenshot|written)" || true

# Move any flutter_*.png files
if ls flutter_*.png 1> /dev/null 2>&1; then
    mv flutter_*.png "$SCREENSHOT_DIR/" 2>/dev/null || true
fi

# Verify screenshot shows app content
echo ""
echo -e "${BLUE}Verifying screenshot...${NC}"
if [ -f "$SCREENSHOT_DIR/flutter_01.png" ] || [ -f "$SCREENSHOT_DIR/01_initial.png" ]; then
    SCREENSHOT_FILE=$(ls -t "$SCREENSHOT_DIR"/*.png 2>/dev/null | head -1)
    if [ -n "$SCREENSHOT_FILE" ]; then
        SIZE=$(stat -f%z "$SCREENSHOT_FILE" 2>/dev/null || stat -c%s "$SCREENSHOT_FILE" 2>/dev/null)
        if [ "$SIZE" -gt 1000000 ]; then
            echo -e "${GREEN}✅ Screenshot captured: $(basename "$SCREENSHOT_FILE")${NC}"
            echo -e "${GREEN}   Size: $(echo "scale=1; $SIZE/1024/1024" | bc)MB${NC}"
        fi
    fi
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Manual Navigation Guide${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Now navigate through your app and capture each screen:${NC}"
echo ""

declare -A SCREENS=(
    ["home"]="Home Screen - Main screen"
    ["analytics"]="Analytics - Tap 'Analytics' in bottom nav"
    ["history"]="History - Tap 'History' in bottom nav"
    ["logging"]="Logging - Tap 'Log' in bottom nav"
    ["accounts"]="Accounts - Tap account icon in app bar"
)

for screen in "${!SCREENS[@]}"; do
    description="${SCREENS[$screen]}"
    echo -e "${GREEN}$screen${NC} - $description"
    read -p "Navigate to this screen, then press Enter to capture... "
    
    sleep 1
    echo -e "${BLUE}Capturing $screen...${NC}"
    flutter screenshot -d "$DEVICE_ID" "$SCREENSHOT_DIR/$screen.png" 2>&1 | grep -E "(Screenshot|written)" || true
    
    # Move flutter_*.png if created
    if ls flutter_*.png 1> /dev/null 2>&1; then
        LATEST=$(ls -t flutter_*.png | head -1)
        mv "$LATEST" "$SCREENSHOT_DIR/$screen.png" 2>/dev/null || true
    fi
    
    if [ -f "$SCREENSHOT_DIR/$screen.png" ]; then
        SIZE=$(stat -f%z "$SCREENSHOT_DIR/$screen.png" 2>/dev/null || stat -c%s "$SCREENSHOT_DIR/$screen.png" 2>/dev/null)
        echo -e "${GREEN}✅ Captured: $screen.png ($(echo "scale=1; $SIZE/1024/1024" | bc)MB)${NC}"
    fi
    echo ""
done

echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Screenshot capture complete!${NC}"
echo -e "${BLUE}Screenshots saved to: $SCREENSHOT_DIR${NC}"
echo ""
echo -e "${BLUE}Next:${NC}"
echo -e "  ${GREEN}./scripts/prepare_figma_import.sh${NC}"

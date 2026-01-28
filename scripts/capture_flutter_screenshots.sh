#!/bin/bash

# Script to capture Flutter app screenshots for Figma import
# Usage: ./scripts/capture_flutter_screenshots.sh [device-id] [output-dir]

set -e

# Configuration
OUTPUT_DIR="${2:-screenshots/flutter}"
DEVICE_ID="${1:-}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SCREENSHOT_DIR="${OUTPUT_DIR}/${TIMESTAMP}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}📸 Flutter Screenshot Capture for Figma${NC}"
echo "=================================="

# Create output directory
mkdir -p "$SCREENSHOT_DIR"

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}❌ Flutter not found. Please install Flutter first.${NC}"
    exit 1
fi

# List available devices
echo -e "\n${BLUE}Available devices:${NC}"
flutter devices

# Get device ID if not provided
if [ -z "$DEVICE_ID" ]; then
    echo -e "\n${YELLOW}No device specified. Using first available device.${NC}"
    DEVICE_ID=$(flutter devices | grep -E '^[^ ]+ •' | head -1 | awk '{print $1}')
    if [ -z "$DEVICE_ID" ]; then
        echo -e "${YELLOW}❌ No devices found. Please start an emulator/simulator or connect a device.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Using device: $DEVICE_ID${NC}"
fi

# Check if app is already running
echo -e "\n${BLUE}Checking if app is running...${NC}"
if ! pgrep -f "flutter run" > /dev/null; then
    echo -e "${YELLOW}App is not running. You need to start it first.${NC}"
    echo -e "${YELLOW}Run: ${GREEN}flutter run -d $DEVICE_ID${NC}"
    echo -e "${YELLOW}Then run this script again, or use the manual capture script:${NC}"
    echo -e "${GREEN}./scripts/capture_screenshots_manual.sh${NC}"
    echo ""
    echo -e "${YELLOW}Alternatively, you can let this script start the app (may be slower)...${NC}"
    read -p "Start app now? (y/n): " start_app
    if [[ "$start_app" == "y" ]]; then
        echo -e "\n${BLUE}Building and launching app...${NC}"
        flutter run -d "$DEVICE_ID" &
        APP_PID=$!
        echo -e "${YELLOW}Waiting 15 seconds for app to initialize...${NC}"
        sleep 15
    else
        echo -e "${YELLOW}Please start the app manually and run this script again.${NC}"
        exit 0
    fi
else
    echo -e "${GREEN}✓ App appears to be running${NC}"
    echo -e "${YELLOW}Waiting 3 seconds to ensure app is ready...${NC}"
    sleep 3
fi

# Define screens to capture (you can customize this list)
SCREENS=(
    "home"
    "analytics"
    "history"
    "logging"
    "accounts"
    "export"
    "profile"
)

echo -e "\n${BLUE}Capturing screenshots...${NC}"
echo -e "${YELLOW}Note: You may need to manually navigate to each screen.${NC}"
echo -e "${YELLOW}Or use Flutter's integration_test framework for automated navigation.${NC}"

# Capture screenshots using Flutter's screenshot command
# Note: This requires the app to be running and you may need to navigate manually
for screen in "${SCREENS[@]}"; do
    echo -e "\n${BLUE}Capturing: $screen${NC}"
    
    # Try to capture screenshot
    # Note: flutter screenshot may save to current directory with auto-generated name
    # We'll capture and move it to the correct location
    if flutter screenshot -d "$DEVICE_ID" "${SCREENSHOT_DIR}/${screen}.png" 2>&1 | grep -q "Screenshot written"; then
        # Check if file was created in current directory (Flutter sometimes does this)
        LATEST_SCREENSHOT=$(ls -t flutter_*.png 2>/dev/null | head -1)
        if [ -n "$LATEST_SCREENSHOT" ] && [ -f "$LATEST_SCREENSHOT" ]; then
            mv "$LATEST_SCREENSHOT" "${SCREENSHOT_DIR}/${screen}.png"
            echo -e "${GREEN}✓ Captured ${screen}.png${NC}"
        elif [ -f "${SCREENSHOT_DIR}/${screen}.png" ]; then
            echo -e "${GREEN}✓ Captured ${screen}.png${NC}"
        else
            echo -e "${YELLOW}⚠ Screenshot captured but location unclear. Check current directory.${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ Could not auto-capture ${screen}. Please capture manually.${NC}"
        echo -e "${YELLOW}   You can use: flutter screenshot -d $DEVICE_ID${NC}"
        echo -e "${YELLOW}   Then move the generated flutter_*.png file to: ${SCREENSHOT_DIR}/${screen}.png${NC}"
    fi
    
    # Small delay between captures
    sleep 2
done

# Alternative: Manual capture instructions
echo -e "\n${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Manual Screenshot Instructions:${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}If automatic capture didn't work, you can:${NC}"
echo -e "1. Navigate to each screen in your app"
echo -e "2. Run: flutter screenshot -d $DEVICE_ID ${SCREENSHOT_DIR}/<screen-name>.png"
echo -e "3. Or use device-specific screenshot tools:"
echo -e "   - iOS Simulator: Cmd+S or Device > Screenshot"
echo -e "   - Android Emulator: Click camera icon in toolbar"
echo -e "   - Physical device: Use device screenshot shortcut"

# Create a manifest file
cat > "${SCREENSHOT_DIR}/manifest.json" << EOF
{
  "timestamp": "$TIMESTAMP",
  "device": "$DEVICE_ID",
  "screenshots": [
$(for screen in "${SCREENS[@]}"; do
    if [ -f "${SCREENSHOT_DIR}/${screen}.png" ]; then
        echo "    {\"name\": \"$screen\", \"file\": \"${screen}.png\"},"
    fi
done | sed '$ s/,$//')
  ]
}
EOF

echo -e "\n${GREEN}✅ Screenshots saved to: ${SCREENSHOT_DIR}${NC}"
echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Review screenshots in: ${SCREENSHOT_DIR}"
echo -e "2. Import to Figma (see docs/figma-workflow.md)"
echo -e "3. Use Codia AI Design plugin to convert screenshots to editable designs"

# Cleanup
if [ ! -z "$APP_PID" ]; then
    echo -e "\n${YELLOW}App is still running (PID: $APP_PID). Press Ctrl+C to stop.${NC}"
fi

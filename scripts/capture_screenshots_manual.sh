#!/bin/bash

# Manual screenshot capture guide - simpler approach
# This script helps you capture screenshots step-by-step

set -e

# Configuration
OUTPUT_DIR="${1:-screenshots/flutter}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SCREENSHOT_DIR="${OUTPUT_DIR}/${TIMESTAMP}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📸 Manual Screenshot Capture Guide${NC}"
echo "======================================"
echo ""

# Create output directory
mkdir -p "$SCREENSHOT_DIR"

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${YELLOW}❌ Flutter not found${NC}"
    exit 1
fi

# List devices
echo -e "${BLUE}Available devices:${NC}"
flutter devices
echo ""

# Get device selection
echo -e "${YELLOW}Which device would you like to use?${NC}"
echo -e "1. iPhone 16 Pro Max (Simulator)"
echo -e "2. macOS (Desktop)"
echo -e "3. Chrome (Web)"
echo -e "4. Physical iOS device (Soupy)"
echo -e "5. Enter device ID manually"
read -p "Choice [1-5]: " choice

case $choice in
    1) DEVICE_ID="0A875592-129B-40B6-A072-A0C0CA94AED3" ;;
    2) DEVICE_ID="macos" ;;
    3) DEVICE_ID="chrome" ;;
    4) DEVICE_ID="00008140-0010589430A2201C" ;;
    5) 
        read -p "Enter device ID: " DEVICE_ID
        ;;
    *)
        echo -e "${YELLOW}Using first available device${NC}"
        DEVICE_ID=$(flutter devices | grep -E '^[^ ]+ •' | head -1 | awk '{print $1}')
        ;;
esac

echo -e "\n${GREEN}Using device: $DEVICE_ID${NC}"
echo ""

# Instructions
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${BLUE}Step-by-Step Instructions:${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}1. Start your Flutter app:${NC}"
echo -e "   ${GREEN}flutter run -d $DEVICE_ID${NC}"
echo ""
echo -e "${YELLOW}2. Wait for the app to fully load${NC}"
echo ""
echo -e "${YELLOW}3. Navigate to each screen and capture:${NC}"
echo ""

# Define screens
SCREENS=(
    "home:Home Screen"
    "analytics:Analytics Screen"
    "history:History Screen"
    "logging:Logging Screen"
    "accounts:Accounts Screen"
    "export:Export Screen"
    "profile:Profile Screen"
)

echo -e "${BLUE}Screenshots will be saved to:${NC}"
echo -e "${GREEN}$SCREENSHOT_DIR${NC}"
echo ""
echo -e "${BLUE}For each screen, use one of these methods:${NC}"
echo ""

# Method based on device type
if [[ "$DEVICE_ID" == *"simulator"* ]] || [[ "$DEVICE_ID" == *"iOS"* ]] || [[ "$DEVICE_ID" == *"AED3"* ]] || [[ "$DEVICE_ID" == *"A2201C"* ]]; then
    echo -e "${YELLOW}Method 1: iOS Simulator Screenshot${NC}"
    echo -e "   - Press ${GREEN}Cmd + S${NC} in the simulator"
    echo -e "   - Or: ${GREEN}Device > Screenshot${NC} from menu"
    echo -e "   - Save to: ${GREEN}$SCREENSHOT_DIR/<screen-name>.png${NC}"
    echo ""
    echo -e "${YELLOW}Method 2: Flutter Screenshot Command${NC}"
    echo -e "   - Navigate to the screen in your app"
    echo -e "   - Run: ${GREEN}flutter screenshot -d $DEVICE_ID $SCREENSHOT_DIR/<screen-name>.png${NC}"
    echo ""
elif [[ "$DEVICE_ID" == "macos" ]]; then
    echo -e "${YELLOW}Method 1: macOS Screenshot${NC}"
    echo -e "   - Press ${GREEN}Cmd + Shift + 4${NC} and select the app window"
    echo -e "   - Save to: ${GREEN}$SCREENSHOT_DIR/<screen-name>.png${NC}"
    echo ""
    echo -e "${YELLOW}Method 2: Flutter Screenshot Command${NC}"
    echo -e "   - Navigate to the screen in your app"
    echo -e "   - Run: ${GREEN}flutter screenshot -d $DEVICE_ID $SCREENSHOT_DIR/<screen-name>.png${NC}"
    echo ""
elif [[ "$DEVICE_ID" == "chrome" ]]; then
    echo -e "${YELLOW}Method 1: Browser Screenshot${NC}"
    echo -e "   - Use browser dev tools or extension"
    echo -e "   - Save to: ${GREEN}$SCREENSHOT_DIR/<screen-name>.png${NC}"
    echo ""
    echo -e "${YELLOW}Method 2: Flutter Screenshot Command${NC}"
    echo -e "   - Navigate to the screen in your app"
    echo -e "   - Run: ${GREEN}flutter screenshot -d $DEVICE_ID $SCREENSHOT_DIR/<screen-name>.png${NC}"
    echo ""
fi

echo -e "${BLUE}Screen names to use:${NC}"
for screen_info in "${SCREENS[@]}"; do
    IFS=':' read -r name label <<< "$screen_info"
    echo -e "   ${GREEN}$name${NC} - $label"
done

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}Quick Capture Commands (run these after navigating to each screen):${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
echo ""

for screen_info in "${SCREENS[@]}"; do
    IFS=':' read -r name label <<< "$screen_info"
    echo -e "${GREEN}flutter screenshot -d $DEVICE_ID $SCREENSHOT_DIR/$name.png${NC}"
done

echo ""
echo -e "${BLUE}After capturing all screenshots:${NC}"
echo -e "${GREEN}./scripts/prepare_figma_import.sh${NC}"
echo ""
echo -e "${YELLOW}Press Enter when ready to start capturing (or Ctrl+C to cancel)...${NC}"
read

echo ""
echo -e "${GREEN}✅ Ready! Start your app and begin capturing screenshots.${NC}"
echo -e "${GREEN}   Screenshots directory: $SCREENSHOT_DIR${NC}"

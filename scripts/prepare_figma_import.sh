#!/bin/bash

# Script to prepare screenshots for Figma import
# Organizes screenshots and creates a structured layout guide

set -e

INPUT_DIR="${1:-screenshots/flutter}"
OUTPUT_DIR="${2:-screenshots/figma-ready}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🎨 Preparing Screenshots for Figma Import${NC}"
echo "=========================================="

# Find the most recent screenshot directory
if [ -d "$INPUT_DIR" ]; then
    LATEST_DIR=$(find "$INPUT_DIR" -type d -maxdepth 1 | sort -r | head -1)
    echo -e "${GREEN}Found latest screenshots: $LATEST_DIR${NC}"
else
    echo -e "${YELLOW}❌ No screenshots directory found at: $INPUT_DIR${NC}"
    echo -e "${YELLOW}Run ./scripts/capture_flutter_screenshots.sh first${NC}"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR/$TIMESTAMP"

# Copy and organize screenshots
echo -e "\n${BLUE}Organizing screenshots...${NC}"
cp -r "$LATEST_DIR"/* "$OUTPUT_DIR/$TIMESTAMP/" 2>/dev/null || true

# Create a Figma import guide
cat > "$OUTPUT_DIR/$TIMESTAMP/FIGMA_IMPORT_GUIDE.md" << 'EOF'
# Figma Import Guide

## Method 1: Direct Screenshot Import (Recommended)

1. Open Figma Desktop or Web
2. Create a new file or open your design file
3. Drag and drop the PNG files directly into Figma
4. Arrange screenshots on frames (recommended: iPhone 14 Pro frame size: 393x852)

## Method 2: AI-Powered Conversion (Best for Editable Designs)

### Using Codia AI Design Plugin

1. Install the "Codia AI Design" plugin from Figma Community
2. Select a screenshot image in Figma
3. Run the plugin: Plugins > Codia AI Design > Screenshot to Editable Design
4. The plugin will convert your screenshot into editable Figma components

### Using Figma's Built-in Image Trace

1. Select the screenshot image
2. Right-click > Flatten Image (optional)
3. Use Auto Layout to organize elements
4. Manually recreate components for better editability

## Method 3: Design Token Extraction

For maintaining consistency, extract design tokens:

1. Use Figma's "Figma Puller" or similar tools
2. Extract colors, spacing, typography from your Flutter app
3. Create Figma variables/styles matching your Flutter theme
4. Apply these to your imported designs

## Recommended Frame Sizes

- **Mobile (iOS)**: 393 x 852 (iPhone 14 Pro)
- **Mobile (Android)**: 412 x 915 (Pixel 7)
- **Tablet**: 820 x 1180 (iPad Air)
- **Desktop**: 1440 x 900 (MacBook Pro)

## Tips

- Name frames clearly: "Home Screen", "Analytics Screen", etc.
- Use Auto Layout for responsive designs
- Create components for reusable UI elements
- Document spacing and sizing in comments
- Use Figma variables for colors matching your Flutter theme
EOF

# Create a design spec template
cat > "$OUTPUT_DIR/$TIMESTAMP/DESIGN_SPEC.md" << 'EOF'
# Flutter UI Design Spec

## Color Palette
Extract from your Flutter theme:
- Primary: #4169E1 (Royal Blue)
- Surface: (from ThemeData)
- OnSurface: (from ThemeData)
- etc.

## Typography
- Font families used
- Font sizes
- Font weights

## Spacing
- Padding values
- Margin values
- Border radius values

## Components
List of reusable components to create in Figma:
- Cards
- Buttons
- Input fields
- Icons
- etc.
EOF

echo -e "\n${GREEN}✅ Screenshots prepared in: $OUTPUT_DIR/$TIMESTAMP${NC}"
echo -e "${BLUE}Files created:${NC}"
echo -e "  - Screenshot PNG files"
echo -e "  - FIGMA_IMPORT_GUIDE.md"
echo -e "  - DESIGN_SPEC.md"
echo -e "\n${YELLOW}Next: Import screenshots to Figma using the guide above${NC}"

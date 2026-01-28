# Flutter ↔ Figma Workflow - Complete Solution

## Overview

This solution provides a complete workflow for importing Flutter UI into Figma, editing designs, and implementing changes back into your Flutter codebase.

## What's Included

### 📁 Scripts
- **`scripts/capture_flutter_screenshots.sh`** - Automated screenshot capture
- **`scripts/prepare_figma_import.sh`** - Prepares screenshots for Figma import

### 📚 Documentation
- **`docs/FIGMA_WORKFLOW.md`** - Complete workflow guide
- **`docs/FIGMA_QUICK_START.md`** - Quick reference guide
- **`docs/FIGMA_SETUP.md`** - Figma setup and configuration
- **`screenshots/README.md`** - Screenshots directory guide

### 🧪 Integration Test
- **`integration_test/screenshot_capture_test.dart`** - Automated screenshot capture test

## Quick Start

### 1. Capture Screenshots (2 minutes)

```bash
# Run the capture script
./scripts/capture_flutter_screenshots.sh

# Or manually capture using device tools
# iOS Simulator: Cmd+S
# Android Emulator: Camera icon
```

Screenshots saved to: `screenshots/flutter/[timestamp]/`

### 2. Prepare for Figma (30 seconds)

```bash
./scripts/prepare_figma_import.sh
```

Prepared files in: `screenshots/figma-ready/[timestamp]/`

### 3. Import to Figma (5 minutes)

**Option A: Direct Import**
- Drag PNG files into Figma
- Arrange on frames (393x852 for iPhone)

**Option B: AI Conversion (Recommended)**
- Install "Codia AI Design" plugin
- Import screenshot
- Run plugin: `Plugins > Codia AI Design > Screenshot to Editable Design`
- Wait 30-60 seconds for conversion

### 4. Edit in Figma

- Make design changes
- Use Auto Layout for responsive design
- Create components for reusable elements
- Apply design tokens matching Flutter theme

### 5. Export & Share (2 minutes)

- Export edited screenshots from Figma
- Save to `screenshots/figma-edited/`
- Share screenshots with AI for code implementation

### 6. Code Implementation

Share the edited screenshots, and I'll:
- Analyze the design changes
- Update Flutter widgets and styling
- Maintain code structure and patterns
- Ensure consistency with design system

## Workflow Diagram

```
┌─────────────────┐
│  Flutter App    │
│  (Running)      │
└────────┬────────┘
         │
         │ ./scripts/capture_flutter_screenshots.sh
         ▼
┌─────────────────┐
│  Screenshots    │
│  (PNG files)    │
└────────┬────────┘
         │
         │ ./scripts/prepare_figma_import.sh
         ▼
┌─────────────────┐
│  Figma-Ready    │
│  Screenshots    │
└────────┬────────┘
         │
         │ Import to Figma
         │ (Drag & drop or AI plugin)
         ▼
┌─────────────────┐
│  Figma Design   │
│  (Editable)      │
└────────┬────────┘
         │
         │ Edit designs
         ▼
┌─────────────────┐
│  Edited Design  │
│  (In Figma)     │
└────────┬────────┘
         │
         │ Export as PNG
         ▼
┌─────────────────┐
│  Edited PNGs   │
│  (screenshots/  │
│   figma-edited/)│
└────────┬────────┘
         │
         │ Share with AI
         ▼
┌─────────────────┐
│  Code Updates   │
│  (Flutter)      │
└─────────────────┘
```

## Key Features

### ✅ Automated Screenshot Capture
- Scripts for easy capture
- Supports iOS, Android, and desktop
- Organized by timestamp

### ✅ AI-Powered Conversion
- Codia AI Design plugin converts screenshots to editable designs
- Saves hours of manual work
- Creates proper layers and components

### ✅ Design Token Sync
- Extract Flutter design constants
- Create matching Figma variables
- Maintain consistency across tools

### ✅ Round-Trip Workflow
- Flutter → Figma → Edit → Flutter
- Seamless design iteration
- Code implementation from screenshots

## File Structure

```
ash_trail/
├── scripts/
│   ├── capture_flutter_screenshots.sh
│   └── prepare_figma_import.sh
├── integration_test/
│   └── screenshot_capture_test.dart
├── screenshots/
│   ├── flutter/              # Original screenshots
│   ├── figma-ready/          # Prepared for import
│   └── figma-edited/         # Edited designs
└── docs/
    ├── FIGMA_WORKFLOW.md
    ├── FIGMA_QUICK_START.md
    ├── FIGMA_SETUP.md
    └── FIGMA_WORKFLOW_SUMMARY.md (this file)
```

## Recommended Tools

### Essential
- **Figma Desktop** - Better performance than web
- **Codia AI Design Plugin** - Converts screenshots automatically

### Optional
- **Figma Puller** - Sync design tokens
- **Figma Variables** - Design token management

## Design Token Reference

Your Flutter app uses these design constants (from `lib/utils/design_constants.dart`):

### Spacing
- XS: 4px
- SM: 8px
- MD: 12px
- LG: 16px
- XL: 24px
- XXL: 32px
- XXXL: 48px

### Colors (from `lib/main.dart`)
- Primary: #4169E1 (Royal Blue)
- Surface (Dark): #1E1E1E
- Background (Dark): #121212

### Border Radius
- SM: 8px
- MD: 12px
- LG: 16px
- XL: 24px

### Breakpoints
- Mobile: < 600px
- Tablet: 600px - 1199px
- Desktop: ≥ 1200px

## Tips for Success

1. **High Resolution**: Always capture/export at 2x or 3x
2. **Consistent Naming**: Use clear, descriptive names
3. **Component Library**: Build reusable components in Figma
4. **Design Tokens**: Match Figma variables to Flutter constants
5. **Documentation**: Note changes when exporting
6. **Iteration**: Use this workflow for continuous improvement

## Troubleshooting

### Screenshots Not Capturing
- Check device connection: `flutter devices`
- Try manual capture methods
- Verify Flutter is running

### Figma Import Issues
- Use PNG format
- Check file size limits
- Try different import methods

### AI Conversion Problems
- Wait 30-60 seconds for processing
- Try simpler screens first
- May need manual refinement

## Next Steps

1. **Read**: [FIGMA_QUICK_START.md](./FIGMA_QUICK_START.md) for quick commands
2. **Setup**: [FIGMA_SETUP.md](./FIGMA_SETUP.md) for Figma configuration
3. **Workflow**: [FIGMA_WORKFLOW.md](./FIGMA_WORKFLOW.md) for detailed guide
4. **Start**: Run `./scripts/capture_flutter_screenshots.sh`

## Support

For issues or questions:
- Review the detailed documentation
- Check troubleshooting sections
- Verify script permissions: `chmod +x scripts/*.sh`

---

**Ready to start?** Run the capture script and begin your design workflow!

```bash
./scripts/capture_flutter_screenshots.sh
```

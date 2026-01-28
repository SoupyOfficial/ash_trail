# Flutter ↔ Figma Design Workflow

This document describes the workflow for importing Flutter UI into Figma, editing designs, and implementing changes back into the Flutter codebase.

## Overview

The workflow enables a round-trip design process:
1. **Flutter → Figma**: Capture Flutter screenshots and import to Figma
2. **Figma Editing**: Edit designs in Figma with full design tools
3. **Figma → Flutter**: Analyze edited Figma screenshots and update Flutter code

## Prerequisites

- Flutter app running on device/emulator
- Figma account (free tier works)
- Figma Desktop app or Web access
- (Optional) Codia AI Design plugin for Figma

## Step 1: Capture Flutter Screenshots

### Automated Capture

Run the screenshot capture script:

```bash
./scripts/capture_flutter_screenshots.sh [device-id] [output-dir]
```

Example:
```bash
./scripts/capture_flutter_screenshots.sh emulator-5554 screenshots/flutter
```

### Manual Capture

If automated capture doesn't work:

1. **iOS Simulator**:
   - Navigate to screen in app
   - Press `Cmd + S` or use `Device > Screenshot`
   - Save to `screenshots/flutter/[screen-name].png`

2. **Android Emulator**:
   - Navigate to screen in app
   - Click camera icon in emulator toolbar
   - Save to `screenshots/flutter/[screen-name].png`

3. **Physical Device**:
   - Use device screenshot shortcut
   - Transfer to computer
   - Save to `screenshots/flutter/[screen-name].png`

### Recommended Screens to Capture

- `home.png` - Home screen
- `analytics.png` - Analytics screen
- `history.png` - History screen
- `logging.png` - Logging screen
- `accounts.png` - Accounts screen
- `export.png` - Export screen
- `profile.png` - Profile screen

## Step 2: Prepare for Figma Import

Run the preparation script:

```bash
./scripts/prepare_figma_import.sh [input-dir] [output-dir]
```

This will:
- Organize screenshots
- Create import guide
- Generate design spec template

## Step 3: Import to Figma

### Option A: Direct Import (Quick)

1. Open Figma Desktop or Web
2. Create a new file or open your design file
3. Drag PNG files directly into Figma
4. Arrange on frames (recommended: iPhone 14 Pro - 393x852)

### Option B: AI-Powered Conversion (Best for Editing)

1. **Install Codia AI Design Plugin**:
   - Open Figma
   - Go to Community > Plugins
   - Search "Codia AI Design"
   - Install the plugin

2. **Convert Screenshots**:
   - Import screenshot to Figma
   - Select the image
   - Run: `Plugins > Codia AI Design > Screenshot to Editable Design`
   - Wait for AI conversion (may take 30-60 seconds)
   - Result: Editable Figma components with proper layers

3. **Refine the Design**:
   - Clean up any AI artifacts
   - Organize layers properly
   - Create components for reusable elements
   - Apply design tokens/variables

### Option C: Manual Recreation (Most Control)

1. Import screenshot as reference
2. Lock the reference layer
3. Recreate UI elements manually
4. Use Auto Layout for responsive design
5. Create components for reusability

## Step 4: Edit in Figma

### Design Best Practices

1. **Use Frames**: Create frames matching device sizes
   - Mobile: 393x852 (iPhone 14 Pro)
   - Tablet: 820x1180 (iPad Air)
   - Desktop: 1440x900

2. **Create Components**: 
   - Buttons, cards, input fields
   - Navigation elements
   - Reusable UI patterns

3. **Use Auto Layout**:
   - For responsive spacing
   - Consistent padding/margins
   - Easy to adjust

4. **Design Tokens**:
   - Create Figma variables for colors
   - Match your Flutter theme colors
   - Document spacing values

5. **Naming Convention**:
   - Use clear, descriptive names
   - Match Flutter widget names when possible
   - Example: "HomeScreen", "AnalyticsCard", "PrimaryButton"

## Step 5: Export Edited Designs

After editing in Figma:

1. **Export Screenshots**:
   - Select the frame(s) you edited
   - Right-click > Export
   - Choose PNG format
   - Export at 2x or 3x resolution for clarity
   - Save to `screenshots/figma-edited/[screen-name].png`

2. **Document Changes**:
   - Create a change log
   - Note specific modifications
   - Include measurements if relevant

## Step 6: Implement Changes in Flutter

### Process

1. **Share Edited Screenshots**:
   - Place edited screenshots in `screenshots/figma-edited/`
   - Or share directly in conversation

2. **AI Analysis**:
   - I'll analyze the Figma screenshots
   - Compare with current Flutter code
   - Identify changes needed

3. **Code Updates**:
   - I'll update Flutter widgets
   - Adjust styling, spacing, colors
   - Maintain code structure and patterns

### What I Can Update

- **Visual Styling**: Colors, fonts, sizes
- **Layout**: Spacing, padding, margins
- **Components**: Button styles, card designs
- **Typography**: Font sizes, weights, styles
- **Spacing**: Consistent spacing values
- **Shapes**: Border radius, elevations

### What to Include in Screenshots

For best results, include:
- Full screen captures
- Clear, high-resolution images
- Both before/after if possible
- Notes about specific changes
- Any design measurements

## Advanced: Design Token Sync

### Extract Flutter Design Tokens

Your Flutter app uses design constants. To sync with Figma:

1. **Review Design Constants**:
   - Check `lib/utils/design_constants.dart`
   - Extract color values, spacing, typography

2. **Create Figma Variables**:
   - Match colors exactly
   - Create spacing variables
   - Document typography styles

3. **Use Figma Puller** (Optional):
   ```bash
   # Install figma_puller
   dart pub global activate figma_puller
   
   # Pull design tokens from Figma
   figma_pull --file-key YOUR_FILE_KEY --token YOUR_API_TOKEN
   ```

## Troubleshooting

### Screenshots Not Capturing

- Ensure app is running
- Check device connection: `flutter devices`
- Try manual capture methods
- Verify Flutter version compatibility

### Figma Import Issues

- Use high-resolution screenshots (2x or 3x)
- Ensure PNG format
- Try different import methods
- Check file size limits

### AI Conversion Not Working

- Ensure Codia AI plugin is installed
- Try with simpler screens first
- Wait for processing to complete
- May need to refine manually

### Design Mismatches

- Verify device frame sizes match
- Check for responsive breakpoints
- Ensure design tokens match
- Compare actual vs. expected dimensions

## Workflow Summary

```
Flutter App
    ↓ (Capture Screenshots)
screenshots/flutter/
    ↓ (Prepare for Import)
screenshots/figma-ready/
    ↓ (Import to Figma)
Figma Design File
    ↓ (Edit Designs)
Figma Edited Designs
    ↓ (Export Screenshots)
screenshots/figma-edited/
    ↓ (Share with AI)
Code Updates in Flutter
```

## Best Practices

1. **Version Control**: Keep screenshots organized by date/timestamp
2. **Documentation**: Document design decisions and changes
3. **Consistency**: Maintain design system across screens
4. **Testing**: Verify changes work across different screen sizes
5. **Iteration**: Use this workflow for iterative design improvements

## Resources

- [Figma Desktop App](https://www.figma.com/downloads/)
- [Codia AI Design Plugin](https://www.figma.com/community/plugin/1329812760871373657)
- [Figma Puller Package](https://pub.dev/packages/figma_puller)
- [Flutter Screenshot Documentation](https://docs.flutter.dev/testing/integration-tests#taking-screenshots)

## Example Workflow Session

1. **Capture**: `./scripts/capture_flutter_screenshots.sh`
2. **Prepare**: `./scripts/prepare_figma_import.sh`
3. **Import**: Drag screenshots to Figma, use Codia AI plugin
4. **Edit**: Make design changes in Figma
5. **Export**: Export edited screenshots
6. **Share**: Share screenshots and request code updates
7. **Implement**: Code changes are made based on screenshots
8. **Verify**: Test changes in Flutter app
9. **Repeat**: Iterate as needed

---

For questions or issues, refer to this document or create an issue in the project repository.

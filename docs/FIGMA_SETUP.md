# Figma Setup Guide

This guide helps you set up Figma for the Flutter design workflow, including plugins and design token configuration.

## Initial Setup

### 1. Create a Figma Account
- Sign up at [figma.com](https://www.figma.com) (free tier works)
- Download Figma Desktop app for better performance

### 2. Create a New Design File
- Create a new file: `Ash Trail - Design System`
- Organize with pages: "Screens", "Components", "Design Tokens"

## Recommended Plugins

### Essential Plugin: Codia AI Design

**Purpose**: Converts screenshots to editable Figma designs automatically

**Installation**:
1. Open Figma
2. Go to `Plugins > Browse plugins in Community`
3. Search: "Codia AI Design"
4. Click "Install"

**Usage**:
1. Import a Flutter screenshot to Figma
2. Select the image
3. Run: `Plugins > Codia AI Design > Screenshot to Editable Design`
4. Wait for AI processing (30-60 seconds)
5. Review and refine the converted design

**Benefits**:
- Automatically creates layers and components
- Extracts text, colors, and shapes
- Saves hours of manual recreation

### Optional Plugin: Figma Puller Integration

**Purpose**: Sync design tokens between Figma and Flutter

**Setup**:
1. Get Figma API token:
   - Go to Figma Settings
   - Personal Access Tokens
   - Generate new token
   - Copy token (save securely)

2. Install Flutter package:
   ```bash
   dart pub global activate figma_puller
   ```

3. Get your Figma file key:
   - Open your Figma file
   - URL format: `https://www.figma.com/file/FILE_KEY/file-name`
   - Copy the `FILE_KEY` from URL

4. Pull design tokens:
   ```bash
   figma_pull --file-key YOUR_FILE_KEY --token YOUR_API_TOKEN
   ```

## Design Token Configuration

### Extract Flutter Design Tokens

Your Flutter app uses design constants. To sync with Figma:

1. **Review Design Constants**:
   - File: `lib/utils/design_constants.dart`
   - Extract: Colors, Spacing, Typography, Border Radius

2. **Create Figma Variables**:
   - In Figma: `Design > Variables`
   - Create color variables matching Flutter theme
   - Create spacing variables
   - Document typography styles

### Example: Color Variables

Based on your Flutter theme (`lib/main.dart`):

```
Primary Color: #4169E1 (Royal Blue)
Surface (Light): [from ColorScheme]
Surface (Dark): #1E1E1E
Background (Dark): #121212
```

Create these as Figma variables:
- `Color/Primary`
- `Color/Surface/Light`
- `Color/Surface/Dark`
- `Color/Background/Dark`

### Example: Spacing Variables

From `design_constants.dart`, create spacing variables:
- `Spacing/XS`: 4px
- `Spacing/SM`: 8px
- `Spacing/MD`: 16px
- `Spacing/LG`: 24px
- `Spacing/XL`: 32px

## Frame Sizes

Create frames matching your target devices:

### Mobile
- **iPhone 14 Pro**: 393 x 852
- **iPhone 14 Pro Max**: 430 x 932
- **Pixel 7**: 412 x 915
- **Pixel 7 Pro**: 412 x 892

### Tablet
- **iPad Air**: 820 x 1180
- **iPad Pro 12.9"**: 1024 x 1366

### Desktop
- **MacBook Pro**: 1440 x 900
- **Desktop HD**: 1920 x 1080

## Component Library Setup

### Create Reusable Components

1. **Buttons**:
   - Primary Button
   - Secondary Button
   - Text Button
   - Icon Button

2. **Cards**:
   - Stat Card
   - Log Entry Card
   - Chart Card

3. **Inputs**:
   - Text Field
   - Date Picker
   - Dropdown

4. **Navigation**:
   - Bottom Navigation Bar
   - App Bar
   - Drawer

### Component Organization

```
Components/
├── Buttons/
├── Cards/
├── Inputs/
├── Navigation/
├── Icons/
└── Charts/
```

## Auto Layout Setup

Use Auto Layout for responsive designs:

1. **Select elements**
2. **Apply Auto Layout**: `Shift + A`
3. **Configure**:
   - Direction: Horizontal/Vertical
   - Spacing: Match Flutter spacing values
   - Padding: Use design constants

## Naming Conventions

### Frames
- `Home Screen`
- `Analytics Screen`
- `History Screen`

### Components
- `Button/Primary`
- `Card/Stat`
- `Input/Text`

### Variables
- `Color/Primary`
- `Spacing/MD`
- `Typography/Body`

## Workflow Integration

### Import Workflow
1. Capture Flutter screenshots
2. Import to Figma (drag & drop)
3. Use Codia AI to convert to editable
4. Organize into frames
5. Create components from reusable elements

### Export Workflow
1. Edit designs in Figma
2. Select frame(s)
3. Export as PNG (2x or 3x resolution)
4. Save to `screenshots/figma-edited/`
5. Share for code implementation

## Tips for Best Results

1. **High Resolution**: Always capture/export at 2x or 3x
2. **Consistent Spacing**: Use variables for all spacing
3. **Component Library**: Build reusable components
4. **Documentation**: Add comments explaining design decisions
5. **Version Control**: Use Figma's version history
6. **Collaboration**: Share file with team members

## Troubleshooting

### Codia AI Not Working
- Ensure plugin is installed and up to date
- Try with simpler screens first
- Wait for processing to complete
- May need manual refinement

### Design Tokens Not Syncing
- Verify API token is valid
- Check file key is correct
- Ensure Flutter package is installed
- Review generated files

### Frame Sizes Mismatch
- Verify device frame sizes
- Check Flutter app's responsive breakpoints
- Adjust frames to match actual device dimensions

## Resources

- [Figma Desktop App](https://www.figma.com/downloads/)
- [Codia AI Design Plugin](https://www.figma.com/community/plugin/1329812760871373657)
- [Figma Variables Documentation](https://help.figma.com/hc/en-us/articles/15339657135383)
- [Auto Layout Guide](https://help.figma.com/hc/en-us/articles/5731384052759)
- [Figma Puller Package](https://pub.dev/packages/figma_puller)

---

For the complete workflow, see [FIGMA_WORKFLOW.md](./FIGMA_WORKFLOW.md)

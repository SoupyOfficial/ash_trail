# Figma Workflow Quick Start

A quick reference guide for the Flutter ↔ Figma design workflow.

## Quick Commands

### 1. Capture Screenshots
```bash
./scripts/capture_flutter_screenshots.sh
```

### 2. Prepare for Figma
```bash
./scripts/prepare_figma_import.sh
```

### 3. Import to Figma
- Drag screenshots from `screenshots/figma-ready/` into Figma
- Or use Codia AI Design plugin for editable conversion

### 4. After Editing in Figma
- Export edited screenshots
- Save to `screenshots/figma-edited/`
- Share with AI for code updates

## Recommended Figma Plugins

1. **Codia AI Design** - Converts screenshots to editable designs
   - Install from: Figma Community > Plugins
   - Use: Select image > Plugins > Codia AI Design

2. **Figma Puller** (Optional) - Sync design tokens
   - Install: `dart pub global activate figma_puller`
   - Requires Figma API token

## Workflow Diagram

```
┌─────────────┐
│ Flutter App │
└──────┬──────┘
       │ capture
       ▼
┌─────────────┐
│ Screenshots │
└──────┬──────┘
       │ import
       ▼
┌─────────────┐
│   Figma     │
└──────┬──────┘
       │ edit
       ▼
┌─────────────┐
│ Edited PNGs │
└──────┬──────┘
       │ share
       ▼
┌─────────────┐
│ Code Update │
└─────────────┘
```

## Tips

- **High Resolution**: Capture at 2x or 3x for better quality
- **Consistent Frames**: Use standard device frame sizes in Figma
- **Component Library**: Create reusable components in Figma
- **Design Tokens**: Match Figma variables to Flutter theme colors
- **Documentation**: Note changes when exporting from Figma

## File Structure

```
screenshots/
├── flutter/              # Original Flutter screenshots
│   └── YYYYMMDD_HHMMSS/
├── figma-ready/          # Prepared for Figma import
│   └── YYYYMMDD_HHMMSS/
│       ├── *.png
│       ├── FIGMA_IMPORT_GUIDE.md
│       └── DESIGN_SPEC.md
└── figma-edited/         # Edited designs from Figma
    └── [screen-name].png
```

## Common Issues

**Screenshots not capturing?**
- Check device connection: `flutter devices`
- Try manual capture (Cmd+S on iOS Simulator)

**Figma import not working?**
- Use PNG format
- Check file size limits
- Try direct drag-and-drop

**AI conversion slow?**
- Wait 30-60 seconds for processing
- Try simpler screens first
- May need manual refinement

For detailed instructions, see [FIGMA_WORKFLOW.md](./FIGMA_WORKFLOW.md)

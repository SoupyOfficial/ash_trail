# widget_standardization

> **Source:** `lib/utils/widget_standardization.dart`

## Purpose

Provides standardized helper widgets for consistent alignment, spacing, padding, cards, sizing, dividers, sections, and safe-area handling across the app. These composable building blocks reduce boilerplate and enforce uniform layout patterns.

## Dependencies

- `package:flutter/material.dart` — Core Flutter widgets, `EdgeInsets`, `BoxConstraints`, `SafeArea`, etc.
- `design_constants.dart` — `Spacing`, `Paddings`, `BorderRadii`, `ElevationLevel`, `A11yConstants`, `ResponsiveSize`, `Breakpoints`

## Pseudo-Code

---

### Class: AlignmentHelper

Static utility for common widget alignment patterns.

#### Method: centerHorizontal({child, width?}) → Widget
```
IF width IS NOT NULL
  RETURN Center → ConstrainedBox(maxWidth: width) → child
ELSE
  RETURN Center → child
```

#### Method: centerVertical({child, height?}) → Widget
```
RETURN SizedBox(height) → Center → child
```

#### Method: center({child, width?, height?}) → Widget
```
RETURN SizedBox(width, height) → Center → child
```

#### Method: alignWithPadding({child, alignment, padding}) → Widget
```
RETURN Align(alignment) → Padding(padding) → child
```

---

### Class: SpacedColumn (StatelessWidget)

Column that automatically inserts vertical spacing between children.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| children | List\<Widget\> | required |
| spacing | double | 16 |
| mainAxisAlignment | MainAxisAlignment | start |
| crossAxisAlignment | CrossAxisAlignment | stretch |
| mainAxisSize | MainAxisSize | min |

#### Method: build(context) → Widget
```
INIT spacedChildren = empty List
FOR i FROM 0 TO children.length - 1
  APPEND children[i] TO spacedChildren
  IF i < children.length - 1
    APPEND SizedBox(height: spacing) TO spacedChildren

RETURN Column(mainAxisAlignment, crossAxisAlignment, mainAxisSize, spacedChildren)
```

---

### Class: SpacedRow (StatelessWidget)

Row that automatically inserts horizontal spacing between children.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| children | List\<Widget\> | required |
| spacing | double | 16 |
| mainAxisAlignment | MainAxisAlignment | start |
| crossAxisAlignment | CrossAxisAlignment | center |
| mainAxisSize | MainAxisSize | min |

#### Method: build(context) → Widget
```
INIT spacedChildren = empty List
FOR i FROM 0 TO children.length - 1
  APPEND children[i] TO spacedChildren
  IF i < children.length - 1
    APPEND SizedBox(width: spacing) TO spacedChildren

RETURN Row(mainAxisAlignment, crossAxisAlignment, mainAxisSize, spacedChildren)
```

---

### Class: CenteredSpacedColumn (StatelessWidget)

Centered column with spacing, optionally width-constrained.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| children | List\<Widget\> | required |
| spacing | double | 16 |
| maxWidth | double? | null (infinity) |

#### Method: build(context) → Widget
```
RETURN Center → ConstrainedBox(maxWidth: maxWidth ?? infinity)
  → SpacedColumn(spacing, mainAxis: center, crossAxis: center, children)
```

---

### Class: CenteredSpacedRow (StatelessWidget)

Centered row with spacing, optionally width-constrained.

#### Properties and build logic identical to `CenteredSpacedColumn` but uses `SpacedRow` internally.

---

### Class: PaddedContainer (StatelessWidget)

Widget wrapped with standard padding from the `Spacing` enum.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| child | Widget | required |
| padding | Spacing | Spacing.lg (16) |
| fillWidth | bool | true |
| fillHeight | bool | false |
| minHeight | double? | null |
| minWidth | double? | null |

#### Method: build(context) → Widget
```
RETURN Container(
  width: IF fillWidth THEN infinity ELSE minWidth,
  height: minHeight,
  padding: EdgeInsets.all(padding.value),
  child: child
)
```

---

### Class: ResponsivePaddedContainer (StatelessWidget)

Container with responsive padding that scales per breakpoint.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| child | Widget | required |
| mobilePadding | double | 16 |
| tabletPadding | double? | 24 |
| desktopPadding | double? | 32 |
| fillWidth | bool | true |
| fillHeight | bool | false |

#### Method: build(context) → Widget
```
SET padding = ResponsiveSize.responsive(context, mobilePadding, tabletPadding, desktopPadding)
RETURN Container(
  width: IF fillWidth THEN infinity ELSE null,
  height: IF fillHeight THEN infinity ELSE null,
  padding: EdgeInsets.all(padding),
  child: child
)
```

---

### Class: StandardCard (StatelessWidget)

Consistently styled card with optional tap handling.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| child | Widget | required |
| padding | EdgeInsets? | all(16) |
| elevation | double? | null (→ ElevationLevel.md = 2) |
| borderRadius | BorderRadius? | null (→ BorderRadii.md) |
| backgroundColor | Color? | null |
| onTap | VoidCallback? | null |
| filled | bool | true |

#### Method: build(context) → Widget
```
RETURN Card(
  elevation: elevation ?? ElevationLevel.md.value,
  shape: RoundedRectangleBorder(borderRadius ?? BorderRadii.md)
  color: backgroundColor
) → InkWell(onTap, borderRadius) → Padding(padding ?? Paddings.lg) → child
```

---

### Class: CenteredCard (StatelessWidget)

`StandardCard` centered and width-constrained.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| child | Widget | required |
| maxWidth | double? | 500 |
| padding | EdgeInsets? | all(24) |
| elevation | double? | null |

#### Method: build(context) → Widget
```
RETURN Center → ConstrainedBox(maxWidth) → StandardCard(padding, elevation) → child
```

---

### Class: FillContainer (StatelessWidget)

Expands to fill all available space and centers child.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| child | Widget | required |
| horizontal | bool | true |
| vertical | bool | true |

#### Method: build(context) → Widget
```
RETURN SizedBox.expand → Center → child
```

---

### Class: MinimumTouchTarget (StatelessWidget)

Ensures a widget meets the minimum 48dp touch target for accessibility. Adds `GestureDetector` and `Semantics`.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| child | Widget | required |
| onTap | VoidCallback? | null |
| onLongPress | VoidCallback? | null |
| minSize | double | A11yConstants.minimumTouchSize (48) |

#### Method: build(context) → Widget
```
RETURN GestureDetector(onTap, onLongPress)
  → Semantics(button: true, enabled: onTap OR onLongPress != null)
    → Container(constraints: min width/height = minSize)
      → Center → child
```

---

### Class: ResponsiveDivider (StatelessWidget)

Horizontal divider with configurable dimensions.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| height | double? | 24 |
| thickness | double? | 1 |
| color | Color? | null |
| indent / endIndent | double? | 0 |

#### Method: build(context) → Widget
```
RETURN Divider(height, thickness, color, indent, endIndent)
```

---

### Class: SpacingDivider (StatelessWidget)

Invisible vertical spacer (no visual line).

```
RETURN SizedBox(height)   // default 16
```

---

### Class: StyledSection (StatelessWidget)

Section container with a title, content area, optional divider.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| title | String | required |
| content | Widget | required |
| showDivider | bool | true |
| spacing | double | 12 |
| titleStyle | TextStyle? | null |

#### Method: build(context) → Widget
```
RETURN Column(crossAxisAlignment: start)
  1. Text(title, style: titleStyle ?? titleMedium.bold)
  2. SizedBox(height: spacing)
  3. content
  4. IF showDivider THEN ResponsiveDivider()
```

---

### Class: SafePadding (StatelessWidget)

`SafeArea` wrapper with configurable edge insets and additional padding.

#### Properties
| Property | Type | Default |
|----------|------|---------|
| child | Widget | required |
| top | bool | true |
| bottom | bool | true |
| left | bool | true |
| right | bool | true |
| additionalPadding | double | 0 |

#### Method: build(context) → Widget
```
RETURN SafeArea(top, bottom, left, right)
  → Padding(EdgeInsets.all(additionalPadding))
    → child
```

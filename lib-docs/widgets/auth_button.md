# auth_button

> **Source:** `lib/widgets/auth_button.dart`

## Purpose
Industry-standard authentication button widget that supports Google, Apple, and Email sign-in styles. Provides consistent sizing, loading states, and platform-appropriate icon/color theming.

## Dependencies
- `package:flutter/material.dart` — Flutter UI framework

## Pseudo-Code

### Enum: AuthButtonType
```
Values: google, apple, email
```

### Class: AuthButton (StatelessWidget)

**Constructor Parameters:**
- `text: String` — button label text
- `onPressed: VoidCallback` — tap handler
- `type: AuthButtonType` — determines styling (colors, icon)
- `isLoading: bool` — defaults to `false`; shows spinner when true

#### Method: build(context) → Widget
```
RETURN SizedBox(width: infinity, height: 50):
  └─ ElevatedButton:
      style:
        padding: horizontal 16
        backgroundColor: _getBackgroundColor()
        foregroundColor: _getForegroundColor()
        shape: RoundedRectangleBorder(radius: 8)
          IF email type → grey border, elevation 0
          ELSE → no border, elevation 2
      child:
        IF isLoading:
          └─ SizedBox(20×20) → CircularProgressIndicator(strokeWidth: 2)
        ELSE:
          └─ Row:
              ├─ IF type != email: _getIcon() + SizedBox(width: 12)
              └─ Expanded → Text(text, fontSize: 16, bold, centered, ellipsis)
```

#### Method: _getBackgroundColor() → Color
```
google → white
apple  → black
email  → white
```

#### Method: _getForegroundColor() → Color
```
google → black87
apple  → white
email  → black87
```

#### Method: _getIcon() → Widget
```
google → Image.asset('assets/google_logo.png', 24×24)
          errorBuilder fallback: Text("G", bold)
apple  → Icon(Icons.apple, 24)
email  → Icon(Icons.email_outlined, 24)
```

# Theming System Documentation

## Overview

The AshTrail theming system provides a comprehensive theme management solution that supports light, dark, and system-based themes. It follows Clean Architecture principles with clear separation between domain, data, and presentation layers.

## Architecture

### Domain Layer
- **Entities**: `AppThemeMode` enum defining theme preferences
- **Use Cases**: Theme preference retrieval and persistence 
- **Repository Interface**: Abstract theme repository contract

### Data Layer  
- **DTOs**: Theme preference data transfer objects
- **Repository Implementation**: SharedPreferences-based persistence
- **Mappers**: Entity-DTO conversion logic

### Presentation Layer
- **Providers**: Riverpod-based theme state management
- **Theme Definitions**: Material 3 color schemes and typography

## Features

### Theme Modes
- **System**: Follows device brightness preference
- **Light**: Force light theme
- **Dark**: Force dark theme

### Default Behavior
- Defaults to dark theme when system preference unavailable
- Persists theme preference across app restarts
- Instant theme switching for responsive UI

### Accessibility Support
- Prepared high-contrast color schemes (placeholder)
- Dynamic Type support up to 200% text scaling
- Material 3 semantic color tokens

## Usage

### Accessing Current Theme
```dart
// In a ConsumerWidget
@override
Widget build(BuildContext context, WidgetRef ref) {
  final themeData = ref.watch(currentThemeDataProvider);
  return MaterialApp(theme: themeData);
}
```

### Changing Theme Mode
```dart
// Get the theme controller
final themeController = ref.read(currentThemeModeProvider.notifier);

// Set theme mode
await themeController.setThemeMode(AppThemeMode.dark);
```

### Reading Current Theme Mode
```dart
final currentMode = ref.watch(currentThemeModeProvider);
```

## Implementation Details

### Theme Persistence
- Uses SharedPreferences for local storage
- Key: `theme_preference`
- Fallback: Returns `AppThemeMode.system` if no preference stored

### Color Schemes
- Based on Material 3 design tokens
- Primary seed color: `#6750A4` (Material 3 purple)
- Automatic light/dark variant generation
- High-contrast variants prepared for accessibility

### Error Handling
- All repository operations return `Either<AppFailure, T>`
- Graceful fallback to default values on errors
- No exceptions exposed to presentation layer

## Testing

The theming system includes comprehensive tests:

- **Unit Tests**: Domain use cases and repository implementation
- **Provider Tests**: Riverpod state management and theme resolution
- **Integration Tests**: End-to-end theme persistence and switching

### Test Coverage
- Theme preference loading and saving
- System brightness detection
- Theme mode switching
- Error handling scenarios
- State management lifecycle

## Files Structure

```
lib/features/theming/
├── domain/
│   ├── entities/
│   │   └── theme_mode.dart
│   ├── repositories/
│   │   └── theme_repository.dart
│   └── usecases/
│       ├── get_theme_preference_use_case.dart
│       └── set_theme_preference_use_case.dart
├── data/
│   ├── models/
│   │   └── theme_preference_dto.dart
│   └── repositories/
│       └── theme_repository_impl.dart
└── presentation/
    └── providers/
        └── theme_provider.dart

lib/core/theme/
└── app_theme.dart

test/features/theming/
├── domain/usecases/
├── data/repositories/
└── presentation/providers/
```

## Integration with Main App

The theming system is integrated in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  runApp(ProviderScope(
    overrides: [createThemeRepositoryOverride(prefs)],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentThemeDataProvider);
    return MaterialApp.router(theme: theme, ...);
  }
}
```

## Future Enhancements

- Accent color customization (referenced in existing Prefs model)
- Schedule-based theme switching
- Custom theme creation
- Additional accessibility themes
- Material You dynamic color support

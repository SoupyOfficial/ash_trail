# ADR-0004: Theming System Architecture

**Status**: Accepted  
**Date**: 2025-09-05  
**Context**: Implementation of ui.theming feature for AshTrail application

## Context

AshTrail requires a comprehensive theming system that supports light/dark modes, follows system preferences, persists user choices, and provides accessibility features. The implementation must align with Clean Architecture principles and integrate seamlessly with the existing Riverpod-based state management.

## Decision

We will implement a theming system with the following architecture:

### 1. Theme Mode Management
- **AppThemeMode enum**: System, Light, Dark options
- **Default behavior**: Dark mode when system preference unavailable (per requirements)
- **Persistence**: SharedPreferences for local storage

### 2. Clean Architecture Layers
- **Domain**: Pure theme entities and use cases
- **Data**: SharedPreferences repository implementation with DTOs
- **Presentation**: Riverpod providers for reactive theme state

### 3. Material 3 Design System
- **Color schemes**: Generated from seed color `#6750A4`
- **Typography**: Material 3 text styles supporting Dynamic Type up to 200%
- **Accessibility**: High-contrast variants prepared as placeholders

### 4. Reactive Theme Resolution
- **System detection**: PlatformDispatcher.instance.platformBrightness
- **Fallback**: Dark theme when system brightness unavailable
- **Instant updates**: State changes apply immediately to UI

## Options Considered

### Option 1: Simple theme toggling with Flutter's built-in ThemeMode
**Pros**: Minimal code, uses Flutter conventions
**Cons**: Limited customization, no persistence, no Clean Architecture alignment

### Option 2: Package-based solution (e.g., adaptive_theme)
**Pros**: Battle-tested, feature-rich
**Cons**: External dependency, may not align with Clean Architecture, less control

### Option 3: Custom Clean Architecture implementation (chosen)
**Pros**: Full control, testable, aligns with project architecture, extensible
**Cons**: More initial development time

## Implementation Details

### Repository Pattern
```dart
abstract interface class ThemeRepository {
  Future<Either<AppFailure, AppThemeMode>> getThemePreference();
  Future<Either<AppFailure, void>> setThemePreference(AppThemeMode mode);
}
```

### Use Cases
- `GetThemePreferenceUseCase`: Loads saved preference with system fallback
- `SetThemePreferenceUseCase`: Persists theme preference

### Provider Architecture
```dart
// Theme mode state
final currentThemeModeProvider = StateNotifierProvider<ThemeModeController, AppThemeMode>

// Resolved theme data
final currentThemeDataProvider = Provider<ThemeData>

// Platform brightness detection
final platformBrightnessProvider = Provider<Brightness>
```

### Error Handling
- All operations return `Either<AppFailure, T>`
- Graceful degradation on persistence failures
- No exceptions exposed to UI layer

## Consequences

### Positive
- **Testability**: Complete unit test coverage for all layers
- **Maintainability**: Clear separation of concerns
- **Extensibility**: Easy to add accent colors, custom themes
- **Performance**: Minimal rebuilds with targeted providers
- **Accessibility**: Ready for high-contrast and dynamic type
- **Offline-first**: Works without network connection

### Negative
- **Complexity**: More files and abstractions than simple solutions
- **Initial effort**: Requires more upfront development time
- **Learning curve**: Team needs to understand Clean Architecture patterns

### Neutral
- **Dependency**: Adds SharedPreferences dependency (already in use)
- **Bundle size**: Minimal impact due to core Flutter components

## Follow-up Actions

1. **Future enhancements** ready for implementation:
   - Accent color customization (Prefs model already includes accentColor field)
   - Scheduled theme switching (night mode)
   - Custom theme creation
   - Material You dynamic colors

2. **Integration points**:
   - Settings UI for theme selection
   - Onboarding theme preference collection
   - Developer tools for theme testing

3. **Performance monitoring**:
   - Track theme switch latency
   - Monitor rebuild frequency
   - Validate accessibility compliance

## References

- [Material Design 3 Color System](https://m3.material.io/styles/color/system)
- [Flutter Accessibility Guide](https://docs.flutter.dev/accessibility-and-localization/accessibility)
- [Clean Architecture by Robert Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- AshTrail instruction prompt (theming requirements)

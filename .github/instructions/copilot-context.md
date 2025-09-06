# Copilot Chat Configuration for AshTrail

This file helps GitHub Copilot Chat understand the AshTrail project context and architecture.

## Project Overview
- **Name**: AshTrail
- **Type**: Flutter mobile app (iOS primary)
- **Purpose**: Smoke logging and insights with offline-first design
- **Architecture**: Clean Architecture + Feature-first modules
- **State Management**: Riverpod with code generation
- **Data**: Freezed models + JSON serialization + Isar (planned)

## Key Conventions

### Naming
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Providers: `<Thing>Provider`
- Variables: `camelCase`

### Architecture Layers
```
presentation/ -> domain/ -> data/
     ↑              ↑        ↑
   Widgets    Use Cases   Repository
  Providers   Entities      DTOs
```

### Common Patterns

#### Creating a Provider
```dart
@riverpod
Future<List<SmokeLog>> smokeLogs(
  SmokeLogsRef ref, {
  required String accountId,
}) async {
  final repository = ref.watch(smokeLogRepositoryProvider);
  final result = await repository.getByAccount(accountId);
  return result.fold(
    (failure) => throw failure,
    (logs) => logs,
  );
}
```

#### Error Handling
```dart
// Repository returns Either<AppFailure, T>
sealed class AppFailure {
  const AppFailure();
}

class NetworkFailure extends AppFailure {
  final String message;
  const NetworkFailure(this.message);
}
```

#### Freezed Model
```dart
@freezed
class SmokeLog with _$SmokeLog {
  const factory SmokeLog({
    required String id,
    required String accountId,
    required DateTime timestamp,
    required int durationMs,
    String? notes,
    int? moodScore,
  }) = _SmokeLog;

  factory SmokeLog.fromJson(Map<String, dynamic> json) =>
      _$SmokeLogFromJson(json);
}
```

## Development Workflow

### Before Making Changes
1. Check `feature_matrix.yaml` for requirements
2. Understand which epic/feature you're working on
3. Follow the acceptance criteria

### After Making Changes
```bash
# Windows
scripts\dev_generate.bat

# Or manually:
python scripts\generate_from_feature_matrix.py
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test --coverage
```

### Testing Strategy
- **Unit tests**: Use cases, repositories, mappers
- **Widget tests**: Key UI components with golden files
- **Integration tests**: Multi-account, offline scenarios

## Current Priorities (from feature_matrix.yaml)

### P0 Features (Must Have)
- `ui.app_shell` - App navigation scaffold
- `ui.routing` - Typed routing with go_router
- `ui.theming` - Dark/light themes
- `logging.capture_hit` - Hold-to-record functionality
- `logging.undo_last` - Undo last log
- `accounts.multi_sign_in_switch` - Multi-account support

### Development Phase
Currently in early development phase focusing on:
1. Core UI shell and navigation
2. Basic logging functionality
3. Data model establishment
4. Architecture scaffolding

## File Structure Context
```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── failures/               # Sealed failure classes
│   └── routing/                # Go router configuration
├── domain/
│   ├── models/                 # Generated Freezed models
│   └── indexes/                # Generated entity indexes
├── features/
│   └── <feature_name>/
│       ├── domain/             # Entities, use cases
│       ├── data/               # DTOs, repositories, data sources
│       └── presentation/       # Widgets, providers, screens
└── telemetry/
    └── events.dart             # Generated telemetry events
```

## Guidelines for AI Assistance

### DO:
- Follow Clean Architecture principles
- Use generated models from feature_matrix.yaml
- Write tests for new functionality
- Follow offline-first patterns
- Use Riverpod providers for state management

### DON'T:
- Modify generated files (marked with // GENERATED)
- Mix presentation and data layer imports
- Use global singletons instead of providers
- Skip adding tests for new features
- Ignore the feature matrix requirements

### When Adding New Features:
1. Update `feature_matrix.yaml` if needed
2. Run code generation
3. Implement following Clean Architecture
4. Add comprehensive tests
5. Update documentation

This context should help Copilot provide more accurate and architecture-compliant suggestions.

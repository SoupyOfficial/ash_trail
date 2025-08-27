# GitHub Copilot Instructions for AshTrail

## Quick Reference for AI Assistance

This file provides context for GitHub Copilot to generate high-quality, architecture-compliant code for the AshTrail project.

### Project Context
- **App**: AshTrail - Smoke logging and insights app
- **Architecture**: Clean Architecture with feature-first modules
- **State**: Riverpod with code generation
- **Navigation**: go_router with typed routes
- **Data**: Freezed models + JSON serialization
- **Offline**: Isar local storage with sync queue

### Current Development Phase
- **Status**: Early development, models and core architecture being established
- **Priority**: P0 features from `feature_matrix.yaml`
- **Target Platform**: iOS first (iPhone 16 Pro Max baseline)

### Code Generation Commands
```bash
# Full regeneration (Windows)
scripts\dev_generate.bat

# Manual steps
python scripts\generate_from_feature_matrix.py
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test --coverage
```

### Architecture Patterns

#### Provider Pattern
```dart
@riverpod
Future<List<SmokeLog>> recentLogs(
  RecentLogsRef ref, {
  required AccountId accountId,
}) async {
  final repo = ref.watch(logRepositoryProvider);
  final result = await repo.fetchRecent(accountId: accountId, limit: 50);
  return result.fold((f) => throw f, (r) => r);
}
```

#### Error Handling
- Use sealed `AppFailure` classes
- Return `Either<AppFailure, T>` from repositories
- Never expose raw exceptions to UI

#### Offline Pattern
- Write to Isar first, mark `dirty`
- Enqueue remote sync operations
- Use `write_policy: enqueue_then_write_remote`

### File Structure
```
lib/
├── core/
│   ├── failures/          # Sealed failure classes
│   └── routing/           # Typed routes
├── domain/
│   ├── models/           # Generated Freezed models
│   └── indexes/          # Generated entity indexes
├── features/
│   └── <feature>/
│       ├── domain/       # Entities, use cases
│       ├── data/         # DTOs, repos, sources
│       └── presentation/ # Widgets, providers
└── telemetry/            # Generated events
```

### Key Dependencies
- `riverpod_annotation` + `riverpod_generator`
- `freezed` + `json_serializable`
- `go_router` + `go_router_builder`
- `flutter_riverpod`

### Development Guidelines
1. **Never** modify generated files (marked with `// GENERATED - DO NOT EDIT`)
2. **Always** update `feature_matrix.yaml` for new entities/features
3. **Run** code generation after matrix changes
4. **Follow** Clean Architecture layers strictly
5. **Test** with minimum 70% coverage

### Common Tasks
- **New Feature**: Add to `feature_matrix.yaml`, run generator
- **New Entity**: Define in `entities` section, regenerate models
- **New Screen**: Create in `features/<name>/presentation/`
- **New Provider**: Use `@riverpod` annotation
- **New Route**: Add to go_router configuration

### Performance Budgets
- Cold start: ≤1200ms (p95)
- Chart render: ≤200ms (p95)
- Log save: ≤80ms (p95)
- Coverage: ≥70% line coverage

### Testing Strategy
- **Unit**: Use cases, mappers, repositories
- **Widget**: Key interactive components
- **Integration**: Account switching, offline sync
- **Golden**: UI components with visual validation

For detailed instructions, see `.github/instructions/` files.

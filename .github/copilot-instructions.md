# GitHub Copilot Instructions for AshTrail

## Project Context
AshTrail is a Flutter-based smoke logging app built with Clean Architecture, feature-first modules, and extensive development automation. The project is optimized for AI-assisted development with comprehensive tooling and strict architectural patterns.

## Essential Architecture Patterns

### Feature Structure
```
lib/features/<feature>/
  domain/           # Pure business logic (no Flutter imports)
    entities/       # Domain models with Freezed
    repositories/   # Abstract interfaces
  data/            # External data handling
    repositories/   # Concrete implementations
  presentation/    # UI and state management
    providers/      # Riverpod providers
    screens/        # Route-level widgets
```

### Key Architectural Rules
1. **Dependency Direction**: UI → Domain ← Data (never UI → Data directly)
2. **Error Handling**: Use sealed `AppFailure` hierarchy - never expose raw exceptions to UI
3. **Providers**: Name as `<Thing>Provider`, keep stateless, use `autoDispose` appropriately
4. **Entities**: Generated from `feature_matrix.yaml` in `lib/domain/models/`

### Code Generation Workflow
Critical: Run after any model changes:
```bash
# Windows
scripts\dev_generate.bat

# macOS/Linux  
./scripts/dev_generate.sh
```
This regenerates Freezed models, builds JSON serialization, and runs analysis.

## Development Commands & Workflows

### Feature Creation
```bash
# Create new feature scaffold
python scripts/simple_feature_scaffold.py feature_name --epic epic_name

# Full development cycle check
python scripts/dev_assistant.py full-check

# Health check with coverage
python scripts/dev_assistant.py health
```

### Testing & Coverage
- Target: ≥80% line coverage (enforced)
- Patch coverage: ≥85% for new/changed lines
- Run: `flutter test --coverage`
- Golden tests required for key widget states

### Performance Budgets (Enforce in code reviews)
- Cold start: ≤2.5s
- Log save: ≤120ms local  
- Chart render: ≤200ms
- Use `const` constructors, minimize rebuilds

## Code Patterns & Examples

### Entity Definition (Freezed)
```dart
@freezed
class SmokeLog with _$SmokeLog {
  const factory SmokeLog({
    required String id,
    required String accountId,
    required DateTime ts,
    required int durationMs,
    String? notes,
  }) = _SmokeLog;
  
  factory SmokeLog.fromJson(Map<String, dynamic> json) => 
    _$SmokeLogFromJson(json);
}
```

### Repository Pattern
```dart
// Domain interface
abstract class SmokeLogRepository {
  Future<Either<AppFailure, List<SmokeLog>>> getLogs(String accountId);
}

// Provider
final smokeLogRepositoryProvider = Provider<SmokeLogRepository>((ref) {
  return IsarSmokeLogRepository(ref.watch(isarProvider));
});
```

### Error Handling
```dart
// Use Either from fpdart
Future<Either<AppFailure, SmokeLog>> saveLog(SmokeLog log) async {
  try {
    final saved = await _dataSource.save(log);
    return Right(saved);
  } catch (e) {
    return Left(DataFailure.saveError(e.toString()));
  }
}
```

## Key Files & Directories
- `feature_matrix.yaml` - Source of truth for all features and data models
- `lib/core/routing/app_router.dart` - go_router configuration
- `lib/main.dart` - App entry point with provider overrides
- `scripts/dev_assistant.py` - Main development automation tool
- `.github/instructions/instruction-prompt.instructions.md` - Canonical AI instructions

## Integration Points
- **State Management**: Riverpod with code generation (`riverpod_annotation`)
- **Navigation**: go_router with typed routes
- **Local Storage**: Isar (planned) with write queue for offline-first
- **Remote**: Firestore with Dio HTTP client
- **Charts**: fl_chart for data visualization

## Development Automation
This project has extensive automation - always use provided scripts:
- `python scripts/dev_assistant.py status` - Feature status overview
- `python scripts/dev_assistant.py dev-cycle` - Full development cycle
- Use VS Code tasks: "Finalize Feature", "Start Next Feature"

## Testing Strategy
- **Unit**: Domain logic, use cases, repositories
- **Widget**: UI components with golden tests for visual states  
- **Integration**: Multi-account flows, offline sync, data persistence
- Use Firebase emulator for backend testing, avoid real Firebase in CI

## Accessibility Requirements
- Semantic labels on interactive elements
- Support text scaling to 200%
- High contrast support
- Tap targets ≥48dp
- Logical focus order

This codebase prioritizes correctness, maintainability, and offline resilience. When in doubt, prefer explicit interfaces, pure functions, and incremental sync patterns.
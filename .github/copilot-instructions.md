````instructions
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

### AI-Assisted Development Workflow

#### Trigger Patterns
When you see these patterns in requests, initiate the full development workflow:

**Feature Implementation Trigger**:
```
#github-pull-request_copilot-coding-agent

Title: [FEATURE] <Feature Name>
Epic: <Epic Name>
Priority: <P0|P1|P2|P3>
...
```

**Bug Fix Trigger**:
```
#github-pull-request_copilot-coding-agent

Title: [BUG] <Bug Description>
Priority: <Critical|High|Medium|Low>
...
```

#### Development Process
1. **Analysis Phase**: Review requirements, existing code, and ask clarifying questions
2. **Planning Phase**: Propose architecture and implementation approach
3. **Implementation Phase**: Create code following established patterns
4. **Testing Phase**: Write comprehensive tests
5. **Documentation Phase**: Update relevant documentation
6. **Integration Phase**: Create PR and update GitHub issues

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
5. **Test** with minimum 80% coverage
6. **Update** GitHub issues as work progresses

### Requirements Integration
Always reference these documents when implementing features:
- `docs/requirements/functional-requirements.md` - Core feature requirements
- `.github/instructions/development-workflow.md` - AI development process
- `.github/instructions/testing-standards.md` - Testing requirements
- `feature_matrix.yaml` - Current feature definitions

### Quality Gates

#### Code Quality
- [ ] Follows established patterns in `.github/instructions/`
- [ ] Uses correct architectural layers (domain/data/presentation)
- [ ] Implements proper error handling with `AppFailure`
- [ ] Includes comprehensive tests (≥80% coverage)
- [ ] Passes static analysis (`flutter analyze`)

#### Documentation Quality
- [ ] README files updated for new features
- [ ] API documentation for public interfaces
- [ ] Architecture decisions documented in ADRs
- [ ] User-facing changes documented

#### Integration Quality
- [ ] All tests pass (`flutter test`)
- [ ] No breaking changes to existing functionality
- [ ] Proper Riverpod provider integration
- [ ] Offline-first patterns followed

### Performance Budgets
- Cold start: ≤1200ms (p95)
- Chart render: ≤200ms (p95)
- Log save: ≤80ms (p95)
- Coverage: ≥80% line coverage

### Testing Strategy
- **Unit**: Use cases, mappers, repositories
- **Widget**: Key interactive components
- **Integration**: Account switching, offline sync
- **Golden**: UI components with visual validation

### GitHub Issue Integration
- Always link PRs to related issues
- Update issue status when starting work
- Close issues when PRs are merged
- Create new issues for discovered dependencies

### Communication Templates

#### Progress Update Format
```
## Progress Update

**Feature**: <Feature Name>
**Status**: <In Progress|Blocked|Ready for Review>
**Completion**: <percentage>%

### Completed
- [x] Task 1
- [x] Task 2

### In Progress
- [ ] Task 3 (50% complete)

### Blocked
- [ ] Task 4 (waiting for clarification on X)

### Next Steps
- Implement task 3
- Await feedback on task 4
```

#### Question Format
```
## Clarification Needed

**Context**: <Brief context>
**Question**: <Specific question>
**Options**: <Available options with pros/cons>
**Recommendation**: <Preferred option with reasoning>
**Impact**: <What happens if delayed>
```

### Success Metrics
- Time from request to implementation: <1 week for P1 features
- Test coverage maintained above 80%
- Zero breaking changes in releases
- All changes reviewed before merge

For detailed development workflow, see `.github/instructions/development-workflow.md`.

````

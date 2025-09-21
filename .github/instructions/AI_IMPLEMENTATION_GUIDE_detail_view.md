# 🚀 Production AI Implementation Guide

## 🎯 Feature Overview
**Feature ID:** `logs.detail_view`
**Title:** Log Detail
**Epic:** logging (LOGGING) | **Priority:** P2 | **Order:** 7
**Complexity:** Simple | **Estimated Duration:** 2-4 hours

---

## 📝 Executive Summary

You are tasked with implementing **Log Detail** (logs.detail_view) as part of the AshTrail mobile application.
This is a production-grade implementation requiring adherence to established architectural patterns,
comprehensive testing, and quality assurance measures.

### 🎨 Rationale & Business Value
_(Refer to acceptance criteria for implementation guidance)_

---

## 🏗️ Architecture & Technical Context

### Clean Architecture Overview
AshTrail follows Clean Architecture principles with strict layer separation:

```
lib/features/detail_view/
├── domain/                    # Pure business logic (no dependencies)
│   ├── entities/              # Core business objects (immutable)
│   ├── repositories/          # Abstract contracts (interfaces)
│   └── usecases/              # Business use cases (pure functions)
├── data/                      # External data handling
│   ├── datasources/           # Remote (Firestore) & Local (Isar) sources
│   ├── repositories/          # Repository implementations
│   └── models/                # DTOs with JSON serialization
└── presentation/              # UI and state management
    ├── providers/             # Riverpod providers and controllers
    ├── screens/               # Full screen implementations
    └── widgets/               # Reusable UI components

test/features/detail_view/         # Comprehensive test coverage
├── domain/                    # Unit tests for use cases and entities
├── data/                      # Repository and data source tests
└── presentation/              # Widget and integration tests
```

### 🔄 Data Flow Pattern
```
UI Widget (Consumer)
    ↓ (user action)
Provider/Controller (Riverpod)
    ↓ (business operation)
UseCase (Domain)
    ↓ (data request)
Repository Interface (Domain)
    ↓ (implementation)
Repository Impl (Data)
    ↓ (I/O operation)
DataSource (Local/Remote)
```

### 🛡️ Error Handling Pattern
```dart
sealed class AppFailure extends Equatable {
  const AppFailure();
}

class NetworkFailure extends AppFailure {
  final String message;
  const NetworkFailure({required this.message});
  @override
  List<Object> get props => [message];
}

class CacheFailure extends AppFailure {
  final String message;
  const CacheFailure({required this.message});
  @override
  List<Object> get props => [message];
}
```

---

## 📋 Requirements Analysis

### ✅ Acceptance Criteria
  - **Must:** Open from table to view full metadata and history.

### 🔧 Technical Specifications

**Required Components:**
  - detail_card
  - actions_row

**Screens/Views:**
  - log_detail

### 🔗 Related Features (Reference Patterns)
  - `logging.capture_hit` - Study existing implementation patterns
  - `logging.undo_last` - Study existing implementation patterns
  - `logs.table_browse_edit` - Study existing implementation patterns

###  Implementation Hints
  - Ensure offline-first data persistence with sync queue
  - Focus on user experience - minimal taps and fast interactions

---

## 🛠️ Implementation Strategy

### Phase 1: Domain Layer (Pure Business Logic)

#### 1.1 Define Entities
```dart
// lib/features/detail_view/domain/entities/detail_view_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'detail_view_entity.freezed.dart';

@freezed
class DetailViewEntity with _$DetailViewEntity {
  const factory DetailViewEntity({
    required String id,
    required DateTime createdAt,
    DateTime? updatedAt,
    // Add your domain fields here based on requirements
  }) = _DetailViewEntity;
  
  // Add domain business logic methods
  // Example: bool get isValid => /* validation logic */;
}
```

#### 1.2 Define Repository Interface
```dart
// lib/features/detail_view/domain/repositories/detail_view_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/detail_view_entity.dart';
import '../../../../core/error/failures.dart';

abstract class DetailViewRepository {
  Future<Either<AppFailure, List<DetailViewEntity>>> getAll();
  Future<Either<AppFailure, DetailViewEntity>> getById(String id);
  Future<Either<AppFailure, DetailViewEntity>> create(DetailViewEntity entity);
  Future<Either<AppFailure, DetailViewEntity>> update(DetailViewEntity entity);
  Future<Either<AppFailure, void>> delete(String id);
}
```

#### 1.3 Implement Use Cases
```dart
// lib/features/detail_view/domain/usecases/get_detail_views_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/detail_view_entity.dart';
import '../repositories/detail_view_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

@injectable
class GetDetailViewsUseCase implements UseCase<List<DetailViewEntity>, NoParams> {
  const GetDetailViewsUseCase(this._repository);
  
  final DetailViewRepository _repository;
  
  @override
  Future<Either<AppFailure, List<DetailViewEntity>>> call(NoParams params) {
    return _repository.getAll();
  }
}
```

### Phase 2: Data Layer (External Dependencies)

#### 2.1 Create Data Models
```dart
// lib/features/detail_view/data/models/detail_view_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/detail_view_entity.dart';

part 'detail_view_model.freezed.dart';
part 'detail_view_model.g.dart';

@freezed
@Collection()
class DetailViewModel with _$DetailViewModel {
  const factory DetailViewModel({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _DetailViewModel;
  
  factory DetailViewModel.fromJson(Map<String, dynamic> json) =>
      _$DetailViewModelFromJson(json);
  
  DetailViewEntity toEntity() => DetailViewEntity(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
  
  factory DetailViewModel.fromEntity(DetailViewEntity entity) =>
      DetailViewModel(
        id: entity.id,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}
```

### Phase 3: Presentation Layer (UI & State)

#### 3.1 Create Riverpod Providers
```dart
// lib/features/detail_view/presentation/providers/detail_view_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/detail_view_entity.dart';
import '../../domain/usecases/get_detail_views_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/di/injection.dart';

part 'detail_view_providers.g.dart';

@riverpod
class DetailViewListNotifier extends _DetailViewListNotifier {
  @override
  Future<List<DetailViewEntity>> build() async {
    final useCase = getIt<GetDetailViewsUseCase>();
    final result = await useCase(NoParams());
    
    return result.fold(
      (failure) => throw failure,
      (entities) => entities,
    );
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}
```

---

## 🧪 Testing Requirements

### Test Coverage Target: ≥85% (Project minimum: 80.0%)

### 📊 Codecov Integration & Coverage Monitoring

This project uses **Codecov** for comprehensive test coverage tracking and quality gates. Understanding and leveraging Codecov is essential for maintaining code quality.

#### Codecov Configuration
The project uses component-based coverage tracking with different targets:
- **Domain Layer**: 90% (business logic requires highest coverage)
- **Core Infrastructure**: 85% (critical system components)
- **Data Layer**: 85% (data handling and persistence)
- **Use Cases**: 95% (critical business operations)
- **Presentation Layer**: 70% (UI tests can be more challenging)
- **Overall Project**: 80% minimum (with 75% patch coverage)

#### Codecov Token & Authentication
The project includes a Codecov token stored in `.codecov_token` for direct CLI usage:
```bash
# View current token (first few characters only)
head -c 8 .codecov_token && echo "..."

# Use token for direct uploads
codecov -f coverage/lcov.info -t $(cat .codecov_token) -F flutter_tests

# Environment variable method (alternative)
export CODECOV_TOKEN=$(cat .codecov_token)
codecov -f coverage/lcov.info -F flutter_tests
```
**Note**: The dev_assistant.py script handles token authentication automatically.

#### Development Workflow with Codecov

**Before Implementation:**
```bash
# Check current Codecov CLI availability
python scripts/dev_assistant.py test-codecov

# Run baseline coverage check
python scripts/dev_assistant.py test-coverage
```

**During Development:**
```bash
# Run tests with coverage (generates coverage/lcov.info)
flutter test --coverage

# Quick development cycle with optional upload
python scripts/dev_assistant.py dev-cycle --upload

# Monitor coverage changes per file
# The dev-cycle command shows file-level coverage deltas
```

**For CI/Production:**
```bash
# Upload coverage to Codecov (with flutter_tests flag)
python scripts/dev_assistant.py upload-codecov

# This uploads coverage/lcov.info with proper flagging
```

**Direct Codecov CLI Usage:**
For advanced usage or troubleshooting, you can use Codecov CLI directly:
```bash
# Using project token (stored in .codecov_token file)
codecov -f coverage/lcov.info -t $(cat .codecov_token) -F flutter_tests

# With verbose output for debugging
codecov -f coverage/lcov.info -t $(cat .codecov_token) -F flutter_tests -v

# Upload specific feature coverage
codecov -f coverage/lcov.info -t $(cat .codecov_token) -F flutter_tests -n "siri_shortcuts_feature"

# Upload with custom branch name
codecov -f coverage/lcov.info -t $(cat .codecov_token) -F flutter_tests -B feat/ui_siri_shortcuts
```

#### Codecov Quality Gates
- **Project Coverage**: Must maintain ≥80% overall
- **Patch Coverage**: New code must have ≥75% coverage
- **Component Targets**: Each architectural component has specific targets
- **Threshold**: 1-2% drop allowed before failure (varies by component)

#### Using Codecov Data During Development

**1. Coverage Analysis:**
```bash
# View current coverage status
python scripts/dev_assistant.py status
# Shows: health check, coverage summary, next features

# Detailed coverage analysis
python scripts/dev_assistant.py test-coverage
# Shows: before/after coverage, warnings if below minimum
```

**2. Session Tracking:**
The `dev-cycle` command creates session manifests in `automation_sessions/` containing:
- Coverage before/after with delta
- File-level coverage changes
- Test pass/fail status
- Git branch and commit info

**3. PR Integration:**
Codecov automatically comments on PRs with:
- Coverage diff showing changes
- Component-level status
- Files with coverage changes
- Quality gate pass/fail status

#### Coverage Best Practices

**High-Priority Testing Areas:**
- ✅ Domain entities and use cases (aim for 90-95%)
- ✅ Repository implementations and data sources
- ✅ Error handling and edge cases
- ✅ State management providers and controllers

**Acceptable Lower Coverage:**
- 🎯 UI widgets (focus on critical user flows)
- 🎯 Generated code (automatically excluded in codecov.yml)
- 🎯 Platform-specific code (Android/iOS directories excluded)

#### Troubleshooting Coverage Issues

**Coverage Too Low:**
```bash
# Identify uncovered code
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # View detailed coverage report

# Focus on critical paths in domain/use cases first
```

**Coverage Upload Failing:**
```bash
# Verify Codecov CLI installation
codecov --version

# Check coverage file exists
ls -la coverage/lcov.info

# Test token authentication
codecov -t $(cat .codecov_token) --dry-run

# Manual upload with debug info
codecov -f coverage/lcov.info -F flutter_tests -v

# Direct upload with token (bypassing dev_assistant.py)
codecov -f coverage/lcov.info -t $(cat .codecov_token) -F flutter_tests -v
```

**⚠️ Coverage Requirements for This Feature:**
- Target ≥85% overall coverage for new `detail_view` feature code
- Domain layer (entities/use cases) should achieve 90%+
- All error scenarios must be tested
- Widget tests should cover loading/error/success states

#### Unit Tests
```dart
// test/features/detail_view/domain/usecases/get_detail_views_usecase_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('GetDetailViewsUseCase', () {
    test('should return entities from repository', () async {
      // arrange
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => Right(testEntities));
      
      // act  
      final result = await useCase(NoParams());
      
      // assert
      expect(result, equals(Right(testEntities)));
      verify(() => mockRepository.getAll());
    });
  });
}
```

#### Widget Tests
```dart
// test/features/detail_view/presentation/screens/detail_view_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('displays loading state correctly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          detail_viewListNotifierProvider.overrideWith((ref) {
            return const AsyncValue.loading();
          }),
        ],
        child: const MaterialApp(home: DetailViewScreen()),
      ),
    );
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

---

## ✅ Quality Checklist

### Architecture Compliance
- [ ] Domain layer has no external dependencies
- [ ] Repository interfaces defined in domain
- [ ] Data layer implements repository contracts
- [ ] Presentation layer uses providers for state

### Error Handling
- [ ] All operations return `Either<AppFailure, T>`
- [ ] User-friendly error messages displayed
- [ ] Network and cache failures handled

### Testing
- [ ] Unit tests cover use cases (happy + error paths)
- [ ] Widget tests cover UI states (loading/error/success)
- [ ] Integration tests verify critical flows
- [ ] Test coverage ≥85% for new code
- [ ] Codecov upload successful (`python scripts/dev_assistant.py upload-codecov`)
- [ ] Component-specific coverage targets met (check PR comments)
- [ ] No critical business logic left uncovered
- [ ] Coverage delta positive or within threshold limits

### Performance & Accessibility
- [ ] No unnecessary widget rebuilds
- [ ] Proper provider disposal (autoDispose where needed)
- [ ] Semantic labels on interactive elements
- [ ] Touch targets ≥48dp minimum

---

## 🚫 Common Pitfalls & Anti-Patterns

### ❌ Feature-Specific Anti-Patterns for Logging Features

```dart
// ❌ BAD: Synchronous logging operations
void logHit() {
  final log = SmokeLog(/*...*/);
  repository.save(log); // Blocks UI thread
}

// ✅ GOOD: Async with offline queue
Future<void> logHit() async {
  final log = SmokeLog(/*...*/);
  await localRepository.save(log); // Offline-first
  syncQueue.enqueue(log); // Background sync
}
```

### ❌ General Architecture Violations
```dart
// ❌ BAD: Direct data import in presentation
import '../data/models/smoke_log_model.dart'; // Domain violation

// ❌ BAD: Business logic in widgets
class LogWidget extends StatelessWidget {
  Widget build(context) {
    final isValid = log.duration > 0 && log.timestamp.isBefore(DateTime.now());
    // Business logic belongs in domain layer
  }
}

// ✅ GOOD: Use domain entities
import '../domain/entities/smoke_log_entity.dart';

class LogWidget extends StatelessWidget {
  Widget build(context) {
    return log.isValid ? ValidLogView() : InvalidLogView();
    // Business logic in entity.isValid getter
  }
}
```

---

## 🚧 Development Workflow

### Validation Commands
```bash
# Continuous testing during development
flutter test --coverage test/features/detail_view/

# Run code generation  
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check syntax and analysis
flutter analyze

# Complete dev cycle with coverage tracking
python scripts/dev_assistant.py dev-cycle --upload

# Check Codecov status and requirements
python scripts/dev_assistant.py test-codecov
python scripts/dev_assistant.py status

# Validate feature completion
python scripts/dev_assistant.py finalize-feature --feature-id logs.detail_view --dry-run
```

### Codecov Development Workflow
```bash
# 1. Initial setup - verify Codecov CLI
python scripts/dev_assistant.py test-codecov

# Alternative: Direct CLI check
codecov --version
codecov -t $(cat .codecov_token) --dry-run

# 2. Development cycle - run tests, track coverage, upload
python scripts/dev_assistant.py dev-cycle --upload

# Alternative: Manual development cycle
flutter test --coverage
codecov -f coverage/lcov.info -t $(cat .codecov_token) -F flutter_tests -v

# 3. Review coverage changes
# Check automation_sessions/ for latest session manifest
# Review file-level coverage deltas

# 4. Manual coverage analysis (if needed)
python scripts/dev_assistant.py test-coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
# Open coverage/html/index.html for detailed analysis

# 5. Final validation before PR
python scripts/dev_assistant.py upload-codecov
# Alternative: Direct upload with feature naming
codecov -f coverage/lcov.info -t $(cat .codecov_token) -F flutter_tests -n "siri_shortcuts_implementation"
# Ensure coverage meets component targets
```

### Quick Reference
- **Feature Matrix:** [`feature_matrix.yaml`](../../feature_matrix.yaml)
- **Architecture Docs:** [`docs/system-architecture.md`](../../docs/system-architecture.md)
- **AI Instructions:** [`.github/instructions/instruction-prompt.instructions.md`](../../.github/instructions/instruction-prompt.instructions.md)

---

## 🎯 Success Criteria

✅ **Implementation Complete When:**
- All acceptance criteria satisfied
- Test coverage ≥85% for new code
- No architectural boundary violations
- All error cases handled gracefully
- Performance targets met (if specified)
- Accessibility requirements satisfied
- Code review passes (automated + human)

---

**Generated:** 2025-09-21T00:01:45.787712+00:00
**Complexity:** Simple | **Epic:** logging | **Priority:** P2

🚀 **Ready to implement? Follow Clean Architecture patterns and maintain quality standards!**
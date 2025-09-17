# 🚀 Production AI Implementation Guide

## 🎯 Feature Overview
**Feature ID:** `ui.haptics_baseline`
**Title:** Haptics Baseline
**Epic:** ui (UI) | **Priority:** P1 | **Order:** 8
**Complexity:** Simple | **Estimated Duration:** 2-4 hours

---

## 📝 Executive Summary

You are tasked with implementing **Haptics Baseline** (ui.haptics_baseline) as part of the AshTrail mobile application.
This is a production-grade implementation requiring adherence to established architectural patterns,
comprehensive testing, and quality assurance measures.

### 🎨 Rationale & Business Value
_(Refer to acceptance criteria for implementation guidance)_

---

## 🏗️ Architecture & Technical Context

### Clean Architecture Overview
AshTrail follows Clean Architecture principles with strict layer separation:

```
lib/features/haptics_baseline/
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

test/features/haptics_baseline/         # Comprehensive test coverage
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
  - **Must:** Central utility exposes semantic haptic events: tap, success, warning, error, impact_light.
  - **Must:** Logging capture uses press (impact_light) and release (success) patterns.
  - **Must:** Haptics disabled automatically when Reduce Motion or system haptics disabled (if detectable) or via dev flag.
  - **Must:** Unit test: utility no-op when disabled flag set.

### 🔧 Technical Specifications

**Required Components:**
  - haptics_service

### 🔗 Related Features (Reference Patterns)
  - `ui.app_shell` - Study existing implementation patterns
  - `ui.routing` - Study existing implementation patterns
  - `ui.theming` - Study existing implementation patterns

###  Implementation Hints
  - Focus on responsive design and accessibility compliance
  - Use consistent theming and semantic colors from design system

---

## 🛠️ Implementation Strategy

### Phase 1: Domain Layer (Pure Business Logic)

#### 1.1 Define Entities
```dart
// lib/features/haptics_baseline/domain/entities/haptics_baseline_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'haptics_baseline_entity.freezed.dart';

@freezed
class HapticsBaselineEntity with _$HapticsBaselineEntity {
  const factory HapticsBaselineEntity({
    required String id,
    required DateTime createdAt,
    DateTime? updatedAt,
    // Add your domain fields here based on requirements
  }) = _HapticsBaselineEntity;
  
  // Add domain business logic methods
  // Example: bool get isValid => /* validation logic */;
}
```

#### 1.2 Define Repository Interface
```dart
// lib/features/haptics_baseline/domain/repositories/haptics_baseline_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/haptics_baseline_entity.dart';
import '../../../../core/error/failures.dart';

abstract class HapticsBaselineRepository {
  Future<Either<AppFailure, List<HapticsBaselineEntity>>> getAll();
  Future<Either<AppFailure, HapticsBaselineEntity>> getById(String id);
  Future<Either<AppFailure, HapticsBaselineEntity>> create(HapticsBaselineEntity entity);
  Future<Either<AppFailure, HapticsBaselineEntity>> update(HapticsBaselineEntity entity);
  Future<Either<AppFailure, void>> delete(String id);
}
```

#### 1.3 Implement Use Cases
```dart
// lib/features/haptics_baseline/domain/usecases/get_haptics_baselines_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/haptics_baseline_entity.dart';
import '../repositories/haptics_baseline_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

@injectable
class GetHapticsBaselinesUseCase implements UseCase<List<HapticsBaselineEntity>, NoParams> {
  const GetHapticsBaselinesUseCase(this._repository);
  
  final HapticsBaselineRepository _repository;
  
  @override
  Future<Either<AppFailure, List<HapticsBaselineEntity>>> call(NoParams params) {
    return _repository.getAll();
  }
}
```

### Phase 2: Data Layer (External Dependencies)

#### 2.1 Create Data Models
```dart
// lib/features/haptics_baseline/data/models/haptics_baseline_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/haptics_baseline_entity.dart';

part 'haptics_baseline_model.freezed.dart';
part 'haptics_baseline_model.g.dart';

@freezed
@Collection()
class HapticsBaselineModel with _$HapticsBaselineModel {
  const factory HapticsBaselineModel({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _HapticsBaselineModel;
  
  factory HapticsBaselineModel.fromJson(Map<String, dynamic> json) =>
      _$HapticsBaselineModelFromJson(json);
  
  HapticsBaselineEntity toEntity() => HapticsBaselineEntity(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
  
  factory HapticsBaselineModel.fromEntity(HapticsBaselineEntity entity) =>
      HapticsBaselineModel(
        id: entity.id,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}
```

### Phase 3: Presentation Layer (UI & State)

#### 3.1 Create Riverpod Providers
```dart
// lib/features/haptics_baseline/presentation/providers/haptics_baseline_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/haptics_baseline_entity.dart';
import '../../domain/usecases/get_haptics_baselines_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/di/injection.dart';

part 'haptics_baseline_providers.g.dart';

@riverpod
class HapticsBaselineListNotifier extends _HapticsBaselineListNotifier {
  @override
  Future<List<HapticsBaselineEntity>> build() async {
    final useCase = getIt<GetHapticsBaselinesUseCase>();
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

#### Unit Tests
```dart
// test/features/haptics_baseline/domain/usecases/get_haptics_baselines_usecase_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('GetHapticsBaselinesUseCase', () {
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
// test/features/haptics_baseline/presentation/screens/haptics_baseline_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('displays loading state correctly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          haptics_baselineListNotifierProvider.overrideWith((ref) {
            return const AsyncValue.loading();
          }),
        ],
        child: const MaterialApp(home: HapticsBaselineScreen()),
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

### Performance & Accessibility
- [ ] No unnecessary widget rebuilds
- [ ] Proper provider disposal (autoDispose where needed)
- [ ] Semantic labels on interactive elements
- [ ] Touch targets ≥48dp minimum

---

## 🚫 Common Pitfalls & Anti-Patterns

### ❌ Feature-Specific Anti-Patterns for Ui Features

```dart
// ❌ BAD: Hardcoded accessibility
Text('Record Hit'); // No semantic meaning

// ✅ GOOD: Accessible with proper sizing
Semantics(
  label: 'Record smoking hit. Hold to start timing.',
  child: GestureDetector(
    child: Container(width: 48, height: 48),
  ),
);
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
flutter test --coverage test/features/haptics_baseline/

# Run code generation  
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check syntax and analysis
flutter analyze

# Validate feature completion
python scripts/dev_assistant.py finalize-feature --feature-id ui.haptics_baseline --dry-run
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

**Generated:** 2025-09-17T03:04:45.030193+00:00
**Complexity:** Simple | **Epic:** ui | **Priority:** P1

🚀 **Ready to implement? Follow Clean Architecture patterns and maintain quality standards!**
# 🚀 Production AI Implementation Guide

## 🎯 Feature Overview
**Feature ID:** `ui.accessibility_foundation`
**Title:** Accessibility Foundation
**Epic:** ui (UI) | **Priority:** P2 | **Order:** 7
**Complexity:** Simple | **Estimated Duration:** 2-4 hours

---

## 📝 Executive Summary

You are tasked with implementing **Accessibility Foundation** (ui.accessibility_foundation) as part of the AshTrail mobile application.
This is a production-grade implementation requiring adherence to established architectural patterns,
comprehensive testing, and quality assurance measures.

### 🎨 Rationale & Business Value
_(Refer to acceptance criteria for implementation guidance)_

---

## 🏗️ Architecture & Technical Context

### Clean Architecture Overview
AshTrail follows Clean Architecture principles with strict layer separation:

```
lib/features/accessibility_foundation/
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

test/features/accessibility_foundation/         # Comprehensive test coverage
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
  - **Must:** Global text scale up to 200% without overflow on primary screens.
  - **Must:** Focus order and traversal defined for keyboard / assistive tech.
  - **Must:** Semantics labels on navigation items and record button.
  - **Must:** VoiceOver rotor / actions labels present for log rows & record button.
  - **Must:** All interactive elements meet ≥44pt (iOS) hit area; audit documented.
  - **Must:** Supports Bold Text, Increase Contrast, Reduce Motion without layout breakage.

### 🔧 Technical Specifications

**Required Components:**
  - semantics_wrappers

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
// lib/features/accessibility_foundation/domain/entities/accessibility_foundation_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'accessibility_foundation_entity.freezed.dart';

@freezed
class AccessibilityFoundationEntity with _$AccessibilityFoundationEntity {
  const factory AccessibilityFoundationEntity({
    required String id,
    required DateTime createdAt,
    DateTime? updatedAt,
    // Add your domain fields here based on requirements
  }) = _AccessibilityFoundationEntity;
  
  // Add domain business logic methods
  // Example: bool get isValid => /* validation logic */;
}
```

#### 1.2 Define Repository Interface
```dart
// lib/features/accessibility_foundation/domain/repositories/accessibility_foundation_repository.dart
import 'package:dartz/dartz.dart';
import '../entities/accessibility_foundation_entity.dart';
import '../../../../core/error/failures.dart';

abstract class AccessibilityFoundationRepository {
  Future<Either<AppFailure, List<AccessibilityFoundationEntity>>> getAll();
  Future<Either<AppFailure, AccessibilityFoundationEntity>> getById(String id);
  Future<Either<AppFailure, AccessibilityFoundationEntity>> create(AccessibilityFoundationEntity entity);
  Future<Either<AppFailure, AccessibilityFoundationEntity>> update(AccessibilityFoundationEntity entity);
  Future<Either<AppFailure, void>> delete(String id);
}
```

#### 1.3 Implement Use Cases
```dart
// lib/features/accessibility_foundation/domain/usecases/get_accessibility_foundations_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../entities/accessibility_foundation_entity.dart';
import '../repositories/accessibility_foundation_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

@injectable
class GetAccessibilityFoundationsUseCase implements UseCase<List<AccessibilityFoundationEntity>, NoParams> {
  const GetAccessibilityFoundationsUseCase(this._repository);
  
  final AccessibilityFoundationRepository _repository;
  
  @override
  Future<Either<AppFailure, List<AccessibilityFoundationEntity>>> call(NoParams params) {
    return _repository.getAll();
  }
}
```

### Phase 2: Data Layer (External Dependencies)

#### 2.1 Create Data Models
```dart
// lib/features/accessibility_foundation/data/models/accessibility_foundation_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:isar/isar.dart';
import '../../domain/entities/accessibility_foundation_entity.dart';

part 'accessibility_foundation_model.freezed.dart';
part 'accessibility_foundation_model.g.dart';

@freezed
@Collection()
class AccessibilityFoundationModel with _$AccessibilityFoundationModel {
  const factory AccessibilityFoundationModel({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _AccessibilityFoundationModel;
  
  factory AccessibilityFoundationModel.fromJson(Map<String, dynamic> json) =>
      _$AccessibilityFoundationModelFromJson(json);
  
  AccessibilityFoundationEntity toEntity() => AccessibilityFoundationEntity(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
  
  factory AccessibilityFoundationModel.fromEntity(AccessibilityFoundationEntity entity) =>
      AccessibilityFoundationModel(
        id: entity.id,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}
```

### Phase 3: Presentation Layer (UI & State)

#### 3.1 Create Riverpod Providers
```dart
// lib/features/accessibility_foundation/presentation/providers/accessibility_foundation_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/accessibility_foundation_entity.dart';
import '../../domain/usecases/get_accessibility_foundations_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/di/injection.dart';

part 'accessibility_foundation_providers.g.dart';

@riverpod
class AccessibilityFoundationListNotifier extends _AccessibilityFoundationListNotifier {
  @override
  Future<List<AccessibilityFoundationEntity>> build() async {
    final useCase = getIt<GetAccessibilityFoundationsUseCase>();
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
// test/features/accessibility_foundation/domain/usecases/get_accessibility_foundations_usecase_test.dart
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('GetAccessibilityFoundationsUseCase', () {
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
// test/features/accessibility_foundation/presentation/screens/accessibility_foundation_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('displays loading state correctly', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          accessibility_foundationListNotifierProvider.overrideWith((ref) {
            return const AsyncValue.loading();
          }),
        ],
        child: const MaterialApp(home: AccessibilityFoundationScreen()),
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
flutter test --coverage test/features/accessibility_foundation/

# Run code generation  
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check syntax and analysis
flutter analyze

# Validate feature completion
python scripts/dev_assistant.py finalize-feature --feature-id ui.accessibility_foundation --dry-run
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

**Generated:** 2025-09-17T01:57:24.358005+00:00
**Complexity:** Simple | **Epic:** ui | **Priority:** P2

🚀 **Ready to implement? Follow Clean Architecture patterns and maintain quality standards!**
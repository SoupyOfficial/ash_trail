# Testing Standards for AshTrail

## Overview
This document defines the testing standards and practices for AshTrail development, ensuring consistent quality and maintainability across all features.

## Testing Philosophy

### Test-Driven Mindset
- **Quality First**: Tests are not optional, they're part of the definition of done
- **Fast Feedback**: Tests should run quickly and provide immediate feedback
- **Confidence**: Tests should give confidence that changes don't break existing functionality
- **Documentation**: Tests serve as living documentation of feature behavior

### Coverage Requirements
- **Minimum**: 80% line coverage across the entire codebase
- **Domain Layer**: 95% coverage (business logic is critical)
- **Data Layer**: 85% coverage (includes error handling)
- **Presentation Layer**: 75% coverage (focus on key interactions)

## Test Types & Structure

### 1. Unit Tests
**Location**: `test/unit/`
**Purpose**: Test individual components in isolation

#### Domain Layer Tests
```dart
// test/unit/domain/use_cases/log_smoke_use_case_test.dart
void main() {
  group('LogSmokeUseCase', () {
    late MockLogRepository mockRepository;
    late LogSmokeUseCase useCase;

    setUp(() {
      mockRepository = MockLogRepository();
      useCase = LogSmokeUseCase(mockRepository);
    });

    group('execute', () {
      testWidgets('should log smoke entry successfully', (tester) async {
        // Arrange
        final smokeLog = SmokeLog(...);
        when(() => mockRepository.create(any()))
            .thenAnswer((_) async => const Right(unit));

        // Act
        final result = await useCase.execute(smokeLog);

        // Assert
        expect(result, const Right(unit));
        verify(() => mockRepository.create(smokeLog)).called(1);
      });

      testWidgets('should return failure when repository fails', (tester) async {
        // Arrange
        final failure = const DatabaseFailure('Connection failed');
        when(() => mockRepository.create(any()))
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.execute(smokeLog);

        // Assert
        expect(result, Left(failure));
      });
    });
  });
}
```

#### Repository Tests
```dart
// test/unit/data/repositories/log_repository_impl_test.dart
void main() {
  group('LogRepositoryImpl', () {
    late MockLocalDataSource mockLocalDataSource;
    late MockRemoteDataSource mockRemoteDataSource;
    late MockNetworkInfo mockNetworkInfo;
    late LogRepositoryImpl repository;

    setUp(() {
      mockLocalDataSource = MockLocalDataSource();
      mockRemoteDataSource = MockRemoteDataSource();
      mockNetworkInfo = MockNetworkInfo();
      repository = LogRepositoryImpl(
        localDataSource: mockLocalDataSource,
        remoteDataSource: mockRemoteDataSource,
        networkInfo: mockNetworkInfo,
      );
    });

    group('create', () {
      testWidgets('should save locally first then sync remotely when online',
          (tester) async {
        // Test offline-first pattern
      });

      testWidgets('should save locally only when offline', (tester) async {
        // Test offline behavior
      });
    });
  });
}
```

### 2. Widget Tests
**Location**: `test/widget/`
**Purpose**: Test UI components and their interactions

#### Screen Tests
```dart
// test/widget/features/dashboard/dashboard_screen_test.dart
void main() {
  group('DashboardScreen', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          logRepositoryProvider.overrideWithValue(MockLogRepository()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should display loading indicator when loading', (tester) async {
      // Arrange
      when(() => mockRepository.getRecent(any()))
          .thenAnswer((_) => const Stream.empty());

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display smoke logs when loaded', (tester) async {
      // Test successful data display
    });

    testWidgets('should display error message when failed', (tester) async {
      // Test error handling
    });
  });
}
```

#### Component Tests
```dart
// test/widget/features/logging/record_button_test.dart
void main() {
  group('RecordButton', () {
    testWidgets('should show idle state initially', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RecordButton()),
      );

      expect(find.text('Start Session'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('should transition to recording state when tapped', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: RecordButton()),
      );

      await tester.tap(find.byType(RecordButton));
      await tester.pumpAndSettle();

      expect(find.text('Recording...'), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
    });
  });
}
```

### 3. Integration Tests
**Location**: `test/integration/`
**Purpose**: Test complete user workflows and system integration

#### User Flow Tests
```dart
// test/integration/smoke_logging_flow_test.dart
void main() {
  group('Smoke Logging Flow', () {
    testWidgets('complete smoke logging workflow', (tester) async {
      // Arrange
      await tester.pumpWidget(const MyApp());
      
      // Navigate to logging screen
      await tester.tap(find.text('Log Session'));
      await tester.pumpAndSettle();
      
      // Start recording
      await tester.tap(find.byType(RecordButton));
      await tester.pumpAndSettle();
      
      // Verify recording state
      expect(find.text('Recording...'), findsOneWidget);
      
      // Stop recording
      await tester.tap(find.byType(RecordButton));
      await tester.pumpAndSettle();
      
      // Fill out details
      await tester.enterText(find.byType(TextField), 'Great session');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      
      // Verify saved to dashboard
      expect(find.text('Great session'), findsOneWidget);
    });
  });
}
```

### 4. Golden Tests
**Location**: `test/golden/`
**Purpose**: Visual regression testing for UI components

```dart
// test/golden/record_button_test.dart
void main() {
  group('RecordButton Golden Tests', () {
    testWidgets('idle state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(body: Center(child: RecordButton())),
        ),
      );

      await expectLater(
        find.byType(RecordButton),
        matchesGoldenFile('record_button_idle.png'),
      );
    });

    testWidgets('recording state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: Center(child: RecordButton(isRecording: true)),
          ),
        ),
      );

      await expectLater(
        find.byType(RecordButton),
        matchesGoldenFile('record_button_recording.png'),
      );
    });
  });
}
```

## Test Utilities & Setup

### Common Test Utilities
```dart
// test/test_util/test_helpers.dart
class TestHelpers {
  static Widget createTestApp({
    required Widget child,
    List<Override> providerOverrides = const [],
  }) {
    return ProviderScope(
      overrides: providerOverrides,
      child: MaterialApp(
        home: child,
        theme: ThemeData.light(),
      ),
    );
  }

  static ProviderContainer createTestContainer({
    List<Override> overrides = const [],
  }) {
    return ProviderContainer(overrides: overrides);
  }
}
```

### Mock Factories
```dart
// test/test_util/mock_factories.dart
class MockFactories {
  static SmokeLog createSmokeLog({
    String? id,
    String? accountId,
    DateTime? timestamp,
  }) {
    return SmokeLog(
      id: id ?? 'test-id',
      accountId: accountId ?? 'test-account',
      timestamp: timestamp ?? DateTime.now(),
      durationMs: 300000, // 5 minutes
    );
  }

  static Account createAccount({
    String? id,
    String? displayName,
  }) {
    return Account(
      id: id ?? 'test-account',
      displayName: displayName ?? 'Test User',
      lastActiveAt: DateTime.now(),
    );
  }
}
```

## Test Organization

### File Naming Convention
- Unit tests: `*_test.dart`
- Widget tests: `*_widget_test.dart`
- Integration tests: `*_integration_test.dart`
- Golden tests: `*_golden_test.dart`

### Directory Structure
```
test/
├── test_util/              # Shared test utilities
│   ├── test_helpers.dart
│   ├── mock_factories.dart
│   └── test_data.dart
├── unit/                   # Unit tests
│   ├── domain/
│   ├── data/
│   └── core/
├── widget/                 # Widget tests
│   ├── features/
│   └── core/
├── integration/            # Integration tests
│   └── flows/
└── golden/                 # Golden tests
    └── components/
```

## Mocking Strategy

### Repository Mocking
```dart
class MockLogRepository extends Mock implements LogRepository {}
```

### Provider Mocking
```dart
final mockLogRepository = MockLogRepository();

// Override in tests
ProviderScope(
  overrides: [
    logRepositoryProvider.overrideWithValue(mockLogRepository),
  ],
  child: MyWidget(),
);
```

### Data Source Mocking
```dart
class MockFirestoreDataSource extends Mock implements FirestoreDataSource {}
class MockIsarDataSource extends Mock implements IsarDataSource {}
```

## CI/CD Integration

### Test Commands
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test suite
flutter test test/unit/
flutter test test/widget/
flutter test test/integration/

# Run golden tests
flutter test test/golden/ --update-goldens  # Update goldens
flutter test test/golden/                   # Verify goldens
```

### Coverage Gates
- **PR Requirement**: All tests must pass
- **Coverage Gate**: Must maintain 80% minimum coverage
- **Regression Gate**: No reduction in coverage from baseline

### Performance Tests
```dart
// test/performance/chart_rendering_test.dart
void main() {
  testWidgets('chart rendering performance', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ChartWidget(data: largeSampleData)),
    );

    // Measure rendering time
    final stopwatch = Stopwatch()..start();
    await tester.pumpAndSettle();
    stopwatch.stop();

    expect(stopwatch.elapsedMilliseconds, lessThan(200));
  });
}
```

## Best Practices

### Test Writing Guidelines
1. **Arrange-Act-Assert**: Structure tests clearly
2. **Single Responsibility**: One test per behavior
3. **Descriptive Names**: Test names should describe the scenario
4. **Independent Tests**: Tests should not depend on each other
5. **Fast Execution**: Tests should run quickly

### Mock Guidelines
1. **Minimal Mocking**: Only mock external dependencies
2. **Behavior Verification**: Verify interactions when important
3. **State Verification**: Verify outcomes over implementation
4. **Realistic Data**: Use realistic test data

### Error Testing
1. **Happy Path**: Test the main success scenario
2. **Error Cases**: Test all failure modes
3. **Edge Cases**: Test boundary conditions
4. **Async Errors**: Test async operation failures

## Maintenance

### Regular Tasks
- Review and update test data monthly
- Update golden files when UI changes
- Refactor tests when code changes
- Monitor and improve coverage

### Test Debt Management
- Flag flaky tests for investigation
- Remove obsolete tests promptly
- Refactor duplicated test code
- Keep test utilities current

---

These testing standards ensure high-quality, maintainable code throughout AshTrail development.

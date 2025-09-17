import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/features/siri_shortcuts/presentation/providers/siri_shortcuts_providers.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/repositories/siri_shortcuts_repository.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/usecases/donate_shortcuts_use_case.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/usecases/get_siri_shortcuts_use_case.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/usecases/handle_shortcut_invocation_use_case.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcuts_entity.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcut_type.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:fpdart/fpdart.dart';

class MockSiriShortcutsRepository extends Mock
    implements SiriShortcutsRepository {}

class MockDonateShortcutsUseCase extends Mock
    implements DonateShortcutsUseCase {}

class MockGetSiriShortcutsUseCase extends Mock
    implements GetSiriShortcutsUseCase {}

class MockHandleShortcutInvocationUseCase extends Mock
    implements HandleShortcutInvocationUseCase {}

void main() {
  setUpAll(() {
    // Register fallback value for SiriShortcutType
    registerFallbackValue(const SiriShortcutType.addLog());
  });
  group('SiriShortcutsProviders', () {
    late MockSiriShortcutsRepository mockRepository;
    late MockDonateShortcutsUseCase mockDonateUseCase;
    late MockGetSiriShortcutsUseCase mockGetUseCase;
    late MockHandleShortcutInvocationUseCase mockHandleUseCase;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockSiriShortcutsRepository();
      mockDonateUseCase = MockDonateShortcutsUseCase();
      mockGetUseCase = MockGetSiriShortcutsUseCase();
      mockHandleUseCase = MockHandleShortcutInvocationUseCase();

      container = ProviderContainer(
        overrides: [
          siriShortcutsRepositoryProvider.overrideWithValue(mockRepository),
          donateShortcutsUseCaseProvider.overrideWithValue(mockDonateUseCase),
          getSiriShortcutsUseCaseProvider.overrideWithValue(mockGetUseCase),
          handleShortcutInvocationUseCaseProvider
              .overrideWithValue(mockHandleUseCase),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('siriShortcutsListProvider', () {
      test('should return shortcuts when use case succeeds', () async {
        // arrange
        final shortcuts = [
          SiriShortcutsEntity(
            id: '1',
            type: const SiriShortcutType.addLog(),
            createdAt: DateTime.now(),
          ),
        ];
        when(() => mockGetUseCase.call())
            .thenAnswer((_) async => Right(shortcuts));

        // act
        final result = await container.read(siriShortcutsListProvider.future);

        // assert
        expect(result, equals(shortcuts));
        verify(() => mockGetUseCase.call()).called(1);
      });

      test('should throw exception when use case fails', () async {
        // arrange
        const failure = AppFailure.cache(message: 'Cache error');
        when(() => mockGetUseCase.call())
            .thenAnswer((_) async => const Left(failure));

        // act & assert
        await expectLater(
          () => container.read(siriShortcutsListProvider.future),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('siriShortcutsSupportProvider', () {
      test('should return true when platform supports shortcuts', () async {
        // arrange
        when(() => mockRepository.isSiriShortcutsSupported())
            .thenAnswer((_) async => const Right(true));

        // act
        final result =
            await container.read(siriShortcutsSupportProvider.future);

        // assert
        expect(result, isTrue);
        verify(() => mockRepository.isSiriShortcutsSupported()).called(1);
      });

      test('should return false when repository call fails', () async {
        // arrange
        when(() => mockRepository.isSiriShortcutsSupported()).thenAnswer(
            (_) async => const Left(AppFailure.unexpected(message: 'Error')));

        // act
        final result =
            await container.read(siriShortcutsSupportProvider.future);

        // assert
        expect(result, isFalse);
      });
    });

    group('SiriShortcutsController', () {
      test('should initialize with loading state and eventually load shortcuts',
          () async {
        // arrange
        final shortcuts = [
          SiriShortcutsEntity(
            id: '1',
            type: const SiriShortcutType.addLog(),
            createdAt: DateTime.now(),
          ),
        ];
        when(() => mockRepository.isSiriShortcutsSupported())
            .thenAnswer((_) async => const Right(true));
        when(() => mockGetUseCase.call())
            .thenAnswer((_) async => Right(shortcuts));

        // act - controller automatically loads on creation
        final initialState = container.read(siriShortcutsControllerProvider);

        // Should start in loading state since constructor calls _loadShortcuts
        expect(initialState.status, SiriShortcutsStatus.loading);

        // Wait for loading to complete
        await Future.delayed(const Duration(milliseconds: 200));

        final finalState = container.read(siriShortcutsControllerProvider);

        // assert
        expect(finalState.status, SiriShortcutsStatus.loaded);
        expect(finalState.shortcuts, shortcuts);
        expect(finalState.isSupported, isTrue);
      });

      test('should handle load shortcuts error', () async {
        // arrange
        const failure = AppFailure.cache(message: 'Cache error');
        when(() => mockRepository.isSiriShortcutsSupported())
            .thenAnswer((_) async => const Right(false));
        when(() => mockGetUseCase.call())
            .thenAnswer((_) async => const Left(failure));

        // act - controller automatically loads on creation
        container.read(siriShortcutsControllerProvider);

        // Wait for loading to complete
        await Future.delayed(const Duration(milliseconds: 200));

        final state = container.read(siriShortcutsControllerProvider);

        // assert
        expect(state.status, SiriShortcutsStatus.error);
        expect(state.errorMessage, 'Cache error');
        expect(state.isSupported, isFalse);
      });

      test('should handle exception during load', () async {
        // arrange
        when(() => mockRepository.isSiriShortcutsSupported())
            .thenThrow(Exception('Test exception'));

        // act - controller automatically loads on creation
        container.read(siriShortcutsControllerProvider);

        // Wait for loading to complete
        await Future.delayed(const Duration(milliseconds: 200));

        final state = container.read(siriShortcutsControllerProvider);

        // assert
        expect(state.status, SiriShortcutsStatus.error);
        expect(state.errorMessage, contains('Failed to load shortcuts'));
      });

      test('should donate shortcuts successfully', () async {
        // arrange - create a separate container for this test
        final testContainer = ProviderContainer(
          overrides: [
            siriShortcutsRepositoryProvider.overrideWithValue(mockRepository),
            donateShortcutsUseCaseProvider.overrideWithValue(mockDonateUseCase),
            getSiriShortcutsUseCaseProvider.overrideWithValue(mockGetUseCase),
            handleShortcutInvocationUseCaseProvider
                .overrideWithValue(mockHandleUseCase),
          ],
        );

        when(() => mockRepository.isSiriShortcutsSupported())
            .thenAnswer((_) async => const Right(true));
        when(() => mockGetUseCase.call())
            .thenAnswer((_) async => const Right([]));
        when(() => mockDonateUseCase.call())
            .thenAnswer((_) async => const Right(null));

        // Wait for initial load
        testContainer.read(siriShortcutsControllerProvider);
        await Future.delayed(const Duration(milliseconds: 200));

        final controller =
            testContainer.read(siriShortcutsControllerProvider.notifier);

        // act
        await controller.donateShortcuts();
        // Wait for the reload that happens after donation
        await Future.delayed(const Duration(milliseconds: 200));

        // assert
        final state = testContainer.read(siriShortcutsControllerProvider);
        expect(state.isDonating, isFalse);
        verify(() => mockDonateUseCase.call()).called(1);

        testContainer.dispose();
      });

      test('should handle donate shortcuts error', () async {
        // arrange
        const failure = AppFailure.network(message: 'Network error');
        when(() => mockRepository.isSiriShortcutsSupported())
            .thenAnswer((_) async => const Right(true));
        when(() => mockGetUseCase.call())
            .thenAnswer((_) async => const Right([]));
        when(() => mockDonateUseCase.call())
            .thenAnswer((_) async => const Left(failure));

        final controller =
            container.read(siriShortcutsControllerProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 200));

        // act
        await controller.donateShortcuts();

        // assert
        final state = container.read(siriShortcutsControllerProvider);
        expect(state.isDonating, isFalse);
        expect(state.errorMessage, 'Network error');
      });

      test('should skip donation when platform not supported', () async {
        // arrange
        when(() => mockRepository.isSiriShortcutsSupported())
            .thenAnswer((_) async => const Right(false));
        when(() => mockGetUseCase.call())
            .thenAnswer((_) async => const Right([]));

        final controller =
            container.read(siriShortcutsControllerProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 200));

        // act
        await controller.donateShortcuts();

        // assert
        verifyNever(() => mockDonateUseCase.call());
      });

      test('should handle donate shortcuts exception', () async {
        // arrange
        when(() => mockRepository.isSiriShortcutsSupported())
            .thenAnswer((_) async => const Right(true));
        when(() => mockGetUseCase.call())
            .thenAnswer((_) async => const Right([]));
        when(() => mockDonateUseCase.call())
            .thenThrow(Exception('Test exception'));

        final controller =
            container.read(siriShortcutsControllerProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 200));

        // act
        await controller.donateShortcuts();

        // assert
        final state = container.read(siriShortcutsControllerProvider);
        expect(state.isDonating, isFalse);
        expect(state.errorMessage, contains('Failed to donate shortcuts'));
      });

      test('should handle shortcut invocation successfully', () async {
        // arrange
        when(() => mockRepository.isSiriShortcutsSupported())
            .thenAnswer((_) async => const Right(true));
        when(() => mockGetUseCase.call())
            .thenAnswer((_) async => const Right([]));
        when(() => mockHandleUseCase.call(any()))
            .thenAnswer((_) async => const Right('/logs'));

        final controller =
            container.read(siriShortcutsControllerProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 200));

        // act
        final route = await controller.handleShortcutInvocation(
          const SiriShortcutType.addLog(),
        );

        // assert
        expect(route, '/logs');
        verify(() => mockHandleUseCase.call(const SiriShortcutType.addLog()))
            .called(1);
      });

      test('should handle shortcut invocation failure', () async {
        // arrange
        const failure = AppFailure.network(message: 'Network error');
        when(() => mockRepository.isSiriShortcutsSupported())
            .thenAnswer((_) async => const Right(true));
        when(() => mockGetUseCase.call())
            .thenAnswer((_) async => const Right([]));
        when(() => mockHandleUseCase.call(any()))
            .thenAnswer((_) async => const Left(failure));

        final controller =
            container.read(siriShortcutsControllerProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 200));

        // act
        final route = await controller.handleShortcutInvocation(
          const SiriShortcutType.addLog(),
        );

        // assert
        expect(route, isNull);
        final state = container.read(siriShortcutsControllerProvider);
        expect(state.errorMessage, 'Network error');
      });

      test('should handle shortcut invocation exception', () async {
        // arrange
        when(() => mockRepository.isSiriShortcutsSupported())
            .thenAnswer((_) async => const Right(true));
        when(() => mockGetUseCase.call())
            .thenAnswer((_) async => const Right([]));
        when(() => mockHandleUseCase.call(any()))
            .thenThrow(Exception('Test exception'));

        final controller =
            container.read(siriShortcutsControllerProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 200));

        // act
        final route = await controller.handleShortcutInvocation(
          const SiriShortcutType.startTimedLog(),
        );

        // assert
        expect(route, isNull);
        final state = container.read(siriShortcutsControllerProvider);
        expect(state.errorMessage, contains('Failed to handle shortcut'));
      });

      test('should refresh shortcuts', () async {
        // arrange
        when(() => mockRepository.isSiriShortcutsSupported())
            .thenAnswer((_) async => const Right(true));
        when(() => mockGetUseCase.call())
            .thenAnswer((_) async => const Right([]));

        final controller =
            container.read(siriShortcutsControllerProvider.notifier);
        await Future.delayed(const Duration(milliseconds: 200));

        // act
        controller.refresh();
        await Future.delayed(const Duration(milliseconds: 200));

        // assert
        verify(() => mockRepository.isSiriShortcutsSupported())
            .called(greaterThan(1));
        verify(() => mockGetUseCase.call()).called(greaterThan(1));
      });
    });

    group('SiriShortcutsState', () {
      test('should create state with default values', () {
        // act
        const state = SiriShortcutsState();

        // assert
        expect(state.status, equals(SiriShortcutsStatus.initial));
        expect(state.shortcuts, isEmpty);
        expect(state.isSupported, isFalse);
        expect(state.errorMessage, isNull);
        expect(state.isDonating, isFalse);
      });

      test('should create state with custom values', () {
        // arrange
        final shortcuts = [
          SiriShortcutsEntity(
            id: '1',
            type: const SiriShortcutType.addLog(),
            createdAt: DateTime.now(),
          ),
        ];

        // act
        final state = SiriShortcutsState(
          status: SiriShortcutsStatus.loaded,
          shortcuts: shortcuts,
          isSupported: true,
          errorMessage: 'Error',
          isDonating: true,
        );

        // assert
        expect(state.status, equals(SiriShortcutsStatus.loaded));
        expect(state.shortcuts, equals(shortcuts));
        expect(state.isSupported, isTrue);
        expect(state.errorMessage, equals('Error'));
        expect(state.isDonating, isTrue);
      });

      test('should copy state with partial updates', () {
        // arrange
        final shortcuts = [
          SiriShortcutsEntity(
            id: '1',
            type: const SiriShortcutType.addLog(),
            createdAt: DateTime.now(),
          ),
        ];

        const originalState = SiriShortcutsState(
          status: SiriShortcutsStatus.initial,
          isSupported: false,
        );

        // act
        final newState = originalState.copyWith(
          status: SiriShortcutsStatus.loaded,
          shortcuts: shortcuts,
          isSupported: true,
        );

        // assert
        expect(newState.status, equals(SiriShortcutsStatus.loaded));
        expect(newState.shortcuts, equals(shortcuts));
        expect(newState.isSupported, isTrue);
        expect(newState.errorMessage, isNull); // unchanged
        expect(newState.isDonating, isFalse); // unchanged
      });
    });

    group('SiriShortcutsStatus', () {
      test('should have all expected enum values', () {
        // act & assert
        expect(SiriShortcutsStatus.values, hasLength(4));
        expect(
            SiriShortcutsStatus.values, contains(SiriShortcutsStatus.initial));
        expect(
            SiriShortcutsStatus.values, contains(SiriShortcutsStatus.loading));
        expect(
            SiriShortcutsStatus.values, contains(SiriShortcutsStatus.loaded));
        expect(SiriShortcutsStatus.values, contains(SiriShortcutsStatus.error));
      });
    });

    group('createSiriShortcutsRepositoryOverride', () {
      test('should create repository override with SharedPreferences',
          () async {
        // arrange
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();

        // act
        final override = createSiriShortcutsRepositoryOverride(prefs);

        // assert
        expect(override, isNotNull);

        // Test that the override actually provides a repository
        final testContainer = ProviderContainer(overrides: [override]);
        final repository = testContainer.read(siriShortcutsRepositoryProvider);
        expect(repository, isNotNull);
        testContainer.dispose();
      });
    });

    group('Provider creation without override', () {
      test(
          'should throw UnimplementedError for repository provider without override',
          () {
        // arrange
        final containerWithoutOverride = ProviderContainer();

        // act & assert
        expect(
          () => containerWithoutOverride.read(siriShortcutsRepositoryProvider),
          throwsA(isA<UnimplementedError>()),
        );

        containerWithoutOverride.dispose();
      });
    });
  });
}

// Unit tests for InitializeQuickActionsUseCase
// Tests business logic for initializing quick actions

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/quick_actions/domain/usecases/initialize_quick_actions_use_case.dart';
import 'package:ash_trail/features/quick_actions/domain/repositories/quick_actions_repository.dart';
import 'package:ash_trail/features/quick_actions/domain/entities/quick_action_entity.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

// Mock repository
class MockQuickActionsRepository extends Mock
    implements QuickActionsRepository {}

void main() {
  group('InitializeQuickActionsUseCase', () {
    late InitializeQuickActionsUseCase useCase;
    late MockQuickActionsRepository mockRepository;

    setUp(() {
      mockRepository = MockQuickActionsRepository();
      useCase = InitializeQuickActionsUseCase(mockRepository);
    });

    test('should initialize and setup quick actions successfully', () async {
      // arrange
      when(() => mockRepository.initialize())
          .thenAnswer((_) async => const Right(null));
      when(() => mockRepository.setupActions(any()))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await useCase.call();

      // assert
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (success) {
          // Success case - no specific assertion needed
        },
      );

      // verify interactions
      verify(() => mockRepository.initialize()).called(1);
      final setupVerify =
          verify(() => mockRepository.setupActions(captureAny()));
      setupVerify.called(1);

      // verify the correct actions were set up
      final actions = setupVerify.captured.first as List<QuickActionEntity>;

      expect(actions, hasLength(3));
      expect(actions.any((a) => a.type == QuickActionTypes.logHit), isTrue);
      expect(actions.any((a) => a.type == QuickActionTypes.viewLogs), isTrue);
      expect(
          actions.any((a) => a.type == QuickActionTypes.startTimedLog), isTrue);
    });

    test('should return failure when repository initialization fails',
        () async {
      // arrange
      const failure = AppFailure.network(message: 'Initialization failed');
      when(() => mockRepository.initialize())
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await useCase.call();

      // assert
      expect(result, isA<Left>());
      result.fold(
        (actualFailure) => expect(actualFailure, equals(failure)),
        (success) => fail('Expected failure but got success'),
      );

      // verify setup was not called
      verify(() => mockRepository.initialize()).called(1);
      verifyNever(() => mockRepository.setupActions(any()));
    });

    test('should return failure when setup actions fails', () async {
      // arrange
      const failure = AppFailure.unexpected(message: 'Setup failed');
      when(() => mockRepository.initialize())
          .thenAnswer((_) async => const Right(null));
      when(() => mockRepository.setupActions(any()))
          .thenAnswer((_) async => const Left(failure));

      // act
      final result = await useCase.call();

      // assert
      expect(result, isA<Left>());
      result.fold(
        (actualFailure) => expect(actualFailure, equals(failure)),
        (success) => fail('Expected failure but got success'),
      );

      // verify both methods were called
      verify(() => mockRepository.initialize()).called(1);
      verify(() => mockRepository.setupActions(any())).called(1);
    });

    group('predefined actions validation', () {
      test('should create correct log hit action', () async {
        // arrange
        when(() => mockRepository.initialize())
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.setupActions(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        await useCase.call();

        // assert
        final verifyCall =
            verify(() => mockRepository.setupActions(captureAny()));
        verifyCall.called(1);
        final actions = verifyCall.captured.first as List<QuickActionEntity>;
        final logHitAction =
            actions.firstWhere((a) => a.type == QuickActionTypes.logHit);

        expect(logHitAction.localizedTitle, equals('Log Hit'));
        expect(logHitAction.localizedSubtitle,
            equals('Quick record smoking session'));
        expect(logHitAction.icon, equals('add'));
      });

      test('should create correct view logs action', () async {
        // arrange
        when(() => mockRepository.initialize())
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.setupActions(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        await useCase.call();

        // assert
        final verifyCall =
            verify(() => mockRepository.setupActions(captureAny()));
        verifyCall.called(1);
        final actions = verifyCall.captured.first as List<QuickActionEntity>;
        final viewLogsAction =
            actions.firstWhere((a) => a.type == QuickActionTypes.viewLogs);

        expect(viewLogsAction.localizedTitle, equals('View Logs'));
        expect(viewLogsAction.localizedSubtitle,
            equals('See your smoking history'));
        expect(viewLogsAction.icon, equals('list'));
      });

      test('should create correct start timed log action', () async {
        // arrange
        when(() => mockRepository.initialize())
            .thenAnswer((_) async => const Right(null));
        when(() => mockRepository.setupActions(any()))
            .thenAnswer((_) async => const Right(null));

        // act
        await useCase.call();

        // assert
        final verifyCall =
            verify(() => mockRepository.setupActions(captureAny()));
        verifyCall.called(1);
        final actions = verifyCall.captured.first as List<QuickActionEntity>;
        final timedLogAction =
            actions.firstWhere((a) => a.type == QuickActionTypes.startTimedLog);

        expect(timedLogAction.localizedTitle, equals('Start Timed Log'));
        expect(
            timedLogAction.localizedSubtitle, equals('Begin timing session'));
        expect(timedLogAction.icon, equals('timer'));
      });
    });
  });
}

// Unit tests for ListenQuickActionsUseCase
// Tests business logic for listening to quick action invocations

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/quick_actions/domain/usecases/listen_quick_actions_use_case.dart';
import 'package:ash_trail/features/quick_actions/domain/repositories/quick_actions_repository.dart';
import 'package:ash_trail/features/quick_actions/domain/entities/quick_action_entity.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

// Mock repository
class MockQuickActionsRepository extends Mock
    implements QuickActionsRepository {}

void main() {
  group('ListenQuickActionsUseCase', () {
    late ListenQuickActionsUseCase useCase;
    late MockQuickActionsRepository mockRepository;

    setUp(() {
      mockRepository = MockQuickActionsRepository();
      useCase = ListenQuickActionsUseCase(mockRepository);
    });

    test('should return stream from repository', () {
      // arrange
      const testAction = QuickActionEntity(
        type: QuickActionTypes.logHit,
        localizedTitle: 'Log Hit',
        localizedSubtitle: 'Quick record smoking session',
      );

      final testStream = Stream<QuickActionEntity>.value(testAction);
      when(() => mockRepository.actionStream).thenAnswer((_) => testStream);

      // act
      final result = useCase.call();

      // assert
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (stream) {
          expect(stream, equals(testStream));
        },
      );

      verify(() => mockRepository.actionStream).called(1);
    });

    test('should return failure when accessing stream throws exception', () {
      // arrange
      when(() => mockRepository.actionStream)
          .thenThrow(Exception('Stream access failed'));

      // act
      final result = useCase.call();

      // assert
      expect(result, isA<Left>());
      result.fold(
        (failure) {
          expect(failure, isA<AppFailure>());
          expect(failure.displayMessage,
              contains('Failed to listen for quick actions'));
        },
        (stream) => fail('Expected failure but got success'),
      );
    });

    test('should handle stream errors gracefully', () async {
      // arrange
      final testStream =
          Stream<QuickActionEntity>.error(Exception('Stream error'));
      when(() => mockRepository.actionStream).thenAnswer((_) => testStream);

      // act
      final result = useCase.call();

      // assert - should still return the stream, error handling is downstream
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (stream) async {
          expect(stream, equals(testStream));

          // Verify the stream does contain an error
          expect(
            stream.first,
            throwsA(isA<Exception>()),
          );
        },
      );
    });
  });
}

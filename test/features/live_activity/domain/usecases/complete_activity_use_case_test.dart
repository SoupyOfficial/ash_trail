// Unit tests for CompleteActivityUseCase.

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/features/live_activity/domain/entities/live_activity_entity.dart';
import 'package:ash_trail/features/live_activity/domain/repositories/live_activity_repository.dart';
import 'package:ash_trail/features/live_activity/domain/usecases/complete_activity_use_case.dart';

class MockLiveActivityRepository extends Mock
    implements LiveActivityRepository {}

void main() {
  group('CompleteActivityUseCase', () {
    late MockLiveActivityRepository mockRepository;
    late CompleteActivityUseCase useCase;

    setUp(() {
      mockRepository = MockLiveActivityRepository();
      useCase = CompleteActivityUseCase(mockRepository);
    });

    group('call', () {
      test('successfully completes active activity', () async {
        // Arrange
        const activityId = 'test-activity-id';

        final activeActivity = LiveActivityEntity(
          id: activityId,
          startedAt: DateTime(2023, 9, 17, 12, 0, 0),
          status: LiveActivityStatus.active,
        );

        final completedActivity = activeActivity.copyWith(
          status: LiveActivityStatus.completed,
          endedAt: DateTime(2023, 9, 17, 12, 5, 0),
        );

        when(() => mockRepository.getActivityById(activityId))
            .thenAnswer((_) async => right(activeActivity));
        when(() => mockRepository.completeActivity(activityId))
            .thenAnswer((_) async => right(completedActivity));

        // Act
        final result = await useCase(activityId);

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (activity) {
            expect(activity.id, equals(activityId));
            expect(activity.status, equals(LiveActivityStatus.completed));
            expect(activity.endedAt, isNotNull);
          },
        );

        verify(() => mockRepository.getActivityById(activityId)).called(1);
        verify(() => mockRepository.completeActivity(activityId)).called(1);
      });

      test('fails when activity does not exist', () async {
        // Arrange
        const activityId = 'non-existent-id';
        const expectedFailure =
            AppFailure.notFound(message: 'Activity not found');

        when(() => mockRepository.getActivityById(activityId))
            .thenAnswer((_) async => left(expectedFailure));

        // Act
        final result = await useCase(activityId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, equals(expectedFailure)),
          (activity) => fail('Expected failure but got success: $activity'),
        );

        verify(() => mockRepository.getActivityById(activityId)).called(1);
        verifyNever(() => mockRepository.completeActivity(any()));
      });

      test('fails when activity is not active', () async {
        // Arrange
        const activityId = 'completed-activity-id';

        final completedActivity = LiveActivityEntity(
          id: activityId,
          startedAt: DateTime(2023, 9, 17, 12, 0, 0),
          endedAt: DateTime(2023, 9, 17, 12, 5, 0),
          status: LiveActivityStatus.completed,
        );

        when(() => mockRepository.getActivityById(activityId))
            .thenAnswer((_) async => right(completedActivity));

        // Act
        final result = await useCase(activityId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.displayMessage,
                contains('Cannot complete inactive recording session'));
          },
          (activity) => fail('Expected failure but got success: $activity'),
        );

        verify(() => mockRepository.getActivityById(activityId)).called(1);
        verifyNever(() => mockRepository.completeActivity(any()));
      });

      test('fails when activity is cancelled', () async {
        // Arrange
        const activityId = 'cancelled-activity-id';

        final cancelledActivity = LiveActivityEntity(
          id: activityId,
          startedAt: DateTime(2023, 9, 17, 12, 0, 0),
          endedAt: DateTime(2023, 9, 17, 12, 2, 0),
          status: LiveActivityStatus.cancelled,
        );

        when(() => mockRepository.getActivityById(activityId))
            .thenAnswer((_) async => right(cancelledActivity));

        // Act
        final result = await useCase(activityId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.displayMessage,
                contains('Cannot complete inactive recording session'));
          },
          (activity) => fail('Expected failure but got success: $activity'),
        );

        verify(() => mockRepository.getActivityById(activityId)).called(1);
        verifyNever(() => mockRepository.completeActivity(any()));
      });

      test('propagates repository failure from completeActivity', () async {
        // Arrange
        const activityId = 'test-activity-id';
        const expectedFailure = AppFailure.network(message: 'Network error');

        final activeActivity = LiveActivityEntity(
          id: activityId,
          startedAt: DateTime(2023, 9, 17, 12, 0, 0),
          status: LiveActivityStatus.active,
        );

        when(() => mockRepository.getActivityById(activityId))
            .thenAnswer((_) async => right(activeActivity));
        when(() => mockRepository.completeActivity(activityId))
            .thenAnswer((_) async => left(expectedFailure));

        // Act
        final result = await useCase(activityId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, equals(expectedFailure)),
          (activity) => fail('Expected failure but got success: $activity'),
        );

        verify(() => mockRepository.getActivityById(activityId)).called(1);
        verify(() => mockRepository.completeActivity(activityId)).called(1);
      });
    });
  });
}

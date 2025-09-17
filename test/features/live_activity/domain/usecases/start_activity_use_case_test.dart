// Unit tests for StartActivityUseCase.

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/features/live_activity/domain/entities/live_activity_entity.dart';
import 'package:ash_trail/features/live_activity/domain/repositories/live_activity_repository.dart';
import 'package:ash_trail/features/live_activity/domain/usecases/start_activity_use_case.dart';

class MockLiveActivityRepository extends Mock
    implements LiveActivityRepository {}

void main() {
  group('StartActivityUseCase', () {
    late MockLiveActivityRepository mockRepository;
    late StartActivityUseCase useCase;

    setUp(() {
      mockRepository = MockLiveActivityRepository();
      useCase = StartActivityUseCase(mockRepository);
    });

    group('call', () {
      test('successfully starts activity when no current activity exists',
          () async {
        // Arrange
        final expectedActivity = LiveActivityEntity(
          id: 'new-activity-id',
          startedAt: DateTime(2023, 9, 17, 12, 0, 0),
          status: LiveActivityStatus.active,
        );

        when(() => mockRepository.getCurrentActivity()).thenAnswer(
            (_) async => right<AppFailure, LiveActivityEntity?>(null));
        when(() => mockRepository.startActivity())
            .thenAnswer((_) async => right(expectedActivity));

        // Act
        final result = await useCase();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (activity) => expect(activity, equals(expectedActivity)),
        );

        verify(() => mockRepository.getCurrentActivity()).called(1);
        verify(() => mockRepository.startActivity()).called(1);
      });

      test('successfully starts activity when current activity is inactive',
          () async {
        // Arrange
        final inactiveActivity = LiveActivityEntity(
          id: 'inactive-id',
          startedAt: DateTime(2023, 9, 17, 11, 0, 0),
          endedAt: DateTime(2023, 9, 17, 11, 30, 0),
          status: LiveActivityStatus.completed,
        );

        final newActivity = LiveActivityEntity(
          id: 'new-activity-id',
          startedAt: DateTime(2023, 9, 17, 12, 0, 0),
          status: LiveActivityStatus.active,
        );

        when(() => mockRepository.getCurrentActivity()).thenAnswer((_) async =>
            right<AppFailure, LiveActivityEntity?>(inactiveActivity));
        when(() => mockRepository.startActivity())
            .thenAnswer((_) async => right(newActivity));

        // Act
        final result = await useCase();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (activity) => expect(activity, equals(newActivity)),
        );

        verify(() => mockRepository.getCurrentActivity()).called(1);
        verify(() => mockRepository.startActivity()).called(1);
      });

      test('fails when another active activity exists', () async {
        // Arrange
        final activeActivity = LiveActivityEntity(
          id: 'active-id',
          startedAt: DateTime(2023, 9, 17, 11, 30, 0),
          status: LiveActivityStatus.active,
        );

        when(() => mockRepository.getCurrentActivity()).thenAnswer((_) async =>
            right<AppFailure, LiveActivityEntity?>(activeActivity));

        // Act
        final result = await useCase();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<AppFailure>());
            expect(failure.displayMessage,
                contains('Another recording session is already active'));
          },
          (activity) => fail('Expected failure but got success: $activity'),
        );

        verify(() => mockRepository.getCurrentActivity()).called(1);
        verifyNever(() => mockRepository.startActivity());
      });

      test('propagates repository failure from getCurrentActivity', () async {
        // Arrange
        const expectedFailure = AppFailure.cache(message: 'Cache error');
        when(() => mockRepository.getCurrentActivity())
            .thenAnswer((_) async => left(expectedFailure));

        // Act
        final result = await useCase();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, equals(expectedFailure)),
          (activity) => fail('Expected failure but got success: $activity'),
        );

        verify(() => mockRepository.getCurrentActivity()).called(1);
        verifyNever(() => mockRepository.startActivity());
      });

      test('propagates repository failure from startActivity', () async {
        // Arrange
        const expectedFailure = AppFailure.network(message: 'Network error');

        when(() => mockRepository.getCurrentActivity()).thenAnswer(
            (_) async => right<AppFailure, LiveActivityEntity?>(null));
        when(() => mockRepository.startActivity())
            .thenAnswer((_) async => left(expectedFailure));

        // Act
        final result = await useCase();

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, equals(expectedFailure)),
          (activity) => fail('Expected failure but got success: $activity'),
        );

        verify(() => mockRepository.getCurrentActivity()).called(1);
        verify(() => mockRepository.startActivity()).called(1);
      });
    });
  });
}

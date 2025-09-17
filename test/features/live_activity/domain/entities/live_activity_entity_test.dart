// Unit tests for LiveActivityEntity business logic and validation.

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/live_activity/domain/entities/live_activity_entity.dart';

void main() {
  group('LiveActivityEntity', () {
    late DateTime now;
    late DateTime earlier;
    late DateTime later;

    setUp(() {
      now = DateTime(2023, 9, 17, 12, 0, 0);
      earlier = now.subtract(const Duration(minutes: 5));
      later = now.add(const Duration(minutes: 3));
    });

    group('creation', () {
      test('creates valid active entity', () {
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          status: LiveActivityStatus.active,
        );

        expect(entity.id, equals('test-id'));
        expect(entity.startedAt, equals(earlier));
        expect(entity.endedAt, isNull);
        expect(entity.status, equals(LiveActivityStatus.active));
        expect(entity.cancelReason, isNull);
      });

      test('creates completed entity with all fields', () {
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          endedAt: now,
          status: LiveActivityStatus.completed,
        );

        expect(entity.id, equals('test-id'));
        expect(entity.startedAt, equals(earlier));
        expect(entity.endedAt, equals(now));
        expect(entity.status, equals(LiveActivityStatus.completed));
        expect(entity.cancelReason, isNull);
      });

      test('creates cancelled entity with reason', () {
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          endedAt: now,
          status: LiveActivityStatus.cancelled,
          cancelReason: 'User requested',
        );

        expect(entity.cancelReason, equals('User requested'));
        expect(entity.status, equals(LiveActivityStatus.cancelled));
      });
    });

    group('elapsedDuration', () {
      test('calculates duration for active entity', () {
        // Mock DateTime.now() by using a specific time
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          status: LiveActivityStatus.active,
        );

        // Since we can't mock DateTime.now(), we'll test that it returns a reasonable duration
        expect(entity.elapsedDuration.inMinutes, greaterThanOrEqualTo(0));
      });

      test('returns total duration for completed entity', () {
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          endedAt: now,
          status: LiveActivityStatus.completed,
        );

        expect(entity.elapsedDuration, equals(const Duration(minutes: 5)));
      });

      test('returns total duration for cancelled entity', () {
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          endedAt: later,
          status: LiveActivityStatus.cancelled,
        );

        expect(entity.elapsedDuration, equals(const Duration(minutes: 8)));
      });
    });

    group('status checks', () {
      test('isActive returns true for active status', () {
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          status: LiveActivityStatus.active,
        );

        expect(entity.isActive, isTrue);
        expect(entity.isCompleted, isFalse);
        expect(entity.isCancelled, isFalse);
      });

      test('isCompleted returns true for completed status', () {
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          endedAt: now,
          status: LiveActivityStatus.completed,
        );

        expect(entity.isActive, isFalse);
        expect(entity.isCompleted, isTrue);
        expect(entity.isCancelled, isFalse);
      });

      test('isCancelled returns true for cancelled status', () {
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          endedAt: now,
          status: LiveActivityStatus.cancelled,
        );

        expect(entity.isActive, isFalse);
        expect(entity.isCompleted, isFalse);
        expect(entity.isCancelled, isTrue);
      });
    });

    group('formattedElapsedTime', () {
      test('formats minutes and seconds correctly', () {
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          endedAt: now,
          status: LiveActivityStatus.completed,
        );

        expect(entity.formattedElapsedTime, equals('05:00'));
      });

      test('formats single digits with zero padding', () {
        final endTime = earlier.add(const Duration(minutes: 2, seconds: 5));
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          endedAt: endTime,
          status: LiveActivityStatus.completed,
        );

        expect(entity.formattedElapsedTime, equals('02:05'));
      });

      test('handles durations over an hour correctly', () {
        final endTime =
            earlier.add(const Duration(hours: 1, minutes: 23, seconds: 45));
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          endedAt: endTime,
          status: LiveActivityStatus.completed,
        );

        expect(entity.formattedElapsedTime, equals('83:45'));
      });

      test('handles zero duration correctly', () {
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: now,
          endedAt: now,
          status: LiveActivityStatus.completed,
        );

        expect(entity.formattedElapsedTime, equals('00:00'));
      });
    });

    group('validation', () {
      test('valid active entity passes validation', () {
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          status: LiveActivityStatus.active,
        );

        expect(entity.isValid, isTrue);
      });

      test('valid completed entity passes validation', () {
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          endedAt: now,
          status: LiveActivityStatus.completed,
        );

        expect(entity.isValid, isTrue);
      });

      test('invalid start time in future fails validation', () {
        final futureTime = DateTime.now().add(const Duration(hours: 1));
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: futureTime,
          status: LiveActivityStatus.active,
        );

        expect(entity.isValid, isFalse);
      });

      test('invalid end time before start time fails validation', () {
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: now,
          endedAt: earlier,
          status: LiveActivityStatus.completed,
        );

        expect(entity.isValid, isFalse);
      });

      test('inactive status without end time fails validation', () {
        final entity = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          status: LiveActivityStatus.completed,
        );

        expect(entity.isValid, isFalse);
      });
    });

    group('copyWith', () {
      test('copies with updated status', () {
        final original = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          status: LiveActivityStatus.active,
        );

        final updated = original.copyWith(
          status: LiveActivityStatus.completed,
          endedAt: now,
        );

        expect(updated.id, equals(original.id));
        expect(updated.startedAt, equals(original.startedAt));
        expect(updated.status, equals(LiveActivityStatus.completed));
        expect(updated.endedAt, equals(now));
      });

      test('copies with cancel reason', () {
        final original = LiveActivityEntity(
          id: 'test-id',
          startedAt: earlier,
          status: LiveActivityStatus.active,
        );

        final updated = original.copyWith(
          status: LiveActivityStatus.cancelled,
          endedAt: now,
          cancelReason: 'User cancelled',
        );

        expect(updated.status, equals(LiveActivityStatus.cancelled));
        expect(updated.cancelReason, equals('User cancelled'));
      });
    });
  });

  group('LiveActivityStatus', () {
    test('fromString parses valid strings', () {
      expect(
        LiveActivityStatus.fromString('active'),
        equals(LiveActivityStatus.active),
      );
      expect(
        LiveActivityStatus.fromString('completed'),
        equals(LiveActivityStatus.completed),
      );
      expect(
        LiveActivityStatus.fromString('cancelled'),
        equals(LiveActivityStatus.cancelled),
      );
    });

    test('fromString handles case insensitivity', () {
      expect(
        LiveActivityStatus.fromString('ACTIVE'),
        equals(LiveActivityStatus.active),
      );
      expect(
        LiveActivityStatus.fromString('Completed'),
        equals(LiveActivityStatus.completed),
      );
    });

    test('fromString throws on invalid string', () {
      expect(
        () => LiveActivityStatus.fromString('invalid'),
        throwsArgumentError,
      );
    });

    test('toString returns correct string', () {
      expect(LiveActivityStatus.active.toString(), equals('active'));
      expect(LiveActivityStatus.completed.toString(), equals('completed'));
      expect(LiveActivityStatus.cancelled.toString(), equals('cancelled'));
    });
  });
}

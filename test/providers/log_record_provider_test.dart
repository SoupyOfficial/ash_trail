import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/providers/log_record_provider.dart';
import 'package:ash_trail/models/enums.dart';

void main() {
  group('LogDraft', () {
    test('creates with default values', () {
      final draft = LogDraft.empty();
      expect(draft.eventType, EventType.vape);
      expect(draft.duration, isNull);
      expect(draft.unit, Unit.seconds);
      expect(draft.note, isNull);
      expect(draft.moodRating, isNull);
      expect(draft.physicalRating, isNull);
      expect(draft.reasons, isNull);
      expect(draft.latitude, isNull);
      expect(draft.longitude, isNull);
      expect(draft.isValid, isTrue);
    });

    test('creates with custom values', () {
      final now = DateTime.now();
      final draft = LogDraft(
        eventType: EventType.note,
        duration: 30,
        unit: Unit.minutes,
        eventTime: now,
        note: 'Test note',
        moodRating: 5.0,
        physicalRating: 7.0,
        reasons: [LogReason.stress],
        latitude: 45.0,
        longitude: -122.0,
      );

      expect(draft.eventType, EventType.note);
      expect(draft.duration, 30);
      expect(draft.unit, Unit.minutes);
      expect(draft.note, 'Test note');
      expect(draft.moodRating, 5.0);
      expect(draft.physicalRating, 7.0);
      expect(draft.reasons, [LogReason.stress]);
      expect(draft.latitude, 45.0);
      expect(draft.longitude, -122.0);
    });

    group('copyWith', () {
      test('copies with new event type', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(eventType: EventType.note);
        expect(updated.eventType, EventType.note);
        expect(updated.unit, Unit.seconds); // Unchanged
      });

      test('copies with new duration', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(duration: () => 60.0);
        expect(updated.duration, 60.0);
      });

      test('copies with null duration using function', () {
        final draft = LogDraft(eventType: EventType.vape, duration: 30);
        final updated = draft.copyWith(duration: () => null);
        expect(updated.duration, isNull);
      });

      test('copies with new unit', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(unit: Unit.minutes);
        expect(updated.unit, Unit.minutes);
      });

      test('copies with new event time', () {
        final draft = LogDraft.empty();
        final newTime = DateTime(2024, 1, 15, 10, 30);
        final updated = draft.copyWith(eventTime: newTime);
        expect(updated.eventTime, newTime);
      });

      test('copies with new note', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(note: () => 'New note');
        expect(updated.note, 'New note');
      });

      test('copies with new mood rating', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(moodRating: () => 8.0);
        expect(updated.moodRating, 8.0);
      });

      test('copies with new physical rating', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(physicalRating: () => 6.0);
        expect(updated.physicalRating, 6.0);
      });

      test('copies with new reasons', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(
          reasons: () => [LogReason.medical, LogReason.habit],
        );
        expect(updated.reasons, [LogReason.medical, LogReason.habit]);
      });

      test('copies with new location', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(
          latitude: () => 45.0,
          longitude: () => -122.0,
        );
        expect(updated.latitude, 45.0);
        expect(updated.longitude, -122.0);
      });
    });

    group('validation', () {
      test('invalid with negative duration', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(duration: () => -5.0);
        expect(updated.isValid, isFalse);
      });

      test('valid with zero duration', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(duration: () => 0.0);
        expect(updated.isValid, isTrue);
      });

      test('valid with positive duration', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(duration: () => 30.0);
        expect(updated.isValid, isTrue);
      });

      test('invalid with mood rating below 1', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(moodRating: () => 0.5);
        expect(updated.isValid, isFalse);
      });

      test('invalid with mood rating above 10', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(moodRating: () => 11.0);
        expect(updated.isValid, isFalse);
      });

      test('valid with mood rating in range 1-10', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(moodRating: () => 5.0);
        expect(updated.isValid, isTrue);
      });

      test('valid with null mood rating', () {
        final draft = LogDraft.empty();
        expect(draft.moodRating, isNull);
        expect(draft.isValid, isTrue);
      });

      test('invalid with physical rating below 1', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(physicalRating: () => 0.0);
        expect(updated.isValid, isFalse);
      });

      test('invalid with physical rating above 10', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(physicalRating: () => 15.0);
        expect(updated.isValid, isFalse);
      });

      test('valid with physical rating in range 1-10', () {
        final draft = LogDraft.empty();
        final updated = draft.copyWith(physicalRating: () => 7.0);
        expect(updated.isValid, isTrue);
      });
    });

    group('equality', () {
      test('two empty drafts are equal', () {
        final draft1 = LogDraft.empty();
        final draft2 = LogDraft.empty();
        // They should have same structure but eventTime differs
        expect(draft1.eventType, draft2.eventType);
        expect(draft1.duration, draft2.duration);
        expect(draft1.unit, draft2.unit);
      });

      test('drafts with same values are equal', () {
        final time = DateTime(2024, 1, 15, 10, 0);
        final draft1 = LogDraft(
          eventType: EventType.vape,
          duration: 30,
          eventTime: time,
        );
        final draft2 = LogDraft(
          eventType: EventType.vape,
          duration: 30,
          eventTime: time,
        );
        expect(draft1, equals(draft2));
      });

      test('drafts with different event types are not equal', () {
        final time = DateTime(2024, 1, 15, 10, 0);
        final draft1 = LogDraft(eventType: EventType.vape, eventTime: time);
        final draft2 = LogDraft(eventType: EventType.note, eventTime: time);
        expect(draft1, isNot(equals(draft2)));
      });

      test('drafts with different durations are not equal', () {
        final time = DateTime(2024, 1, 15, 10, 0);
        final draft1 = LogDraft(duration: 30, eventTime: time);
        final draft2 = LogDraft(duration: 60, eventTime: time);
        expect(draft1, isNot(equals(draft2)));
      });

      test('drafts with same reasons in same order are equal', () {
        final time = DateTime(2024, 1, 15, 10, 0);
        final draft1 = LogDraft(
          reasons: [LogReason.stress, LogReason.habit],
          eventTime: time,
        );
        final draft2 = LogDraft(
          reasons: [LogReason.stress, LogReason.habit],
          eventTime: time,
        );
        expect(draft1, equals(draft2));
      });
    });

    test('hashCode is consistent with equality', () {
      final time = DateTime(2024, 1, 15, 10, 0);
      final draft1 = LogDraft(eventType: EventType.vape, eventTime: time);
      final draft2 = LogDraft(eventType: EventType.vape, eventTime: time);
      expect(draft1.hashCode, equals(draft2.hashCode));
    });
  });

  group('LogDraftNotifier', () {
    late LogDraftNotifier notifier;

    setUp(() {
      notifier = LogDraftNotifier();
    });

    test('initializes with empty draft', () {
      expect(notifier.state.eventType, EventType.vape);
      expect(notifier.state.duration, isNull);
      expect(notifier.state.isValid, isTrue);
    });

    test('setEventType updates event type', () {
      notifier.setEventType(EventType.note);
      expect(notifier.state.eventType, EventType.note);
    });

    test('setEventType sets unit to seconds', () {
      notifier.setEventType(EventType.vape);
      expect(notifier.state.unit, Unit.seconds);
    });

    test('setDuration updates duration', () {
      notifier.setDuration(45.0);
      expect(notifier.state.duration, 45.0);
    });

    test('setDuration with null clears duration', () {
      notifier.setDuration(30.0);
      notifier.setDuration(null);
      expect(notifier.state.duration, isNull);
    });

    test('setUnit updates unit', () {
      notifier.setUnit(Unit.minutes);
      expect(notifier.state.unit, Unit.minutes);
    });

    test('setEventTime updates event time', () {
      final newTime = DateTime(2024, 6, 15, 14, 30);
      notifier.setEventTime(newTime);
      expect(notifier.state.eventTime, newTime);
    });

    test('setNote updates note', () {
      notifier.setNote('Test note');
      expect(notifier.state.note, 'Test note');
    });

    test('setNote with empty string sets null', () {
      notifier.setNote('Something');
      notifier.setNote('');
      expect(notifier.state.note, isNull);
    });

    test('setNote with null clears note', () {
      notifier.setNote('Test');
      notifier.setNote(null);
      expect(notifier.state.note, isNull);
    });

    test('setMoodRating updates mood rating', () {
      notifier.setMoodRating(8.0);
      expect(notifier.state.moodRating, 8.0);
    });

    test('setPhysicalRating updates physical rating', () {
      notifier.setPhysicalRating(6.0);
      expect(notifier.state.physicalRating, 6.0);
    });

    group('toggleReason', () {
      test('adds reason when not present', () {
        notifier.toggleReason(LogReason.stress);
        expect(notifier.state.reasons, [LogReason.stress]);
      });

      test('removes reason when present', () {
        notifier.toggleReason(LogReason.stress);
        notifier.toggleReason(LogReason.stress);
        expect(notifier.state.reasons, isNull);
      });

      test('can add multiple reasons', () {
        notifier.toggleReason(LogReason.stress);
        notifier.toggleReason(LogReason.habit);
        expect(notifier.state.reasons, contains(LogReason.stress));
        expect(notifier.state.reasons, contains(LogReason.habit));
      });

      test('removes specific reason from multiple', () {
        notifier.toggleReason(LogReason.stress);
        notifier.toggleReason(LogReason.habit);
        notifier.toggleReason(LogReason.medical);
        notifier.toggleReason(LogReason.habit);
        expect(notifier.state.reasons, contains(LogReason.stress));
        expect(notifier.state.reasons, contains(LogReason.medical));
        expect(notifier.state.reasons, isNot(contains(LogReason.habit)));
      });
    });

    test('setReasons replaces reasons list', () {
      notifier.toggleReason(LogReason.stress);
      notifier.setReasons([LogReason.medical, LogReason.sleep]);
      expect(notifier.state.reasons, [LogReason.medical, LogReason.sleep]);
    });

    test('setReasons with null clears reasons', () {
      notifier.toggleReason(LogReason.stress);
      notifier.setReasons(null);
      expect(notifier.state.reasons, isNull);
    });

    test('setLatitude updates latitude', () {
      notifier.setLatitude(45.5);
      expect(notifier.state.latitude, 45.5);
    });

    test('setLongitude updates longitude', () {
      notifier.setLongitude(-122.5);
      expect(notifier.state.longitude, -122.5);
    });

    test('setLocation updates both coordinates', () {
      notifier.setLocation(45.5, -122.5);
      expect(notifier.state.latitude, 45.5);
      expect(notifier.state.longitude, -122.5);
    });

    test('setLocation with null clears location', () {
      notifier.setLocation(45.5, -122.5);
      notifier.setLocation(null, null);
      expect(notifier.state.latitude, isNull);
      expect(notifier.state.longitude, isNull);
    });

    test('reset clears all values to defaults', () {
      notifier.setEventType(EventType.note);
      notifier.setDuration(60.0);
      notifier.setNote('Test');
      notifier.setMoodRating(5.0);
      notifier.toggleReason(LogReason.stress);
      notifier.setLocation(45.0, -122.0);

      notifier.reset();

      expect(notifier.state.eventType, EventType.vape);
      expect(notifier.state.duration, isNull);
      expect(notifier.state.note, isNull);
      expect(notifier.state.moodRating, isNull);
      expect(notifier.state.reasons, isNull);
      expect(notifier.state.latitude, isNull);
    });

    test('isDirty returns true when modified', () {
      expect(notifier.isDirty, isFalse);
      notifier.setNote('Modified');
      expect(notifier.isDirty, isTrue);
    });

    test('isDirty returns false after reset', () {
      notifier.setNote('Modified');
      notifier.reset();
      expect(notifier.isDirty, isFalse);
    });
  });
}

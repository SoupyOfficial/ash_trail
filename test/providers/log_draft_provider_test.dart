import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/providers/log_record_provider.dart';

void main() {
  group('LogDraft', () {
    test('creates with default values', () {
      final draft = LogDraft.empty();

      expect(draft.eventType, EventType.inhale);
      expect(draft.duration, isNull);
      expect(draft.unit, Unit.hits);
      expect(draft.note, isNull);
      expect(draft.moodRating, isNull);
      expect(draft.physicalRating, isNull);
      expect(draft.reason, isNull);
      expect(draft.latitude, isNull);
      expect(draft.longitude, isNull);
      expect(draft.isValid, true);
    });

    test('copyWith preserves unchanged values', () {
      final draft = LogDraft.empty();
      final updated = draft.copyWith(eventType: EventType.note);

      expect(updated.eventType, EventType.note);
      expect(updated.unit, draft.unit);
    });

    test('copyWith with nullable duration using function syntax', () {
      final draft = LogDraft.empty().copyWith(duration: () => 5.0);
      expect(draft.duration, 5.0);

      final cleared = draft.copyWith(duration: () => null);
      expect(cleared.duration, isNull);
    });

    test('copyWith with nullable note using function syntax', () {
      final draft = LogDraft.empty().copyWith(note: () => 'Test note');
      expect(draft.note, 'Test note');

      final cleared = draft.copyWith(note: () => null);
      expect(cleared.note, isNull);
    });

    test('copyWith with nullable moodRating using function syntax', () {
      final draft = LogDraft.empty().copyWith(moodRating: () => 7.5);
      expect(draft.moodRating, 7.5);

      final cleared = draft.copyWith(moodRating: () => null);
      expect(cleared.moodRating, isNull);
    });

    test('copyWith with nullable physicalRating using function syntax', () {
      final draft = LogDraft.empty().copyWith(physicalRating: () => 8.0);
      expect(draft.physicalRating, 8.0);

      final cleared = draft.copyWith(physicalRating: () => null);
      expect(cleared.physicalRating, isNull);
    });

    test('copyWith with nullable reason using function syntax', () {
      final draft = LogDraft.empty().copyWith(reason: () => LogReason.medical);
      expect(draft.reason, LogReason.medical);

      final cleared = draft.copyWith(reason: () => null);
      expect(cleared.reason, isNull);
    });

    test('copyWith with location coordinates', () {
      final draft = LogDraft.empty().copyWith(
        latitude: () => 37.7749,
        longitude: () => -122.4194,
      );

      expect(draft.latitude, 37.7749);
      expect(draft.longitude, -122.4194);
    });

    group('validation', () {
      test('negative duration is invalid', () {
        final draft = LogDraft.empty().copyWith(duration: () => -5.0);
        expect(draft.isValid, false);
      });

      test('zero duration is valid', () {
        final draft = LogDraft.empty().copyWith(duration: () => 0.0);
        expect(draft.isValid, true);
      });

      test('positive duration is valid', () {
        final draft = LogDraft.empty().copyWith(duration: () => 10.0);
        expect(draft.isValid, true);
      });

      test('moodRating below 0 is invalid', () {
        final draft = LogDraft.empty().copyWith(moodRating: () => -1.0);
        expect(draft.isValid, false);
      });

      test('moodRating above 10 is invalid', () {
        final draft = LogDraft.empty().copyWith(moodRating: () => 11.0);
        expect(draft.isValid, false);
      });

      test('moodRating at 0 is valid', () {
        final draft = LogDraft.empty().copyWith(moodRating: () => 0.0);
        expect(draft.isValid, true);
      });

      test('moodRating at 10 is valid', () {
        final draft = LogDraft.empty().copyWith(moodRating: () => 10.0);
        expect(draft.isValid, true);
      });

      test('moodRating within range is valid', () {
        final draft = LogDraft.empty().copyWith(moodRating: () => 5.5);
        expect(draft.isValid, true);
      });

      test('physicalRating below 0 is invalid', () {
        final draft = LogDraft.empty().copyWith(physicalRating: () => -1.0);
        expect(draft.isValid, false);
      });

      test('physicalRating above 10 is invalid', () {
        final draft = LogDraft.empty().copyWith(physicalRating: () => 11.0);
        expect(draft.isValid, false);
      });

      test('physicalRating within range is valid', () {
        final draft = LogDraft.empty().copyWith(physicalRating: () => 7.0);
        expect(draft.isValid, true);
      });
    });

    group('equality', () {
      test('two empty drafts have same base values', () {
        final draft1 = LogDraft.empty();
        final draft2 = LogDraft.empty();

        // Note: eventTime will differ, so they won't be exactly equal
        // But the other fields should be comparable
        expect(draft1.eventType, draft2.eventType);
        expect(draft1.duration, draft2.duration);
        expect(draft1.unit, draft2.unit);
      });

      test('drafts with same values have equal fields', () {
        final time = DateTime(2025, 1, 1, 12, 0);
        final draft1 = const LogDraft(
          eventType: EventType.inhale,
          unit: Unit.hits,
        ).copyWith(eventTime: time);
        final draft2 = const LogDraft(
          eventType: EventType.inhale,
          unit: Unit.hits,
        ).copyWith(eventTime: time);

        expect(draft1.eventType, draft2.eventType);
        expect(draft1.unit, draft2.unit);
      });
    });
  });

  group('LogDraftNotifier', () {
    late ProviderContainer container;
    late LogDraftNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(logDraftProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty draft', () {
      final draft = container.read(logDraftProvider);

      expect(draft.eventType, EventType.inhale);
      expect(draft.duration, isNull);
      expect(draft.unit, Unit.hits);
    });

    group('setEventType', () {
      test('updates event type', () {
        notifier.setEventType(EventType.note);

        final draft = container.read(logDraftProvider);
        expect(draft.eventType, EventType.note);
      });

      test('auto-selects hits unit for inhale', () {
        notifier.setEventType(EventType.note);
        notifier.setEventType(EventType.inhale);

        final draft = container.read(logDraftProvider);
        expect(draft.unit, Unit.hits);
      });

      test('auto-selects seconds unit for sessionStart', () {
        notifier.setEventType(EventType.sessionStart);

        final draft = container.read(logDraftProvider);
        expect(draft.unit, Unit.seconds);
      });

      test('auto-selects seconds unit for sessionEnd', () {
        notifier.setEventType(EventType.sessionEnd);

        final draft = container.read(logDraftProvider);
        expect(draft.unit, Unit.seconds);
      });
    });

    group('setDuration', () {
      test('sets numeric duration', () {
        notifier.setDuration(5.0);

        final draft = container.read(logDraftProvider);
        expect(draft.duration, 5.0);
      });

      test('can set null duration', () {
        notifier.setDuration(5.0);
        notifier.setDuration(null);

        final draft = container.read(logDraftProvider);
        expect(draft.duration, isNull);
      });
    });

    group('setUnit', () {
      test('updates unit', () {
        notifier.setUnit(Unit.grams);

        final draft = container.read(logDraftProvider);
        expect(draft.unit, Unit.grams);
      });
    });

    group('setEventTime', () {
      test('updates event time', () {
        final time = DateTime(2025, 6, 15, 14, 30);
        notifier.setEventTime(time);

        final draft = container.read(logDraftProvider);
        expect(draft.eventTime, time);
      });
    });

    group('setNote', () {
      test('sets note text', () {
        notifier.setNote('Test note content');

        final draft = container.read(logDraftProvider);
        expect(draft.note, 'Test note content');
      });

      test('empty string sets null', () {
        notifier.setNote('Test');
        notifier.setNote('');

        final draft = container.read(logDraftProvider);
        expect(draft.note, isNull);
      });

      test('can set null', () {
        notifier.setNote('Test');
        notifier.setNote(null);

        final draft = container.read(logDraftProvider);
        expect(draft.note, isNull);
      });
    });

    group('setMoodRating', () {
      test('sets mood rating value', () {
        notifier.setMoodRating(7.5);

        final draft = container.read(logDraftProvider);
        expect(draft.moodRating, 7.5);
      });

      test('can set null', () {
        notifier.setMoodRating(5.0);
        notifier.setMoodRating(null);

        final draft = container.read(logDraftProvider);
        expect(draft.moodRating, isNull);
      });
    });

    group('setPhysicalRating', () {
      test('sets physical rating value', () {
        notifier.setPhysicalRating(8.0);

        final draft = container.read(logDraftProvider);
        expect(draft.physicalRating, 8.0);
      });

      test('can set null', () {
        notifier.setPhysicalRating(5.0);
        notifier.setPhysicalRating(null);

        final draft = container.read(logDraftProvider);
        expect(draft.physicalRating, isNull);
      });
    });

    group('setReason', () {
      test('sets reason', () {
        notifier.setReason(LogReason.medical);

        final draft = container.read(logDraftProvider);
        expect(draft.reason, LogReason.medical);
      });

      test('can set null', () {
        notifier.setReason(LogReason.stress);
        notifier.setReason(null);

        final draft = container.read(logDraftProvider);
        expect(draft.reason, isNull);
      });
    });

    group('setLocation', () {
      test('sets latitude and longitude', () {
        notifier.setLocation(37.7749, -122.4194);

        final draft = container.read(logDraftProvider);
        expect(draft.latitude, 37.7749);
        expect(draft.longitude, -122.4194);
      });

      test('can set null coordinates', () {
        notifier.setLocation(37.7749, -122.4194);
        notifier.setLocation(null, null);

        final draft = container.read(logDraftProvider);
        expect(draft.latitude, isNull);
        expect(draft.longitude, isNull);
      });
    });

    group('setLatitude', () {
      test('sets latitude only', () {
        notifier.setLatitude(37.7749);

        final draft = container.read(logDraftProvider);
        expect(draft.latitude, 37.7749);
        expect(draft.longitude, isNull);
      });
    });

    group('setLongitude', () {
      test('sets longitude only', () {
        notifier.setLongitude(-122.4194);

        final draft = container.read(logDraftProvider);
        expect(draft.longitude, -122.4194);
        expect(draft.latitude, isNull);
      });
    });

    group('reset', () {
      test('resets all values to defaults', () {
        // Set various values
        notifier.setEventType(EventType.note);
        notifier.setDuration(10.0);
        notifier.setUnit(Unit.grams);
        notifier.setNote('Test note');
        notifier.setMoodRating(8.0);
        notifier.setPhysicalRating(6.0);
        notifier.setReason(LogReason.recreational);
        notifier.setLocation(37.7749, -122.4194);

        // Reset
        notifier.reset();

        final draft = container.read(logDraftProvider);
        expect(draft.eventType, EventType.inhale);
        expect(draft.duration, isNull);
        expect(draft.unit, Unit.hits);
        expect(draft.note, isNull);
        expect(draft.moodRating, isNull);
        expect(draft.physicalRating, isNull);
        expect(draft.reason, isNull);
        expect(draft.latitude, isNull);
        expect(draft.longitude, isNull);
      });
    });

    group('isDirty', () {
      test('returns false for empty draft', () {
        expect(notifier.isDirty, false);
      });

      test('returns true when eventType changed', () {
        notifier.setEventType(EventType.note);
        expect(notifier.isDirty, true);
      });

      test('returns true when duration set', () {
        notifier.setDuration(5.0);
        expect(notifier.isDirty, true);
      });

      test('returns true when note set', () {
        notifier.setNote('Test');
        expect(notifier.isDirty, true);
      });

      test('returns true when moodRating set', () {
        notifier.setMoodRating(5.0);
        expect(notifier.isDirty, true);
      });

      test('returns true when physicalRating set', () {
        notifier.setPhysicalRating(5.0);
        expect(notifier.isDirty, true);
      });

      test('returns true when reason set', () {
        notifier.setReason(LogReason.stress);
        expect(notifier.isDirty, true);
      });

      test('returns true when location set', () {
        notifier.setLocation(37.7749, -122.4194);
        expect(notifier.isDirty, true);
      });

      test('returns false after reset', () {
        notifier.setDuration(10.0);
        notifier.setNote('Test');
        expect(notifier.isDirty, true);

        notifier.reset();
        expect(notifier.isDirty, false);
      });
    });
  });
}

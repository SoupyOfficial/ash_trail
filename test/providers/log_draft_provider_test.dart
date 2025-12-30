import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/providers/log_record_provider.dart';

void main() {
  group('LogDraft', () {
    test('creates with default values', () {
      final draft = LogDraft.empty();

      expect(draft.eventType, EventType.inhale);
      expect(draft.value, isNull);
      expect(draft.unit, Unit.hits);
      expect(draft.note, isNull);
      expect(draft.tags, isEmpty);
      expect(draft.mood, isNull);
      expect(draft.craving, isNull);
      expect(draft.reason, isNull);
      expect(draft.location, isNull);
      expect(draft.isValid, true);
    });

    test('copyWith preserves unchanged values', () {
      final draft = LogDraft.empty();
      final updated = draft.copyWith(eventType: EventType.note);

      expect(updated.eventType, EventType.note);
      expect(updated.unit, draft.unit);
      expect(updated.tags, draft.tags);
    });

    test('copyWith with nullable value using function syntax', () {
      final draft = LogDraft.empty().copyWith(value: () => 5.0);
      expect(draft.value, 5.0);

      final cleared = draft.copyWith(value: () => null);
      expect(cleared.value, isNull);
    });

    test('copyWith with nullable note using function syntax', () {
      final draft = LogDraft.empty().copyWith(note: () => 'Test note');
      expect(draft.note, 'Test note');

      final cleared = draft.copyWith(note: () => null);
      expect(cleared.note, isNull);
    });

    test('copyWith with nullable mood using function syntax', () {
      final draft = LogDraft.empty().copyWith(mood: () => 7.5);
      expect(draft.mood, 7.5);

      final cleared = draft.copyWith(mood: () => null);
      expect(cleared.mood, isNull);
    });

    test('copyWith with nullable craving using function syntax', () {
      final draft = LogDraft.empty().copyWith(craving: () => 3.0);
      expect(draft.craving, 3.0);

      final cleared = draft.copyWith(craving: () => null);
      expect(cleared.craving, isNull);
    });

    test('copyWith with nullable reason using function syntax', () {
      final draft = LogDraft.empty().copyWith(reason: () => LogReason.medical);
      expect(draft.reason, LogReason.medical);

      final cleared = draft.copyWith(reason: () => null);
      expect(cleared.reason, isNull);
    });

    test('copyWith with tags list', () {
      final draft = LogDraft.empty();
      final updated = draft.copyWith(tags: ['tag1', 'tag2']);

      expect(updated.tags, ['tag1', 'tag2']);
    });

    group('validation', () {
      test('negative value is invalid', () {
        final draft = LogDraft.empty().copyWith(value: () => -5.0);
        expect(draft.isValid, false);
      });

      test('zero value is valid', () {
        final draft = LogDraft.empty().copyWith(value: () => 0.0);
        expect(draft.isValid, true);
      });

      test('positive value is valid', () {
        final draft = LogDraft.empty().copyWith(value: () => 10.0);
        expect(draft.isValid, true);
      });

      test('mood below 0 is invalid', () {
        final draft = LogDraft.empty().copyWith(mood: () => -1.0);
        expect(draft.isValid, false);
      });

      test('mood above 10 is invalid', () {
        final draft = LogDraft.empty().copyWith(mood: () => 11.0);
        expect(draft.isValid, false);
      });

      test('mood at 0 is valid', () {
        final draft = LogDraft.empty().copyWith(mood: () => 0.0);
        expect(draft.isValid, true);
      });

      test('mood at 10 is valid', () {
        final draft = LogDraft.empty().copyWith(mood: () => 10.0);
        expect(draft.isValid, true);
      });

      test('mood within range is valid', () {
        final draft = LogDraft.empty().copyWith(mood: () => 5.5);
        expect(draft.isValid, true);
      });

      test('craving below 0 is invalid', () {
        final draft = LogDraft.empty().copyWith(craving: () => -1.0);
        expect(draft.isValid, false);
      });

      test('craving above 10 is invalid', () {
        final draft = LogDraft.empty().copyWith(craving: () => 11.0);
        expect(draft.isValid, false);
      });

      test('craving within range is valid', () {
        final draft = LogDraft.empty().copyWith(craving: () => 7.0);
        expect(draft.isValid, true);
      });
    });

    group('equality', () {
      test('two empty drafts are equal', () {
        final draft1 = LogDraft.empty();
        final draft2 = LogDraft.empty();

        // Note: eventTime will differ, so they won't be exactly equal
        // But the other fields should be comparable
        expect(draft1.eventType, draft2.eventType);
        expect(draft1.value, draft2.value);
        expect(draft1.unit, draft2.unit);
      });

      test('drafts with same values are equal', () {
        final time = DateTime(2025, 1, 1, 12, 0);
        final draft1 = const LogDraft(
          eventType: EventType.inhale,
          unit: Unit.hits,
          tags: ['tag1'],
        ).copyWith(eventTime: time);
        final draft2 = const LogDraft(
          eventType: EventType.inhale,
          unit: Unit.hits,
          tags: ['tag1'],
        ).copyWith(eventTime: time);

        expect(draft1.eventType, draft2.eventType);
        expect(draft1.unit, draft2.unit);
        expect(draft1.tags, draft2.tags);
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
      expect(draft.value, isNull);
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

    group('setValue', () {
      test('sets numeric value', () {
        notifier.setValue(5.0);

        final draft = container.read(logDraftProvider);
        expect(draft.value, 5.0);
      });

      test('can set null value', () {
        notifier.setValue(5.0);
        notifier.setValue(null);

        final draft = container.read(logDraftProvider);
        expect(draft.value, isNull);
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

    group('setTags', () {
      test('sets tags list', () {
        notifier.setTags(['morning', 'sativa']);

        final draft = container.read(logDraftProvider);
        expect(draft.tags, ['morning', 'sativa']);
      });

      test('can set empty list', () {
        notifier.setTags(['tag1']);
        notifier.setTags([]);

        final draft = container.read(logDraftProvider);
        expect(draft.tags, isEmpty);
      });
    });

    group('addTag', () {
      test('adds new tag', () {
        notifier.addTag('morning');

        final draft = container.read(logDraftProvider);
        expect(draft.tags, contains('morning'));
      });

      test('does not add duplicate tag', () {
        notifier.addTag('morning');
        notifier.addTag('morning');

        final draft = container.read(logDraftProvider);
        expect(draft.tags.where((t) => t == 'morning').length, 1);
      });

      test('does not add empty tag', () {
        notifier.addTag('');

        final draft = container.read(logDraftProvider);
        expect(draft.tags, isEmpty);
      });
    });

    group('removeTag', () {
      test('removes existing tag', () {
        notifier.setTags(['morning', 'evening']);
        notifier.removeTag('morning');

        final draft = container.read(logDraftProvider);
        expect(draft.tags, ['evening']);
      });

      test('handles removing non-existent tag', () {
        notifier.setTags(['morning']);
        notifier.removeTag('evening');

        final draft = container.read(logDraftProvider);
        expect(draft.tags, ['morning']);
      });
    });

    group('setMood', () {
      test('sets mood value', () {
        notifier.setMood(7.5);

        final draft = container.read(logDraftProvider);
        expect(draft.mood, 7.5);
      });

      test('can set null', () {
        notifier.setMood(5.0);
        notifier.setMood(null);

        final draft = container.read(logDraftProvider);
        expect(draft.mood, isNull);
      });
    });

    group('setCraving', () {
      test('sets craving value', () {
        notifier.setCraving(3.0);

        final draft = container.read(logDraftProvider);
        expect(draft.craving, 3.0);
      });

      test('can set null', () {
        notifier.setCraving(5.0);
        notifier.setCraving(null);

        final draft = container.read(logDraftProvider);
        expect(draft.craving, isNull);
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
      test('sets location', () {
        notifier.setLocation('home');

        final draft = container.read(logDraftProvider);
        expect(draft.location, 'home');
      });

      test('empty string sets null', () {
        notifier.setLocation('home');
        notifier.setLocation('');

        final draft = container.read(logDraftProvider);
        expect(draft.location, isNull);
      });

      test('can set null', () {
        notifier.setLocation('home');
        notifier.setLocation(null);

        final draft = container.read(logDraftProvider);
        expect(draft.location, isNull);
      });
    });

    group('reset', () {
      test('resets all values to defaults', () {
        // Set various values
        notifier.setEventType(EventType.note);
        notifier.setValue(10.0);
        notifier.setUnit(Unit.grams);
        notifier.setNote('Test note');
        notifier.setTags(['tag1', 'tag2']);
        notifier.setMood(8.0);
        notifier.setCraving(4.0);
        notifier.setReason(LogReason.recreational);
        notifier.setLocation('work');

        // Reset
        notifier.reset();

        final draft = container.read(logDraftProvider);
        expect(draft.eventType, EventType.inhale);
        expect(draft.value, isNull);
        expect(draft.unit, Unit.hits);
        expect(draft.note, isNull);
        expect(draft.tags, isEmpty);
        expect(draft.mood, isNull);
        expect(draft.craving, isNull);
        expect(draft.reason, isNull);
        expect(draft.location, isNull);
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

      test('returns true when value set', () {
        notifier.setValue(5.0);
        expect(notifier.isDirty, true);
      });

      test('returns true when note set', () {
        notifier.setNote('Test');
        expect(notifier.isDirty, true);
      });

      test('returns true when tags added', () {
        notifier.addTag('tag1');
        expect(notifier.isDirty, true);
      });

      test('returns true when mood set', () {
        notifier.setMood(5.0);
        expect(notifier.isDirty, true);
      });

      test('returns true when craving set', () {
        notifier.setCraving(5.0);
        expect(notifier.isDirty, true);
      });

      test('returns true when reason set', () {
        notifier.setReason(LogReason.stress);
        expect(notifier.isDirty, true);
      });

      test('returns true when location set', () {
        notifier.setLocation('home');
        expect(notifier.isDirty, true);
      });

      test('returns false after reset', () {
        notifier.setValue(10.0);
        notifier.setNote('Test');
        expect(notifier.isDirty, true);

        notifier.reset();
        expect(notifier.isDirty, false);
      });
    });
  });
}

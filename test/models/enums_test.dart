import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/enums.dart';

void main() {
  group('LogReason Enum', () {
    test('has all expected values', () {
      expect(LogReason.values.length, 8);
      expect(LogReason.values, contains(LogReason.medical));
      expect(LogReason.values, contains(LogReason.recreational));
      expect(LogReason.values, contains(LogReason.social));
      expect(LogReason.values, contains(LogReason.stress));
      expect(LogReason.values, contains(LogReason.habit));
      expect(LogReason.values, contains(LogReason.sleep));
      expect(LogReason.values, contains(LogReason.pain));
      expect(LogReason.values, contains(LogReason.other));
    });

    group('displayName extension', () {
      test('medical returns correct display name', () {
        expect(LogReason.medical.displayName, 'Medical');
      });

      test('recreational returns correct display name', () {
        expect(LogReason.recreational.displayName, 'Recreational');
      });

      test('social returns correct display name', () {
        expect(LogReason.social.displayName, 'Social');
      });

      test('stress returns correct display name', () {
        expect(LogReason.stress.displayName, 'Stress Relief');
      });

      test('habit returns correct display name', () {
        expect(LogReason.habit.displayName, 'Habit');
      });

      test('sleep returns correct display name', () {
        expect(LogReason.sleep.displayName, 'Sleep Aid');
      });

      test('pain returns correct display name', () {
        expect(LogReason.pain.displayName, 'Pain Management');
      });

      test('other returns correct display name', () {
        expect(LogReason.other.displayName, 'Other');
      });

      test('all values have non-empty display names', () {
        for (final reason in LogReason.values) {
          expect(reason.displayName, isNotEmpty);
          expect(reason.displayName.length, greaterThan(0));
        }
      });
    });

    group('icon extension', () {
      test('medical returns medical_services icon', () {
        expect(LogReason.medical.icon, Icons.medical_services);
      });

      test('recreational returns celebration icon', () {
        expect(LogReason.recreational.icon, Icons.celebration);
      });

      test('social returns people icon', () {
        expect(LogReason.social.icon, Icons.people);
      });

      test('stress returns spa icon', () {
        expect(LogReason.stress.icon, Icons.spa);
      });

      test('habit returns repeat icon', () {
        expect(LogReason.habit.icon, Icons.repeat);
      });

      test('sleep returns bedtime icon', () {
        expect(LogReason.sleep.icon, Icons.bedtime);
      });

      test('pain returns healing icon', () {
        expect(LogReason.pain.icon, Icons.healing);
      });

      test('other returns more_horiz icon', () {
        expect(LogReason.other.icon, Icons.more_horiz);
      });

      test('all values have icons', () {
        for (final reason in LogReason.values) {
          expect(reason.icon, isA<IconData>());
        }
      });
    });

    group('serialization', () {
      test('name property returns correct string', () {
        expect(LogReason.medical.name, 'medical');
        expect(LogReason.recreational.name, 'recreational');
        expect(LogReason.social.name, 'social');
        expect(LogReason.stress.name, 'stress');
        expect(LogReason.habit.name, 'habit');
        expect(LogReason.sleep.name, 'sleep');
        expect(LogReason.pain.name, 'pain');
        expect(LogReason.other.name, 'other');
      });

      test('can parse from string name', () {
        for (final reason in LogReason.values) {
          final parsed = LogReason.values.firstWhere(
            (r) => r.name == reason.name,
          );
          expect(parsed, reason);
        }
      });

      test('handles unknown value with orElse', () {
        final parsed = LogReason.values.firstWhere(
          (r) => r.name == 'unknown_value',
          orElse: () => LogReason.other,
        );
        expect(parsed, LogReason.other);
      });
    });
  });

  group('EventType Enum', () {
    test('has all expected values', () {
      expect(EventType.values, contains(EventType.inhale));
      expect(EventType.values, contains(EventType.sessionStart));
      expect(EventType.values, contains(EventType.sessionEnd));
      expect(EventType.values, contains(EventType.note));
      expect(EventType.values, contains(EventType.purchase));
      expect(EventType.values, contains(EventType.tolerance));
      expect(EventType.values, contains(EventType.symptomRelief));
      expect(EventType.values, contains(EventType.custom));
    });
  });

  group('Unit Enum', () {
    test('has all expected values', () {
      expect(Unit.values, contains(Unit.seconds));
      expect(Unit.values, contains(Unit.minutes));
      expect(Unit.values, contains(Unit.hits));
      expect(Unit.values, contains(Unit.mg));
      expect(Unit.values, contains(Unit.grams));
      expect(Unit.values, contains(Unit.ml));
      expect(Unit.values, contains(Unit.count));
      expect(Unit.values, contains(Unit.none));
    });
  });

  group('SyncState Enum', () {
    test('has all expected values', () {
      expect(SyncState.values, contains(SyncState.pending));
      expect(SyncState.values, contains(SyncState.syncing));
      expect(SyncState.values, contains(SyncState.synced));
      expect(SyncState.values, contains(SyncState.error));
      expect(SyncState.values, contains(SyncState.conflict));
    });
  });

  group('TimeConfidence Enum', () {
    test('has all expected values', () {
      expect(TimeConfidence.values, contains(TimeConfidence.high));
      expect(TimeConfidence.values, contains(TimeConfidence.medium));
      expect(TimeConfidence.values, contains(TimeConfidence.low));
    });
  });
}

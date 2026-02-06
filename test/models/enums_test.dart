import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/enums.dart';

void main() {
  group('LogReason Enum', () {
    test('all values have valid displayName and icon', () {
      final expectedDisplayNames = {
        LogReason.medical: 'Medical',
        LogReason.recreational: 'Recreational',
        LogReason.social: 'Social',
        LogReason.stress: 'Stress Relief',
        LogReason.habit: 'Habit',
        LogReason.sleep: 'Sleep Aid',
        LogReason.pain: 'Pain Management',
        LogReason.other: 'Other',
      };

      final expectedIcons = {
        LogReason.medical: Icons.medical_services,
        LogReason.recreational: Icons.celebration,
        LogReason.social: Icons.people,
        LogReason.stress: Icons.spa,
        LogReason.habit: Icons.repeat,
        LogReason.sleep: Icons.bedtime,
        LogReason.pain: Icons.healing,
        LogReason.other: Icons.more_horiz,
      };

      for (final reason in LogReason.values) {
        expect(
          reason.displayName,
          expectedDisplayNames[reason],
          reason: 'displayName mismatch for $reason',
        );
        expect(
          reason.icon,
          expectedIcons[reason],
          reason: 'icon mismatch for $reason',
        );
      }
    });

    group('serialization', () {
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

    test('has expected number of values', () {
      expect(LogReason.values.length, equals(8));
    });

    test('displayName is non-empty for all values', () {
      for (final reason in LogReason.values) {
        expect(reason.displayName.isNotEmpty, isTrue);
      }
    });
  });

  group('EventType Enum', () {
    test('has all expected values', () {
      expect(EventType.values.contains(EventType.vape), isTrue);
      expect(EventType.values.contains(EventType.inhale), isTrue);
      expect(EventType.values.contains(EventType.sessionStart), isTrue);
      expect(EventType.values.contains(EventType.sessionEnd), isTrue);
      expect(EventType.values.contains(EventType.note), isTrue);
      expect(EventType.values.contains(EventType.purchase), isTrue);
      expect(EventType.values.contains(EventType.tolerance), isTrue);
      expect(EventType.values.contains(EventType.symptomRelief), isTrue);
      expect(EventType.values.contains(EventType.custom), isTrue);
    });

    test('has expected count of 9 event types', () {
      expect(EventType.values.length, equals(9));
    });

    test('can be serialized to string name', () {
      expect(EventType.vape.name, equals('vape'));
      expect(EventType.inhale.name, equals('inhale'));
      expect(EventType.sessionStart.name, equals('sessionStart'));
    });

    test('can be parsed from string name', () {
      final parsed = EventType.values.firstWhere(
        (e) => e.name == 'vape',
        orElse: () => EventType.custom,
      );
      expect(parsed, EventType.vape);
    });
  });

  group('Unit Enum', () {
    test('has all expected values', () {
      expect(Unit.values.contains(Unit.seconds), isTrue);
      expect(Unit.values.contains(Unit.minutes), isTrue);
      expect(Unit.values.contains(Unit.hits), isTrue);
      expect(Unit.values.contains(Unit.mg), isTrue);
      expect(Unit.values.contains(Unit.grams), isTrue);
      expect(Unit.values.contains(Unit.ml), isTrue);
      expect(Unit.values.contains(Unit.count), isTrue);
      expect(Unit.values.contains(Unit.none), isTrue);
    });

    test('has expected count of 8 units', () {
      expect(Unit.values.length, equals(8));
    });

    test('can be serialized to string name', () {
      expect(Unit.seconds.name, equals('seconds'));
      expect(Unit.grams.name, equals('grams'));
    });
  });

  group('Source Enum', () {
    test('has all expected values', () {
      expect(Source.values.contains(Source.manual), isTrue);
      expect(Source.values.contains(Source.imported), isTrue);
      expect(Source.values.contains(Source.automation), isTrue);
      expect(Source.values.contains(Source.migration), isTrue);
    });

    test('has expected count of 4 sources', () {
      expect(Source.values.length, equals(4));
    });
  });

  group('SyncState Enum', () {
    test('has all expected values', () {
      expect(SyncState.values.contains(SyncState.pending), isTrue);
      expect(SyncState.values.contains(SyncState.syncing), isTrue);
      expect(SyncState.values.contains(SyncState.synced), isTrue);
      expect(SyncState.values.contains(SyncState.error), isTrue);
      expect(SyncState.values.contains(SyncState.conflict), isTrue);
    });

    test('has expected count of 5 sync states', () {
      expect(SyncState.values.length, equals(5));
    });
  });

  group('AuthProvider Enum', () {
    test('has all expected values', () {
      expect(AuthProvider.values.contains(AuthProvider.gmail), isTrue);
      expect(AuthProvider.values.contains(AuthProvider.apple), isTrue);
      expect(AuthProvider.values.contains(AuthProvider.email), isTrue);
      expect(AuthProvider.values.contains(AuthProvider.devStatic), isTrue);
    });

    test('has expected count of 4 providers', () {
      expect(AuthProvider.values.length, equals(4));
    });

    test('can be serialized to string name', () {
      expect(AuthProvider.gmail.name, equals('gmail'));
      expect(AuthProvider.apple.name, equals('apple'));
      expect(AuthProvider.email.name, equals('email'));
    });
  });

  group('TimeConfidence Enum', () {
    test('has all expected values', () {
      expect(TimeConfidence.values.contains(TimeConfidence.high), isTrue);
      expect(TimeConfidence.values.contains(TimeConfidence.medium), isTrue);
      expect(TimeConfidence.values.contains(TimeConfidence.low), isTrue);
    });

    test('has expected count of 3 confidence levels', () {
      expect(TimeConfidence.values.length, equals(3));
    });
  });

  group('RangeType Enum', () {
    test('has all expected values', () {
      expect(RangeType.values.contains(RangeType.today), isTrue);
      expect(RangeType.values.contains(RangeType.yesterday), isTrue);
      expect(RangeType.values.contains(RangeType.week), isTrue);
      expect(RangeType.values.contains(RangeType.month), isTrue);
      expect(RangeType.values.contains(RangeType.quarter), isTrue);
      expect(RangeType.values.contains(RangeType.year), isTrue);
      expect(RangeType.values.contains(RangeType.ytd), isTrue);
      expect(RangeType.values.contains(RangeType.custom), isTrue);
      expect(RangeType.values.contains(RangeType.all), isTrue);
    });

    test('has expected count of 9 range types', () {
      expect(RangeType.values.length, equals(9));
    });
  });

  group('GroupBy Enum', () {
    test('has all expected values', () {
      expect(GroupBy.values.contains(GroupBy.hour), isTrue);
      expect(GroupBy.values.contains(GroupBy.day), isTrue);
      expect(GroupBy.values.contains(GroupBy.week), isTrue);
      expect(GroupBy.values.contains(GroupBy.month), isTrue);
      expect(GroupBy.values.contains(GroupBy.quarter), isTrue);
      expect(GroupBy.values.contains(GroupBy.year), isTrue);
    });

    test('has expected count of 6 grouping options', () {
      expect(GroupBy.values.length, equals(6));
    });
  });
}

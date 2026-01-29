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
  });

  // Note: EventType, Unit, SyncState, TimeConfidence enum values are
  // compile-time checked. Testing that they exist is redundant.
}

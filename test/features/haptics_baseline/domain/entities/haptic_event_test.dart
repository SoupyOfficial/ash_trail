// Unit tests for haptics domain entities

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/haptics_baseline/domain/entities/haptic_event.dart';

void main() {
  group('HapticEvent', () {
    test('should provide all required haptic event types', () {
      const events = [
        HapticEvent.tap,
        HapticEvent.success,
        HapticEvent.warning,
        HapticEvent.error,
        HapticEvent.impactLight,
      ];

      expect(events.length, equals(5));
    });

    test('should provide correct descriptions for all event types', () {
      expect(HapticEvent.tap.description, equals('Light tap feedback'));
      expect(HapticEvent.success.description, equals('Success feedback'));
      expect(HapticEvent.warning.description, equals('Warning feedback'));
      expect(HapticEvent.error.description, equals('Error feedback'));
      expect(
          HapticEvent.impactLight.description, equals('Light impact feedback'));
    });

    test('should be comparable and usable in collections', () {
      const event1 = HapticEvent.tap;
      const event2 = HapticEvent.tap;
      const event3 = HapticEvent.success;

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));

      final eventSet = <HapticEvent>{event1, event3};
      eventSet.add(event2); // Adding duplicate won't increase size
      expect(eventSet.length, equals(2)); // tap appears only once
    });
  });
}

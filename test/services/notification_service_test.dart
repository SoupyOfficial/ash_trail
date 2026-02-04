import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/services/notification_service.dart';

void main() {
  group('NotificationService', () {
    late NotificationService service;

    setUp(() {
      // Get the singleton instance - it's stateful so we test behavior
      service = NotificationService();
    });

    group('singleton', () {
      test('returns same instance', () {
        final instance1 = NotificationService();
        final instance2 = NotificationService();
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('scheduleReminder', () {
      test('throws StateError when not initialized', () async {
        // Create a fresh test - the singleton may already be initialized
        // We test the error path behavior
        final newService = NotificationService();
        // If already initialized from previous tests, this will work
        // The test documents expected behavior when not initialized
        expect(
          () async => await newService.scheduleReminder(
            id: 1,
            title: 'Test',
            body: 'Test body',
            scheduledTime: DateTime.now().add(const Duration(hours: 1)),
            accountId: 'test-account',
          ),
          throwsStateError,
        );
      });
    });

    group('scheduleDailyReminder', () {
      test('throws StateError when not initialized', () async {
        final newService = NotificationService();
        expect(
          () async => await newService.scheduleDailyReminder(
            id: 1,
            title: 'Test',
            body: 'Test body',
            hour: 8,
            minute: 0,
            accountId: 'test-account',
          ),
          throwsStateError,
        );
      });
    });

    group('getPendingReminders', () {
      test('returns empty list when not initialized', () async {
        final result = await service.getPendingReminders();
        expect(result, isEmpty);
      });
    });

    group('areNotificationsEnabled', () {
      test('returns false by default', () async {
        final enabled = await service.areNotificationsEnabled();
        expect(enabled, isFalse);
      });
    });

    group('requestPermissions', () {
      test('returns false by default', () async {
        final granted = await service.requestPermissions();
        expect(granted, isFalse);
      });
    });
  });

  group('PendingReminder', () {
    test('creates with required parameters', () {
      final scheduledTime = DateTime.now().add(const Duration(hours: 1));
      final reminder = PendingReminder(
        id: 1,
        title: 'Test Reminder',
        body: 'Test body',
        scheduledTime: scheduledTime,
        accountId: 'account-123',
      );

      expect(reminder.id, 1);
      expect(reminder.title, 'Test Reminder');
      expect(reminder.body, 'Test body');
      expect(reminder.scheduledTime, scheduledTime);
      expect(reminder.accountId, 'account-123');
      expect(reminder.repeatInterval, isNull);
    });

    test('creates with optional repeatInterval', () {
      final scheduledTime = DateTime.now().add(const Duration(hours: 1));
      final reminder = PendingReminder(
        id: 2,
        title: 'Daily Reminder',
        body: 'Daily body',
        scheduledTime: scheduledTime,
        accountId: 'account-456',
        repeatInterval: RepeatInterval.daily,
      );

      expect(reminder.repeatInterval, RepeatInterval.daily);
    });
  });

  group('RepeatInterval', () {
    test('has all expected values', () {
      expect(RepeatInterval.values.length, 4);
      expect(RepeatInterval.values, contains(RepeatInterval.daily));
      expect(RepeatInterval.values, contains(RepeatInterval.weekly));
      expect(RepeatInterval.values, contains(RepeatInterval.monthly));
      expect(RepeatInterval.values, contains(RepeatInterval.custom));
    });
  });

  group('ReminderPresets', () {
    test('morningCheckIn has expected values', () {
      expect(ReminderPresets.morningCheckIn.title, 'Morning Check-in');
      expect(ReminderPresets.morningCheckIn.body, 'How are you feeling this morning?');
      expect(ReminderPresets.morningCheckIn.defaultHour, 8);
      expect(ReminderPresets.morningCheckIn.defaultMinute, 0);
    });

    test('eveningReflection has expected values', () {
      expect(ReminderPresets.eveningReflection.title, 'Evening Reflection');
      expect(ReminderPresets.eveningReflection.body, 'Time to log your day');
      expect(ReminderPresets.eveningReflection.defaultHour, 20);
      expect(ReminderPresets.eveningReflection.defaultMinute, 0);
    });

    test('medicationReminder has expected values', () {
      expect(ReminderPresets.medicationReminder.title, 'Medication Reminder');
      expect(ReminderPresets.medicationReminder.body, 'Time for your medication');
      expect(ReminderPresets.medicationReminder.defaultHour, 9);
      expect(ReminderPresets.medicationReminder.defaultMinute, 0);
    });
  });

  group('ReminderTemplate', () {
    test('creates with required parameters', () {
      const template = ReminderTemplate(
        title: 'Custom Reminder',
        body: 'Custom body',
        defaultHour: 14,
        defaultMinute: 30,
      );

      expect(template.title, 'Custom Reminder');
      expect(template.body, 'Custom body');
      expect(template.defaultHour, 14);
      expect(template.defaultMinute, 30);
    });

    test('is immutable (const constructor)', () {
      const template1 = ReminderTemplate(
        title: 'Test',
        body: 'Test',
        defaultHour: 10,
        defaultMinute: 0,
      );
      const template2 = ReminderTemplate(
        title: 'Test',
        body: 'Test',
        defaultHour: 10,
        defaultMinute: 0,
      );
      
      // Const objects with same values are identical
      expect(identical(template1, template2), isTrue);
    });
  });
}

# notification_service

> **Source:** `lib/services/notification_service.dart`

## Purpose

Singleton service stub for local notification scheduling — daily reminders, custom reminders, and cancellation. Currently contains TODO implementations; defines the data model (`PendingReminder`, `RepeatInterval`, `ReminderPresets`, `ReminderTemplate`) for the upcoming notification feature (Design Doc §22).

## Dependencies

- `../logging/app_logger.dart` — Structured logging via `AppLogger`

## Pseudo-Code

### Class: NotificationService (Singleton)

#### Fields
- `_log` — static logger tagged `'NotificationService'`
- `_instance` — static singleton instance (lazy)

#### Constructor / Factory
```
NotificationService._internal()            // private constructor
factory NotificationService():
  _instance ??= NotificationService._internal()
  RETURN _instance
```

---

#### `scheduleReminder({id, title, body, scheduledTime, repeatInterval?}) → Future<void>`

```
LOG [NOTIFICATION] Schedule reminder id, title, scheduledTime
// TODO: Implement via flutter_local_notifications
```

---

#### `scheduleDailyReminder({id, title, body, hour, minute, repeatInterval?}) → Future<void>`

```
LOG [NOTIFICATION] Schedule daily reminder id, hour:minute
// TODO: Implement via flutter_local_notifications
```

---

#### `cancelReminder(id) → Future<void>`

```
LOG [NOTIFICATION] Cancel reminder id
// TODO: Implement cancellation
```

---

#### `cancelAllReminders() → Future<void>`

```
LOG [NOTIFICATION] Cancel all reminders
// TODO: Implement cancel-all
```

---

#### `getPendingReminders() → Future<List<PendingReminder>>`

```
LOG [NOTIFICATION] Get pending reminders
// TODO: Implement retrieval
RETURN []
```

---

### Class: PendingReminder

```
PendingReminder {
  id: int,
  title: String,
  body: String?,
  scheduledTime: DateTime,
  repeatInterval: RepeatInterval?
}
```

---

### Enum: RepeatInterval

```
RepeatInterval { daily, weekly, custom }
```

---

### Class: ReminderPresets (static utility)

```
morningCheckIn:
  RETURN ReminderTemplate(
    title = 'Morning Check-in',
    body  = 'How are you feeling today?',
    hour  = 9, minute = 0,
    repeatInterval = daily
  )

eveningReflection:
  RETURN ReminderTemplate(
    title = 'Evening Reflection',
    body  = 'Take a moment to reflect on your day',
    hour  = 20, minute = 0,
    repeatInterval = daily
  )

medicationReminder:
  RETURN ReminderTemplate(
    title = 'Medication Reminder',
    body  = 'Time for your medication',
    hour  = 8, minute = 0,
    repeatInterval = daily
  )
```

---

### Class: ReminderTemplate

```
ReminderTemplate {
  title: String,
  body: String,
  hour: int,
  minute: int,
  repeatInterval: RepeatInterval
}
```

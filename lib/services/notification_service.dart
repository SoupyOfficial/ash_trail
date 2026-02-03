import '../logging/app_logger.dart';

/// Notification service per design doc 22. Notifications & Reminders
/// Provides local notification scheduling for reminders
/// Account-aware reminders per design doc 22.5.1
class NotificationService {
  static final _log = AppLogger.logger('NotificationService');
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;

  /// Initialize the notification service
  /// Must be called before scheduling any notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    // TODO: Initialize flutter_local_notifications plugin
    // Per design doc 22.3: Use local notifications
    // Setup notification channels for Android
    // Request permissions for iOS

    _isInitialized = true;
    _log.i('NotificationService initialized');
  }

  /// Schedule a reminder notification per design doc 22.4
  /// [id] Unique identifier for this reminder
  /// [title] Notification title
  /// [body] Notification body text
  /// [scheduledTime] When to show the notification
  /// [accountId] Account this reminder belongs to (per design doc 22.5.1)
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String accountId,
    RepeatInterval? repeatInterval,
  }) async {
    if (!_isInitialized) {
      throw StateError('NotificationService not initialized');
    }

    // TODO: Implement actual notification scheduling
    // Per design doc 22.4: Schedule reminders locally
    // Store accountId in notification payload for account-aware handling

    _log.i('Scheduled reminder: $title at $scheduledTime for account $accountId');
  }

  /// Schedule a daily reminder at a specific time
  /// Per design doc 22.4
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String accountId,
  }) async {
    if (!_isInitialized) {
      throw StateError('NotificationService not initialized');
    }

    // TODO: Implement daily reminder scheduling
    // Per design doc 22.4: Recurring reminders

    _log.i('Scheduled daily reminder: $title at $hour:$minute for account $accountId');
  }

  /// Cancel a specific reminder
  Future<void> cancelReminder(int id) async {
    if (!_isInitialized) return;

    // TODO: Implement notification cancellation

    _log.d('Cancelled reminder: $id');
  }

  /// Cancel all reminders for a specific account
  /// Per design doc 22.5.1: Account-aware reminders
  Future<void> cancelAllRemindersForAccount(String accountId) async {
    if (!_isInitialized) return;

    // TODO: Cancel all notifications with matching accountId in payload

    _log.d('Cancelled all reminders for account: $accountId');
  }

  /// Cancel all reminders
  Future<void> cancelAllReminders() async {
    if (!_isInitialized) return;

    // TODO: Cancel all scheduled notifications

    _log.d('Cancelled all reminders');
  }

  /// Get all pending reminders
  Future<List<PendingReminder>> getPendingReminders() async {
    if (!_isInitialized) return [];

    // TODO: Retrieve list of pending notifications

    return [];
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    // TODO: Check platform notification permissions

    return false;
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    // TODO: Request notification permissions from user
    // Per design doc 22.3: Handle permission requests gracefully

    return false;
  }

  /// Handle notification tap (when user taps on a notification)
  void onNotificationTapped(String? payload) {
    // TODO: Navigate to appropriate screen based on payload
    // Parse accountId from payload and switch to that account if needed

    _log.d('Notification tapped with payload: $payload');
  }
}

/// Represents a pending reminder notification
class PendingReminder {
  final int id;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final String accountId;
  final RepeatInterval? repeatInterval;

  PendingReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.accountId,
    this.repeatInterval,
  });
}

/// Repeat intervals for recurring reminders
/// Per design doc 22.4
enum RepeatInterval { daily, weekly, monthly, custom }

/// Reminder preset templates
/// Common reminder patterns for quick setup
class ReminderPresets {
  /// Morning check-in reminder
  static const morningCheckIn = ReminderTemplate(
    title: 'Morning Check-in',
    body: 'How are you feeling this morning?',
    defaultHour: 8,
    defaultMinute: 0,
  );

  /// Evening reflection reminder
  static const eveningReflection = ReminderTemplate(
    title: 'Evening Reflection',
    body: 'Time to log your day',
    defaultHour: 20,
    defaultMinute: 0,
  );

  /// Medication reminder
  static const medicationReminder = ReminderTemplate(
    title: 'Medication Reminder',
    body: 'Time for your medication',
    defaultHour: 9,
    defaultMinute: 0,
  );
}

/// Template for creating reminders
class ReminderTemplate {
  final String title;
  final String body;
  final int defaultHour;
  final int defaultMinute;

  const ReminderTemplate({
    required this.title,
    required this.body,
    required this.defaultHour,
    required this.defaultMinute,
  });
}

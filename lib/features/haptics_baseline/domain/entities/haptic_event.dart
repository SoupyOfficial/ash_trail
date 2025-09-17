// Core haptic event types for semantic feedback
// Provides type-safe haptic feedback options aligned with user experience patterns.

/// Represents different types of haptic feedback events
enum HapticEvent {
  /// Light tap feedback for general interactions
  tap,

  /// Success feedback for completed actions
  success,

  /// Warning feedback for cautionary states
  warning,

  /// Error feedback for failed actions
  error,

  /// Light impact feedback for press interactions
  impactLight;

  /// Returns a user-friendly description of the haptic event
  String get description => switch (this) {
        HapticEvent.tap => 'Light tap feedback',
        HapticEvent.success => 'Success feedback',
        HapticEvent.warning => 'Warning feedback',
        HapticEvent.error => 'Error feedback',
        HapticEvent.impactLight => 'Light impact feedback',
      };
}

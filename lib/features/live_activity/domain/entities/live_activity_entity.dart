// Live Activity entity for recording sessions.
// Represents an active recording session with timing and state management.

import 'package:freezed_annotation/freezed_annotation.dart';

part 'live_activity_entity.freezed.dart';

@freezed
class LiveActivityEntity with _$LiveActivityEntity {
  const factory LiveActivityEntity({
    required String id,
    required DateTime startedAt,
    DateTime? endedAt,
    required LiveActivityStatus status,
    String? cancelReason,
  }) = _LiveActivityEntity;

  const LiveActivityEntity._();

  /// Get the elapsed duration since the activity started.
  /// If ended, returns the total duration. If active, returns current elapsed.
  Duration get elapsedDuration {
    final endTime = endedAt ?? DateTime.now();
    return endTime.difference(startedAt);
  }

  /// Check if the activity is currently active (recording).
  bool get isActive => status == LiveActivityStatus.active;

  /// Check if the activity has been completed.
  bool get isCompleted => status == LiveActivityStatus.completed;

  /// Check if the activity was cancelled.
  bool get isCancelled => status == LiveActivityStatus.cancelled;

  /// Format elapsed duration for display (e.g., "00:15", "01:23").
  String get formattedElapsedTime {
    final duration = elapsedDuration;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Business logic: validate that the activity is in a consistent state
  bool get isValid {
    // Activity must have a valid start time
    if (startedAt.isAfter(DateTime.now())) return false;
    
    // If ended, end time must be after start time
    if (endedAt != null && endedAt!.isBefore(startedAt)) return false;
    
    // Status must be consistent with end state
    if (status != LiveActivityStatus.active && endedAt == null) return false;
    
    return true;
  }
}

/// Status of a live activity recording session.
enum LiveActivityStatus {
  /// Activity is currently recording
  active,

  /// Activity was completed successfully
  completed,

  /// Activity was cancelled by user
  cancelled;

  /// Convert from string for persistence
  static LiveActivityStatus fromString(String value) {
    return switch (value.toLowerCase()) {
      'active' => LiveActivityStatus.active,
      'completed' => LiveActivityStatus.completed,
      'cancelled' => LiveActivityStatus.cancelled,
      _ => throw ArgumentError('Unknown LiveActivityStatus: $value'),
    };
  }

  /// Convert to string for persistence
  @override
  String toString() => name;
}
import 'package:flutter/material.dart';

/// Event types for logging different actions
enum EventType {
  vape, // Vaping session
  inhale, // Single inhale/hit
  sessionStart, // Start of a session
  sessionEnd, // End of a session
  note, // General note/observation
  purchase, // Purchase tracking
  tolerance, // Tolerance note
  symptomRelief, // Medical symptom tracking
  custom, // Custom event type
}

/// Units of measurement
enum Unit {
  seconds, // Duration
  minutes, // Duration
  hits, // Number of hits/inhales
  mg, // Milligrams
  grams, // Grams
  ml, // Milliliters
  count, // Generic count
  none, // No unit
}

/// Source of the log entry
enum Source {
  manual, // Manually entered
  imported, // Imported from another source
  automation, // Auto-generated
  migration, // Migrated from old system
}

/// Sync state for cloud synchronization
enum SyncState {
  pending, // Waiting to sync
  syncing, // Currently syncing
  synced, // Successfully synced
  error, // Error occurred during sync
  conflict, // Conflict detected
}

/// Authentication provider types
enum AuthProvider {
  gmail, // Google Sign-In
  apple, // Apple Sign-In
  email, // Email/password
  devStatic, // Development static account
}

/// Time confidence levels for clock skew handling
enum TimeConfidence {
  high, // Device time is trusted
  medium, // Minor time discrepancy detected
  low, // Significant clock skew or manual backdate
}

/// Range types for analytics queries
enum RangeType {
  today,
  yesterday,
  week,
  month,
  quarter,
  year,
  ytd, // Year to date
  custom,
  all,
}

/// Grouping options for aggregation
enum GroupBy { hour, day, week, month, quarter, year }

/// Reasons for logging an event (optional context)
enum LogReason {
  medical, // Medical/therapeutic use
  recreational, // Recreational use
  social, // Social situation
  stress, // Stress relief
  habit, // Habitual/routine
  sleep, // Sleep aid
  pain, // Pain management
  other, // Other reason
}

/// Extension to provide display names for LogReason
extension LogReasonExtension on LogReason {
  String get displayName {
    switch (this) {
      case LogReason.medical:
        return 'Medical';
      case LogReason.recreational:
        return 'Recreational';
      case LogReason.social:
        return 'Social';
      case LogReason.stress:
        return 'Stress Relief';
      case LogReason.habit:
        return 'Habit';
      case LogReason.sleep:
        return 'Sleep Aid';
      case LogReason.pain:
        return 'Pain Management';
      case LogReason.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case LogReason.medical:
        return Icons.medical_services;
      case LogReason.recreational:
        return Icons.celebration;
      case LogReason.social:
        return Icons.people;
      case LogReason.stress:
        return Icons.spa;
      case LogReason.habit:
        return Icons.repeat;
      case LogReason.sleep:
        return Icons.bedtime;
      case LogReason.pain:
        return Icons.healing;
      case LogReason.other:
        return Icons.more_horiz;
    }
  }
}

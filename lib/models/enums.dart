/// Event types for logging different actions
enum EventType {
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
  anonymous, // Anonymous account
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

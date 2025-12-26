


/// @deprecated This model is deprecated. Use [LogRecord] from log_record.dart instead.
/// LogEntry is a legacy model that's being phased out in favor of the more
/// comprehensive LogRecord model which provides:
/// - EventType enum for better event categorization
/// - Unit enum for measurement standardization
/// - Tags for flexible categorization
/// - Source tracking for data provenance
/// - Platform-agnostic repository pattern
///
/// Migration path: Use LogRecordService instead of LoggingService
enum SyncState {
  pending, // Not yet synced to Firestore
  synced, // Successfully synced
  conflict, // Conflict detected during sync
  error, // Error occurred during sync
}

/// @deprecated Use [LogRecord] instead. This model will be removed in a future release.

class LogEntry {
  int id = 0;

  
  late String entryId; // UUID for cloud sync identity

  
  late String userId; // Links to Account.userId

  
  late DateTime timestamp;

  // Optional fields for enhanced logging
  String? notes;

  double? amount; // Could be used for quantity tracking

  String? sessionId; // Group related entries into sessions

  // Sync state tracking
  
  late SyncState syncState;

  DateTime? lastSyncAttempt;

  String? syncError;

  // Firestore document reference (if synced)
  String? firestoreDocId;

  late DateTime createdAt;

  DateTime? updatedAt;

  LogEntry();

  LogEntry.create({
    required this.entryId,
    required this.userId,
    DateTime? timestamp,
    this.notes,
    this.amount,
    this.sessionId,
    this.syncState = SyncState.pending,
    this.lastSyncAttempt,
    this.syncError,
    this.firestoreDocId,
    DateTime? createdAt,
    this.updatedAt,
  }) {
    this.timestamp = timestamp ?? DateTime.now();
    this.createdAt = createdAt ?? DateTime.now();
  }
}

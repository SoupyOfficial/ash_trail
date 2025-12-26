import 'package:isar/isar.dart';

part 'log_entry.g.dart';

enum SyncState {
  pending, // Not yet synced to Firestore
  synced, // Successfully synced
  conflict, // Conflict detected during sync
  error, // Error occurred during sync
}

@collection
class LogEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String entryId; // UUID for cloud sync identity

  @Index()
  late String userId; // Links to Account.userId

  @Index()
  late DateTime timestamp;

  // Optional fields for enhanced logging
  String? notes;

  double? amount; // Could be used for quantity tracking

  String? sessionId; // Group related entries into sessions

  // Sync state tracking
  @Enumerated(EnumType.name)
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

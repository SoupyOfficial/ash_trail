


/// Tracks sync state and metadata for accounts

class SyncMetadata {
  int id = 0;

  
  late String userId;

  DateTime? lastFullSync;

  DateTime? lastSuccessfulSync;

  int pendingCount = 0;

  int errorCount = 0;

  String? lastError;

  DateTime? lastErrorAt;

  bool isSyncing = false;
}

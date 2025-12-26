import 'package:isar/isar.dart';

part 'sync_metadata.g.dart';

/// Tracks sync state and metadata for accounts
@collection
class SyncMetadata {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String userId;

  DateTime? lastFullSync;

  DateTime? lastSuccessfulSync;

  int pendingCount = 0;

  int errorCount = 0;

  String? lastError;

  DateTime? lastErrorAt;

  bool isSyncing = false;
}

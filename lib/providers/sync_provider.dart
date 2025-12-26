import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';

/// Provider for SyncService
final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService();

  // Start auto-sync when service is created
  service.startAutoSync();

  // Clean up when provider is disposed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for sync status
final syncStatusProvider = StreamProvider.family<SyncStatus, String>((
  ref,
  accountId,
) async* {
  final service = ref.read(syncServiceProvider);

  // Emit initial status
  yield await service.getSyncStatus(accountId);

  // Poll for status updates every 5 seconds
  await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
    yield await service.getSyncStatus(accountId);
  }
});

/// Provider for triggering manual sync
final triggerSyncProvider = FutureProvider<SyncResult>((ref) async {
  final service = ref.read(syncServiceProvider);
  return await service.forceSyncNow();
});

/// Provider for checking online status
final isOnlineProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(syncServiceProvider);
  return await service.isOnline();
});

/// Provider for pulling records for an account
final pullRecordsProvider =
    FutureProvider.family<SyncResult, PullRecordsParams>((ref, params) async {
      final service = ref.read(syncServiceProvider);
      return await service.pullRecordsForAccount(
        accountId: params.accountId,
        since: params.since,
      );
    });

/// Provider for watching real-time updates from Firestore
final firestoreUpdatesProvider = StreamProvider.family<LogRecordUpdate, String>(
  (ref, accountId) {
    final service = ref.read(syncServiceProvider);
    return service
        .watchAccountLogs(accountId)
        .map((record) => LogRecordUpdate(record: record));
  },
);

/// Parameters for pulling records
class PullRecordsParams {
  final String accountId;
  final DateTime? since;

  const PullRecordsParams({required this.accountId, this.since});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PullRecordsParams &&
        other.accountId == accountId &&
        other.since == since;
  }

  @override
  int get hashCode => Object.hash(accountId, since);
}

/// Update event for log records
class LogRecordUpdate {
  final dynamic record;

  LogRecordUpdate({required this.record});
}

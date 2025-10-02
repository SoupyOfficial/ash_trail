# Phase 2: Data Persistence Enhancement Plan

## Overview
Enhance data persistence layer with robust offline-first capabilities, background sync, and comprehensive error handling.

## Goal
Ensure reliable data storage and sync with proper conflict resolution and offline queue management.

## Assumptions
- Phase 1 basic integration is complete and working
- Users can successfully save smoke logs locally
- Isar database is preferred for local storage over SharedPreferences
- Firebase Firestore will be the remote data source

## Acceptance Criteria
- [ ] Isar database implemented for local storage with proper indexing
- [ ] Background write queue with exponential backoff retry logic
- [ ] Offline-first pattern: write local immediately, sync remote when available
- [ ] Conflict resolution using last-write-wins per field strategy
- [ ] Data migration from SharedPreferences to Isar (if needed)
- [ ] Proper error handling with user-friendly messages
- [ ] Telemetry for data operations and sync status
- [ ] Data integrity validation and repair mechanisms

## Files to Create/Modify

### 1. Isar Database Setup
**File**: `lib/features/smoke_logs/data/datasources/smoke_logs_local_datasource_isar.dart`
- Implement Isar collections for SmokeLog and Account entities
- Add proper indexing for query performance
- Implement CRUD operations with error handling

### 2. Background Sync Service
**File**: `lib/core/data/sync/background_sync_service.dart`
- Implement write queue with job persistence
- Add exponential backoff for failed sync attempts
- Handle network connectivity changes
- Manage sync conflicts and resolution

### 3. Enhanced Repository Implementation
**File**: `lib/features/smoke_logs/data/repositories/smoke_log_repository_impl.dart`
- Replace SharedPreferences with Isar implementation
- Add offline queue management
- Implement proper error mapping and recovery
- Add data validation and sanitization

### 4. Remote Data Source
**File**: `lib/features/smoke_logs/data/datasources/smoke_logs_remote_datasource.dart`
- Implement Firestore integration with Dio HTTP client
- Add proper authentication and security rules
- Implement batch operations for sync efficiency
- Handle remote errors and rate limiting

### 5. Data Migration Service
**File**: `lib/core/data/migration/data_migration_service.dart`
- Migrate existing SharedPreferences data to Isar
- Validate data integrity during migration
- Handle migration errors gracefully
- Provide rollback mechanism if needed

## Implementation Steps

### Step 1: Database Foundation
1. Set up Isar database with SmokeLog schema
2. Implement local data source with full CRUD operations
3. Add proper indexing for performance (accountId, timestamp)
4. Create database initialization and version management

### Step 2: Write Queue Implementation
1. Create persistent job queue for failed writes
2. Implement exponential backoff retry logic
3. Add job prioritization (user-initiated vs background)
4. Handle queue overflow and cleanup

### Step 3: Sync Service Architecture
1. Implement background sync with connectivity awareness
2. Add conflict resolution using server timestamp authority
3. Create sync progress tracking and user notifications
4. Implement incremental sync for efficiency

### Step 4: Error Handling Enhancement
1. Map low-level errors to user-friendly messages
2. Implement error recovery strategies
3. Add telemetry for error tracking and debugging
4. Create error reporting and diagnostics

### Step 5: Migration and Testing
1. Implement data migration from existing storage
2. Add comprehensive integration tests for sync scenarios
3. Test offline/online transitions and edge cases
4. Validate data integrity and performance

## Code Implementation Examples

### Isar Local Data Source
```dart
@Collection()
class SmokeLogIsar {
  Id id = Isar.autoIncrement;
  
  @Index()
  late String accountId;
  
  @Index()
  late DateTime timestamp;
  
  late int durationMs;
  String? method;
  String? notes;
  String? mood;
  int? potency;
  
  // Sync metadata
  late bool isDirty;
  DateTime? lastSyncAt;
  String? syncVersion;
}

class SmokeLogsLocalDataSourceIsar implements SmokeLogsLocalDataSource {
  final Isar isar;
  
  @override
  Future<Either<AppFailure, SmokeLog>> create(SmokeLog log) async {
    try {
      final isarLog = log.toIsar()..isDirty = true;
      await isar.writeTxn(() => isar.smokeLogIsars.put(isarLog));
      
      // Enqueue for background sync
      _backgroundSync.enqueueWrite(log.id);
      
      return Right(log);
    } catch (e) {
      return Left(DataFailure.saveError(e.toString()));
    }
  }
}
```

### Background Sync Service
```dart
class BackgroundSyncService {
  static const _maxRetries = 5;
  static const _baseDelayMs = 1000;
  
  final Queue<SyncJob> _writeQueue = Queue();
  final ConnectivityService _connectivity;
  Timer? _syncTimer;
  
  Future<void> enqueueWrite(String logId) async {
    final job = SyncJob(
      type: SyncJobType.write,
      entityId: logId,
      attempts: 0,
      createdAt: DateTime.now(),
    );
    
    _writeQueue.add(job);
    await _persistQueue();
    
    if (_connectivity.isConnected) {
      _scheduleSyncAttempt();
    }
  }
  
  Future<void> _processSyncJob(SyncJob job) async {
    try {
      final result = await _remoteDatasource.syncLog(job.entityId);
      
      result.match(
        (failure) => _handleSyncFailure(job, failure),
        (success) => _handleSyncSuccess(job),
      );
    } catch (e) {
      _handleSyncFailure(job, DataFailure.syncError(e.toString()));
    }
  }
  
  void _handleSyncFailure(SyncJob job, AppFailure failure) {
    job.attempts++;
    
    if (job.attempts >= _maxRetries) {
      _telemetry.logEvent('sync_permanent_failure', {
        'job_id': job.id,
        'error': failure.displayMessage,
      });
      return;
    }
    
    // Exponential backoff
    final delayMs = _baseDelayMs * math.pow(2, job.attempts).toInt();
    Timer(Duration(milliseconds: delayMs), () => _processSyncJob(job));
  }
}
```

### Enhanced Repository
```dart
class SmokeLogRepositoryImpl implements SmokeLogRepository {
  final SmokeLogsLocalDataSource _localSource;
  final SmokeLogsRemoteDataSource _remoteSource;
  final BackgroundSyncService _syncService;
  
  @override
  Future<Either<AppFailure, SmokeLog>> createLog(SmokeLog log) async {
    // Always write locally first (offline-first)
    final localResult = await _localSource.create(log);
    
    return localResult.match(
      (failure) => Left(failure),
      (savedLog) {
        // Enqueue for background sync
        _syncService.enqueueWrite(savedLog.id);
        
        // Return immediately with local save success
        return Right(savedLog);
      },
    );
  }
  
  @override
  Future<Either<AppFailure, List<SmokeLog>>> getLogs(String accountId) async {
    // Try local first
    final localResult = await _localSource.getByAccount(accountId);
    
    // Trigger background refresh if online
    if (_connectivity.isConnected) {
      _syncService.enqueueRefresh(accountId);
    }
    
    return localResult;
  }
}
```

## Manual QA Steps
1. **Offline Recording**: Disable network → record entries → verify local storage → enable network → verify sync
2. **Conflict Resolution**: Record on device A → record on device B same time → verify merge behavior
3. **Error Recovery**: Simulate sync failures → verify retry logic → verify eventual consistency
4. **Data Migration**: Install with old data format → upgrade → verify migration works
5. **Performance**: Record 100+ entries → verify query performance → test sync performance
6. **Storage Limits**: Fill device storage → verify graceful degradation → verify cleanup

## Performance Expectations
- Local write operation: ≤80ms (improved from 120ms)
- Database query (100 logs): ≤50ms with proper indexing
- Sync batch (50 logs): ≤2 seconds on good connection
- Migration (1000+ logs): ≤10 seconds with progress indication

## Accessibility Considerations
- Sync progress announcements for screen readers
- Error messages in accessible formats
- Offline mode indicators with semantic labels

## Error Handling Strategy
```
Network Error → Enqueue for retry → Exponential backoff → User notification
Storage Full → Cleanup old data → Notify user → Graceful degradation
Sync Conflict → Log conflict → Apply resolution strategy → Update UI
Data Corruption → Validate on read → Attempt repair → Fallback to backup
```

## Success Metrics
- Sync success rate >95% under normal conditions
- Data loss rate <0.1% including edge cases
- Local write operations complete within 80ms p95
- User satisfaction with offline reliability >4.5/5
- Background sync battery impact <2% daily usage
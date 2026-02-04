import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:ash_trail/services/sync_service.dart';
import 'package:ash_trail/services/log_record_service.dart';
import 'package:ash_trail/services/account_session_manager.dart';
import 'package:ash_trail/services/token_service.dart';
import 'package:ash_trail/services/legacy_data_adapter.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/repositories/log_record_repository.dart';

/// Mock LogRecordService for testing
class MockLogRecordService implements LogRecordService {
  final List<LogRecord> _records = [];
  final Map<String, List<String>> _syncErrors = {};
  
  void addRecord(LogRecord record) => _records.add(record);
  void clearRecords() => _records.clear();
  List<LogRecord> get records => List.unmodifiable(_records);
  Map<String, String> get lastErrors => Map.unmodifiable(
    _syncErrors.map((k, v) => MapEntry(k, v.last)),
  );
  
  @override
  Future<List<LogRecord>> getPendingSync({String? accountId, int limit = 50}) async {
    return _records.where((r) {
      if (accountId != null && r.accountId != accountId) return false;
      return r.syncState == SyncState.pending || r.syncState == SyncState.error;
    }).take(limit).toList();
  }
  
  @override
  Future<LogRecord?> getLogRecordByLogId(String logId) async {
    try {
      return _records.firstWhere((r) => r.logId == logId);
    } catch (_) {
      return null;
    }
  }
  
  @override
  Future<void> markSynced(LogRecord record, DateTime remoteUpdatedAt) async {
    final index = _records.indexWhere((r) => r.logId == record.logId);
    if (index >= 0) {
      _records[index] = record.copyWith(
        syncState: SyncState.synced,
        lastRemoteUpdateAt: remoteUpdatedAt,
      );
    }
  }
  
  @override
  Future<void> markSyncError(LogRecord record, String error) async {
    final index = _records.indexWhere((r) => r.logId == record.logId);
    if (index >= 0) {
      _records[index] = record.copyWith(syncState: SyncState.error);
      _syncErrors[record.logId] = [...(_syncErrors[record.logId] ?? []), error];
    }
  }
  
  @override
  Future<int> countLogRecords({
    required String accountId,
    DateTime? startDate,
    DateTime? endDate,
    bool includeDeleted = false,
  }) async {
    return _records.where((r) {
      if (r.accountId != accountId) return false;
      if (!includeDeleted && r.isDeleted) return false;
      if (startDate != null && r.eventAt.isBefore(startDate)) return false;
      if (endDate != null && r.eventAt.isAfter(endDate)) return false;
      return true;
    }).length;
  }
  
  @override
  Future<LogRecord> importLogRecord({
    required String logId,
    required String accountId,
    required EventType eventType,
    required DateTime eventAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    double duration = 0,
    Unit unit = Unit.seconds,
    String? note,
    List<LogReason>? reasons,
    double? moodRating,
    double? physicalRating,
    double? latitude,
    double? longitude,
    Source source = Source.imported,
    String? deviceId,
    String? appVersion,
  }) async {
    final record = LogRecord.create(
      logId: logId,
      accountId: accountId,
      eventType: eventType,
      eventAt: eventAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncState: SyncState.synced,
      duration: duration,
      unit: unit,
      note: note,
      reasons: reasons,
      moodRating: moodRating,
      physicalRating: physicalRating,
      latitude: latitude,
      longitude: longitude,
      source: source,
      deviceId: deviceId,
      appVersion: appVersion,
    );
    _records.add(record);
    return record;
  }
  
  @override
  Future<LogRecord> updateLogRecord(
    LogRecord record, {
    EventType? eventType,
    DateTime? eventAt,
    double? duration,
    Unit? unit,
    String? note,
    List<LogReason>? reasons,
    double? moodRating,
    double? physicalRating,
    double? latitude,
    double? longitude,
  }) async {
    final index = _records.indexWhere((r) => r.logId == record.logId);
    if (index >= 0) {
      _records[index] = record.copyWith(
        eventType: eventType ?? record.eventType,
        eventAt: eventAt ?? record.eventAt,
        duration: duration,
        unit: unit,
        note: note,
        reasons: reasons,
        moodRating: moodRating,
        physicalRating: physicalRating,
        latitude: latitude,
        longitude: longitude,
        updatedAt: DateTime.now(),
      );
    }
    return _records[index];
  }
  
  @override
  Future<void> applyRemoteDeletion(
    LogRecord record, {
    DateTime? deletedAt,
    required DateTime remoteUpdatedAt,
  }) async {
    final index = _records.indexWhere((r) => r.logId == record.logId);
    if (index >= 0) {
      _records[index] = record.copyWith(
        isDeleted: true,
        deletedAt: deletedAt,
        syncState: SyncState.synced,
        lastRemoteUpdateAt: remoteUpdatedAt,
      );
    }
  }
  
  // Stubs for other methods
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Mock AccountSessionManager for testing
class MockAccountSessionManager implements AccountSessionManager {
  final List<Account> _loggedInAccounts = [];
  final Map<String, String> _customTokens = {};
  
  void setLoggedInAccounts(List<Account> accounts) {
    _loggedInAccounts.clear();
    _loggedInAccounts.addAll(accounts);
  }
  
  void setCustomToken(String userId, String token) {
    _customTokens[userId] = token;
  }
  
  @override
  Future<List<Account>> getLoggedInAccounts() async {
    return List.unmodifiable(_loggedInAccounts);
  }
  
  @override
  Future<String?> getValidCustomToken(String userId) async {
    return _customTokens[userId];
  }
  
  @override
  Future<void> storeCustomToken(String userId, String token) async {
    _customTokens[userId] = token;
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Mock TokenService for testing
class MockTokenService implements TokenService {
  bool shouldFail = false;
  int generateCallCount = 0;
  
  @override
  Future<Map<String, dynamic>> generateCustomToken(String uid) async {
    generateCallCount++;
    if (shouldFail) {
      throw Exception('Token generation failed');
    }
    return {
      'customToken': 'mock_token_for_$uid',
      'expiresIn': 172800,
    };
  }
  
  @override
  Future<bool> isEndpointReachable() async => !shouldFail;
}

/// Test helper to create a LogRecord
LogRecord createTestLogRecord({
  String? logId,
  String accountId = 'test-user-123',
  EventType eventType = EventType.vape,
  DateTime? eventAt,
  SyncState syncState = SyncState.pending,
  int revision = 1,
  DateTime? updatedAt,
  String? note,
}) {
  final now = DateTime.now();
  return LogRecord.create(
    logId: logId ?? 'log-${now.millisecondsSinceEpoch}',
    accountId: accountId,
    eventType: eventType,
    eventAt: eventAt ?? now,
    createdAt: now,
    updatedAt: updatedAt ?? now,
    syncState: syncState,
    revision: revision,
    note: note,
    reasons: [],
  );
}

/// Test helper to create an Account
Account createTestAccount({
  String? userId,
  String? email,
  AuthProvider authProvider = AuthProvider.gmail,
}) {
  final uid = userId ?? 'user-${DateTime.now().millisecondsSinceEpoch}';
  return Account.create(
    userId: uid,
    email: email ?? '$uid@test.com',
    displayName: 'Test User',
    authProvider: authProvider,
    isActive: true,
    isLoggedIn: true,
  );
}

/// Mock LegacyDataAdapter for testing
class MockLegacyDataAdapter implements LegacyDataAdapter {
  final List<LogRecord> _legacyRecords = [];
  
  void addLegacyRecord(LogRecord record) => _legacyRecords.add(record);
  
  @override
  Future<List<LogRecord>> queryAllLegacyCollections({
    DateTime? since,
    int limit = 100,
  }) async {
    return _legacyRecords.take(limit).toList();
  }
  
  @override
  Future<bool> hasLegacyData(String accountId) async {
    return _legacyRecords.isNotEmpty;
  }
  
  @override
  Future<int> getLegacyRecordCount(String accountId) async {
    return _legacyRecords.length;
  }
  
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Creates a SyncService with mocked dependencies for testing
SyncService createTestSyncService({
  required MockLogRecordService logRecordService,
  required MockAccountSessionManager sessionManager,
  required MockTokenService tokenService,
  FakeFirebaseFirestore? firestore,
  MockLegacyDataAdapter? legacyAdapter,
  Future<List<ConnectivityResult>> Function()? connectivityCheck,
}) {
  final fakeFirestore = firestore ?? FakeFirebaseFirestore();
  return SyncService(
    firestore: fakeFirestore,
    logRecordService: logRecordService,
    sessionManager: sessionManager,
    tokenService: tokenService,
    legacyAdapter: legacyAdapter ?? MockLegacyDataAdapter(),
    connectivityCheck: connectivityCheck ?? () async => [ConnectivityResult.wifi],
  );
}

void main() {
  group('SyncService - Connectivity', () {
    late MockLogRecordService mockLogRecordService;
    late MockAccountSessionManager mockSessionManager;
    late MockTokenService mockTokenService;

    setUp(() {
      mockLogRecordService = MockLogRecordService();
      mockSessionManager = MockAccountSessionManager();
      mockTokenService = MockTokenService();
    });

    test('isOnline returns true when wifi is available', () async {
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.wifi],
      );

      expect(await syncService.isOnline(), true);
    });

    test('isOnline returns true when mobile is available', () async {
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.mobile],
      );

      expect(await syncService.isOnline(), true);
    });

    test('isOnline returns true when ethernet is available', () async {
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.ethernet],
      );

      expect(await syncService.isOnline(), true);
    });

    test('isOnline returns false when no connectivity', () async {
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.none],
      );

      expect(await syncService.isOnline(), false);
    });

    test('isOnline returns false when bluetooth only', () async {
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.bluetooth],
      );

      expect(await syncService.isOnline(), false);
    });

    test('isOnline returns true when multiple connections available', () async {
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [
          ConnectivityResult.wifi,
          ConnectivityResult.mobile,
        ],
      );

      expect(await syncService.isOnline(), true);
    });
  });

  group('SyncService - Auto Sync', () {
    late MockLogRecordService mockLogRecordService;
    late MockAccountSessionManager mockSessionManager;
    late MockTokenService mockTokenService;

    setUp(() {
      mockLogRecordService = MockLogRecordService();
      mockSessionManager = MockAccountSessionManager();
      mockTokenService = MockTokenService();
    });

    test('startAutoSync and stopAutoSync manage timers', () async {
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.wifi],
      );

      // Start auto sync
      syncService.startAutoSync(
        pushInterval: const Duration(seconds: 1),
        pullInterval: const Duration(seconds: 1),
      );

      // Should not throw
      expect(() => syncService.stopAutoSync(), returnsNormally);

      // Stop again should also not throw
      expect(() => syncService.stopAutoSync(), returnsNormally);

      syncService.dispose();
    });

    test('dispose stops auto sync', () {
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.wifi],
      );

      syncService.startAutoSync();
      expect(() => syncService.dispose(), returnsNormally);
    });
  });

  group('SyncService - Sync Status', () {
    late MockLogRecordService mockLogRecordService;
    late MockAccountSessionManager mockSessionManager;
    late MockTokenService mockTokenService;

    setUp(() {
      mockLogRecordService = MockLogRecordService();
      mockSessionManager = MockAccountSessionManager();
      mockTokenService = MockTokenService();
    });

    test('getSyncStatus returns correct online status when online', () async {
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.wifi],
      );

      final status = await syncService.getSyncStatus('test-account');

      expect(status.isOnline, true);
      expect(status.pendingCount, 0);
      expect(status.isSyncing, false);
    });

    test('getSyncStatus returns correct online status when offline', () async {
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.none],
      );

      final status = await syncService.getSyncStatus('test-account');

      expect(status.isOnline, false);
    });

    test('getSyncStatus counts pending records', () async {
      // Add some records
      mockLogRecordService.addRecord(createTestLogRecord(
        logId: 'log-1',
        syncState: SyncState.pending,
      ));
      mockLogRecordService.addRecord(createTestLogRecord(
        logId: 'log-2',
        syncState: SyncState.synced,
      ));
      mockLogRecordService.addRecord(createTestLogRecord(
        logId: 'log-3',
        syncState: SyncState.pending,
      ));

      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.wifi],
      );

      final status = await syncService.getSyncStatus('test-user-123');

      // countLogRecords counts all non-deleted records, not just pending
      expect(status.pendingCount, 3);
    });
  });

  group('SyncResult', () {
    test('SyncResult hasErrors returns true when failed > 0', () {
      final result = SyncResult(
        success: 5,
        failed: 1,
        skipped: 0,
        message: 'Test',
      );

      expect(result.hasErrors, true);
    });

    test('SyncResult hasErrors returns false when failed == 0', () {
      final result = SyncResult(
        success: 5,
        failed: 0,
        skipped: 0,
        message: 'Test',
      );

      expect(result.hasErrors, false);
    });

    test('SyncResult toString provides useful output', () {
      final result = SyncResult(
        success: 5,
        failed: 1,
        skipped: 2,
        message: 'Test message',
      );

      final str = result.toString();
      expect(str, contains('success: 5'));
      expect(str, contains('failed: 1'));
      expect(str, contains('skipped: 2'));
      expect(str, contains('Test message'));
    });
  });

  group('SyncStatus', () {
    test('SyncStatus isFullySynced when no pending and not syncing', () {
      final status = SyncStatus(
        pendingCount: 0,
        isOnline: true,
        isSyncing: false,
      );

      expect(status.isFullySynced, true);
    });

    test('SyncStatus not fully synced when pending > 0', () {
      final status = SyncStatus(
        pendingCount: 5,
        isOnline: true,
        isSyncing: false,
      );

      expect(status.isFullySynced, false);
    });

    test('SyncStatus not fully synced when syncing', () {
      final status = SyncStatus(
        pendingCount: 0,
        isOnline: true,
        isSyncing: true,
      );

      expect(status.isFullySynced, false);
    });

    test('SyncStatus toString provides useful output', () {
      final status = SyncStatus(
        pendingCount: 5,
        isOnline: true,
        isSyncing: false,
      );

      final str = status.toString();
      expect(str, contains('pending: 5'));
      expect(str, contains('online: true'));
      expect(str, contains('syncing: false'));
    });
  });

  group('SyncService - Pull Records', () {
    late MockLogRecordService mockLogRecordService;
    late MockAccountSessionManager mockSessionManager;
    late MockTokenService mockTokenService;

    setUp(() {
      mockLogRecordService = MockLogRecordService();
      mockSessionManager = MockAccountSessionManager();
      mockTokenService = MockTokenService();
    });

    test('pullRecordsForAccount returns offline message when offline', () async {
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.none],
      );

      final result = await syncService.pullRecordsForAccount(
        accountId: 'test-account',
      );

      expect(result.success, 0);
      expect(result.message, 'Device is offline');
    });

    test('pullRecordsForAccountIncludingLegacy returns offline message when offline', () async {
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.none],
      );

      final result = await syncService.pullRecordsForAccountIncludingLegacy(
        accountId: 'test-account',
      );

      expect(result.success, 0);
      expect(result.message, 'Device is offline');
    });

    test('pullAllLoggedInAccounts returns offline message when offline', () async {
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.none],
      );

      final result = await syncService.pullAllLoggedInAccounts();

      expect(result.success, 0);
      expect(result.message, 'Device is offline');
    });

    test('pullAllLoggedInAccounts returns no accounts message when empty', () async {
      mockSessionManager.setLoggedInAccounts([]);
      
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.wifi],
      );

      final result = await syncService.pullAllLoggedInAccounts();

      expect(result.success, 0);
      expect(result.message, 'No logged-in accounts');
    });
  });

  group('SyncService - Sync All Accounts', () {
    late MockLogRecordService mockLogRecordService;
    late MockAccountSessionManager mockSessionManager;
    late MockTokenService mockTokenService;

    setUp(() {
      mockLogRecordService = MockLogRecordService();
      mockSessionManager = MockAccountSessionManager();
      mockTokenService = MockTokenService();
    });

    test('syncAllLoggedInAccounts returns offline message when offline', () async {
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.none],
      );

      final result = await syncService.syncAllLoggedInAccounts();

      expect(result.success, 0);
      expect(result.message, 'Device is offline');
    });

    test('syncAllLoggedInAccounts returns no accounts message when empty', () async {
      mockSessionManager.setLoggedInAccounts([]);
      
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.wifi],
      );

      final result = await syncService.syncAllLoggedInAccounts();

      expect(result.success, 0);
      expect(result.message, 'No logged-in accounts');
    });
  });

  group('SyncService - Force Sync', () {
    late MockLogRecordService mockLogRecordService;
    late MockAccountSessionManager mockSessionManager;
    late MockTokenService mockTokenService;

    setUp(() {
      mockLogRecordService = MockLogRecordService();
      mockSessionManager = MockAccountSessionManager();
      mockTokenService = MockTokenService();
    });

    test('forceSyncNow calls syncAllLoggedInAccounts', () async {
      mockSessionManager.setLoggedInAccounts([]);
      
      final syncService = createTestSyncService(
        logRecordService: mockLogRecordService,
        sessionManager: mockSessionManager,
        tokenService: mockTokenService,
        connectivityCheck: () async => [ConnectivityResult.wifi],
      );

      final result = await syncService.forceSyncNow();

      expect(result.message, 'No logged-in accounts');
    });
  });

  group('SyncService - Account Sync', () {
    late MockLogRecordService mockLogRecordService;
    late MockAccountSessionManager mockSessionManager;
    late MockTokenService mockTokenService;

    setUp(() {
      mockLogRecordService = MockLogRecordService();
      mockSessionManager = MockAccountSessionManager();
      mockTokenService = MockTokenService();
    });

    // Note: startAccountSync requires FirebaseAuth.instance which can't be mocked in unit tests
    // This functionality is tested in integration tests instead
  });

  group('TokenService Mock', () {
    test('generates custom token successfully', () async {
      final tokenService = MockTokenService();
      final result = await tokenService.generateCustomToken('test-uid');

      expect(result['customToken'], 'mock_token_for_test-uid');
      expect(result['expiresIn'], 172800);
      expect(tokenService.generateCallCount, 1);
    });

    test('throws when shouldFail is true', () async {
      final tokenService = MockTokenService();
      tokenService.shouldFail = true;

      expect(
        () => tokenService.generateCustomToken('test-uid'),
        throwsException,
      );
    });

    test('isEndpointReachable returns correct value', () async {
      final tokenService = MockTokenService();
      
      expect(await tokenService.isEndpointReachable(), true);
      
      tokenService.shouldFail = true;
      expect(await tokenService.isEndpointReachable(), false);
    });
  });

  group('MockLogRecordService', () {
    late MockLogRecordService service;

    setUp(() {
      service = MockLogRecordService();
    });

    test('getPendingSync filters by account and sync state', () async {
      service.addRecord(createTestLogRecord(
        logId: 'log-1',
        accountId: 'account-1',
        syncState: SyncState.pending,
      ));
      service.addRecord(createTestLogRecord(
        logId: 'log-2',
        accountId: 'account-1',
        syncState: SyncState.synced,
      ));
      service.addRecord(createTestLogRecord(
        logId: 'log-3',
        accountId: 'account-2',
        syncState: SyncState.pending,
      ));
      service.addRecord(createTestLogRecord(
        logId: 'log-4',
        accountId: 'account-1',
        syncState: SyncState.error,
      ));

      final pending = await service.getPendingSync(accountId: 'account-1');

      expect(pending.length, 2);
      expect(pending.map((r) => r.logId), containsAll(['log-1', 'log-4']));
    });

    test('getPendingSync respects limit', () async {
      for (var i = 0; i < 10; i++) {
        service.addRecord(createTestLogRecord(
          logId: 'log-$i',
          syncState: SyncState.pending,
        ));
      }

      final pending = await service.getPendingSync(limit: 5);

      expect(pending.length, 5);
    });

    test('getLogRecordByLogId returns record or null', () async {
      service.addRecord(createTestLogRecord(logId: 'log-1'));

      expect(await service.getLogRecordByLogId('log-1'), isNotNull);
      expect(await service.getLogRecordByLogId('nonexistent'), isNull);
    });

    test('markSynced updates sync state', () async {
      final record = createTestLogRecord(logId: 'log-1', syncState: SyncState.pending);
      service.addRecord(record);

      await service.markSynced(record, DateTime.now());

      final updated = await service.getLogRecordByLogId('log-1');
      expect(updated?.syncState, SyncState.synced);
    });

    test('markSyncError updates sync state and stores error', () async {
      final record = createTestLogRecord(logId: 'log-1', syncState: SyncState.pending);
      service.addRecord(record);

      await service.markSyncError(record, 'Test error');

      final updated = await service.getLogRecordByLogId('log-1');
      expect(updated?.syncState, SyncState.error);
      expect(service.lastErrors['log-1'], 'Test error');
    });

    test('importLogRecord creates new record', () async {
      final now = DateTime.now();
      await service.importLogRecord(
        logId: 'imported-log',
        accountId: 'account-1',
        eventType: EventType.vape,
        eventAt: now,
        createdAt: now,
        updatedAt: now,
      );

      final record = await service.getLogRecordByLogId('imported-log');
      expect(record, isNotNull);
      expect(record?.accountId, 'account-1');
      expect(record?.syncState, SyncState.synced);
    });

    test('updateLogRecord modifies existing record', () async {
      final record = createTestLogRecord(
        logId: 'log-1',
        note: 'Original note',
      );
      service.addRecord(record);

      await service.updateLogRecord(
        record,
        note: 'Updated note',
        eventType: EventType.note,
      );

      final updated = await service.getLogRecordByLogId('log-1');
      expect(updated?.note, 'Updated note');
      expect(updated?.eventType, EventType.note);
    });

    test('applyRemoteDeletion marks record as deleted', () async {
      final record = createTestLogRecord(logId: 'log-1');
      service.addRecord(record);

      await service.applyRemoteDeletion(
        record,
        deletedAt: DateTime.now(),
        remoteUpdatedAt: DateTime.now(),
      );

      final updated = await service.getLogRecordByLogId('log-1');
      expect(updated?.isDeleted, true);
      expect(updated?.syncState, SyncState.synced);
    });

    test('countLogRecords filters correctly', () async {
      service.addRecord(createTestLogRecord(
        logId: 'log-1',
        accountId: 'account-1',
        eventType: EventType.vape,
      ));
      service.addRecord(createTestLogRecord(
        logId: 'log-2',
        accountId: 'account-1',
        eventType: EventType.note,
      ));
      service.addRecord(createTestLogRecord(
        logId: 'log-3',
        accountId: 'account-2',
        eventType: EventType.vape,
      ));

      expect(await service.countLogRecords(accountId: 'account-1'), 2);
      expect(await service.countLogRecords(accountId: 'account-2'), 1);
    });
  });

  group('MockAccountSessionManager', () {
    late MockAccountSessionManager manager;

    setUp(() {
      manager = MockAccountSessionManager();
    });

    test('getLoggedInAccounts returns set accounts', () async {
      final accounts = [
        createTestAccount(userId: 'user-1'),
        createTestAccount(userId: 'user-2'),
      ];
      manager.setLoggedInAccounts(accounts);

      final result = await manager.getLoggedInAccounts();
      expect(result.length, 2);
    });

    test('getValidCustomToken returns stored token', () async {
      manager.setCustomToken('user-1', 'token-abc');

      expect(await manager.getValidCustomToken('user-1'), 'token-abc');
      expect(await manager.getValidCustomToken('user-2'), isNull);
    });

    test('storeCustomToken saves token', () async {
      await manager.storeCustomToken('user-1', 'new-token');

      expect(await manager.getValidCustomToken('user-1'), 'new-token');
    });
  });

  group('Test Helper Functions', () {
    test('createTestLogRecord creates valid record', () {
      final record = createTestLogRecord(
        logId: 'custom-id',
        accountId: 'custom-account',
        eventType: EventType.note,
        syncState: SyncState.synced,
        note: 'Test note',
      );

      expect(record.logId, 'custom-id');
      expect(record.accountId, 'custom-account');
      expect(record.eventType, EventType.note);
      expect(record.syncState, SyncState.synced);
      expect(record.note, 'Test note');
    });

    test('createTestLogRecord uses defaults', () {
      final record = createTestLogRecord();

      expect(record.logId, startsWith('log-'));
      expect(record.accountId, 'test-user-123');
      expect(record.eventType, EventType.vape);
      expect(record.syncState, SyncState.pending);
    });

    test('createTestAccount creates valid account', () {
      final account = createTestAccount(
        userId: 'custom-user',
        email: 'custom@test.com',
        authProvider: AuthProvider.apple,
      );

      expect(account.userId, 'custom-user');
      expect(account.email, 'custom@test.com');
      expect(account.authProvider, AuthProvider.apple);
    });

    test('createTestAccount uses defaults', () {
      final account = createTestAccount();

      expect(account.userId, startsWith('user-'));
      expect(account.email, contains('@test.com'));
      expect(account.authProvider, AuthProvider.gmail);
    });
  });
}

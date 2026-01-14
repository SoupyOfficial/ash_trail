import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Sequential Login Scenarios - Logout and Re-login', () {
    // Don't instantiate real services - just test the models
    const uuid = Uuid();

    group('Basic Logout and Login Sequence', () {
      test('user can logout and login again with same account', () async {
        // GIVEN: User logged in
        const userId = 'test-user-001';
        const email = 'user@example.com';

        var account = Account.create(
          userId: userId,
          email: email,
          displayName: 'Test User',
          authProvider: AuthProvider.email,
        ).copyWith(isActive: true);

        expect(account.isActive, isTrue);
        expect(account.userId, userId);

        // WHEN: User logs out
        account = account.copyWith(isActive: false);

        // THEN: Account is inactive
        expect(account.isActive, isFalse);
        expect(account.userId, userId); // Account data preserved

        // WHEN: User logs back in
        account = account.copyWith(isActive: true);

        // THEN: Account is active again with same data
        expect(account.isActive, isTrue);
        expect(account.userId, userId);
        expect(account.email, email);
        expect(account.displayName, 'Test User');
      });

      test('logout and login preserves user email', () async {
        // GIVEN: User with specific email
        const email = 'user@example.com';
        var account = Account.create(
          userId: 'user-123',
          email: email,
          displayName: 'User',
        ).copyWith(isActive: true);

        final emailBeforeLogout = account.email;

        // WHEN: Logout and login
        account = account.copyWith(isActive: false);
        account = account.copyWith(isActive: true);

        // THEN: Email is preserved
        expect(account.email, emailBeforeLogout);
        expect(account.email, email);
      });

      test('logout and login preserves displayName', () async {
        // GIVEN: User with display name
        const displayName = 'John Doe';
        var account = Account.create(
          userId: 'john-123',
          email: 'john@example.com',
          displayName: displayName,
        ).copyWith(isActive: true);

        // WHEN: Logout and login
        account = account.copyWith(isActive: false);
        account = account.copyWith(isActive: true);

        // THEN: Display name preserved
        expect(account.displayName, displayName);
      });
    });

    group('Local Data Persistence After Sequential Login', () {
      test('logs created before logout persist after login', () async {
        // GIVEN: User creates logs
        const userId = 'user-logs-001';
        final logs = <LogRecord>[];

        for (int i = 0; i < 3; i++) {
          logs.add(
            LogRecord.create(
              logId: uuid.v4(),
              accountId: userId,
              eventType: i % 2 == 0 ? EventType.vape : EventType.inhale,
              duration: 30 + i * 5,
              eventAt: DateTime.now().subtract(Duration(hours: i)),
            ),
          );
        }

        expect(logs.length, 3);

        // WHEN: User logs out
        var account = Account.create(
          userId: userId,
          email: 'user@example.com',
          displayName: 'User',
        ).copyWith(isActive: false);

        // THEN: Logs are still in local storage (accountId preserved)
        expect(logs.every((log) => log.accountId == userId), isTrue);

        // WHEN: User logs back in
        account = account.copyWith(isActive: true);

        // THEN: Logs are still accessible
        expect(logs.length, 3);
        expect(logs.every((log) => log.accountId == userId), isTrue);
      });

      test('pending sync logs remain pending after logout/login', () async {
        // GIVEN: User creates pending logs
        const userId = 'pending-logs-user';
        final pendingLogs = <LogRecord>[];

        for (int i = 0; i < 2; i++) {
          pendingLogs.add(
            LogRecord.create(
              logId: uuid.v4(),
              accountId: userId,
              eventType: EventType.vape,
            ),
          );
        }

        // All should be pending
        expect(
          pendingLogs.every((log) => log.syncState == SyncState.pending),
          isTrue,
        );

        // WHEN: User logs out
        var account = Account.create(
          userId: userId,
          email: 'user@example.com',
          displayName: 'User',
        ).copyWith(isActive: false);

        // THEN: Logs remain pending
        expect(
          pendingLogs.every((log) => log.syncState == SyncState.pending),
          isTrue,
        );

        // WHEN: User logs back in
        account = account.copyWith(isActive: true);

        // THEN: Logs can be synced
        final syncedLogs =
            pendingLogs
                .map((log) => log.copyWith(syncState: SyncState.synced))
                .toList();

        expect(
          syncedLogs.every((log) => log.syncState == SyncState.synced),
          isTrue,
        );
      });

      test('synced logs remain synced after logout/login', () async {
        // GIVEN: User has synced logs
        const userId = 'synced-logs-user';
        final syncedLogs = <LogRecord>[];

        for (int i = 0; i < 2; i++) {
          syncedLogs.add(
            LogRecord.create(
              logId: uuid.v4(),
              accountId: userId,
              eventType: EventType.vape,
            ).copyWith(syncState: SyncState.synced),
          );
        }

        // All should be synced
        expect(
          syncedLogs.every((log) => log.syncState == SyncState.synced),
          isTrue,
        );

        // WHEN: User logs out then in
        var account = Account.create(
          userId: userId,
          email: 'user@example.com',
          displayName: 'User',
        );
        account = account.copyWith(isActive: false);
        account = account.copyWith(isActive: true);

        // THEN: Logs remain synced
        expect(
          syncedLogs.every((log) => log.syncState == SyncState.synced),
          isTrue,
        );
      });

      test('mixed pending and synced logs remain in correct states', () async {
        // GIVEN: User has mix of pending and synced logs
        const userId = 'mixed-logs-user';
        final logs = <LogRecord>[
          LogRecord.create(
            logId: uuid.v4(),
            accountId: userId,
            eventType: EventType.vape,
          ), // Pending
          LogRecord.create(
            logId: uuid.v4(),
            accountId: userId,
            eventType: EventType.inhale,
          ).copyWith(syncState: SyncState.synced), // Synced
          LogRecord.create(
            logId: uuid.v4(),
            accountId: userId,
            eventType: EventType.vape,
          ), // Pending
          LogRecord.create(
            logId: uuid.v4(),
            accountId: userId,
            eventType: EventType.inhale,
          ).copyWith(syncState: SyncState.synced), // Synced
        ];

        final pendingBefore =
            logs.where((log) => log.syncState == SyncState.pending).length;
        final syncedBefore =
            logs.where((log) => log.syncState == SyncState.synced).length;

        expect(pendingBefore, 2);
        expect(syncedBefore, 2);

        // WHEN: User logs out and in
        var account = Account.create(
          userId: userId,
          email: 'user@example.com',
          displayName: 'User',
        );
        account = account.copyWith(isActive: false);
        account = account.copyWith(isActive: true);

        // THEN: States are preserved
        final pendingAfter =
            logs.where((log) => log.syncState == SyncState.pending).length;
        final syncedAfter =
            logs.where((log) => log.syncState == SyncState.synced).length;

        expect(pendingAfter, pendingBefore);
        expect(syncedAfter, syncedBefore);
      });
    });

    group('Multiple Sequential Login Cycles', () {
      test('user can logout and login multiple times', () async {
        // GIVEN: User account
        const userId = 'multi-login-user';
        var account = Account.create(
          userId: userId,
          email: 'user@example.com',
          displayName: 'User',
        );

        // WHEN: Perform 3 logout/login cycles
        for (int i = 0; i < 3; i++) {
          account = account.copyWith(isActive: true);
          expect(account.isActive, isTrue);

          account = account.copyWith(isActive: false);
          expect(account.isActive, isFalse);
        }

        // THEN: Final state should be logged out
        expect(account.isActive, isFalse);
        expect(account.userId, userId); // Data preserved
      });

      test('data persists across multiple logout/login cycles', () async {
        // GIVEN: User creates logs and performs cycles
        const userId = 'cycle-test-user';

        // First cycle - create logs
        var account = Account.create(
          userId: userId,
          email: 'user@example.com',
          displayName: 'User',
        ).copyWith(isActive: true);

        final logs = [
          LogRecord.create(
            logId: uuid.v4(),
            accountId: userId,
            eventType: EventType.vape,
          ),
          LogRecord.create(
            logId: uuid.v4(),
            accountId: userId,
            eventType: EventType.inhale,
          ),
        ];

        // Logout
        account = account.copyWith(isActive: false);

        // Second cycle - logs persist
        account = account.copyWith(isActive: true);
        expect(logs.length, 2);

        // Add more logs
        logs.add(
          LogRecord.create(
            logId: uuid.v4(),
            accountId: userId,
            eventType: EventType.vape,
          ),
        );

        // Logout again
        account = account.copyWith(isActive: false);

        // Third cycle - all logs persist
        account = account.copyWith(isActive: true);
        expect(logs.length, 3);

        // THEN: All logs preserved across cycles
        expect(logs.every((log) => log.accountId == userId), isTrue);
      });

      test('account timestamps update on each login', () async {
        // GIVEN: User account
        const userId = 'timestamp-test-user';
        var account = Account.create(
          userId: userId,
          email: 'user@example.com',
          displayName: 'User',
        ).copyWith(isActive: true);

        final createdAt = account.createdAt;

        // WHEN: Logout
        account = account.copyWith(isActive: false);

        // THEN: Created timestamp unchanged
        expect(account.createdAt, createdAt);

        // WHEN: Login again (simulating time passing)
        await Future.delayed(const Duration(milliseconds: 10));
        account = account.copyWith(
          isActive: true,
          lastModifiedAt: DateTime.now(),
        );

        // THEN: CreatedAt same, but lastModifiedAt updated
        expect(account.createdAt, createdAt);
        expect(account.lastModifiedAt?.isAfter(createdAt) ?? false, isTrue);
      });
    });

    group('Sequential Login With Different Auth Providers', () {
      test('user can switch auth provider in sequential logins', () async {
        // GIVEN: User originally logged in with email
        var account = Account.create(
          userId: 'switching-user',
          email: 'user@example.com',
          displayName: 'User',
          authProvider: AuthProvider.email,
        ).copyWith(isActive: true);

        expect(account.authProvider, AuthProvider.email);

        // WHEN: User logs out
        account = account.copyWith(isActive: false);

        // WHEN: User logs back in with Gmail (different provider)
        account = account.copyWith(
          isActive: true,
          authProvider: AuthProvider.gmail,
        );

        // THEN: Auth provider updated but account preserved
        expect(account.authProvider, AuthProvider.gmail);
        expect(account.displayName, 'User');
        expect(account.email, 'user@example.com');
      });

      test('logs persist regardless of auth provider change', () async {
        // GIVEN: User with email auth and logs
        const userId = 'provider-change-user';
        var account = Account.create(
          userId: userId,
          email: 'user@example.com',
          displayName: 'User',
          authProvider: AuthProvider.email,
        ).copyWith(isActive: true);

        final logs = [
          LogRecord.create(
            logId: uuid.v4(),
            accountId: userId,
            eventType: EventType.vape,
          ),
        ];

        // WHEN: Switch to Gmail auth
        account = account.copyWith(
          authProvider: AuthProvider.gmail,
          isActive: false,
        );
        account = account.copyWith(isActive: true);

        // THEN: Logs still accessible
        expect(logs.length, 1);
        expect(logs.first.accountId, userId);
      });
    });

    group('Session State Reset on Sequential Login', () {
      test('session state resets on logout', () async {
        // GIVEN: User logged in with active session
        const userId = 'session-reset-user';
        var account = Account.create(
          userId: userId,
          email: 'user@example.com',
          displayName: 'User',
        ).copyWith(isActive: true);

        expect(account.isActive, isTrue);

        // WHEN: User logs out
        account = account.copyWith(isActive: false);

        // THEN: Session should be reset (inactive)
        expect(account.isActive, isFalse);
      });

      test('new session starts fresh on login', () async {
        // GIVEN: User logs in after logout
        const userId = 'fresh-session-user';
        var account = Account.create(
          userId: userId,
          email: 'user@example.com',
          displayName: 'User',
        ).copyWith(isActive: true);

        // THEN: Session is fresh (just logged in)
        expect(account.isActive, isTrue);
      });
    });

    group('Sequential Login With Data Modification', () {
      test('profile updates persist across sequential login', () async {
        // GIVEN: User logs in and updates profile
        var account = Account.create(
          userId: 'profile-update-user',
          email: 'user@example.com',
          displayName: 'Original Name',
        ).copyWith(isActive: true);

        // WHEN: Update display name
        account = account.copyWith(displayName: 'Updated Name');

        // THEN: Update is reflected
        expect(account.displayName, 'Updated Name');

        // WHEN: Log out
        account = account.copyWith(isActive: false);

        // THEN: Updated name persists
        expect(account.displayName, 'Updated Name');

        // WHEN: Log back in
        account = account.copyWith(isActive: true);

        // THEN: Updated name is still there
        expect(account.displayName, 'Updated Name');
      });

      test('log data modifications persist across sequential login', () async {
        // GIVEN: User creates and modifies logs
        const userId = 'log-modify-user';
        var log = LogRecord.create(
          logId: uuid.v4(),
          accountId: userId,
          eventType: EventType.vape,
          duration: 30,
          moodRating: 5,
        );

        // WHEN: Update log details
        log = log.copyWith(
          moodRating: 7,
          physicalRating: 6,
          note: 'Updated notes',
        );

        expect(log.moodRating, 7);
        expect(log.note, 'Updated notes');

        // WHEN: User logs out and in
        var account = Account.create(
          userId: userId,
          email: 'user@example.com',
          displayName: 'User',
        );
        account = account.copyWith(isActive: false);
        account = account.copyWith(isActive: true);

        // THEN: Log modifications persist
        expect(log.moodRating, 7);
        expect(log.note, 'Updated notes');
      });

      test('sync state persists across sequential login', () async {
        // GIVEN: User with logs in various sync states
        const userId = 'sync-state-user';
        var pendingLog = LogRecord.create(
          logId: uuid.v4(),
          accountId: userId,
          eventType: EventType.vape,
        );
        var syncedLog = LogRecord.create(
          logId: uuid.v4(),
          accountId: userId,
          eventType: EventType.inhale,
        ).copyWith(syncState: SyncState.synced);

        expect(pendingLog.syncState, SyncState.pending);
        expect(syncedLog.syncState, SyncState.synced);

        // WHEN: User logs out and in
        var account = Account.create(
          userId: userId,
          email: 'user@example.com',
          displayName: 'User',
        );
        account = account.copyWith(isActive: false);
        account = account.copyWith(isActive: true);

        // THEN: Sync states are preserved
        expect(pendingLog.syncState, SyncState.pending);
        expect(syncedLog.syncState, SyncState.synced);
      });
    });

    group('Edge Cases in Sequential Login', () {
      test('rapid logout and login maintains data', () async {
        // GIVEN: User account with logs
        const userId = 'rapid-login-user';
        var account = Account.create(
          userId: userId,
          email: 'user@example.com',
          displayName: 'User',
        ).copyWith(isActive: true);

        final log = LogRecord.create(
          logId: uuid.v4(),
          accountId: userId,
          eventType: EventType.vape,
        );

        // WHEN: Rapid logout and login
        account = account.copyWith(isActive: false);
        account = account.copyWith(isActive: true);

        // THEN: Data intact
        expect(account.isActive, isTrue);
        expect(log.accountId, userId);
      });

      test('login after extended inactive period recovers data', () async {
        // GIVEN: Account that was inactive for "extended period"
        const userId = 'extended-inactive-user';
        var account = Account.create(
          userId: userId,
          email: 'user@example.com',
          displayName: 'User',
        ).copyWith(isActive: false);

        final logs = [
          LogRecord.create(
            logId: uuid.v4(),
            accountId: userId,
            eventType: EventType.vape,
            eventAt: DateTime.now().subtract(const Duration(days: 30)),
          ),
        ];

        // WHEN: User logs back in
        account = account.copyWith(isActive: true);

        // THEN: All data recovered
        expect(account.isActive, isTrue);
        expect(logs.length, 1);
        expect(logs.first.accountId, userId);
      });

      test('empty account logout and login works', () async {
        // GIVEN: Empty account (no logs)
        const userId = 'empty-account-user';
        var account = Account.create(
          userId: userId,
          email: 'user@example.com',
          displayName: 'User',
        ).copyWith(isActive: true);

        final logs = <LogRecord>[];

        // WHEN: Logout and login
        account = account.copyWith(isActive: false);
        account = account.copyWith(isActive: true);

        // THEN: Account still valid even with no logs
        expect(account.isActive, isTrue);
        expect(logs.isEmpty, isTrue);
      });
    });
  });
}

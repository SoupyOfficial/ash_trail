import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ash_trail/widgets/sync_status_widget.dart';
import 'package:ash_trail/providers/sync_provider.dart';
import 'package:ash_trail/providers/log_record_provider.dart';
import 'package:ash_trail/services/sync_service.dart';

void main() {
  group('SyncStatusWidget Tests', () {
    Widget createTestWidget({
      String? accountId = 'test-account',
      SyncStatus? syncStatus,
      Widget? child,
    }) {
      final status =
          syncStatus ??
          SyncStatus(pendingCount: 0, isOnline: true, isSyncing: false);

      return ProviderScope(
        overrides: [
          // Override account ID provider
          activeAccountIdProvider.overrideWith((ref) => accountId),
          // Override sync status provider to avoid timers - emit single value stream
          if (accountId != null)
            syncStatusProvider(
              accountId,
            ).overrideWith((ref) => Stream.value(status)),
        ],
        child: MaterialApp(
          home: Scaffold(body: child ?? const SyncStatusWidget()),
        ),
      );
    }

    group('SyncStatusWidget', () {
      testWidgets('shows nothing when no account', (tester) async {
        await tester.pumpWidget(createTestWidget(accountId: null));
        await tester.pumpAndSettle();

        // SizedBox.shrink is rendered when no account
        expect(find.byType(Card), findsNothing);
      });

      testWidgets('shows synced status when fully synced', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            syncStatus: SyncStatus(
              pendingCount: 0,
              isOnline: true,
              isSyncing: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show "All synced" text
        expect(find.text('All synced'), findsWidgets);
      });

      testWidgets('shows pending status when items pending', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            syncStatus: SyncStatus(
              pendingCount: 5,
              isOnline: true,
              isSyncing: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pending sync'), findsOneWidget);
        expect(find.text('5 items pending'), findsOneWidget);
      });

      testWidgets('shows syncing status when syncing', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            syncStatus: SyncStatus(
              pendingCount: 3,
              isOnline: true,
              isSyncing: true,
            ),
          ),
        );
        // Use pump() instead of pumpAndSettle() because CircularProgressIndicator
        // is animated and will never settle
        await tester.pump();
        await tester.pump();

        expect(find.text('Syncing...'), findsOneWidget);
      });

      testWidgets('shows offline status when offline', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            syncStatus: SyncStatus(
              pendingCount: 2,
              isOnline: false,
              isSyncing: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Offline'), findsOneWidget);
      });

      testWidgets('shows sync button when online', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            syncStatus: SyncStatus(
              pendingCount: 3,
              isOnline: true,
              isSyncing: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.sync), findsOneWidget);
      });

      testWidgets('does not show sync button when offline', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            syncStatus: SyncStatus(
              pendingCount: 3,
              isOnline: false,
              isSyncing: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Sync button is replaced by cloud_off icon
        expect(find.byIcon(Icons.sync), findsNothing);
      });
    });

    group('SyncStatusIndicator', () {
      testWidgets('shows nothing when no account', (tester) async {
        await tester.pumpWidget(
          createTestWidget(accountId: null, child: const SyncStatusIndicator()),
        );
        await tester.pumpAndSettle();

        // SizedBox.shrink
        expect(find.byIcon(Icons.cloud_done), findsNothing);
        expect(find.byIcon(Icons.cloud_off), findsNothing);
        expect(find.byIcon(Icons.cloud_upload), findsNothing);
      });

      testWidgets('shows green cloud when synced', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            syncStatus: SyncStatus(
              pendingCount: 0,
              isOnline: true,
              isSyncing: false,
            ),
            child: const SyncStatusIndicator(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.cloud_done), findsOneWidget);
      });

      testWidgets('shows orange cloud when pending', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            syncStatus: SyncStatus(
              pendingCount: 10,
              isOnline: true,
              isSyncing: false,
            ),
            child: const SyncStatusIndicator(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.cloud_upload), findsOneWidget);
      });

      testWidgets('shows grey cloud when offline', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            syncStatus: SyncStatus(
              pendingCount: 0,
              isOnline: false,
              isSyncing: false,
            ),
            child: const SyncStatusIndicator(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      });

      testWidgets('tapping shows sync details dialog', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            syncStatus: SyncStatus(
              pendingCount: 3,
              isOnline: true,
              isSyncing: false,
            ),
            child: const SyncStatusIndicator(),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Sync Status'), findsOneWidget);
      });

      testWidgets('dialog shows sync now button when items pending', (
        tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            syncStatus: SyncStatus(
              pendingCount: 5,
              isOnline: true,
              isSyncing: false,
            ),
            child: const SyncStatusIndicator(),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        expect(find.text('Sync Now'), findsOneWidget);
      });

      testWidgets('dialog close button works', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            syncStatus: SyncStatus(
              pendingCount: 0,
              isOnline: true,
              isSyncing: false,
            ),
            child: const SyncStatusIndicator(),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byType(IconButton));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
      });
    });

    group('Edge Cases', () {
      testWidgets('handles high pending count', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            syncStatus: SyncStatus(
              pendingCount: 9999,
              isOnline: true,
              isSyncing: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('9999 items pending'), findsOneWidget);
      });

      testWidgets('handles zero pending count correctly', (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            syncStatus: SyncStatus(
              pendingCount: 0,
              isOnline: true,
              isSyncing: false,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('All synced'), findsWidgets);
      });
    });
  });
}

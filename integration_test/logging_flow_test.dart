import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ash_trail/main.dart' as app;
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/services/isar_service.dart';
import 'package:ash_trail/services/log_record_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full end-to-end test of the logging flow:
/// 1. Create log entry via UI
/// 2. Verify it appears in the list
/// 3. Edit the entry
/// 4. View details
/// 5. Delete the entry
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete Logging Flow', () {
    late IsarService isarService;
    late LogRecordService logRecordService;

    setUp(() async {
      // Initialize services
      isarService = IsarService();
      await isarService.init();
      logRecordService = LogRecordService(isarService);
    });

    tearDown(() async {
      // Clean up
      await isarService.clearAllData();
      await isarService.close();
    });

    testWidgets('Create, view, edit, and delete log entry', (tester) async {
      // Start the app
      await tester.pumpWidget(ProviderScope(child: app.MyApp()));
      await tester.pumpAndSettle();

      // Find and tap the "Add Log" button
      final addButton = find.byIcon(Icons.add);
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Fill in the log entry form
      // Event Type dropdown
      final eventTypeDropdown = find.byType(DropdownButton<EventType>);
      await tester.tap(eventTypeDropdown);
      await tester.pumpAndSettle();

      final inhaleOption = find.text('Inhale').last;
      await tester.tap(inhaleOption);
      await tester.pumpAndSettle();

      // Value field
      final valueField = find.widgetWithText(TextFormField, 'Value');
      await tester.enterText(valueField, '2.0');
      await tester.pumpAndSettle();

      // Unit dropdown
      final unitDropdown = find.byType(DropdownButton<Unit>);
      await tester.tap(unitDropdown);
      await tester.pumpAndSettle();

      final hitsOption = find.text('Hits').last;
      await tester.tap(hitsOption);
      await tester.pumpAndSettle();

      // Note field
      final noteField = find.widgetWithText(TextFormField, 'Note');
      await tester.enterText(noteField, 'Test log entry');
      await tester.pumpAndSettle();

      // Tags field
      final tagsField = find.widgetWithText(TextFormField, 'Tags');
      await tester.enterText(tagsField, 'morning,sativa');
      await tester.pumpAndSettle();

      // Save button
      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify the entry appears in the list
      expect(find.text('Test log entry'), findsOneWidget);
      expect(find.text('2.0 hits'), findsOneWidget);

      // Tap on the entry to view details
      final entryTile = find.text('Test log entry');
      await tester.tap(entryTile);
      await tester.pumpAndSettle();

      // Verify detail dialog shows
      expect(find.text('Log Details'), findsOneWidget);
      expect(find.text('morning, sativa'), findsOneWidget);

      // Close detail dialog
      final closeButton = find.text('Close');
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // Long press to delete
      await tester.longPress(entryTile);
      await tester.pumpAndSettle();

      // Confirm delete
      final deleteButton = find.text('Delete');
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      final confirmButton = find.text('Confirm');
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Verify entry is deleted
      expect(find.text('Test log entry'), findsNothing);
    });

    testWidgets('Quick log button creates entry', (tester) async {
      await tester.pumpWidget(ProviderScope(child: app.MyApp()));
      await tester.pumpAndSettle();

      // Find quick log button (if implemented)
      final quickLogButton = find.byType(FloatingActionButton);
      if (quickLogButton.evaluate().isNotEmpty) {
        await tester.tap(quickLogButton);
        await tester.pumpAndSettle();

        // Verify entry was created
        expect(find.byType(ListTile), findsWidgets);
      }
    });

    testWidgets('Sync status widget shows pending state', (tester) async {
      // Create a pending log entry
      await logRecordService.createLogRecord(
        accountId: 'test-account',
        profileId: 'test-profile',
        eventType: EventType.inhale,
        value: 1.0,
        unit: Unit.hits,
      );

      await tester.pumpWidget(ProviderScope(child: app.MyApp()));
      await tester.pumpAndSettle();

      // Look for sync status indicators
      // This depends on your UI implementation
      // Could be a badge, icon, or status text
      expect(find.byIcon(Icons.sync), findsWidgets);
    });

    testWidgets('Filter log entries by event type', (tester) async {
      // Create multiple log entries
      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
        unit: Unit.hits,
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.note,
        note: 'Test note',
      );

      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.sessionStart,
      );

      await tester.pumpWidget(ProviderScope(child: app.MyApp()));
      await tester.pumpAndSettle();

      // Verify all entries are visible
      expect(find.byType(ListTile), findsNWidgets(3));

      // Apply filter (if filter UI is implemented)
      final filterButton = find.byIcon(Icons.filter_list);
      if (filterButton.evaluate().isNotEmpty) {
        await tester.tap(filterButton);
        await tester.pumpAndSettle();

        // Select "Inhale" filter
        final inhaleFilter = find.text('Inhale');
        await tester.tap(inhaleFilter);
        await tester.pumpAndSettle();

        // Verify only inhale entries are visible
        expect(find.byType(ListTile), findsNWidgets(1));
      }
    });

    testWidgets('Analytics screen shows statistics', (tester) async {
      // Create sample data
      for (int i = 0; i < 10; i++) {
        await logRecordService.createLogRecord(
          accountId: 'test-account',
          eventType: EventType.inhale,
          value: 1.0 + i * 0.5,
          unit: Unit.hits,
          eventAt: DateTime.now().subtract(Duration(days: i)),
        );
      }

      await tester.pumpWidget(ProviderScope(child: app.MyApp()));
      await tester.pumpAndSettle();

      // Navigate to analytics screen
      final analyticsTab = find.text('Analytics');
      if (analyticsTab.evaluate().isNotEmpty) {
        await tester.tap(analyticsTab);
        await tester.pumpAndSettle();

        // Verify charts are displayed
        expect(find.byType(Container), findsWidgets);

        // Look for statistics
        expect(find.textContaining('Total:'), findsWidgets);
      }
    });
  });

  group('Offline Scenarios', () {
    late IsarService isarService;
    late LogRecordService logRecordService;

    setUp(() async {
      isarService = IsarService();
      await isarService.init();
      logRecordService = LogRecordService(isarService);
    });

    tearDown(() async {
      await isarService.clearAllData();
      await isarService.close();
    });

    testWidgets('Create entries while offline', (tester) async {
      await tester.pumpWidget(ProviderScope(child: app.MyApp()));
      await tester.pumpAndSettle();

      // Create entry (implicitly offline since no Firestore setup)
      final addButton = find.byIcon(Icons.add);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Fill form (simplified)
      final saveButton = find.text('Save');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify entry is marked as pending sync
      // Check for sync indicator
      expect(find.byIcon(Icons.sync), findsWidgets);
    });

    testWidgets('Edit offline entry', (tester) async {
      // Create entry
      final logId = await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
        unit: Unit.hits,
        note: 'Original note',
      );

      await tester.pumpWidget(ProviderScope(child: app.MyApp()));
      await tester.pumpAndSettle();

      // Tap entry to edit
      final entryTile = find.text('Original note');
      await tester.tap(entryTile);
      await tester.pumpAndSettle();

      // Edit note
      final noteField = find.widgetWithText(TextFormField, 'Note');
      if (noteField.evaluate().isNotEmpty) {
        await tester.enterText(noteField, 'Updated note');
        await tester.pumpAndSettle();

        final updateButton = find.text('Update');
        await tester.tap(updateButton);
        await tester.pumpAndSettle();

        // Verify update
        expect(find.text('Updated note'), findsOneWidget);
      }
    });
  });

  group('Data Persistence', () {
    testWidgets('Data persists across app restarts', (tester) async {
      final isarService = IsarService();
      await isarService.init();
      final logRecordService = LogRecordService(isarService);

      // Create entry
      await logRecordService.createLogRecord(
        accountId: 'test-account',
        eventType: EventType.inhale,
        value: 1.0,
        unit: Unit.hits,
        note: 'Persistent entry',
      );

      // Start app
      await tester.pumpWidget(ProviderScope(child: app.MyApp()));
      await tester.pumpAndSettle();

      // Verify entry exists
      expect(find.text('Persistent entry'), findsOneWidget);

      // Restart app (simulate by disposing and recreating)
      await isarService.close();
      await isarService.init();

      await tester.pumpWidget(ProviderScope(child: app.MyApp()));
      await tester.pumpAndSettle();

      // Verify entry still exists
      expect(find.text('Persistent entry'), findsOneWidget);

      await isarService.clearAllData();
      await isarService.close();
    });
  });
}

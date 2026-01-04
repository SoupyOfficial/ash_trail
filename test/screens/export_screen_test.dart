import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/providers/log_record_provider.dart';
import 'package:ash_trail/screens/export_screen.dart';
import 'package:ash_trail/services/export_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeExportService extends ExportService {
  bool shouldThrow = false;
  int exportToCsvCalls = 0;
  int exportToJsonCalls = 0;
  List<LogRecord> lastExportedRecords = [];

  @override
  Future<String> exportToCsv(List<LogRecord> records) async {
    exportToCsvCalls++;
    lastExportedRecords = records;
    if (shouldThrow) {
      throw Exception('Export failed');
    }
    return 'timestamp,consumedAmount,note\n2024-01-01,2,test';
  }

  @override
  Future<String> exportToJson(List<LogRecord> records) async {
    exportToJsonCalls++;
    lastExportedRecords = records;
    if (shouldThrow) {
      throw Exception('Export failed');
    }
    return '{"records":[{"timestamp":"2024-01-01","consumedAmount":2}]}';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock clipboard to prevent platform channel errors
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, (
        MethodCall methodCall,
      ) async {
        if (methodCall.method == 'Clipboard.setData') {
          return null;
        }
        return null;
      });

  group('ExportScreen', () {
    testWidgets('renders export screen UI', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService = _FakeExportService();
      final testRecords = [
        LogRecord.create(
          logId: 'log-1',
          accountId: 'test-account',
          eventAt: DateTime(2024, 1, 1),
          eventType: EventType.vape,
          duration: 120.0,
          unit: Unit.seconds,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exportServiceProvider.overrideWithValue(fakeService),
            activeAccountLogRecordsProvider.overrideWith(
              (ref) => Stream.value(testRecords),
            ),
          ],
          child: const MaterialApp(home: ExportScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Import / Export'), findsOneWidget);
      expect(find.text('Export Data'), findsOneWidget);
      expect(find.text('Import Data'), findsOneWidget);
      expect(find.text('Export as CSV'), findsOneWidget);
      expect(find.text('Export as JSON'), findsOneWidget);
      expect(find.text('Import from CSV'), findsOneWidget);
      expect(find.text('Import from JSON'), findsOneWidget);
    });

    testWidgets('exports CSV successfully', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService = _FakeExportService();
      final testRecords = [
        LogRecord.create(
          logId: 'log-1',
          accountId: 'test-account',
          eventAt: DateTime(2024, 1, 1),
          eventType: EventType.vape,
          duration: 120.0,
          unit: Unit.seconds,
        ),
        LogRecord.create(
          logId: 'log-2',
          accountId: 'test-account',
          eventAt: DateTime(2024, 1, 2),
          eventType: EventType.vape,
          duration: 180.0,
          unit: Unit.seconds,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exportServiceProvider.overrideWithValue(fakeService),
            activeAccountLogRecordsProvider.overrideWith(
              (ref) => Stream.value(testRecords),
            ),
          ],
          child: const MaterialApp(home: ExportScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Export as CSV'));
      await tester.pumpAndSettle();

      expect(fakeService.exportToCsvCalls, 1);
      expect(fakeService.lastExportedRecords.length, 2);
      expect(find.text('Exported 2 records to clipboard'), findsOneWidget);
    });

    testWidgets('exports JSON successfully', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService = _FakeExportService();
      final testRecords = [
        LogRecord.create(
          logId: 'log-1',
          accountId: 'test-account',
          eventAt: DateTime(2024, 1, 1),
          eventType: EventType.vape,
          duration: 120.0,
          unit: Unit.seconds,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exportServiceProvider.overrideWithValue(fakeService),
            activeAccountLogRecordsProvider.overrideWith(
              (ref) => Stream.value(testRecords),
            ),
          ],
          child: const MaterialApp(home: ExportScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Export as JSON'));
      await tester.pumpAndSettle();

      expect(fakeService.exportToJsonCalls, 1);
      expect(fakeService.lastExportedRecords.length, 1);
      expect(
        find.text('Exported 1 records - copied to clipboard'),
        findsOneWidget,
      );
    });

    testWidgets('handles CSV export failure', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService = _FakeExportService()..shouldThrow = true;
      final testRecords = [
        LogRecord.create(
          logId: 'log-1',
          accountId: 'test-account',
          eventAt: DateTime(2024, 1, 1),
          eventType: EventType.vape,
          duration: 120.0,
          unit: Unit.seconds,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exportServiceProvider.overrideWithValue(fakeService),
            activeAccountLogRecordsProvider.overrideWith(
              (ref) => Stream.value(testRecords),
            ),
          ],
          child: const MaterialApp(home: ExportScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Export as CSV'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(fakeService.exportToCsvCalls, 1);
      expect(find.textContaining('Export failed'), findsOneWidget);
    });

    testWidgets('handles JSON export failure', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService = _FakeExportService()..shouldThrow = true;
      final testRecords = [
        LogRecord.create(
          logId: 'log-1',
          accountId: 'test-account',
          eventAt: DateTime(2024, 1, 1),
          eventType: EventType.vape,
          duration: 120.0,
          unit: Unit.seconds,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exportServiceProvider.overrideWithValue(fakeService),
            activeAccountLogRecordsProvider.overrideWith(
              (ref) => Stream.value(testRecords),
            ),
          ],
          child: const MaterialApp(home: ExportScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Export as JSON'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(fakeService.exportToJsonCalls, 1);
      expect(find.textContaining('Export failed'), findsOneWidget);
    });

    testWidgets('shows not implemented dialog for CSV import', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService = _FakeExportService();
      final testRecords = <LogRecord>[];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exportServiceProvider.overrideWithValue(fakeService),
            activeAccountLogRecordsProvider.overrideWith(
              (ref) => Stream.value(testRecords),
            ),
          ],
          child: const MaterialApp(home: ExportScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Import from CSV'));
      await tester.pumpAndSettle();

      expect(find.text('CSV Import Coming Soon'), findsOneWidget);
      expect(
        find.textContaining('This feature is planned for a future release'),
        findsOneWidget,
      );

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('CSV Import Coming Soon'), findsNothing);
    });

    testWidgets('shows not implemented dialog for JSON import', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService = _FakeExportService();
      final testRecords = <LogRecord>[];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exportServiceProvider.overrideWithValue(fakeService),
            activeAccountLogRecordsProvider.overrideWith(
              (ref) => Stream.value(testRecords),
            ),
          ],
          child: const MaterialApp(home: ExportScreen()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Import from JSON'));
      await tester.pumpAndSettle();

      expect(find.text('JSON Import Coming Soon'), findsOneWidget);
      expect(
        find.textContaining('This feature is planned for a future release'),
        findsOneWidget,
      );

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('JSON Import Coming Soon'), findsNothing);
    });

    testWidgets('CSV export is idempotent when called once', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeService = _FakeExportService();
      final testRecords = [
        LogRecord.create(
          logId: 'log-1',
          accountId: 'test-account',
          eventAt: DateTime(2024, 1, 1),
          eventType: EventType.vape,
          duration: 120.0,
          unit: Unit.seconds,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            exportServiceProvider.overrideWithValue(fakeService),
            activeAccountLogRecordsProvider.overrideWith(
              (ref) => Stream.value(testRecords),
            ),
          ],
          child: const MaterialApp(home: ExportScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Trigger export
      await tester.tap(find.text('Export as CSV'));
      await tester.pumpAndSettle();

      // Should have been called once
      expect(fakeService.exportToCsvCalls, 1);
    });
  });
}

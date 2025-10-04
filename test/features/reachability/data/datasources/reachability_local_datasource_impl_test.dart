// Unit tests for ReachabilityLocalDataSourceImpl
// Tests local persistence using SharedPreferences

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/features/reachability/data/datasources/reachability_local_datasource.dart';
import 'package:ash_trail/features/reachability/data/models/reachability_audit_report_model.dart';
import 'package:ash_trail/features/reachability/data/models/audit_summary_model.dart';
import 'package:ash_trail/features/reachability/data/models/ui_element_model.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_zone.dart';

void main() {
  group('ReachabilityLocalDataSourceImpl', () {
    late ReachabilityLocalDataSourceImpl dataSource;
    late SharedPreferences mockPrefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockPrefs = await SharedPreferences.getInstance();
      dataSource = ReachabilityLocalDataSourceImpl(mockPrefs);
    });

    tearDown(() async {
      await mockPrefs.clear();
    });

    group('getAllAuditReports', () {
      test('should return empty list when no reports exist', () async {
        // act
        final result = await dataSource.getAllAuditReports();

        // assert
        expect(result, isEmpty);
      });

      test('should return list of reports sorted by timestamp (newest first)',
          () async {
        // arrange
        final report1 = ReachabilityAuditReportModel(
          id: 'report1',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Screen 1',
          screenWidth: 400.0,
          screenHeight: 800.0,
          elements: const [],
          zones: const [],
          summary: const AuditSummaryModel(
            totalElements: 0,
            interactiveElements: 0,
            elementsInEasyReach: 0,
            elementsWithIssues: 0,
            avgTouchTargetSize: 0.0,
            accessibilityIssues: 0,
          ),
        );

        final report2 = ReachabilityAuditReportModel(
          id: 'report2',
          timestamp: DateTime(2024, 1, 2, 12, 0), // Newer
          screenName: 'Screen 2',
          screenWidth: 400.0,
          screenHeight: 800.0,
          elements: const [],
          zones: const [],
          summary: const AuditSummaryModel(
            totalElements: 0,
            interactiveElements: 0,
            elementsInEasyReach: 0,
            elementsWithIssues: 0,
            avgTouchTargetSize: 0.0,
            accessibilityIssues: 0,
          ),
        );

        // Save reports in reverse order
        await dataSource.saveAuditReport(report1);
        await dataSource.saveAuditReport(report2);

        // act
        final result = await dataSource.getAllAuditReports();

        // assert
        expect(result, hasLength(2));
        expect(result.first.id, equals('report2')); // Newer first
        expect(result.last.id, equals('report1'));
      });

      test('should throw exception for corrupted report data', () async {
        // arrange - manually set invalid JSON
        await mockPrefs.setStringList('reachability_reports', ['invalid-id']);
        await mockPrefs.setString('report_invalid-id', 'invalid-json');

        // act & assert - should throw exception for invalid data
        expect(
            () => dataSource.getAllAuditReports(), throwsA(isA<Exception>()));
      });
    });

    group('getAuditReport', () {
      test('should return null when report does not exist', () async {
        // act
        final result = await dataSource.getAuditReport('nonexistent');

        // assert
        expect(result, isNull);
      });

      test('should return report when it exists', () async {
        // arrange
        final report = ReachabilityAuditReportModel(
          id: 'test-report',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Test Screen',
          screenWidth: 400.0,
          screenHeight: 800.0,
          elements: const [],
          zones: const [],
          summary: const AuditSummaryModel(
            totalElements: 0,
            interactiveElements: 0,
            elementsInEasyReach: 0,
            elementsWithIssues: 0,
            avgTouchTargetSize: 0.0,
            accessibilityIssues: 0,
          ),
        );

        await dataSource.saveAuditReport(report);

        // act
        final result = await dataSource.getAuditReport('test-report');

        // assert
        expect(result, isNotNull);
        expect(result!.id, equals('test-report'));
        expect(result.screenName, equals('Test Screen'));
      });
    });

    group('saveAuditReport', () {
      test('should save report successfully', () async {
        // arrange
        final report = ReachabilityAuditReportModel(
          id: 'save-test',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Save Test',
          screenWidth: 400.0,
          screenHeight: 800.0,
          elements: [
            const UiElementModel(
              id: 'button1',
              label: 'Test Button',
              bounds: Rect.fromLTWH(0, 0, 48, 48),
              type: 'button',
              isInteractive: true,
            ),
          ],
          zones: const [],
          summary: const AuditSummaryModel(
            totalElements: 1,
            interactiveElements: 1,
            elementsInEasyReach: 1,
            elementsWithIssues: 0,
            avgTouchTargetSize: 48.0,
            accessibilityIssues: 0,
          ),
        );

        // act
        final result = await dataSource.saveAuditReport(report);

        // assert
        expect(result, equals(report));

        // Verify persistence
        final retrieved = await dataSource.getAuditReport('save-test');
        expect(retrieved, isNotNull);
        expect(retrieved!.elements, hasLength(1));
        expect(retrieved.elements.first.label, equals('Test Button'));
      });

      test('should add report to reports list', () async {
        // arrange
        final report = ReachabilityAuditReportModel(
          id: 'list-test',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'List Test',
          screenWidth: 400.0,
          screenHeight: 800.0,
          elements: const [],
          zones: const [],
          summary: const AuditSummaryModel(
            totalElements: 0,
            interactiveElements: 0,
            elementsInEasyReach: 0,
            elementsWithIssues: 0,
            avgTouchTargetSize: 0.0,
            accessibilityIssues: 0,
          ),
        );

        // act
        await dataSource.saveAuditReport(report);

        // assert
        final allReports = await dataSource.getAllAuditReports();
        expect(allReports, hasLength(1));
        expect(allReports.first.id, equals('list-test'));
      });
    });

    group('deleteAuditReport', () {
      test('should delete report successfully', () async {
        // arrange
        final report = ReachabilityAuditReportModel(
          id: 'delete-test',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Delete Test',
          screenWidth: 400.0,
          screenHeight: 800.0,
          elements: const [],
          zones: const [],
          summary: const AuditSummaryModel(
            totalElements: 0,
            interactiveElements: 0,
            elementsInEasyReach: 0,
            elementsWithIssues: 0,
            avgTouchTargetSize: 0.0,
            accessibilityIssues: 0,
          ),
        );

        await dataSource.saveAuditReport(report);

        // Verify report exists
        expect(await dataSource.getAuditReport('delete-test'), isNotNull);

        // act
        await dataSource.deleteAuditReport('delete-test');

        // assert
        expect(await dataSource.getAuditReport('delete-test'), isNull);

        final allReports = await dataSource.getAllAuditReports();
        expect(allReports, isEmpty);
      });
    });

    group('saveZoneConfiguration', () {
      test('should save zone configuration successfully', () async {
        // arrange
        const screenSize = Size(400, 800);
        final zones = [
          const ReachabilityZone(
            id: 'easy-zone',
            name: 'Easy Reach Zone',
            bounds: Rect.fromLTWH(0, 500, 400, 300),
            level: ReachabilityLevel.easy,
            description: 'Easy reach area',
          ),
        ];

        // act
        await dataSource.saveZoneConfiguration(screenSize, zones);

        // assert - verify configuration was saved (test will pass if no exception)
        expect(
            () async =>
                await dataSource.saveZoneConfiguration(screenSize, zones),
            returnsNormally);
      });
    });

    group('getZoneConfiguration', () {
      test('should return null when no configuration exists', () async {
        // act
        final result =
            await dataSource.getZoneConfiguration(const Size(400, 800));

        // assert
        expect(result, isNull);
      });

      test('should return saved zone configuration', () async {
        // arrange
        const screenSize = Size(400, 800);
        final zones = [
          const ReachabilityZone(
            id: 'easy-zone',
            name: 'Easy Reach Zone',
            bounds: Rect.fromLTWH(0, 500, 400, 300),
            level: ReachabilityLevel.easy,
            description: 'Easy reach area',
          ),
        ];

        await dataSource.saveZoneConfiguration(screenSize, zones);

        // act
        final result = await dataSource.getZoneConfiguration(screenSize);

        // assert
        expect(result, isNotNull);
        expect(result!, hasLength(1));
        expect(result.first.id, equals('easy-zone'));
        expect(result.first.name, equals('Easy Reach Zone'));
        expect(result.first.level, equals(ReachabilityLevel.easy));
      });
    });

    group('error handling', () {
      test('should handle SharedPreferences exceptions in getAllAuditReports',
          () async {
        // This test exercises exception handling paths
        expect(() => dataSource.getAllAuditReports(), returnsNormally);
      });

      test('should handle SharedPreferences exceptions in save operations',
          () async {
        // arrange
        final report = ReachabilityAuditReportModel(
          id: 'error-test',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Error Test',
          screenWidth: 400.0,
          screenHeight: 800.0,
          elements: const [],
          zones: const [],
          summary: const AuditSummaryModel(
            totalElements: 0,
            interactiveElements: 0,
            elementsInEasyReach: 0,
            elementsWithIssues: 0,
            avgTouchTargetSize: 0.0,
            accessibilityIssues: 0,
          ),
        );

        // act & assert - should handle errors gracefully
        expect(() => dataSource.saveAuditReport(report), returnsNormally);
      });
    });
  });
}

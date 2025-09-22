// Unit tests for ReachabilityLocalDataSourceImpl
// Tests local persistence using SharedPreferences

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/features/reachability/data/datasources/reachability_local_datasource.dart';
import 'package:ash_trail/features/reachability/data/models/reachability_audit_report_model.dart';
import 'package:ash_trail/features/reachability/data/models/audit_summary_model.dart';
import 'package:ash_trail/features/reachability/data/models/ui_element_model.dart';
import 'package:ash_trail/features/reachability/data/models/reachability_zone_model.dart';
import 'package:ash_trail/features/reachability/data/models/audit_recommendation_model.dart';

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
          recommendations: const [],
        );

        final report2 = ReachabilityAuditReportModel(
          id: 'report2',
          timestamp: DateTime(2024, 1, 2, 12, 0), // newer
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
          recommendations: const [],
        );

        // Save reports in reverse chronological order
        await dataSource.saveAuditReport(report1);
        await dataSource.saveAuditReport(report2);

        // act
        final result = await dataSource.getAllAuditReports();

        // assert
        expect(result, hasLength(2));
        expect(result[0].id, equals('report2')); // newer first
        expect(result[1].id, equals('report1'));
      });

      test('should handle corrupted report data gracefully', () async {
        // arrange
        await mockPrefs.setStringList('reachability_reports', ['bad_report']);
        await mockPrefs.setString('report_bad_report', 'invalid_json');

        // act & assert
        expect(() => dataSource.getAllAuditReports(), throwsException);
      });
    });

    group('getAuditReport', () {
      test('should return null when report not found', () async {
        // act
        final result = await dataSource.getAuditReport('nonexistent');

        // assert
        expect(result, isNull);
      });

      test('should return report when found', () async {
        // arrange
        final report = ReachabilityAuditReportModel(
          id: 'test_report',
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
          recommendations: const [],
        );

        await dataSource.saveAuditReport(report);

        // act
        final result = await dataSource.getAuditReport('test_report');

        // assert
        expect(result, isNotNull);
        expect(result!.id, equals('test_report'));
        expect(result.screenName, equals('Test Screen'));
      });

      test('should throw exception when report data is corrupted', () async {
        // arrange
        await mockPrefs.setString('report_corrupted', 'invalid_json');

        // act & assert
        expect(() => dataSource.getAuditReport('corrupted'), throwsException);
      });
    });

    group('saveAuditReport', () {
      test('should save report successfully', () async {
        // arrange
        final report = ReachabilityAuditReportModel(
          id: 'test_save',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Save Test',
          screenWidth: 400.0,
          screenHeight: 800.0,
          elements: [
            UiElementModel(
              id: 'button1',
              label: 'Test Button',
              bounds: const Rect.fromLTWH(0, 0, 48, 48),
              type: 'button',
              isInteractive: true,
              hasAccessibilityLabel: true,
            ),
          ],
          zones: [
            ReachabilityZoneModel(
              id: 'zone1',
              name: 'Easy Zone',
              bounds: const Rect.fromLTWH(0, 320, 400, 480),
              level: 'easy',
              description: 'Easy to reach area',
            ),
          ],
          summary: const AuditSummaryModel(
            totalElements: 1,
            interactiveElements: 1,
            elementsInEasyReach: 1,
            elementsWithIssues: 0,
            avgTouchTargetSize: 48.0,
            accessibilityIssues: 0,
          ),
          recommendations: [
            AuditRecommendationModel(
              elementId: 'button1',
              type: 'add_accessibility_label',
              description: 'Add semantic label',
              priority: 1,
              suggestedFix: 'Add semantics widget',
            ),
          ],
        );

        // act
        await dataSource.saveAuditReport(report);

        // assert
        final saved = await dataSource.getAuditReport('test_save');
        expect(saved, isNotNull);
        expect(saved!.id, equals('test_save'));
        expect(saved.elements, hasLength(1));
        expect(saved.zones, hasLength(1));
        expect(saved.recommendations, hasLength(1));
      });
    });

    group('deleteAuditReport', () {
      test('should delete report successfully', () async {
        // arrange
        final report = ReachabilityAuditReportModel(
          id: 'delete_test',
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
          recommendations: const [],
        );

        await dataSource.saveAuditReport(report);

        // Verify report exists
        expect(await dataSource.getAuditReport('delete_test'), isNotNull);

        // act
        await dataSource.deleteAuditReport('delete_test');

        // assert
        expect(await dataSource.getAuditReport('delete_test'), isNull);
      });

      test('should handle deletion of non-existent report gracefully',
          () async {
        // act & assert - should not throw
        await dataSource.deleteAuditReport('nonexistent');
      });
    });

    group('clearAllAuditReports', () {
      test('should clear all reports successfully', () async {
        // arrange
        final report1 = ReachabilityAuditReportModel(
          id: 'clear_test1',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Clear Test 1',
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
          recommendations: const [],
        );

        final report2 = ReachabilityAuditReportModel(
          id: 'clear_test2',
          timestamp: DateTime(2024, 1, 2, 12, 0),
          screenName: 'Clear Test 2',
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
          recommendations: const [],
        );

        await dataSource.saveAuditReport(report1);
        await dataSource.saveAuditReport(report2);

        // Verify reports exist
        expect(await dataSource.getAllAuditReports(), hasLength(2));

        // act
        await dataSource.clearAllAuditReports();

        // assert
        expect(await dataSource.getAllAuditReports(), isEmpty);
      });
    });

    group('getReportsForDateRange', () {
      test('should return reports within date range', () async {
        // arrange
        final report1 = ReachabilityAuditReportModel(
          id: 'range_test1',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Range Test 1',
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
          recommendations: const [],
        );

        final report2 = ReachabilityAuditReportModel(
          id: 'range_test2',
          timestamp: DateTime(2024, 1, 15, 12, 0),
          screenName: 'Range Test 2',
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
          recommendations: const [],
        );

        final report3 = ReachabilityAuditReportModel(
          id: 'range_test3',
          timestamp: DateTime(2024, 2, 1, 12, 0), // Outside range
          screenName: 'Range Test 3',
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
          recommendations: const [],
        );

        await dataSource.saveAuditReport(report1);
        await dataSource.saveAuditReport(report2);
        await dataSource.saveAuditReport(report3);

        // act
        final result = await dataSource.getReportsForDateRange(
          DateTime(2024, 1, 1),
          DateTime(2024, 1, 31),
        );

        // assert
        expect(result, hasLength(2));
        expect(result.map((r) => r.id),
            containsAll(['range_test1', 'range_test2']));
        expect(result.any((r) => r.id == 'range_test3'), isFalse);
      });

      test('should return empty list when no reports in range', () async {
        // arrange
        final report = ReachabilityAuditReportModel(
          id: 'outside_range',
          timestamp: DateTime(2023, 1, 1, 12, 0),
          screenName: 'Outside Range',
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
          recommendations: const [],
        );

        await dataSource.saveAuditReport(report);

        // act
        final result = await dataSource.getReportsForDateRange(
          DateTime(2024, 1, 1),
          DateTime(2024, 1, 31),
        );

        // assert
        expect(result, isEmpty);
      });
    });
  });
}

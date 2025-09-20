// Tests for ReachabilityLocalDataSource
// Tests SharedPreferences-based persistence for audit reports

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/features/reachability/data/datasources/reachability_local_datasource.dart';
import 'package:ash_trail/features/reachability/data/models/reachability_audit_report_model.dart';
import 'package:ash_trail/features/reachability/data/models/audit_summary_model.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_zone.dart';

void main() {
  group('ReachabilityLocalDataSourceImpl', () {
    late ReachabilityLocalDataSourceImpl dataSource;
    late SharedPreferences sharedPreferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
      dataSource = ReachabilityLocalDataSourceImpl(sharedPreferences);
    });

    group('getAllAuditReports', () {
      test('should return empty list when no reports exist', () async {
        final result = await dataSource.getAllAuditReports();
        expect(result, isEmpty);
      });

      test('should return all saved audit reports', () async {
        // arrange - set up mock data in SharedPreferences
        final report = ReachabilityAuditReportModel(
          id: 'test-report-1',
          timestamp: DateTime(2024, 1, 1),
          screenName: 'Test Screen',
          screenWidth: 375.0,
          screenHeight: 812.0,
          elements: const [],
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

        await dataSource.saveAuditReport(report);

        // act
        final result = await dataSource.getAllAuditReports();

        // assert
        expect(result, hasLength(1));
        expect(result.first.id, equals('test-report-1'));
      });

      test('should handle corrupted data gracefully', () async {
        // arrange - set corrupted data
        await sharedPreferences
            .setStringList('reachability_reports', ['test-id']);
        await sharedPreferences.setString(
            'reachability_report_test-id', 'invalid-json');

        // act
        final result = await dataSource.getAllAuditReports();

        // assert - should return empty list, not throw
        expect(result, isEmpty);
      });
    });

    group('getAuditReport', () {
      test('should return null when report does not exist', () async {
        final result = await dataSource.getAuditReport('non-existent');
        expect(result, isNull);
      });

      test('should return specific audit report by id', () async {
        // arrange
        final report = ReachabilityAuditReportModel(
          id: 'specific-report',
          timestamp: DateTime(2024, 2, 1),
          screenName: 'Specific Screen',
          screenWidth: 414.0,
          screenHeight: 896.0,
          elements: const [],
          zones: const [],
          summary: const AuditSummaryModel(
            totalElements: 2,
            interactiveElements: 2,
            elementsInEasyReach: 1,
            elementsWithIssues: 1,
            avgTouchTargetSize: 42.0,
            accessibilityIssues: 0,
          ),
        );

        await dataSource.saveAuditReport(report);

        // act
        final result = await dataSource.getAuditReport('specific-report');

        // assert
        expect(result, isNotNull);
        expect(result!.id, equals('specific-report'));
        expect(result.screenName, equals('Specific Screen'));
      });

      test('should handle corrupted JSON gracefully', () async {
        // arrange
        await sharedPreferences.setString(
            'reachability_report_corrupt', 'invalid-json');

        // act
        final result = await dataSource.getAuditReport('corrupt');

        // assert
        expect(result, isNull);
      });
    });

    group('saveAuditReport', () {
      test('should save audit report successfully', () async {
        // arrange
        final report = ReachabilityAuditReportModel(
          id: 'save-test',
          timestamp: DateTime(2024, 3, 1),
          screenName: 'Save Test Screen',
          screenWidth: 360.0,
          screenHeight: 640.0,
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
        final result = await dataSource.saveAuditReport(report);

        // assert
        expect(result.id, equals('save-test'));

        // Verify it was actually saved
        final retrieved = await dataSource.getAuditReport('save-test');
        expect(retrieved, isNotNull);
        expect(retrieved!.screenName, equals('Save Test Screen'));
      });

      test('should update existing report', () async {
        // arrange - save initial report
        final initialReport = ReachabilityAuditReportModel(
          id: 'update-test',
          timestamp: DateTime(2024, 3, 1),
          screenName: 'Initial Screen',
          screenWidth: 360.0,
          screenHeight: 640.0,
          elements: const [],
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

        await dataSource.saveAuditReport(initialReport);

        // act - update with new data
        final updatedReport = initialReport.copyWith(
          screenName: 'Updated Screen',
          summary: const AuditSummaryModel(
            totalElements: 2,
            interactiveElements: 2,
            elementsInEasyReach: 2,
            elementsWithIssues: 0,
            avgTouchTargetSize: 48.0,
            accessibilityIssues: 0,
          ),
        );

        await dataSource.saveAuditReport(updatedReport);

        // assert
        final retrieved = await dataSource.getAuditReport('update-test');
        expect(retrieved!.screenName, equals('Updated Screen'));
        expect(retrieved.summary.totalElements, equals(2));

        // Should still only have one report in the list
        final allReports = await dataSource.getAllAuditReports();
        expect(allReports, hasLength(1));
      });
    });

    group('deleteAuditReport', () {
      test('should delete existing audit report', () async {
        // arrange
        final report = ReachabilityAuditReportModel(
          id: 'delete-test',
          timestamp: DateTime(2024, 4, 1),
          screenName: 'Delete Test Screen',
          screenWidth: 320.0,
          screenHeight: 568.0,
          elements: const [],
          zones: const [],
          summary: const AuditSummaryModel(
            totalElements: 1,
            interactiveElements: 1,
            elementsInEasyReach: 0,
            elementsWithIssues: 1,
            avgTouchTargetSize: 32.0,
            accessibilityIssues: 0,
          ),
        );

        await dataSource.saveAuditReport(report);

        // Verify it exists
        expect(await dataSource.getAuditReport('delete-test'), isNotNull);

        // act
        await dataSource.deleteAuditReport('delete-test');

        // assert
        expect(await dataSource.getAuditReport('delete-test'), isNull);

        final allReports = await dataSource.getAllAuditReports();
        expect(allReports, isEmpty);
      });

      test('should handle deleting non-existent report gracefully', () async {
        // act & assert - should not throw
        await dataSource.deleteAuditReport('non-existent');

        final allReports = await dataSource.getAllAuditReports();
        expect(allReports, isEmpty);
      });
    });

    group('Zone Configuration', () {
      test('should save and retrieve zone configuration', () async {
        // arrange
        const screenSize = Size(375.0, 812.0);
        final zones = [
          const ReachabilityZone(
            id: 'easy',
            name: 'Easy Reach',
            bounds: Rect.fromLTWH(0, 600, 375, 212),
            level: ReachabilityLevel.easy,
            description: 'Comfortable thumb zone',
          ),
          const ReachabilityZone(
            id: 'difficult',
            name: 'Difficult Reach',
            bounds: Rect.fromLTWH(0, 0, 375, 200),
            level: ReachabilityLevel.difficult,
            description: 'Difficult to reach',
          ),
        ];

        // act
        await dataSource.saveZoneConfiguration(screenSize, zones);
        final result = await dataSource.getZoneConfiguration(screenSize);

        // assert
        expect(result, isNotNull);
        expect(result!, hasLength(2));
        expect(result.first.id, equals('easy'));
        expect(result.last.id, equals('difficult'));
      });

      test('should return null for non-existent zone configuration', () async {
        // act
        final result =
            await dataSource.getZoneConfiguration(const Size(999, 999));

        // assert
        expect(result, isNull);
      });

      test('should handle different screen sizes separately', () async {
        // arrange
        const phoneSize = Size(375.0, 812.0);
        const tabletSize = Size(768.0, 1024.0);

        final phoneZones = [
          const ReachabilityZone(
            id: 'phone-easy',
            name: 'Phone Easy',
            bounds: Rect.fromLTWH(0, 600, 375, 212),
            level: ReachabilityLevel.easy,
            description: 'Phone comfortable zone',
          ),
        ];

        final tabletZones = [
          const ReachabilityZone(
            id: 'tablet-easy',
            name: 'Tablet Easy',
            bounds: Rect.fromLTWH(0, 800, 768, 224),
            level: ReachabilityLevel.easy,
            description: 'Tablet comfortable zone',
          ),
        ];

        // act
        await dataSource.saveZoneConfiguration(phoneSize, phoneZones);
        await dataSource.saveZoneConfiguration(tabletSize, tabletZones);

        // assert
        final phoneResult = await dataSource.getZoneConfiguration(phoneSize);
        final tabletResult = await dataSource.getZoneConfiguration(tabletSize);

        expect(phoneResult![0].id, equals('phone-easy'));
        expect(tabletResult![0].id, equals('tablet-easy'));
      });
    });
  });
}

// Unit tests for ReachabilityRepositoryImpl
// Tests data layer implementation and persistence logic

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/painting.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/features/reachability/domain/entities/ui_element.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_zone.dart';
import 'package:ash_trail/features/reachability/data/repositories/reachability_repository_impl.dart';
import 'package:ash_trail/features/reachability/data/datasources/reachability_local_datasource.dart';
import 'package:ash_trail/features/reachability/data/datasources/reachability_zone_factory.dart';
import 'package:ash_trail/features/reachability/data/models/reachability_audit_report_model.dart';
import 'package:ash_trail/features/reachability/data/models/audit_summary_model.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockReachabilityLocalDataSource extends Mock
    implements ReachabilityLocalDataSource {}

class MockReachabilityZoneFactory extends Mock
    implements ReachabilityZoneFactory {}

class FakeReachabilityAuditReportModel extends Fake
    implements ReachabilityAuditReportModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeReachabilityAuditReportModel());
  });

  group('ReachabilityRepositoryImpl', () {
    late MockReachabilityLocalDataSource mockLocalDataSource;
    late MockReachabilityZoneFactory mockZoneFactory;
    late ReachabilityRepositoryImpl repository;

    setUp(() {
      mockLocalDataSource = MockReachabilityLocalDataSource();
      mockZoneFactory = MockReachabilityZoneFactory();
      repository =
          ReachabilityRepositoryImpl(mockLocalDataSource, mockZoneFactory);
    });

    group('getAllAuditReports', () {
      test('should return list of audit reports when data source succeeds',
          () async {
        // arrange
        final reportModels = [
          ReachabilityAuditReportModel(
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
          ),
        ];

        when(() => mockLocalDataSource.getAllAuditReports())
            .thenAnswer((_) async => reportModels);

        // act
        final result = await repository.getAllAuditReports();

        // assert
        expect(result.isRight(), isTrue);
        final reports = result.getRight().getOrElse(() => throw Exception());
        expect(reports, hasLength(1));
        expect(reports[0].id, equals('report1'));

        verify(() => mockLocalDataSource.getAllAuditReports()).called(1);
      });

      test('should return failure when data source throws exception', () async {
        // arrange
        when(() => mockLocalDataSource.getAllAuditReports())
            .thenThrow(Exception('Storage error'));

        // act
        final result = await repository.getAllAuditReports();

        // assert
        expect(result.isLeft(), isTrue);
        final failure = result.getLeft().getOrElse(() => throw Exception());
        expect(failure, isA<AppFailure>());
      });
    });

    group('performAudit', () {
      test('should perform complete audit and return report', () async {
        // arrange
        const screenName = 'Test Screen';
        const screenSize = Size(400, 800);
        const elements = [
          UiElement(
            id: 'test_button',
            label: 'Test Button',
            bounds: Rect.fromLTWH(100, 500, 48, 48),
            type: UiElementType.button,
            isInteractive: true,
          ),
        ];

        final testZones = [
          const ReachabilityZone(
            id: 'easy_zone',
            name: 'Easy Zone',
            bounds: Rect.fromLTWH(0, 450, 400, 350),
            level: ReachabilityLevel.easy,
            description: 'Easy to reach',
          ),
        ];

        when(() => mockZoneFactory.createZonesForScreen(screenSize))
            .thenReturn(testZones);
        when(() => mockLocalDataSource.saveAuditReport(any())).thenAnswer(
            (invocation) async => invocation.positionalArguments[0]);

        // act
        final result = await repository.performAudit(
          screenName: screenName,
          screenSize: screenSize,
          elements: elements,
        );

        // assert
        expect(result.isRight(), isTrue);
        final report = result.getRight().getOrElse(() => throw Exception());
        expect(report.screenName, equals(screenName));
        expect(report.screenSize, equals(screenSize));
        expect(report.elements, equals(elements));
        expect(report.zones, equals(testZones));
        expect(report.id, isNotEmpty);

        verify(() => mockZoneFactory.createZonesForScreen(screenSize))
            .called(1);
        verify(() => mockLocalDataSource.saveAuditReport(any())).called(1);
      });

      test('should return failure when zone generation fails', () async {
        // arrange
        const screenName = 'Test Screen';
        const screenSize = Size(400, 800);
        const elements = <UiElement>[];

        when(() => mockZoneFactory.createZonesForScreen(screenSize))
            .thenThrow(Exception('Zone generation failed'));

        // act
        final result = await repository.performAudit(
          screenName: screenName,
          screenSize: screenSize,
          elements: elements,
        );

        // assert
        expect(result.isLeft(), isTrue);
        final failure = result.getLeft().getOrElse(() => throw Exception());
        expect(failure, isA<AppFailure>());

        verify(() => mockZoneFactory.createZonesForScreen(screenSize))
            .called(1);
        verifyNever(() => mockLocalDataSource.saveAuditReport(any()));
      });
    });
  });
}

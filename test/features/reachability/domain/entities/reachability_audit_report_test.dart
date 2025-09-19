// Unit tests for ReachabilityAuditReport entity
// Tests audit report calculations and business logic

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/painting.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_audit_report.dart';
import 'package:ash_trail/features/reachability/domain/entities/ui_element.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_zone.dart';

void main() {
  group('ReachabilityAuditReport', () {
    late List<UiElement> testElements;
    late List<ReachabilityZone> testZones;
    late ReachabilityAuditReport testReport;

    setUp(() {
      testZones = [
        const ReachabilityZone(
          id: 'easy_zone',
          name: 'Easy Zone',
          bounds: Rect.fromLTWH(0, 150, 400, 300),
          level: ReachabilityLevel.easy,
          description: 'Easy to reach',
        ),
        const ReachabilityZone(
          id: 'moderate_zone',
          name: 'Moderate Zone',
          bounds: Rect.fromLTWH(0, 100, 400, 50),
          level: ReachabilityLevel.moderate,
          description: 'Moderate reach',
        ),
        const ReachabilityZone(
          id: 'difficult_zone',
          name: 'Difficult Zone',
          bounds: Rect.fromLTWH(0, 50, 400, 50),
          level: ReachabilityLevel.difficult,
          description: 'Difficult to reach',
        ),
      ];

      testElements = [
        // Easy reach element
        const UiElement(
          id: 'easy_button',
          label: 'Easy Button',
          bounds: Rect.fromLTWH(100, 200, 48, 48),
          type: UiElementType.button,
          isInteractive: true,
          semanticLabel: 'Easy button',
          hasAlternativeAccess: true,
        ),
        // Moderate reach element
        const UiElement(
          id: 'moderate_button',
          label: 'Moderate Button',
          bounds: Rect.fromLTWH(
              100, 102, 48, 48), // Y=102-150, fully in moderate zone
          type: UiElementType.button,
          isInteractive: true,
          semanticLabel: 'Moderate button',
          hasAlternativeAccess: false,
        ),
        // Difficult reach element with accessibility issues
        const UiElement(
          id: 'difficult_button',
          label: 'Difficult Button',
          bounds: Rect.fromLTWH(100, 75, 30, 30), // Too small
          type: UiElementType.button,
          isInteractive: true,
          semanticLabel: null, // Missing semantic label
          hasAlternativeAccess: false,
        ),
        // Non-interactive element
        const UiElement(
          id: 'text_label',
          label: 'Text Label',
          bounds: Rect.fromLTWH(100, 300, 100, 20),
          type: UiElementType.other,
          isInteractive: false,
        ),
      ];

      testReport = ReachabilityAuditReport(
        id: 'test_report',
        timestamp: DateTime(2024, 1, 1, 12, 0),
        screenName: 'Test Screen',
        screenSize: const Size(400, 800),
        elements: testElements,
        zones: testZones,
        summary: AuditSummary(
          totalElements: testElements.length,
          interactiveElements:
              testElements.where((e) => e.isInteractive).length,
          elementsInEasyReach: 1,
          elementsWithIssues: 2,
          avgTouchTargetSize: 40.0,
          accessibilityIssues: 2,
        ),
      );
    });

    group('Problem Elements Identification', () {
      test('should identify elements outside easy reach', () {
        // act
        final result = testReport.problemElements;

        // assert
        expect(result, hasLength(2));
        expect(result.map((e) => e.id),
            containsAll(['moderate_button', 'difficult_button']));
      });

      test('should return empty list when all elements are in easy reach', () {
        // arrange - all elements in easy reach
        final allEasyElements = [
          const UiElement(
            id: 'easy_button_1',
            label: 'Easy Button 1',
            bounds: Rect.fromLTWH(100, 200, 48, 48),
            type: UiElementType.button,
            isInteractive: true,
          ),
          const UiElement(
            id: 'easy_button_2',
            label: 'Easy Button 2',
            bounds: Rect.fromLTWH(200, 250, 48, 48),
            type: UiElementType.button,
            isInteractive: true,
          ),
        ];

        final allEasyReport = ReachabilityAuditReport(
          id: 'all_easy_report',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Test Screen',
          screenSize: const Size(400, 800),
          elements: allEasyElements,
          zones: testZones,
          summary: const AuditSummary(
            totalElements: 2,
            interactiveElements: 2,
            elementsInEasyReach: 2,
            elementsWithIssues: 0,
            avgTouchTargetSize: 48.0,
            accessibilityIssues: 0,
          ),
        );

        // act
        final result = allEasyReport.problemElements;

        // assert
        expect(result, isEmpty);
      });
    });

    group('Touch Target Issues', () {
      test('should identify elements with touch target size issues', () {
        // act
        final result = testReport.touchTargetIssues;

        // assert
        expect(result, hasLength(1));
        expect(result.first.id, equals('difficult_button'));
      });

      test(
          'should return empty list when all elements meet touch target requirements',
          () {
        // arrange - all elements have adequate touch targets
        final goodTouchTargetElements = [
          const UiElement(
            id: 'good_button_1',
            label: 'Good Button 1',
            bounds: Rect.fromLTWH(100, 200, 48, 48),
            type: UiElementType.button,
            isInteractive: true,
          ),
          const UiElement(
            id: 'good_button_2',
            label: 'Good Button 2',
            bounds: Rect.fromLTWH(200, 250, 50, 50),
            type: UiElementType.button,
            isInteractive: true,
          ),
        ];

        final goodTouchTargetReport = ReachabilityAuditReport(
          id: 'good_touch_report',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Test Screen',
          screenSize: const Size(400, 800),
          elements: goodTouchTargetElements,
          zones: testZones,
          summary: const AuditSummary(
            totalElements: 2,
            interactiveElements: 2,
            elementsInEasyReach: 1,
            elementsWithIssues: 0,
            avgTouchTargetSize: 49.0,
            accessibilityIssues: 0,
          ),
        );

        // act
        final result = goodTouchTargetReport.touchTargetIssues;

        // assert
        expect(result, isEmpty);
      });
    });

    group('Accessibility Issues', () {
      test('should identify elements with accessibility issues', () {
        // act
        final result = testReport.accessibilityIssues;

        // assert
        expect(result, hasLength(2));
        expect(result.map((e) => e.id),
            containsAll(['moderate_button', 'difficult_button']));
      });

      test('should return empty list when all elements are accessible', () {
        // arrange - all elements have proper accessibility
        final accessibleElements = [
          const UiElement(
            id: 'accessible_button_1',
            label: 'Accessible Button 1',
            bounds: Rect.fromLTWH(100, 200, 48, 48),
            type: UiElementType.button,
            isInteractive: true,
            semanticLabel: 'First accessible button',
            hasAlternativeAccess: true,
          ),
          const UiElement(
            id: 'accessible_button_2',
            label: 'Accessible Button 2',
            bounds: Rect.fromLTWH(200, 250, 48, 48),
            type: UiElementType.button,
            isInteractive: true,
            semanticLabel: 'Second accessible button',
            hasAlternativeAccess: true,
          ),
        ];

        final accessibleReport = ReachabilityAuditReport(
          id: 'accessible_report',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Test Screen',
          screenSize: const Size(400, 800),
          elements: accessibleElements,
          zones: testZones,
          summary: const AuditSummary(
            totalElements: 2,
            interactiveElements: 2,
            elementsInEasyReach: 1,
            elementsWithIssues: 0,
            avgTouchTargetSize: 48.0,
            accessibilityIssues: 0,
          ),
        );

        // act
        final result = accessibleReport.accessibilityIssues;

        // assert
        expect(result, isEmpty);
      });
    });

    group('Compliance Score Calculation', () {
      test('should calculate correct compliance score', () {
        // act
        final result = testReport.complianceScore;

        // assert
        // Only easy_button is compliant (in easy reach, good touch target, accessible)
        // 1 out of 3 interactive elements = 1/3 ≈ 0.33
        expect(result, closeTo(1.0 / 3.0, 0.01));
      });

      test('should return 1.0 for perfect compliance', () {
        // arrange - all elements compliant
        final perfectElements = [
          const UiElement(
            id: 'perfect_button',
            label: 'Perfect Button',
            bounds: Rect.fromLTWH(100, 200, 48, 48),
            type: UiElementType.button,
            isInteractive: true,
            semanticLabel: 'Perfect button',
            hasAlternativeAccess: true,
          ),
        ];

        final perfectReport = ReachabilityAuditReport(
          id: 'perfect_report',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Perfect Screen',
          screenSize: const Size(400, 800),
          elements: perfectElements,
          zones: testZones,
          summary: const AuditSummary(
            totalElements: 1,
            interactiveElements: 1,
            elementsInEasyReach: 1,
            elementsWithIssues: 0,
            avgTouchTargetSize: 48.0,
            accessibilityIssues: 0,
          ),
        );

        // act
        final result = perfectReport.complianceScore;

        // assert
        expect(result, equals(1.0));
      });

      test('should return 0.0 for worst compliance', () {
        // arrange - all elements non-compliant
        final worstElements = [
          const UiElement(
            id: 'worst_button',
            label: 'Worst Button',
            bounds:
                Rect.fromLTWH(100, 25, 20, 20), // Difficult reach, too small
            type: UiElementType.button,
            isInteractive: true,
            semanticLabel: null, // No semantic label
            hasAlternativeAccess: false,
          ),
        ];

        final worstReport = ReachabilityAuditReport(
          id: 'worst_report',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Worst Screen',
          screenSize: const Size(400, 800),
          elements: worstElements,
          zones: testZones,
          summary: const AuditSummary(
            totalElements: 1,
            interactiveElements: 1,
            elementsInEasyReach: 0,
            elementsWithIssues: 1,
            avgTouchTargetSize: 20.0,
            accessibilityIssues: 1,
          ),
        );

        // act
        final result = worstReport.complianceScore;

        // assert
        expect(result, equals(0.0));
      });
    });

    group('Audit Passing Status', () {
      test('should fail audit when compliance score is below 60%', () {
        // act
        final passesAudit = testReport.passesAudit;

        // assert
        expect(passesAudit, isFalse); // 33% compliance is below 60%
      });

      test('should pass audit when compliance score meets 60% threshold', () {
        // arrange - create report with 60% compliance
        final passingElements = [
          // 3 compliant elements
          const UiElement(
            id: 'compliant_1',
            label: 'Compliant 1',
            bounds: Rect.fromLTWH(100, 200, 48, 48),
            type: UiElementType.button,
            isInteractive: true,
            semanticLabel: 'Compliant button 1',
            hasAlternativeAccess: true,
          ),
          const UiElement(
            id: 'compliant_2',
            label: 'Compliant 2',
            bounds: Rect.fromLTWH(200, 200, 48, 48),
            type: UiElementType.button,
            isInteractive: true,
            semanticLabel: 'Compliant button 2',
            hasAlternativeAccess: true,
          ),
          const UiElement(
            id: 'compliant_3',
            label: 'Compliant 3',
            bounds: Rect.fromLTWH(300, 200, 48, 48),
            type: UiElementType.button,
            isInteractive: true,
            semanticLabel: 'Compliant button 3',
            hasAlternativeAccess: true,
          ),
          // 2 non-compliant elements
          const UiElement(
            id: 'noncompliant_1',
            label: 'Non-compliant 1',
            bounds: Rect.fromLTWH(100, 75, 20, 20),
            type: UiElementType.button,
            isInteractive: true,
          ),
          const UiElement(
            id: 'noncompliant_2',
            label: 'Non-compliant 2',
            bounds: Rect.fromLTWH(200, 75, 20, 20),
            type: UiElementType.button,
            isInteractive: true,
          ),
        ];

        final passingReport = ReachabilityAuditReport(
          id: 'passing_report',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Passing Screen',
          screenSize: const Size(400, 800),
          elements: passingElements,
          zones: testZones,
          summary: const AuditSummary(
            totalElements: 5,
            interactiveElements: 5,
            elementsInEasyReach: 3,
            elementsWithIssues: 2,
            avgTouchTargetSize: 35.2,
            accessibilityIssues: 2,
          ),
        );

        // act
        final passesAudit = passingReport.passesAudit;

        // assert
        expect(passesAudit, isTrue); // 3/5 = 60% compliance
      });
    });

    group('Report Metadata', () {
      test('should have correct report metadata', () {
        // assert
        expect(testReport.id, equals('test_report'));
        expect(testReport.timestamp, equals(DateTime(2024, 1, 1, 12, 0)));
        expect(testReport.screenName, equals('Test Screen'));
        expect(testReport.screenSize, equals(const Size(400, 800)));
      });

      test('should contain summary information', () {
        // assert
        expect(testReport.summary.totalElements, equals(4));
        expect(testReport.summary.interactiveElements, equals(3));
        expect(testReport.summary.elementsInEasyReach, equals(1));
        expect(testReport.summary.elementsWithIssues, equals(2));
        expect(testReport.summary.accessibilityIssues, equals(2));
      });
    });

    group('Edge Cases', () {
      test('should handle empty elements list', () {
        // arrange
        final emptyReport = ReachabilityAuditReport(
          id: 'empty_report',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Empty Screen',
          screenSize: const Size(400, 800),
          elements: const [],
          zones: testZones,
          summary: const AuditSummary(
            totalElements: 0,
            interactiveElements: 0,
            elementsInEasyReach: 0,
            elementsWithIssues: 0,
            avgTouchTargetSize: 0.0,
            accessibilityIssues: 0,
          ),
        );

        // act & assert
        expect(emptyReport.complianceScore,
            equals(1.0)); // Empty is considered compliant
        expect(emptyReport.passesAudit, isTrue);
        expect(emptyReport.problemElements, isEmpty);
        expect(emptyReport.touchTargetIssues, isEmpty);
        expect(emptyReport.accessibilityIssues, isEmpty);
      });

      test('should handle only non-interactive elements', () {
        // arrange
        final nonInteractiveElements = [
          const UiElement(
            id: 'text1',
            label: 'Text 1',
            bounds: Rect.fromLTWH(100, 100, 100, 20),
            type: UiElementType.other,
            isInteractive: false,
          ),
          const UiElement(
            id: 'text2',
            label: 'Text 2',
            bounds: Rect.fromLTWH(100, 200, 100, 20),
            type: UiElementType.other,
            isInteractive: false,
          ),
        ];

        final nonInteractiveReport = ReachabilityAuditReport(
          id: 'non_interactive_report',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Non-Interactive Screen',
          screenSize: const Size(400, 800),
          elements: nonInteractiveElements,
          zones: testZones,
          summary: const AuditSummary(
            totalElements: 2,
            interactiveElements: 0,
            elementsInEasyReach: 0,
            elementsWithIssues: 0,
            avgTouchTargetSize: 0.0,
            accessibilityIssues: 0,
          ),
        );

        // act & assert
        expect(nonInteractiveReport.complianceScore, equals(1.0));
        expect(nonInteractiveReport.passesAudit, isTrue);
        expect(nonInteractiveReport.problemElements, isEmpty);
        expect(nonInteractiveReport.touchTargetIssues, isEmpty);
        expect(nonInteractiveReport.accessibilityIssues, isEmpty);
      });

      test('should handle empty zones list', () {
        // arrange
        final reportWithoutZones = ReachabilityAuditReport(
          id: 'no_zones_report',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'No Zones Screen',
          screenSize: const Size(400, 800),
          elements: testElements,
          zones: const [],
          summary: const AuditSummary(
            totalElements: 4,
            interactiveElements: 3,
            elementsInEasyReach: 0,
            elementsWithIssues: 3,
            avgTouchTargetSize: 40.0,
            accessibilityIssues: 2,
          ),
        );

        // act
        final problemElements = reportWithoutZones.problemElements;

        // assert
        // All interactive elements should be problem elements since no easy zones exist
        expect(problemElements, hasLength(3));
      });
    });
  });

  group('AuditSummary', () {
    test('should create summary with correct values', () {
      // arrange
      const summary = AuditSummary(
        totalElements: 10,
        interactiveElements: 7,
        elementsInEasyReach: 5,
        elementsWithIssues: 3,
        avgTouchTargetSize: 45.5,
        accessibilityIssues: 2,
      );

      // assert
      expect(summary.totalElements, equals(10));
      expect(summary.interactiveElements, equals(7));
      expect(summary.elementsInEasyReach, equals(5));
      expect(summary.elementsWithIssues, equals(3));
      expect(summary.avgTouchTargetSize, equals(45.5));
      expect(summary.accessibilityIssues, equals(2));
    });
  });

  group('AuditRecommendation', () {
    test('should create recommendation with correct values', () {
      // arrange
      const recommendation = AuditRecommendation(
        elementId: 'test_element',
        type: RecommendationType.moveToEasyReach,
        description: 'Move this element to the easy reach zone',
        priority: 1,
        suggestedFix: 'Relocate to lower 60% of screen',
      );

      // assert
      expect(recommendation.elementId, equals('test_element'));
      expect(recommendation.type, equals(RecommendationType.moveToEasyReach));
      expect(recommendation.description,
          equals('Move this element to the easy reach zone'));
      expect(recommendation.priority, equals(1));
      expect(recommendation.suggestedFix,
          equals('Relocate to lower 60% of screen'));
    });
  });

  group('RecommendationType', () {
    test('should have correct display names', () {
      expect(RecommendationType.moveToEasyReach.displayName,
          equals('Move to Easy Reach Zone'));
      expect(RecommendationType.increaseTouchTarget.displayName,
          equals('Increase Touch Target Size'));
      expect(RecommendationType.addAccessibilityLabel.displayName,
          equals('Add Accessibility Label'));
      expect(RecommendationType.addAlternativeAccess.displayName,
          equals('Add Alternative Access'));
      expect(RecommendationType.improveContrast.displayName,
          equals('Improve Color Contrast'));
    });

    test('should have correct default priorities', () {
      expect(RecommendationType.moveToEasyReach.defaultPriority, equals(1));
      expect(RecommendationType.increaseTouchTarget.defaultPriority, equals(2));
      expect(
          RecommendationType.addAccessibilityLabel.defaultPriority, equals(2));
      expect(
          RecommendationType.addAlternativeAccess.defaultPriority, equals(3));
      expect(RecommendationType.improveContrast.defaultPriority, equals(3));
    });
  });
}

// Unit tests for UiElement entity
// Tests element validation and reachability calculations

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/reachability/domain/entities/ui_element.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_zone.dart';

void main() {
  group('UiElement', () {
    late UiElement testElement;
    late List<ReachabilityZone> testZones;

    setUp(() {
      testElement = const UiElement(
        id: 'test_element',
        label: 'Test Button',
        bounds: Rect.fromLTWH(100, 200, 48, 48),
        type: UiElementType.button,
        isInteractive: true,
        semanticLabel: 'Test button for testing',
        hasAlternativeAccess: false,
      );

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
        const ReachabilityZone(
          id: 'unreachable_zone',
          name: 'Unreachable Zone',
          bounds: Rect.fromLTWH(0, 0, 400, 50),
          level: ReachabilityLevel.unreachable,
          description: 'Unreachable',
        ),
      ];
    });

    group('isWithinEasyReach', () {
      test('should return true when element overlaps with easy reach zone', () {
        // act
        final result = testElement.isWithinEasyReach(testZones);

        // assert
        expect(result, isTrue);
      });

      test('should return false when element is outside easy reach zones', () {
        // arrange
        const elementOutsideEasyReach = UiElement(
          id: 'outside_element',
          label: 'Outside Button',
          bounds: Rect.fromLTWH(100, 25, 48, 48), // In difficult zone
          type: UiElementType.button,
          isInteractive: true,
        );

        // act
        final result = elementOutsideEasyReach.isWithinEasyReach(testZones);

        // assert
        expect(result, isFalse);
      });

      test('should return false when no easy reach zones exist', () {
        // arrange
        final zonesWithoutEasy = testZones
            .where((zone) => zone.level != ReachabilityLevel.easy)
            .toList();

        // act
        final result = testElement.isWithinEasyReach(zonesWithoutEasy);

        // assert
        expect(result, isFalse);
      });
    });

    group('getReachabilityLevel', () {
      test('should return easy level when element is in easy zone', () {
        // act
        final result = testElement.getReachabilityLevel(testZones);

        // assert
        expect(result, equals(ReachabilityLevel.easy));
      });

      test('should return moderate when element is only in moderate zone', () {
        // arrange
        const moderateElement = UiElement(
          id: 'moderate_element',
          label: 'Moderate Button',
          bounds: Rect.fromLTWH(
              100, 102, 48, 48), // Y=102-150, fully in moderate zone (100-150)
          type: UiElementType.button,
          isInteractive: true,
        );

        // act
        final result = moderateElement.getReachabilityLevel(testZones);

        // assert
        expect(result, equals(ReachabilityLevel.moderate));
      });

      test('should return unreachable when element is in no zones', () {
        // arrange
        const outsideElement = UiElement(
          id: 'outside_element',
          label: 'Outside Button',
          bounds: Rect.fromLTWH(500, 500, 48, 48), // Outside all zones
          type: UiElementType.button,
          isInteractive: true,
        );

        // act
        final result = outsideElement.getReachabilityLevel(testZones);

        // assert
        expect(result, equals(ReachabilityLevel.unreachable));
      });

      test('should return best level when element spans multiple zones', () {
        // arrange - element that spans easy and moderate zones
        const spanningElement = UiElement(
          id: 'spanning_element',
          label: 'Spanning Button',
          bounds: Rect.fromLTWH(100, 140, 48, 40), // Spans moderate and easy
          type: UiElementType.button,
          isInteractive: true,
        );

        // act
        final result = spanningElement.getReachabilityLevel(testZones);

        // assert
        expect(result, equals(ReachabilityLevel.easy)); // Best level wins
      });
    });

    group('getEasyReachCoverage', () {
      test('should return 1.0 when element is completely in easy zone', () {
        // act
        final result = testElement.getEasyReachCoverage(testZones);

        // assert
        expect(result, equals(1.0));
      });

      test('should return 0.0 when element is outside easy zones', () {
        // arrange
        const outsideElement = UiElement(
          id: 'outside_element',
          label: 'Outside Button',
          bounds: Rect.fromLTWH(100, 25, 48, 48), // In difficult zone
          type: UiElementType.button,
          isInteractive: true,
        );

        // act
        final result = outsideElement.getEasyReachCoverage(testZones);

        // assert
        expect(result, equals(0.0));
      });

      test('should return partial coverage for partially overlapping element',
          () {
        // arrange - element that partially overlaps with easy zone
        const partialElement = UiElement(
          id: 'partial_element',
          label: 'Partial Button',
          bounds: Rect.fromLTWH(
              100, 130, 48, 40), // Y=130-170: 20px in moderate, 20px in easy
          type: UiElementType.button,
          isInteractive: true,
        );

        // act
        final result = partialElement.getEasyReachCoverage(testZones);

        // assert
        expect(result, equals(0.5)); // 20/40 = 0.5
      });
    });

    group('needsAccessibilityImprovement', () {
      test(
          'should return false when element has semantic label and alternative access',
          () {
        // arrange
        const accessibleElement = UiElement(
          id: 'accessible_element',
          label: 'Accessible Button',
          bounds: Rect.fromLTWH(100, 200, 48, 48),
          type: UiElementType.button,
          isInteractive: true,
          semanticLabel: 'Accessible button',
          hasAlternativeAccess: true,
        );

        // act
        final result = accessibleElement.needsAccessibilityImprovement;

        // assert
        expect(result, isFalse);
      });

      test('should return true when interactive element has no semantic label',
          () {
        // arrange
        const elementWithoutLabel = UiElement(
          id: 'no_label_element',
          label: 'Button',
          bounds: Rect.fromLTWH(100, 200, 48, 48),
          type: UiElementType.button,
          isInteractive: true,
          hasAlternativeAccess: true,
        );

        // act
        final result = elementWithoutLabel.needsAccessibilityImprovement;

        // assert
        expect(result, isTrue);
      });

      test(
          'should return true when interactive element has empty semantic label',
          () {
        // arrange
        const elementWithEmptyLabel = UiElement(
          id: 'empty_label_element',
          label: 'Button',
          bounds: Rect.fromLTWH(100, 200, 48, 48),
          type: UiElementType.button,
          isInteractive: true,
          semanticLabel: '',
          hasAlternativeAccess: true,
        );

        // act
        final result = elementWithEmptyLabel.needsAccessibilityImprovement;

        // assert
        expect(result, isTrue);
      });

      test(
          'should return true when interactive element has no alternative access',
          () {
        // arrange
        const elementWithoutAltAccess = UiElement(
          id: 'no_alt_access_element',
          label: 'Button',
          bounds: Rect.fromLTWH(100, 200, 48, 48),
          type: UiElementType.button,
          isInteractive: true,
          semanticLabel: 'Button',
          hasAlternativeAccess: false,
        );

        // act
        final result = elementWithoutAltAccess.needsAccessibilityImprovement;

        // assert
        expect(result, isTrue);
      });

      test('should return false for non-interactive elements', () {
        // arrange
        const nonInteractiveElement = UiElement(
          id: 'text_element',
          label: 'Text Label',
          bounds: Rect.fromLTWH(100, 200, 100, 20),
          type: UiElementType.other,
          isInteractive: false,
        );

        // act
        final result = nonInteractiveElement.needsAccessibilityImprovement;

        // assert
        expect(result, isFalse);
      });
    });

    group('meetsTouchTargetSize', () {
      test('should return true for element meeting minimum size requirements',
          () {
        // act
        final result = testElement.meetsTouchTargetSize; // 48x48

        // assert
        expect(result, isTrue);
      });

      test('should return false for element smaller than minimum touch target',
          () {
        // arrange
        const smallElement = UiElement(
          id: 'small_element',
          label: 'Small Button',
          bounds: Rect.fromLTWH(100, 200, 32, 32),
          type: UiElementType.button,
          isInteractive: true,
        );

        // act
        final result = smallElement.meetsTouchTargetSize;

        // assert
        expect(result, isFalse);
      });

      test('should return false for element with one dimension too small', () {
        // arrange
        const thinElement = UiElement(
          id: 'thin_element',
          label: 'Thin Button',
          bounds: Rect.fromLTWH(100, 200, 20, 48),
          type: UiElementType.button,
          isInteractive: true,
        );

        // act
        final result = thinElement.meetsTouchTargetSize;

        // assert
        expect(result, isFalse);
      });

      test('should return true for non-interactive elements regardless of size',
          () {
        // arrange
        const smallNonInteractive = UiElement(
          id: 'small_text',
          label: 'Small Text',
          bounds: Rect.fromLTWH(100, 200, 20, 16),
          type: UiElementType.other,
          isInteractive: false,
        );

        // act
        final result = smallNonInteractive.meetsTouchTargetSize;

        // assert
        expect(result, isTrue);
      });
    });

    test('should have correct minimum touch target size constant', () {
      expect(UiElement.minTouchTargetSize, equals(48.0));
    });
  });

  group('UiElementType', () {
    test('should have correct display names', () {
      expect(UiElementType.button.displayName, equals('Button'));
      expect(UiElementType.textField.displayName, equals('Text Field'));
      expect(UiElementType.slider.displayName, equals('Slider'));
      expect(UiElementType.toggle.displayName, equals('Toggle'));
      expect(
          UiElementType.navigationItem.displayName, equals('Navigation Item'));
      expect(UiElementType.actionButton.displayName, equals('Action Button'));
      expect(UiElementType.listItem.displayName, equals('List Item'));
      expect(UiElementType.card.displayName, equals('Card'));
      expect(UiElementType.other.displayName, equals('Other'));
    });

    test('should correctly identify high priority element types', () {
      expect(UiElementType.button.isHighPriority, isTrue);
      expect(UiElementType.actionButton.isHighPriority, isTrue);
      expect(UiElementType.navigationItem.isHighPriority, isTrue);
      expect(UiElementType.textField.isHighPriority, isTrue);

      expect(UiElementType.slider.isHighPriority, isFalse);
      expect(UiElementType.toggle.isHighPriority, isFalse);
      expect(UiElementType.listItem.isHighPriority, isFalse);
      expect(UiElementType.card.isHighPriority, isFalse);
      expect(UiElementType.other.isHighPriority, isFalse);
    });
  });
}

// Unit tests for PerformReachabilityAuditUseCase
// Tests business logic for conducting reachability analysis

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/painting.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/features/reachability/domain/entities/ui_element.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_audit_report.dart';
import 'package:ash_trail/features/reachability/domain/repositories/reachability_repository.dart';
import 'package:ash_trail/features/reachability/domain/usecases/perform_reachability_audit_use_case.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockReachabilityRepository extends Mock
    implements ReachabilityRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Size(400, 800));
  });

  group('PerformReachabilityAuditUseCase', () {
    late MockReachabilityRepository mockRepository;
    late PerformReachabilityAuditUseCase usecase;
    late List<UiElement> testElements;
    late ReachabilityAuditReport expectedReport;

    setUp(() {
      mockRepository = MockReachabilityRepository();
      usecase = PerformReachabilityAuditUseCase(mockRepository);

      testElements = [
        const UiElement(
          id: 'test_button',
          label: 'Test Button',
          bounds: Rect.fromLTWH(100, 200, 48, 48),
          type: UiElementType.button,
          isInteractive: true,
          semanticLabel: 'Test button',
          hasAlternativeAccess: true,
        ),
        const UiElement(
          id: 'small_button',
          label: 'Small Button',
          bounds: Rect.fromLTWH(200, 125, 30, 30),
          type: UiElementType.button,
          isInteractive: true,
        ),
      ];

      expectedReport = ReachabilityAuditReport(
        id: 'test_report',
        timestamp: DateTime(2024, 1, 1, 12, 0),
        screenName: 'Test Screen',
        screenSize: const Size(400, 800),
        elements: testElements,
        zones: const [],
        summary: const AuditSummary(
          totalElements: 2,
          interactiveElements: 2,
          elementsInEasyReach: 1,
          elementsWithIssues: 1,
          avgTouchTargetSize: 40.0,
          accessibilityIssues: 1,
        ),
      );
    });

    group('Successful Audit', () {
      test('should return audit report when repository operation succeeds',
          () async {
        // arrange
        when(() => mockRepository.performAudit(
              screenName: any(named: 'screenName'),
              screenSize: any(named: 'screenSize'),
              elements: any(named: 'elements'),
            )).thenAnswer((_) async => Right(expectedReport));

        // act
        final result = await usecase(
          screenName: 'Test Screen',
          screenSize: const Size(400, 800),
          elements: testElements,
        );

        // assert
        expect(result.isRight(), isTrue);
        final report = result.getRight().getOrElse(() => throw Exception());

        expect(report.screenName, equals('Test Screen'));
        expect(report.screenSize, equals(const Size(400, 800)));
        expect(report.elements, equals(testElements));

        // Verify repository was called with correct parameters
        verify(() => mockRepository.performAudit(
              screenName: 'Test Screen',
              screenSize: const Size(400, 800),
              elements: testElements,
            )).called(1);
      });

      test('should pass through all parameters to repository', () async {
        // arrange
        const screenName = 'Custom Screen';
        const screenSize = Size(600, 1200);
        final customElements = [
          const UiElement(
            id: 'custom_element',
            label: 'Custom Element',
            bounds: Rect.fromLTWH(50, 100, 60, 60),
            type: UiElementType.navigationItem,
            isInteractive: true,
          ),
        ];

        final customReport = ReachabilityAuditReport(
          id: 'custom_report',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: screenName,
          screenSize: screenSize,
          elements: customElements,
          zones: const [],
          summary: const AuditSummary(
            totalElements: 1,
            interactiveElements: 1,
            elementsInEasyReach: 0,
            elementsWithIssues: 1,
            avgTouchTargetSize: 60.0,
            accessibilityIssues: 1,
          ),
        );

        when(() => mockRepository.performAudit(
              screenName: any(named: 'screenName'),
              screenSize: any(named: 'screenSize'),
              elements: any(named: 'elements'),
            )).thenAnswer((_) async => Right(customReport));

        // act
        final result = await usecase(
          screenName: screenName,
          screenSize: screenSize,
          elements: customElements,
        );

        // assert
        expect(result.isRight(), isTrue);

        verify(() => mockRepository.performAudit(
              screenName: screenName,
              screenSize: screenSize,
              elements: customElements,
            )).called(1);
      });
    });

    group('Repository Failures', () {
      test('should return failure when repository operation fails', () async {
        // arrange
        const failure = AppFailure.cache(message: 'Failed to perform audit');
        when(() => mockRepository.performAudit(
              screenName: any(named: 'screenName'),
              screenSize: any(named: 'screenSize'),
              elements: any(named: 'elements'),
            )).thenAnswer((_) async => const Left(failure));

        // act
        final result = await usecase(
          screenName: 'Test Screen',
          screenSize: const Size(400, 800),
          elements: testElements,
        );

        // assert
        expect(result.isLeft(), isTrue);
        expect(result.getLeft().getOrElse(() => throw Exception()),
            equals(failure));
      });

      test('should handle network failure', () async {
        // arrange
        const failure =
            AppFailure.network(message: 'Network error during audit');
        when(() => mockRepository.performAudit(
              screenName: any(named: 'screenName'),
              screenSize: any(named: 'screenSize'),
              elements: any(named: 'elements'),
            )).thenAnswer((_) async => const Left(failure));

        // act
        final result = await usecase(
          screenName: 'Test Screen',
          screenSize: const Size(400, 800),
          elements: testElements,
        );

        // assert
        expect(result.isLeft(), isTrue);
        final actualFailure =
            result.getLeft().getOrElse(() => throw Exception());
        expect(actualFailure, isA<AppFailure>());
        expect(actualFailure.displayMessage, contains('Network error'));
      });

      test('should handle validation failure', () async {
        // arrange
        const failure = AppFailure.validation(
          message: 'Invalid screen size',
          field: 'screenSize',
        );
        when(() => mockRepository.performAudit(
              screenName: any(named: 'screenName'),
              screenSize: any(named: 'screenSize'),
              elements: any(named: 'elements'),
            )).thenAnswer((_) async => const Left(failure));

        // act
        final result = await usecase(
          screenName: 'Test Screen',
          screenSize: Size.zero,
          elements: testElements,
        );

        // assert
        expect(result.isLeft(), isTrue);
        final actualFailure =
            result.getLeft().getOrElse(() => throw Exception());
        expect(actualFailure, isA<AppFailure>());
        expect(actualFailure.displayMessage, equals('Invalid screen size'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty elements list', () async {
        // arrange
        final emptyReport = ReachabilityAuditReport(
          id: 'empty_report',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Empty Screen',
          screenSize: const Size(400, 800),
          elements: const [],
          zones: const [],
          summary: const AuditSummary(
            totalElements: 0,
            interactiveElements: 0,
            elementsInEasyReach: 0,
            elementsWithIssues: 0,
            avgTouchTargetSize: 0.0,
            accessibilityIssues: 0,
          ),
        );

        when(() => mockRepository.performAudit(
              screenName: any(named: 'screenName'),
              screenSize: any(named: 'screenSize'),
              elements: any(named: 'elements'),
            )).thenAnswer((_) async => Right(emptyReport));

        // act
        final result = await usecase(
          screenName: 'Empty Screen',
          screenSize: const Size(400, 800),
          elements: const [],
        );

        // assert
        expect(result.isRight(), isTrue);
        final report = result.getRight().getOrElse(() => throw Exception());
        expect(report.elements, isEmpty);
      });

      test('should handle very small screen size', () async {
        // arrange
        const smallScreenSize = Size(100, 200);
        final smallScreenReport = ReachabilityAuditReport(
          id: 'small_screen_report',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Small Screen',
          screenSize: smallScreenSize,
          elements: testElements,
          zones: const [],
          summary: const AuditSummary(
            totalElements: 2,
            interactiveElements: 2,
            elementsInEasyReach: 0,
            elementsWithIssues: 2,
            avgTouchTargetSize: 40.0,
            accessibilityIssues: 1,
          ),
        );

        when(() => mockRepository.performAudit(
              screenName: any(named: 'screenName'),
              screenSize: any(named: 'screenSize'),
              elements: any(named: 'elements'),
            )).thenAnswer((_) async => Right(smallScreenReport));

        // act
        final result = await usecase(
          screenName: 'Small Screen',
          screenSize: smallScreenSize,
          elements: testElements,
        );

        // assert
        expect(result.isRight(), isTrue);
        final report = result.getRight().getOrElse(() => throw Exception());
        expect(report.screenSize, equals(smallScreenSize));
      });

      test('should handle very large elements list', () async {
        // arrange
        final manyElements = List.generate(
          100,
          (index) => UiElement(
            id: 'element_$index',
            label: 'Element $index',
            bounds: Rect.fromLTWH(
              (index % 10) * 40.0,
              (index ~/ 10) * 50.0,
              48,
              48,
            ),
            type: UiElementType.button,
            isInteractive: true,
          ),
        );

        final largeListReport = ReachabilityAuditReport(
          id: 'large_list_report',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          screenName: 'Large List Screen',
          screenSize: const Size(400, 800),
          elements: manyElements,
          zones: const [],
          summary: const AuditSummary(
            totalElements: 100,
            interactiveElements: 100,
            elementsInEasyReach: 50,
            elementsWithIssues: 50,
            avgTouchTargetSize: 48.0,
            accessibilityIssues: 100,
          ),
        );

        when(() => mockRepository.performAudit(
              screenName: any(named: 'screenName'),
              screenSize: any(named: 'screenSize'),
              elements: any(named: 'elements'),
            )).thenAnswer((_) async => Right(largeListReport));

        // act
        final result = await usecase(
          screenName: 'Large List Screen',
          screenSize: const Size(400, 800),
          elements: manyElements,
        );

        // assert
        expect(result.isRight(), isTrue);
        final report = result.getRight().getOrElse(() => throw Exception());
        expect(report.elements, hasLength(100));
      });
    });

    group('Use Case Behavior', () {
      test('should be a pure delegation to repository', () async {
        // This test ensures the use case doesn't add any business logic
        // and purely delegates to the repository

        // arrange
        when(() => mockRepository.performAudit(
              screenName: any(named: 'screenName'),
              screenSize: any(named: 'screenSize'),
              elements: any(named: 'elements'),
            )).thenAnswer((_) async => Right(expectedReport));

        // act
        final result = await usecase(
          screenName: 'Test Screen',
          screenSize: const Size(400, 800),
          elements: testElements,
        );

        // assert
        expect(result.isRight(), isTrue);

        // The use case should make exactly one call to the repository
        verify(() => mockRepository.performAudit(
              screenName: 'Test Screen',
              screenSize: const Size(400, 800),
              elements: testElements,
            )).called(1);

        // No additional calls should be made
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });
}

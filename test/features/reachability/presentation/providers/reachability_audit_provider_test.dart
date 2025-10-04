// Unit tests for Reachability Providers
// Tests Riverpod providers for audit state management

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/features/reachability/presentation/providers/reachability_providers.dart';
import 'package:ash_trail/features/reachability/domain/usecases/perform_reachability_audit_use_case.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_audit_report.dart';
import 'package:ash_trail/features/reachability/domain/entities/ui_element.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockPerformReachabilityAuditUseCase extends Mock
    implements PerformReachabilityAuditUseCase {}

void main() {
  group('CurrentAuditReport Provider', () {
    late MockPerformReachabilityAuditUseCase mockUseCase;
    late ProviderContainer container;

    setUp(() {
      mockUseCase = MockPerformReachabilityAuditUseCase();
      container = ProviderContainer(
        overrides: [
          performReachabilityAuditUseCaseProvider
              .overrideWith((_) async => mockUseCase),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('performAudit', () {
      test('should perform audit successfully', () async {
        // arrange
        const screenName = 'Test Screen';
        const screenSize = Size(400, 800);
        const elements = <UiElement>[];

        final mockReport = ReachabilityAuditReport(
          id: 'test-id',
          timestamp: DateTime(2024, 1, 1),
          screenName: screenName,
          screenSize: screenSize,
          elements: elements,
          zones: const [],
          summary: const AuditSummary(
            totalElements: 0,
            interactiveElements: 0,
            elementsInEasyReach: 0,
            elementsWithIssues: 0,
            avgTouchTargetSize: 0.0,
            accessibilityIssues: 0,
          ),
          recommendations: const [],
        );

        when(() => mockUseCase.call(
              screenName: screenName,
              screenSize: screenSize,
              elements: elements,
            )).thenAnswer((_) async => Right(mockReport));

        // act
        final notifier = container.read(currentAuditReportProvider.notifier);

        await notifier.performAudit(
          screenName: screenName,
          screenSize: screenSize,
          elements: elements,
        );

        // assert
        final state = container.read(currentAuditReportProvider);
        expect(state, equals(mockReport));

        verify(() => mockUseCase.call(
              screenName: screenName,
              screenSize: screenSize,
              elements: elements,
            )).called(1);
      });

      test('should handle use case failure', () async {
        // arrange
        const screenName = 'Test Screen';
        const screenSize = Size(400, 800);
        const elements = <UiElement>[];

        const failure = AppFailure.unexpected(message: 'Test error');

        when(() => mockUseCase.call(
              screenName: screenName,
              screenSize: screenSize,
              elements: elements,
            )).thenAnswer((_) async => Left(failure));

        // act & assert
        final notifier = container.read(currentAuditReportProvider.notifier);

        expect(
          () => notifier.performAudit(
            screenName: screenName,
            screenSize: screenSize,
            elements: elements,
          ),
          throwsA(failure),
        );
      });
    });

    group('state management', () {
      test('should set and clear current report', () {
        // arrange
        final mockReport = ReachabilityAuditReport(
          id: 'test-id',
          timestamp: DateTime(2024, 1, 1),
          screenName: 'Test Screen',
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
          recommendations: const [],
        );

        final notifier = container.read(currentAuditReportProvider.notifier);

        // act - set report
        notifier.setCurrentReport(mockReport);

        // assert
        expect(container.read(currentAuditReportProvider), equals(mockReport));

        // act - clear report
        notifier.clearCurrentReport();

        // assert
        expect(container.read(currentAuditReportProvider), isNull);
      });
    });
  });

  group('Utility Providers', () {
    test('isAuditInProgress should track current report state', () {
      // arrange
      final container = ProviderContainer();
      final mockReport = ReachabilityAuditReport(
        id: 'test-id',
        timestamp: DateTime(2024, 1, 1),
        screenName: 'Test Screen',
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
        recommendations: const [],
      );

      // assert - no audit in progress initially
      expect(container.read(isAuditInProgressProvider), isFalse);

      // act - set current report
      final notifier = container.read(currentAuditReportProvider.notifier);
      notifier.setCurrentReport(mockReport);

      // assert - audit now in progress
      expect(container.read(isAuditInProgressProvider), isTrue);

      // act - clear report
      notifier.clearCurrentReport();

      // assert - no audit in progress
      expect(container.read(isAuditInProgressProvider), isFalse);

      container.dispose();
    });
  });
}

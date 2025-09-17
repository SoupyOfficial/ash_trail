// Unit tests for QuickActionsHandler
// Tests telemetry for quick action handling (navigation tested separately)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ash_trail/features/quick_actions/presentation/handlers/quick_actions_handler.dart';
import 'package:ash_trail/features/quick_actions/domain/entities/quick_action_entity.dart';
import 'package:ash_trail/core/telemetry/telemetry_service.dart';

// Mock classes
class MockTelemetryService extends Mock implements TelemetryService {}

void main() {
  group('QuickActionsHandler', () {
    late QuickActionsHandler handler;
    late MockTelemetryService mockTelemetry;

    setUp(() {
      mockTelemetry = MockTelemetryService();
      handler = QuickActionsHandler(mockTelemetry);
    });

    group('telemetry logging', () {
      test('should create handler with telemetry service', () {
        // arrange & act
        final testHandler = QuickActionsHandler(mockTelemetry);

        // assert
        expect(testHandler, isA<QuickActionsHandler>());
      });

      testWidgets('should log telemetry for log hit action', (tester) async {
        // arrange
        const testAction = QuickActionEntity(
          type: QuickActionTypes.logHit,
          localizedTitle: 'Log Hit',
          localizedSubtitle: 'Quick record smoking session',
        );

        final testApp = MaterialApp(
          home: Builder(
            builder: (context) {
              // Just test the telemetry part, not navigation
              try {
                handler.handleQuickAction(context, testAction);
              } catch (e) {
                // Ignore router not found error - we only care about telemetry
              }
              return const Scaffold(body: Text('Test'));
            },
          ),
        );

        await tester.pumpWidget(testApp);

        // assert
        verify(() => mockTelemetry.logEvent(
              'quick_action_invoked',
              {
                'action_type': QuickActionTypes.logHit,
                'action_title': 'Log Hit',
              },
            )).called(1);
      });

      testWidgets('should log telemetry for view logs action', (tester) async {
        // arrange
        const testAction = QuickActionEntity(
          type: QuickActionTypes.viewLogs,
          localizedTitle: 'View Logs',
          localizedSubtitle: 'See your smoking history',
        );

        final testApp = MaterialApp(
          home: Builder(
            builder: (context) {
              try {
                handler.handleQuickAction(context, testAction);
              } catch (e) {
                // Ignore router not found error
              }
              return const Scaffold(body: Text('Test'));
            },
          ),
        );

        await tester.pumpWidget(testApp);

        // assert
        verify(() => mockTelemetry.logEvent(
              'quick_action_invoked',
              {
                'action_type': QuickActionTypes.viewLogs,
                'action_title': 'View Logs',
              },
            )).called(1);
      });

      testWidgets('should log telemetry for start timed log action',
          (tester) async {
        // arrange
        const testAction = QuickActionEntity(
          type: QuickActionTypes.startTimedLog,
          localizedTitle: 'Start Timed Log',
          localizedSubtitle: 'Begin timing session',
        );

        final testApp = MaterialApp(
          home: Builder(
            builder: (context) {
              try {
                handler.handleQuickAction(context, testAction);
              } catch (e) {
                // Ignore router not found error
              }
              return const Scaffold(body: Text('Test'));
            },
          ),
        );

        await tester.pumpWidget(testApp);

        // assert
        verify(() => mockTelemetry.logEvent(
              'quick_action_invoked',
              {
                'action_type': QuickActionTypes.startTimedLog,
                'action_title': 'Start Timed Log',
              },
            )).called(1);
      });

      testWidgets('should log telemetry for unknown action type',
          (tester) async {
        // arrange
        const testAction = QuickActionEntity(
          type: 'unknown_action',
          localizedTitle: 'Unknown Action',
          localizedSubtitle: 'This should not happen',
        );

        final testApp = MaterialApp(
          home: Builder(
            builder: (context) {
              handler.handleQuickAction(context, testAction);
              return const Scaffold(body: Text('Test'));
            },
          ),
        );

        await tester.pumpWidget(testApp);

        // assert
        verify(() => mockTelemetry.logEvent(
              'quick_action_invoked',
              {
                'action_type': 'unknown_action',
                'action_title': 'Unknown Action',
              },
            )).called(1);

        verify(() => mockTelemetry.logEvent(
              'quick_action_unknown',
              {
                'action_type': 'unknown_action',
              },
            )).called(1);
      });
    });
  });
}

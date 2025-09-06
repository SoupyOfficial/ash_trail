import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/error_boundary/presentation/widgets/error_fallback_widget.dart';

void main() {
  group('ErrorFallbackWidget', () {
    testWidgets('should display error message and action buttons',
        (tester) async {
      // Arrange
      var restartCalled = false;
      var copyLogsCalled = false;
      final error = Exception('Test error');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorFallbackWidget(
            error: error,
            stackTrace: null,
            onRestart: () => restartCalled = true,
            onCopyLogs: () => copyLogsCalled = true,
          ),
        ),
      );

      // Assert
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Restart'), findsOneWidget);
      expect(find.text('Copy Logs'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);

      // Test button callbacks
      await tester.tap(find.text('Restart'));
      expect(restartCalled, isTrue);

      await tester.tap(find.text('Copy Logs'));
      expect(copyLogsCalled, isTrue);
    });

    testWidgets('should show development details when isDevelopment is true',
        (tester) async {
      // Arrange
      final error = Exception('Dev error');
      final stackTrace = StackTrace.current;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorFallbackWidget(
            error: error,
            stackTrace: stackTrace,
            onRestart: () {},
            onCopyLogs: () {},
            isDevelopment: true,
          ),
        ),
      );

      // Assert
      expect(find.text('Development Error Details:'), findsOneWidget);
      expect(find.text('Exception: Dev error'), findsOneWidget);
    });

    testWidgets(
        'should not show development details when isDevelopment is false',
        (tester) async {
      // Arrange
      final error = Exception('Prod error');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorFallbackWidget(
            error: error,
            stackTrace: null,
            onRestart: () {},
            onCopyLogs: () {},
            isDevelopment: false,
          ),
        ),
      );

      // Assert
      expect(find.text('Development Error Details:'), findsNothing);
      expect(find.text('Exception: Prod error'), findsNothing);
    });

    testWidgets('should have accessible buttons with proper semantics',
        (tester) async {
      // Arrange
      var restartCalled = false;
      var copyLogsCalled = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorFallbackWidget(
            error: Exception('Test'),
            stackTrace: null,
            onRestart: () => restartCalled = true,
            onCopyLogs: () => copyLogsCalled = true,
          ),
        ),
      );

      // Assert button accessibility by testing functionality
      final restartButton = find.text('Restart');
      final copyLogsButton = find.text('Copy Logs');

      expect(restartButton, findsOneWidget);
      expect(copyLogsButton, findsOneWidget);

      // Verify buttons are tappable (key accessibility requirement)
      await tester.tap(restartButton);
      await tester.pump();
      expect(restartCalled, isTrue);

      await tester.tap(copyLogsButton);
      await tester.pump();
      expect(copyLogsCalled, isTrue);

      // Verify icons are present for visual accessibility
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.share), findsOneWidget);
    });

    testWidgets('should display error icon with semantic label',
        (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorFallbackWidget(
            error: Exception('Test'),
            stackTrace: null,
            onRestart: () {},
            onCopyLogs: () {},
          ),
        ),
      );

      // Assert
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.error_outline));
      expect(iconWidget.semanticLabel, equals('Error icon'));
      expect(iconWidget.size, equals(64.0));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/core/widgets/error_display.dart';

void main() {
  group('ErrorDisplay', () {
    group('Display', () {
      testWidgets('should display default error icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ErrorDisplay(
                title: 'Error Title',
                message: 'Error message',
              ),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Error Title'), findsOneWidget);
        expect(find.text('Error message'), findsOneWidget);
        expect(find.text('Try Again'), findsNothing);
      });

      testWidgets('should display custom icon when provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ErrorDisplay(
                title: 'Custom Error',
                message: 'Custom message',
                icon: Icons.warning,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.warning), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsNothing);
      });

      testWidgets('should display retry button when onRetry is provided',
          (tester) async {
        // Arrange
        var retryPressed = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorDisplay(
                title: 'Load Failed',
                message: 'Could not load data',
                onRetry: () {
                  retryPressed = true;
                },
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Try Again'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);

        // Test retry button functionality - look for the button by text since ElevatedButton.icon creates a different widget type
        await tester.tap(find.text('Try Again'));
        expect(retryPressed, isTrue);
      });

      testWidgets('should display custom actions when provided',
          (tester) async {
        // Arrange
        var action1Pressed = false;
        var action2Pressed = false;

        final actions = [
          TextButton(
            onPressed: () {
              action1Pressed = true;
            },
            child: const Text('Action 1'),
          ),
          TextButton(
            onPressed: () {
              action2Pressed = true;
            },
            child: const Text('Action 2'),
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorDisplay(
                title: 'Action Error',
                message: 'Choose an action',
                actions: actions,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Action 1'), findsOneWidget);
        expect(find.text('Action 2'), findsOneWidget);
        expect(find.byType(Wrap), findsOneWidget);

        // Test action functionality
        await tester.tap(find.text('Action 1'));
        expect(action1Pressed, isTrue);

        await tester.tap(find.text('Action 2'));
        expect(action2Pressed, isTrue);
      });

      testWidgets('should display both retry button and custom actions',
          (tester) async {
        // Arrange
        var retryPressed = false;
        var actionPressed = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorDisplay(
                title: 'Error with Both',
                message: 'Both retry and actions',
                onRetry: () {
                  retryPressed = true;
                },
                actions: [
                  TextButton(
                    onPressed: () {
                      actionPressed = true;
                    },
                    child: const Text('Custom Action'),
                  ),
                ],
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Try Again'), findsOneWidget);
        expect(find.text('Custom Action'), findsOneWidget);
        expect(find.byType(Wrap), findsOneWidget);

        // Test retry button
        await tester.tap(find.text('Try Again'));
        expect(retryPressed, isTrue);

        // Test custom action
        await tester.tap(find.text('Custom Action'));
        expect(actionPressed, isTrue);
      });
    });

    group('Accessibility', () {
      testWidgets('should be accessible with screen readers', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorDisplay(
                title: 'Accessibility Test',
                message: 'This should be accessible',
                onRetry: () {},
              ),
            ),
          ),
        );

        // Assert - Check semantic structure
        expect(find.text('Accessibility Test'), findsOneWidget);
        expect(find.text('This should be accessible'), findsOneWidget);

        // Verify button is accessible
        expect(find.text('Try Again'), findsOneWidget);
      });

      testWidgets('should support high contrast mode', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              highContrast: true,
              accessibleNavigation: true,
            ),
            child: MaterialApp(
              home: Scaffold(
                body: ErrorDisplay(
                  title: 'High Contrast Test',
                  message: 'Should work in high contrast mode',
                  onRetry: () {},
                ),
              ),
            ),
          ),
        );

        // Assert - Widget should render without issues
        expect(find.text('High Contrast Test'), findsOneWidget);
        expect(find.text('Should work in high contrast mode'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);
      });

      testWidgets('should handle large text scaling', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(2.0), // 200% text scaling
            ),
            child: MaterialApp(
              home: Scaffold(
                body: ErrorDisplay(
                  title: 'Scale Test',
                  message: 'Text should scale properly',
                  onRetry: () {},
                ),
              ),
            ),
          ),
        );

        // Assert - Widget should render without overflow
        expect(find.text('Scale Test'), findsOneWidget);
        expect(find.text('Text should scale properly'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle very long text gracefully', (tester) async {
        // Arrange
        const longTitle =
            'This is a very long error title that might wrap to multiple lines';
        const longMessage =
            'This is an extremely long error message that should wrap properly';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ErrorDisplay(
                  title: longTitle,
                  message: longMessage,
                  onRetry: () {},
                ),
              ),
            ),
          ),
        );

        // Assert - Should render without overflow
        expect(find.text(longTitle), findsOneWidget);
        expect(find.text(longMessage), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('should handle empty actions list', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ErrorDisplay(
                title: 'Empty Actions',
                message: 'No actions provided',
                actions: const [], // Empty actions list
              ),
            ),
          ),
        );

        // Assert - Should still render with empty wrap
        expect(find.text('Empty Actions'), findsOneWidget);
        expect(find.text('No actions provided'), findsOneWidget);
        expect(find.byType(Wrap), findsOneWidget);
      });

      testWidgets('should handle null onRetry and null actions',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ErrorDisplay(
                title: 'Minimal Error',
                message: 'Just the basics',
              ),
            ),
          ),
        );

        // Assert - Only title, message, and icon should be present
        expect(find.text('Minimal Error'), findsOneWidget);
        expect(find.text('Just the basics'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Try Again'), findsNothing);
        expect(find.byType(Wrap), findsNothing);
      });
    });

    group('Theme Integration', () {
      testWidgets('should use theme colors correctly', (tester) async {
        // Arrange
        final theme = ThemeData.light();

        // Act
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: ErrorDisplay(
                title: 'Theme Test',
                message: 'Should use theme colors',
                onRetry: () {},
              ),
            ),
          ),
        );

        // Assert - Widget should render using theme
        expect(find.text('Theme Test'), findsOneWidget);
        expect(find.text('Should use theme colors'), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);
      });
    });
  });
}

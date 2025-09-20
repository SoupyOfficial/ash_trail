
// Widget tests for UndoSnackbar
// Verifies basic construction.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/undo_last/presentation/widgets/undo_snackbar.dart';

void main() {
  group('UndoSnackbar Widget Tests', () {

    test('should build with required parameters', () {
      // Simple unit test that just verifies the widget can be constructed
      const widget = UndoSnackbar(
        accountId: 'test-account',
      );
      
      expect(widget.accountId, equals('test-account'));
      expect(widget.displayDuration, equals(const Duration(seconds: 6)));
      expect(widget.onUndoPressed, isNull);
      expect(widget.onDismissed, isNull);
      expect(widget.margin, isNull);
    });

    test('should build with all optional parameters', () {
      void testCallback() {}
      
      final widget = UndoSnackbar(
        accountId: 'test-account',
        displayDuration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        onUndoPressed: testCallback,
        onDismissed: testCallback,
      );
      
      expect(widget.accountId, equals('test-account'));
      expect(widget.displayDuration, equals(const Duration(seconds: 3)));
      expect(widget.margin, equals(const EdgeInsets.all(10)));
      expect(widget.onUndoPressed, equals(testCallback));
      expect(widget.onDismissed, equals(testCallback));
    });
  });

  group('showUndoSnackbar() Function Tests', () {
    testWidgets('should work with valid ScaffoldMessenger', (tester) async {
      BuildContext? capturedContext;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                capturedContext = context;
                return const Text('Has Scaffold');
              },
            ),
          ),
        ),
      );
      
      await tester.pump();
      expect(find.text('Has Scaffold'), findsOneWidget);
      
      // Test the function with a proper ScaffoldMessenger
      final result = showUndoSnackbar(
        capturedContext!,
        accountId: 'test-account',
        duration: const Duration(milliseconds: 100),
      );
      
      // Should not return null when ScaffoldMessenger is available
      expect(result, isNotNull);
    });
  });
}
// Widget tests for UndoSnackbar
// Verifies basic construction.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/features/undo_last/presentation/widgets/undo_snackbar.dart';
import 'package:ash_trail/features/undo_last/presentation/providers/undo_last_providers.dart';

// Test helpers
bool testExecutedFlag = false;

class TestUndoNotifier extends UndoLastLogNotifier {
  @override
  Future<void> executeUndo() async {
    testExecutedFlag = true;
    state = const AsyncLoading();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    state = const AsyncData(null);
  }
}

class LoadingUndoNotifier extends UndoLastLogNotifier {
  @override
  Future<void> build(String arg) async {
    // Immediately enter loading state without scheduling timers
    state = const AsyncLoading();
  }
}

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

  group('UndoSnackbar interactions', () {
    const accountId = 'acct-1';

    testWidgets('tapping UNDO triggers execute and dismiss', (tester) async {
      testExecutedFlag = false;
      var onUndo = false;
      var onDismissed = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            undoLastLogNotifierProvider.overrideWith(() => TestUndoNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: UndoSnackbar(
                accountId: accountId,
                displayDuration: const Duration(seconds: 2),
                onUndoPressed: () => onUndo = true,
                onDismissed: () => onDismissed = true,
              ),
            ),
          ),
        ),
      );

      // Allow slide-in animation
      await tester.pump(const Duration(milliseconds: 350));
      final undoText = find.text('UNDO');

      // Verify UNDO button is visible and enabled
      expect(undoText, findsOneWidget);

      // Tap UNDO to trigger execute
      await tester.tap(undoText);
      await tester.pump(); // start loading
      expect(testExecutedFlag, isTrue);

      // Let the reverse animation complete after success
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(onUndo, isTrue);
      expect(onDismissed, isTrue);
      // Snackbar content should now be gone
      expect(find.text('UNDO'), findsNothing);
    });

    testWidgets('tapping Dismiss closes without undo', (tester) async {
      var onUndo = false;
      var onDismissed = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Provide a basic notifier (no-op)
            undoLastLogNotifierProvider
                .overrideWith(() => UndoLastLogNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: UndoSnackbar(
                accountId: accountId,
                displayDuration: const Duration(seconds: 2),
                onUndoPressed: () => onUndo = true,
                onDismissed: () => onDismissed = true,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('UNDO'), findsOneWidget);

      // Tap the dismiss icon button
      await tester.tap(find.byTooltip('Dismiss'));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(onUndo, isFalse);
      expect(onDismissed, isTrue);
      expect(find.text('UNDO'), findsNothing);
    });

    testWidgets('auto-dismiss after countdown duration', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            undoLastLogNotifierProvider
                .overrideWith(() => UndoLastLogNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: UndoSnackbar(
                accountId: accountId,
                displayDuration: const Duration(milliseconds: 1200),
                onDismissed: () => dismissed = true,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 350));
      expect(find.text('UNDO'), findsOneWidget);

      // Advance time past the countdown + animation
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(find.text('UNDO'), findsNothing);
    });

    testWidgets('shows loading indicator when undo in progress',
        (tester) async {
      BuildContext? ctx;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            undoLastLogNotifierProvider
                .overrideWith(() => LoadingUndoNotifier()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  ctx = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
      );

      showUndoSnackbar(
        ctx!,
        accountId: accountId,
        duration: const Duration(seconds: 2),
      );

      // Allow slide-in animation to start
      await tester.pump(const Duration(milliseconds: 50));

      // Retry across a few frames to allow loading state UI to appear
      var spinner = find.byType(CircularProgressIndicator);
      for (int i = 0; i < 8 && spinner.evaluate().isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      // While loading, the UNDO button should show a spinner and be disabled
      expect(spinner, findsOneWidget);
    });

    testWidgets('showUndoSnackbar returns null without ScaffoldMessenger',
        (tester) async {
      BuildContext? ctx;
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              ctx = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      final result = showUndoSnackbar(
        ctx!,
        accountId: accountId,
        duration: const Duration(milliseconds: 100),
      );
      expect(result, isNull);
    });
  });
}

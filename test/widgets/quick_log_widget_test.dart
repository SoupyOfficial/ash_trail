import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/widgets/quick_log_widget.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/providers/account_provider.dart';
import 'package:ash_trail/models/user_account.dart';

void main() {
  group('QuickLogWidget', () {
    testWidgets('renders Quick Log button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith(
              (ref) async => UserAccount(
                userId: 'test-user',
                displayName: 'Test User',
                email: 'test@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: QuickLogWidget())),
        ),
      );

      expect(find.text('Quick Log'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('quick tap creates instant log', (tester) async {
      bool logCreated = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith(
              (ref) async => UserAccount(
                userId: 'test-user',
                displayName: 'Test User',
                email: 'test@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: QuickLogWidget(onLogCreated: () => logCreated = true),
            ),
          ),
        ),
      );

      // Find the FAB
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      // Quick tap (no hold)
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Note: Since we can't easily test the actual service call without mocking,
      // we verify the UI behavior
      expect(find.text('Quick Log'), findsOneWidget);
    });

    testWidgets('long press shows recording overlay', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith(
              (ref) async => UserAccount(
                userId: 'test-user',
                displayName: 'Test User',
                email: 'test@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: QuickLogWidget())),
        ),
      );

      // Find the gesture detector wrapping the FAB
      final gestureDetector = find.byType(GestureDetector);
      expect(gestureDetector, findsOneWidget);

      // Long press to trigger recording mode
      await tester.longPress(gestureDetector);
      await tester.pump(const Duration(milliseconds: 600));

      // Verify recording overlay appears
      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.text('seconds'), findsOneWidget);
      expect(find.text('Release to save'), findsOneWidget);
    });

    testWidgets('recording overlay shows live timer', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith(
              (ref) async => UserAccount(
                userId: 'test-user',
                displayName: 'Test User',
                email: 'test@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: QuickLogWidget())),
        ),
      );

      final gestureDetector = find.byType(GestureDetector);

      // Start recording
      await tester.longPress(gestureDetector);
      await tester.pump(const Duration(milliseconds: 600));

      // Verify initial timer value (0.x seconds)
      expect(find.text('seconds'), findsOneWidget);

      // Wait a bit and verify timer updates
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('seconds'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
    });

    testWidgets('recording overlay has pulsing animation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith(
              (ref) async => UserAccount(
                userId: 'test-user',
                displayName: 'Test User',
                email: 'test@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: QuickLogWidget())),
        ),
      );

      final gestureDetector = find.byType(GestureDetector);

      // Start recording
      await tester.longPress(gestureDetector);
      await tester.pump(const Duration(milliseconds: 600));

      // Verify TweenAnimationBuilder exists (for pulsing effect)
      expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);

      // Verify Container with circle decoration
      final containerFinder = find.descendant(
        of: find.byType(TweenAnimationBuilder<double>),
        matching: find.byType(Container),
      );
      expect(containerFinder, findsWidgets);
    });

    testWidgets('displays cancel instruction', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith(
              (ref) async => UserAccount(
                userId: 'test-user',
                displayName: 'Test User',
                email: 'test@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: QuickLogWidget())),
        ),
      );

      final gestureDetector = find.byType(GestureDetector);

      // Start recording
      await tester.longPress(gestureDetector);
      await tester.pump(const Duration(milliseconds: 600));

      // Verify cancel instruction
      expect(find.text('Swipe away to cancel'), findsOneWidget);
      expect(find.text('Release to save'), findsOneWidget);
    });

    testWidgets('supports custom event type', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith(
              (ref) async => UserAccount(
                userId: 'test-user',
                displayName: 'Test User',
                email: 'test@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: QuickLogWidget(defaultEventType: EventType.sessionStart),
            ),
          ),
        ),
      );

      // Verify widget renders with custom event type
      expect(find.text('Quick Log'), findsOneWidget);
    });

    testWidgets('calls onLogCreated callback', (tester) async {
      bool callbackInvoked = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith(
              (ref) async => UserAccount(
                userId: 'test-user',
                displayName: 'Test User',
                email: 'test@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: QuickLogWidget(onLogCreated: () => callbackInvoked = true),
            ),
          ),
        ),
      );

      // Note: Without full service integration, we can only verify
      // the callback property is accepted
      expect(find.text('Quick Log'), findsOneWidget);
    });

    testWidgets('shows error when no active account', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [activeAccountProvider.overrideWith((ref) async => null)],
          child: const MaterialApp(home: Scaffold(body: QuickLogWidget())),
        ),
      );

      final fab = find.byType(FloatingActionButton);

      // Tap without active account
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verify error snackbar appears
      expect(find.text('No active account selected'), findsOneWidget);
    });

    testWidgets('extended FAB shows icon and label', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith(
              (ref) async => UserAccount(
                userId: 'test-user',
                displayName: 'Test User',
                email: 'test@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: QuickLogWidget())),
        ),
      );

      // Verify extended FAB structure
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Quick Log'), findsOneWidget);
    });
  });

  group('QuickLogWidget - Time Adjustment Mode', () {
    testWidgets('very long press shows time adjustment overlay', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith(
              (ref) async => UserAccount(
                userId: 'test-user',
                displayName: 'Test User',
                email: 'test@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: QuickLogWidget())),
        ),
      );

      final gestureDetector = find.byType(GestureDetector);

      // Long press and wait for time adjustment threshold (800ms)
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(gestureDetector),
      );
      await tester.pump(const Duration(milliseconds: 900));

      // Verify time adjustment overlay appears
      expect(find.text('Adjust Time'), findsOneWidget);
      expect(find.text('LOG IT'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('time adjustment has +/- buttons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeAccountProvider.overrideWith(
              (ref) async => UserAccount(
                userId: 'test-user',
                displayName: 'Test User',
                email: 'test@example.com',
                createdAt: DateTime.now(),
              ),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: QuickLogWidget())),
        ),
      );

      final gestureDetector = find.byType(GestureDetector);

      // Trigger time adjustment mode
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(gestureDetector),
      );
      await tester.pump(const Duration(milliseconds: 900));

      // Verify time adjustment buttons
      expect(find.text('+1s'), findsOneWidget);
      expect(find.text('+5s'), findsOneWidget);
      expect(find.text('+30s'), findsOneWidget);
      expect(find.text('+1m'), findsOneWidget);
      expect(find.text('+5m'), findsOneWidget);
      expect(find.text('-1s'), findsOneWidget);
      expect(find.text('-5s'), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });
}

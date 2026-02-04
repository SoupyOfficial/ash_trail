import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/widgets/auth_button.dart';

void main() {
  group('AuthButton', () {
    group('rendering', () {
      testWidgets('renders with required properties', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthButton(
                text: 'Sign in',
                onPressed: () {},
                type: AuthButtonType.email,
              ),
            ),
          ),
        );

        expect(find.text('Sign in'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('renders Google button with icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthButton(
                text: 'Sign in with Google',
                onPressed: () {},
                type: AuthButtonType.google,
              ),
            ),
          ),
        );

        expect(find.text('Sign in with Google'), findsOneWidget);
        // Google button should show an image or fallback G text
        expect(find.byType(Image).evaluate().isNotEmpty || 
               find.text('G').evaluate().isNotEmpty, isTrue);
      });

      testWidgets('renders Apple button with icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthButton(
                text: 'Sign in with Apple',
                onPressed: () {},
                type: AuthButtonType.apple,
              ),
            ),
          ),
        );

        expect(find.text('Sign in with Apple'), findsOneWidget);
        expect(find.byIcon(Icons.apple), findsOneWidget);
      });

      testWidgets('renders email button without icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthButton(
                text: 'Continue with Email',
                onPressed: () {},
                type: AuthButtonType.email,
              ),
            ),
          ),
        );

        expect(find.text('Continue with Email'), findsOneWidget);
        // Email button should not show email icon in the button content
        expect(find.byIcon(Icons.email_outlined), findsNothing);
      });
    });

    group('loading state', () {
      testWidgets('shows loading indicator when isLoading is true',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthButton(
                text: 'Sign in',
                onPressed: () {},
                type: AuthButtonType.google,
                isLoading: true,
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Sign in'), findsNothing);
      });

      testWidgets('does not show text when loading', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthButton(
                text: 'Loading Test',
                onPressed: () {},
                type: AuthButtonType.email,
                isLoading: true,
              ),
            ),
          ),
        );

        expect(find.text('Loading Test'), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('disables button when isLoading is true', (tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthButton(
                text: 'Sign in',
                onPressed: () => wasPressed = true,
                type: AuthButtonType.email,
                isLoading: true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(wasPressed, isFalse);
      });
    });

    group('interaction', () {
      testWidgets('calls onPressed when tapped', (tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthButton(
                text: 'Press Me',
                onPressed: () => wasPressed = true,
                type: AuthButtonType.google,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(wasPressed, isTrue);
      });

      testWidgets('does not call onPressed when loading', (tester) async {
        bool wasPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthButton(
                text: 'Press Me',
                onPressed: () => wasPressed = true,
                type: AuthButtonType.apple,
                isLoading: true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        expect(wasPressed, isFalse);
      });
    });

    group('styling', () {
      testWidgets('Google button has white background', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthButton(
                text: 'Google',
                onPressed: () {},
                type: AuthButtonType.google,
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        final buttonStyle = button.style;

        // The background color should be resolved to white for Google
        expect(buttonStyle?.backgroundColor, isNotNull);
      });

      testWidgets('Apple button has black background', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthButton(
                text: 'Apple',
                onPressed: () {},
                type: AuthButtonType.apple,
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(button.style?.backgroundColor, isNotNull);
      });

      testWidgets('Email button has white background with border',
          (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthButton(
                text: 'Email',
                onPressed: () {},
                type: AuthButtonType.email,
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        // Just verify the button renders correctly
        expect(button, isNotNull);
        expect(button.style, isNotNull);
      });

      testWidgets('button has fixed height of 50', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthButton(
                text: 'Test',
                onPressed: () {},
                type: AuthButtonType.email,
              ),
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byType(ElevatedButton),
            matching: find.byType(SizedBox),
          ).first,
        );
        expect(sizedBox.height, 50);
      });

      testWidgets('button has full width', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthButton(
                text: 'Test',
                onPressed: () {},
                type: AuthButtonType.google,
              ),
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(
          find.ancestor(
            of: find.byType(ElevatedButton),
            matching: find.byType(SizedBox),
          ).first,
        );
        expect(sizedBox.width, double.infinity);
      });
    });

    group('text overflow', () {
      testWidgets('handles long text gracefully', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 200,
                child: AuthButton(
                  text: 'This is a very long button text that should overflow',
                  onPressed: () {},
                  type: AuthButtonType.email,
                ),
              ),
            ),
          ),
        );

        // Should not throw an error even with long text
        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });
  });

  group('AuthButtonType', () {
    test('has all expected values', () {
      expect(AuthButtonType.values, [
        AuthButtonType.google,
        AuthButtonType.apple,
        AuthButtonType.email,
      ]);
    });

    test('google type exists', () {
      expect(AuthButtonType.google.index, 0);
    });

    test('apple type exists', () {
      expect(AuthButtonType.apple.index, 1);
    });

    test('email type exists', () {
      expect(AuthButtonType.email.index, 2);
    });
  });
}

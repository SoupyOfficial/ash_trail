// Comprehensive app tests for Ash Trail
// Run with: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/main.dart';
import 'package:ash_trail/providers/auth_provider.dart';
import 'package:ash_trail/providers/account_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class _FakeUser extends Fake implements firebase_auth.User {
  @override
  final String uid;

  _FakeUser({required this.uid});
}

void main() {
  testWidgets('App initializes and shows home screen', (
    WidgetTester tester,
  ) async {
    // Build the app with mocked auth
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(_FakeUser(uid: 'test-user')),
          ),
          activeAccountProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const AshTrailApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify app loads - should show WelcomeScreen since no active account
    expect(find.textContaining('Ash Trail'), findsOneWidget);
  });

  testWidgets('App has proper Material 3 theming', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(
            (ref) => Stream.value(_FakeUser(uid: 'test-user')),
          ),
          activeAccountProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: const AshTrailApp(),
      ),
    );

    await tester.pumpAndSettle();

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, true);
    expect(app.darkTheme?.useMaterial3, true);
  });
}

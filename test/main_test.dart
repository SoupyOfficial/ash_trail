import 'package:ash_trail/main.dart';
import 'package:ash_trail/providers/account_provider.dart';
import 'package:ash_trail/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeUser extends Fake implements firebase_auth.User {
  @override
  final String uid;

  _FakeUser({required this.uid});
}

void main() {
  group('AshTrailApp', () {
    testWidgets('renders MaterialApp with correct theme', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: AshTrailApp()));
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, 'Ash Trail');
      expect(materialApp.debugShowCheckedModeBanner, false);
      expect(materialApp.themeMode, ThemeMode.system);
    });

    testWidgets('has proper Material 3 theming', (tester) async {
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
  });

  group('AuthWrapper', () {
    testWidgets('shows loading indicator while auth is loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: const MaterialApp(home: AuthWrapper()),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows loading indicator while account is loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream.value(_FakeUser(uid: 'test-user')),
            ),
            activeAccountProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: const MaterialApp(home: AuthWrapper()),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows WelcomeScreen when no active account', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream.value(_FakeUser(uid: 'test-user')),
            ),
            activeAccountProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: const MaterialApp(home: AuthWrapper()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('shows error message on auth error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream.error(Exception('Auth error')),
            ),
          ],
          child: const MaterialApp(home: AuthWrapper()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('unexpected error'), findsOneWidget);
    });

    testWidgets('shows error message on account error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => Stream.value(_FakeUser(uid: 'test-user')),
            ),
            activeAccountProvider.overrideWith(
              (ref) => Stream.error(Exception('Account error')),
            ),
          ],
          child: const MaterialApp(home: AuthWrapper()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('unexpected error'), findsOneWidget);
    });
  });

  group('WelcomeScreen', () {
    testWidgets('renders welcome UI', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
      );

      await tester.pumpAndSettle();

      expect(find.text('Welcome to Ash Trail'), findsOneWidget);
      expect(find.text('Track your sessions with ease'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('navigates to login screen on Sign In tap', (tester) async {
      tester.view.physicalSize = const Size(1400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Check that we navigated away from welcome screen
      expect(find.text('Welcome to Ash Trail'), findsNothing);
    });
  });
}

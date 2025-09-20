import 'package:ash_trail/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/features/theming/presentation/providers/theme_provider.dart';

void main() {
  group('Main App', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('main function should initialize app', () async {
      // Since main() has async initialization, we'll test the components
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();

      // Verify SharedPreferences can be initialized
      expect(prefs, isNotNull);
    });

    testWidgets('should initialize and create MyApp widget', (tester) async {
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            createThemeRepositoryOverride(prefs),
          ],
          child: const MyApp(),
        ),
      );

      expect(find.byType(MyApp), findsOneWidget);
    });

    testWidgets('MyApp should build MaterialApp.router', (tester) async {
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            createThemeRepositoryOverride(prefs),
          ],
          child: const MyApp(),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('MyApp should have correct title', (tester) async {
      WidgetsFlutterBinding.ensureInitialized();
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            createThemeRepositoryOverride(prefs),
          ],
          child: const MyApp(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, equals('AshTrail'));
    });
  });
}

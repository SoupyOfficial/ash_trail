// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ash_trail/main.dart';
import 'package:ash_trail/features/theming/presentation/providers/theme_provider.dart';

void main() {
  testWidgets('Home screen renders', (tester) async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          createThemeRepositoryOverride(prefs),
        ],
        child: const MyApp(),
      ),
    );

    // Shell no longer has explicit AppBar title; just ensure home content present.
    expect(find.text('Home'), findsWidgets); // label + body text
  });
}

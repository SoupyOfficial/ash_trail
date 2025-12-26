// Comprehensive app tests for Ash Trail
// Run with: flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/main.dart';

void main() {
  testWidgets('App initializes and shows home screen', (
    WidgetTester tester,
  ) async {
    // Build the app
    await tester.pumpWidget(const ProviderScope(child: AshTrailApp()));

    await tester.pumpAndSettle();

    // Verify app loads
    expect(find.text('Ash Trail'), findsOneWidget);
  });

  testWidgets('App has proper Material 3 theming', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AshTrailApp()));

    await tester.pumpAndSettle();

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.theme?.useMaterial3, true);
    expect(app.darkTheme?.useMaterial3, true);
  });
}

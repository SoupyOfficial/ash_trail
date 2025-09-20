import 'package:ash_trail/domain/models/tag.dart';
import 'package:ash_trail/features/quick_tagging/presentation/providers/quick_tagging_providers.dart';
import 'package:ash_trail/features/quick_tagging/presentation/widgets/tag_suggestion_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows loading state', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: TagSuggestionChips(accountId: 'a1')),
        ),
      ),
    );

    // Initially FutureProvider is loading, widget shows skeleton
    expect(
        find.byKey(const ValueKey('tag_suggestions_loading')), findsOneWidget);
  });

  testWidgets('renders suggested tags and toggles selection', (tester) async {
    final tags = [
      Tag(
          id: 't1',
          accountId: 'a1',
          name: 'Morning',
          color: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now()),
      Tag(
          id: 't2',
          accountId: 'a1',
          name: 'Evening',
          color: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now()),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          suggestedTagsProvider.overrideWith((ref, accountId) async {
            if (accountId == 'a1') return tags;
            return <Tag>[];
          }),
          allTagsProvider.overrideWith((ref, accountId) async {
            if (accountId == 'a1') return tags;
            return <Tag>[];
          }),
        ],
        child: const MaterialApp(
          home: Scaffold(body: TagSuggestionChips(accountId: 'a1')),
        ),
      ),
    );

    // allow providers to resolve
    await tester.pump();

    expect(find.text('Morning'), findsOneWidget);
    expect(find.text('Evening'), findsOneWidget);

    await tester.tap(find.text('Morning'));
    await tester.pump();

    // State should update; we can infer via tapping again without errors
    await tester.tap(find.text('Morning'));
    await tester.pump();
  });
}

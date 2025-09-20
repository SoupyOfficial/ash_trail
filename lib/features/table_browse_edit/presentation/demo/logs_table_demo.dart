// Demo/example usage of the Logs Table Browse + Edit feature
// This demonstrates how to navigate to the table and basic usage

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Example screen showing how to navigate to the logs table
class LogsTableDemo extends ConsumerWidget {
  const LogsTableDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs Table Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Logs Table Browse + Edit Feature',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            const Text(
              'Features implemented:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            const _FeatureList(features: [
              '✅ Sort by date, duration, mood, physical scores',
              '✅ Filter by date range, method, tags, mood/physical scores',
              '✅ Inline edit duration and notes with validation',
              '✅ iOS swipe actions (Delete, Edit) on rows',
              '✅ Multi-select with batch operations',
              '✅ Pagination with configurable page sizes',
              '✅ Pull-to-refresh functionality',
              '✅ Clean Architecture with offline-first patterns',
              '✅ Comprehensive state management with Riverpod',
            ]),

            const SizedBox(height: 24),

            const Text(
              'Architecture:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            const _FeatureList(features: [
              '🏗️ Domain Layer: Pure business logic with entities and use cases',
              '💾 Data Layer: Repository pattern with offline-first storage',
              '🎨 Presentation Layer: Riverpod providers and responsive widgets',
              '🔄 State Management: Comprehensive table state with selection',
              '📱 Responsive Design: Works on phones, tablets, and desktop',
            ]),

            const SizedBox(height: 32),

            // Navigation button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _navigateToLogsTable(context),
                icon: const Icon(Icons.table_view),
                label: const Text('Open Logs Table'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Note: Replace "demo-account-id" with actual account ID in production',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to the logs table screen
  void _navigateToLogsTable(BuildContext context) {
    // In a real app, you would get the actual account ID from authentication
    const accountId = 'demo-account-id';

    context.go('/logs/table/$accountId');
  }
}

/// Simple widget to display a feature list
class _FeatureList extends StatelessWidget {
  final List<String> features;

  const _FeatureList({
    super.key,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  feature,
                  style: const TextStyle(fontSize: 14),
                ),
              ))
          .toList(),
    );
  }
}

/// Example of how to use the table programmatically
class LogsTableUsageExamples {
  /// Example: Navigate to table with specific account
  static void navigateToTable(BuildContext context, String accountId) {
    context.go('/logs/table/$accountId');
  }

  /// Example: Navigate to table and set initial filters (future enhancement)
  static void navigateToTableWithFilter(
      BuildContext context, String accountId) {
    // This could be enhanced to pass filter parameters via query parameters
    context.go('/logs/table/$accountId?filter=today');
  }

  /// Example: How providers would be used in other features
  static Widget buildTableStatusWidget(String accountId) {
    return Consumer(
      builder: (context, ref, child) {
        final tableState =
            ref.watch(logsTableStateProviderForAccountId(accountId));

        return Text('Total logs: ${tableState?.totalLogs ?? 0}');
      },
    );
  }
}

/// Helper provider for accessing table state from other features
final logsTableStateProviderForAccountId =
    Provider.family<LogsTableState?, String>(
  (ref, accountId) {
    // This would be implemented to provide access to table state
    // from other parts of the app if needed
    return null; // Placeholder
  },
);

// Fake class for the example above - would reference actual provider
class LogsTableState {
  final int totalLogs;
  const LogsTableState({required this.totalLogs});
}

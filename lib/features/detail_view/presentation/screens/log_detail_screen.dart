// Log Detail Screen - Shows full metadata and history for a specific log
// Acceptance criteria: Open from table to view full metadata and history

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/log_detail_entity.dart';
import '../providers/log_detail_providers.dart';
import '../widgets/detail_card.dart';
import '../widgets/actions_row.dart';
import '../../../../core/widgets/loading_skeleton.dart';
import '../../../../core/widgets/error_display.dart';

/// Screen that displays detailed information about a specific smoke log
class LogDetailScreen extends ConsumerWidget {
  final String logId;

  const LogDetailScreen({
    super.key,
    required this.logId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logDetailAsync = ref.watch(logDetailNotifierProvider(logId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Log $logId'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Refresh button in app bar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _handleRefresh(ref),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: logDetailAsync.when(
        data: (logDetail) => _buildContent(context, ref, logDetail),
        loading: () => _buildLoading(),
        error: (error, stackTrace) => _buildError(context, ref, error),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, LogDetailEntity logDetail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main detail card
          DetailCard(logDetail: logDetail),

          const SizedBox(height: 16),

          // Actions row
          ActionsRow(
            logDetail: logDetail,
            onRefresh: () => _handleRefresh(ref),
            onEdit: () => _handleEdit(context, logDetail),
            onShare: () => _handleShare(context, logDetail),
          ),

          const SizedBox(height: 24),

          // Additional metadata section
          _buildMetadataSection(context, logDetail),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          LoadingSkeleton(height: 200),
          SizedBox(height: 16),
          LoadingSkeleton(height: 60),
          SizedBox(height: 16),
          LoadingSkeleton(height: 120),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ErrorDisplay(
          title: 'Failed to Load Log Details',
          message: error.toString(),
          onRetry: () => _handleRefresh(ref),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataSection(
      BuildContext context, LogDetailEntity logDetail) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technical Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildMetadataRow('Log ID', logDetail.log.id),
            _buildMetadataRow('Account ID', logDetail.log.accountId),
            _buildMetadataRow('Created', logDetail.formattedTimestamp),
            if (logDetail.log.notes?.isNotEmpty == true)
              _buildMetadataRow('Notes', logDetail.log.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  void _handleRefresh(WidgetRef ref) {
    ref.read(logDetailNotifierProvider(logId).notifier).refresh();
  }

  void _handleEdit(BuildContext context, LogDetailEntity logDetail) {
    // TODO: Navigate to edit screen when implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit log ${logDetail.log.id}'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _handleShare(BuildContext context, LogDetailEntity logDetail) {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share log ${logDetail.log.id}'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}

// Detail Card Widget - Displays log metadata and history
// Shows comprehensive information about a smoke log

import 'package:flutter/material.dart';
import '../../domain/entities/log_detail_entity.dart';

/// Card widget that displays detailed information about a smoke log
class DetailCard extends StatelessWidget {
  final LogDetailEntity logDetail;

  const DetailCard({
    super.key,
    required this.logDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with timestamp and duration
            _buildHeader(context),

            const SizedBox(height: 16),

            // Main log information
            _buildMainInfo(context),

            const SizedBox(height: 16),

            // Tags section
            if (logDetail.tags.isNotEmpty) _buildTagsSection(context),

            const SizedBox(height: 16),

            // Reasons section
            if (logDetail.reasons.isNotEmpty) _buildReasonsSection(context),

            const SizedBox(height: 16),

            // Method section
            if (logDetail.method != null) _buildMethodSection(context),

            // Scores section
            const SizedBox(height: 16),
            _buildScoresSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smoke Log',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              logDetail.formattedDuration,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTimestamp(logDetail.log.ts),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              _formatTime(logDetail.log.ts),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMainInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (logDetail.log.notes?.isNotEmpty == true) ...[
          Text(
            'Notes',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withOpacity(0.5),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              logDetail.log.notes!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: logDetail.tags
              .map((tag) => Chip(
                    label: Text(tag.name),
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildReasonsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reasons',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: logDetail.reasons
              .map((reason) => Chip(
                    label: Text(reason.name),
                    backgroundColor:
                        Theme.of(context).colorScheme.secondaryContainer,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMethodSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Method',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            logDetail.method!.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoresSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wellbeing Scores',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildScoreCard(
                context,
                'Mood',
                logDetail.log.moodScore,
                logDetail.moodScoreDescription,
                Icons.mood,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildScoreCard(
                context,
                'Physical',
                logDetail.log.physicalScore,
                logDetail.physicalScoreDescription,
                Icons.fitness_center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreCard(
    BuildContext context,
    String label,
    int? score,
    String description,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            score?.toString() ?? 'N/A',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day.toString().padLeft(2, '0')}/'
        '${timestamp.month.toString().padLeft(2, '0')}/'
        '${timestamp.year}';
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

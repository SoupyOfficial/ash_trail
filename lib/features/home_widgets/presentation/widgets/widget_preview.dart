// Widget preview component showing how the widget will appear on home screen.
// Respects theming and displays actual data that will be shown.

import 'package:flutter/material.dart';
import '../../domain/entities/widget_size.dart';
import '../../domain/entities/widget_tap_action.dart';

class WidgetPreview extends StatelessWidget {
  const WidgetPreview({
    required this.size,
    required this.tapAction,
    required this.showStreak,
    required this.showLastSync,
    required this.todayHitCount,
    required this.currentStreak,
    required this.lastSyncAt,
    super.key,
  });

  final WidgetSize size;
  final WidgetTapAction tapAction;
  final bool showStreak;
  final bool showLastSync;
  final int todayHitCount;
  final int currentStreak;
  final DateTime lastSyncAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: _getPreviewWidth(size),
      height: _getPreviewHeight(size),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);

    switch (size) {
      case WidgetSize.small:
        return _buildSmallWidgetContent(theme);
      case WidgetSize.medium:
        return _buildMediumWidgetContent(theme);
      case WidgetSize.large:
        return _buildLargeWidgetContent(theme);
      case WidgetSize.extraLarge:
        return _buildExtraLargeWidgetContent(theme);
    }
  }

  Widget _buildSmallWidgetContent(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$todayHitCount',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'today',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildMediumWidgetContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_fire_department,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'AshTrail',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$todayHitCount hits',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'today',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            if (showStreak && currentStreak > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$currentStreak day${currentStreak != 1 ? 's' : ''}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'streak',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLargeWidgetContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_fire_department,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'AshTrail',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Hit Count Section
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Text(
                '$todayHitCount',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'hits today',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Streak and Last Sync Row
        Row(
          children: [
            if (showStreak && currentStreak > 0) ...[
              Icon(
                Icons.trending_up,
                color: theme.colorScheme.secondary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '$currentStreak day streak',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const Spacer(),
            if (showLastSync) ...[
              Icon(
                Icons.sync,
                color: theme.colorScheme.outline,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                _formatLastSync(lastSyncAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildExtraLargeWidgetContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with app name and action
        Row(
          children: [
            Icon(
              Icons.local_fire_department,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AshTrail',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  tapAction.displayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Stats row
        Row(
          children: [
            // Hit Count
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$todayHitCount',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'hits today',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (showStreak && currentStreak > 0) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$currentStreak',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'day streak',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),

        if (showLastSync) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.sync,
                color: theme.colorScheme.outline,
                size: 12,
              ),
              const SizedBox(width: 4),
              Text(
                'Last sync: ${_formatLastSync(lastSyncAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatLastSync(DateTime lastSync) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  double _getPreviewWidth(WidgetSize size) {
    return switch (size) {
      WidgetSize.small => 160,
      WidgetSize.medium => 320,
      WidgetSize.large => 320,
      WidgetSize.extraLarge => 320,
    };
  }

  double _getPreviewHeight(WidgetSize size) {
    return switch (size) {
      WidgetSize.small => 160,
      WidgetSize.medium => 160,
      WidgetSize.large => 320,
      WidgetSize.extraLarge => 160,
    };
  }
}

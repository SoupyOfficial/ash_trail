// Actions Row Widget - Provides action buttons for log detail view
// Contains refresh, edit, and share actions

import 'package:flutter/material.dart';
import '../../domain/entities/log_detail_entity.dart';

/// Row of action buttons for the log detail screen
class ActionsRow extends StatelessWidget {
  final LogDetailEntity logDetail;
  final VoidCallback onRefresh;
  final VoidCallback onEdit;
  final VoidCallback onShare;

  const ActionsRow({
    super.key,
    required this.logDetail,
    required this.onRefresh,
    required this.onEdit,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Refresh action
            _buildActionButton(
              context,
              icon: Icons.refresh,
              label: 'Refresh',
              onPressed: onRefresh,
              tooltip: 'Refresh log data from server',
            ),

            // Edit action
            _buildActionButton(
              context,
              icon: Icons.edit,
              label: 'Edit',
              onPressed: onEdit,
              tooltip: 'Edit this log',
            ),

            // Share action
            _buildActionButton(
              context,
              icon: Icons.share,
              label: 'Share',
              onPressed: onShare,
              tooltip: 'Share this log',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

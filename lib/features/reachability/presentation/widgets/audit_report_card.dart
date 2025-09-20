// Audit report card widget
// Displays summary information about a reachability audit report

import 'package:flutter/material.dart';
import '../../domain/entities/reachability_audit_report.dart';

class AuditReportCard extends StatelessWidget {
  const AuditReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.onDelete,
  });

  final ReachabilityAuditReport report;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final complianceScore = (report.complianceScore * 100).round();
    final passesAudit = report.passesAudit;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.screenName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(report.timestamp),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete report',
                      iconSize: 20,
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: passesAudit
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$complianceScore%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: passesAudit ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatChip(
                    icon: Icons.widgets_outlined,
                    label: '${report.summary.totalElements} elements',
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    icon: Icons.touch_app_outlined,
                    label: '${report.summary.interactiveElements} interactive',
                    color: Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatChip(
                    icon: Icons.check_circle_outline,
                    label: '${report.summary.elementsInEasyReach} in easy reach',
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  if (report.summary.elementsWithIssues > 0)
                    _StatChip(
                      icon: Icons.warning_outlined,
                      label: '${report.summary.elementsWithIssues} issues',
                      color: Colors.orange,
                    ),
                ],
              ),
              if (report.recommendations?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${report.recommendations!.length} recommendations',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.amber[700],
                      ),
                    ),
                  ],
                ),
              ],
              if (!passesAudit) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.warning,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Below recommended accessibility threshold',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
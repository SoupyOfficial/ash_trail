import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/log_record.dart';
import '../models/enums.dart';
import '../providers/log_record_provider.dart';

/// Widget to display a list of log records
class LogRecordList extends ConsumerWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final bool includeDeleted;

  const LogRecordList({
    super.key,
    this.startDate,
    this.endDate,
    this.includeDeleted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountId = ref.watch(activeAccountIdProvider);

    if (accountId == null) {
      return const Center(child: Text('No active account'));
    }

    final params = LogRecordsParams(
      accountId: accountId,
      startDate: startDate,
      endDate: endDate,
      includeDeleted: includeDeleted,
    );

    final recordsStream = ref.watch(logRecordsProvider(params));

    return recordsStream.when(
      data: (records) {
        if (records.isEmpty) {
          return const Center(child: Text('No log entries yet'));
        }

        return ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return LogRecordTile(record: record);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

/// Individual log record tile
class LogRecordTile extends ConsumerWidget {
  final LogRecord record;

  const LogRecordTile({super.key, required this.record});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: _buildEventIcon(),
        title: Row(
          children: [
            Expanded(child: Text(_formatEventType(record.eventType))),
            if (record.hasLocation)
              Icon(
                Icons.location_on,
                size: 16,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatEventTime(record.eventAt)),
            if (record.duration > 0 && record.unit != Unit.none)
              Text(
                '${_formatDuration(record.duration, record.unit)} ${_formatUnit(record.unit)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            if (record.note != null && record.note!.isNotEmpty)
              Text(
                record.note!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: _buildSyncStatusIcon(),
        onTap: () => _showRecordDetails(context, ref),
      ),
    );
  }

  Widget _buildEventIcon() {
    IconData iconData;
    Color color;

    switch (record.eventType) {
      case EventType.inhale:
        iconData = Icons.air;
        color = Colors.blue;
        break;
      case EventType.sessionStart:
        iconData = Icons.play_circle;
        color = Colors.green;
        break;
      case EventType.sessionEnd:
        iconData = Icons.stop_circle;
        color = Colors.red;
        break;
      case EventType.note:
        iconData = Icons.note;
        color = Colors.orange;
        break;
      case EventType.purchase:
        iconData = Icons.shopping_cart;
        color = Colors.purple;
        break;
      case EventType.tolerance:
        iconData = Icons.trending_up;
        color = Colors.amber;
        break;
      case EventType.symptomRelief:
        iconData = Icons.healing;
        color = Colors.teal;
        break;
      default:
        iconData = Icons.circle;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.2),
      child: Icon(iconData, color: color),
    );
  }

  Widget? _buildSyncStatusIcon() {
    switch (record.syncState) {
      case SyncState.pending:
        return const Icon(Icons.sync, color: Colors.orange, size: 20);
      case SyncState.syncing:
        return const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncState.synced:
        return const Icon(Icons.cloud_done, color: Colors.green, size: 20);
      case SyncState.error:
        return const Icon(Icons.error, color: Colors.red, size: 20);
      case SyncState.conflict:
        return const Icon(Icons.warning, color: Colors.amber, size: 20);
    }
  }

  String _formatEventType(EventType type) {
    final name = type.name;
    final result = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return result[0].toUpperCase() + result.substring(1);
  }

  String _formatEventTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, y h:mm a').format(time);
    }
  }

  String _formatUnit(Unit unit) {
    switch (unit) {
      case Unit.seconds:
        return 's';
      case Unit.minutes:
        return 'min';
      case Unit.hits:
        return 'hits';
      case Unit.mg:
        return 'mg';
      case Unit.grams:
        return 'g';
      case Unit.ml:
        return 'ml';
      case Unit.count:
        return '';
      case Unit.none:
        return '';
    }
  }

  String _formatDuration(double duration, Unit unit) {
    // For duration values (seconds/minutes), show decimal precision
    if (unit == Unit.seconds || unit == Unit.minutes) {
      return duration.toStringAsFixed(1);
    }
    // For count-based values, show as integer if whole number
    if (duration == duration.roundToDouble()) {
      return duration.toInt().toString();
    }
    // Otherwise show with one decimal place
    return duration.toStringAsFixed(1);
  }

  void _showRecordDetails(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(_formatEventType(record.eventType)),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow(
                    'Time',
                    DateFormat('MMM d, y h:mm a').format(record.eventAt),
                  ),
                  if (record.duration > 0)
                    _buildDetailRow(
                      'Duration',
                      '${_formatDuration(record.duration, record.unit)} ${_formatUnit(record.unit)}',
                    ),
                  if (record.note != null && record.note!.isNotEmpty)
                    _buildDetailRow('Note', record.note!),
                  if (record.moodRating != null)
                    _buildDetailRow(
                      'Mood',
                      '${record.moodRating!.toStringAsFixed(1)}/10',
                    ),
                  if (record.physicalRating != null)
                    _buildDetailRow(
                      'Physical',
                      '${record.physicalRating!.toStringAsFixed(1)}/10',
                    ),
                  if (record.reasons != null && record.reasons!.isNotEmpty)
                    _buildDetailRow(
                      'Reasons',
                      record.reasons!.map((r) => r.displayName).join(', '),
                    ),
                  if (record.latitude != null && record.longitude != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          'Location',
                          'Lat: ${record.latitude!.toStringAsFixed(6)}\nLon: ${record.longitude!.toStringAsFixed(6)}',
                        ),
                        const SizedBox(height: 4),
                        TextButton.icon(
                          onPressed: () {
                            // Open in maps - you can customize this URL
                            final url =
                                'https://www.google.com/maps/search/?api=1&query=${record.latitude},${record.longitude}';
                            // For now just show a snackbar - you'd need url_launcher for actual opening
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Map URL: $url')),
                            );
                          },
                          icon: const Icon(Icons.map, size: 16),
                          label: const Text(
                            'View on Map',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  _buildDetailRow('Status', record.syncState.name),
                  _buildDetailRow(
                    'Created',
                    DateFormat('MMM d, y h:mm a').format(record.createdAt),
                  ),
                  if (record.updatedAt != record.createdAt)
                    _buildDetailRow(
                      'Updated',
                      DateFormat('MMM d, y h:mm a').format(record.updatedAt),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              if (!record.isDeleted)
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    final service = ref.read(logRecordServiceProvider);
                    await service.deleteLogRecord(record);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Entry deleted')),
                      );
                    }
                  },
                  child: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/log_record.dart';

/// Widget that displays a live clock showing time since the last log entry
/// Updates every second to show elapsed time
class TimeSinceLastHitWidget extends ConsumerStatefulWidget {
  final List<LogRecord> records;

  const TimeSinceLastHitWidget({super.key, required this.records});

  @override
  ConsumerState<TimeSinceLastHitWidget> createState() =>
      _TimeSinceLastHitWidgetState();
}

class _TimeSinceLastHitWidgetState
    extends ConsumerState<TimeSinceLastHitWidget> {
  Timer? _timer;
  Duration? _timeSinceLastHit;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(TimeSinceLastHitWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart timer if records changed
    if (oldWidget.records != widget.records) {
      _updateTimeSinceLastHit();
    }
  }

  void _startTimer() {
    _updateTimeSinceLastHit();
    // Update every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        _updateTimeSinceLastHit();
      }
    });
  }

  void _updateTimeSinceLastHit() {
    if (widget.records.isEmpty) {
      setState(() => _timeSinceLastHit = null);
      return;
    }

    // Find the most recent log entry
    final sortedRecords =
        widget.records.toList()..sort((a, b) => b.eventAt.compareTo(a.eventAt));
    final mostRecentRecord = sortedRecords.first;

    setState(() {
      _timeSinceLastHit = DateTime.now().difference(mostRecentRecord.eventAt);
    });
  }

  String _formatDuration(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_timeSinceLastHit == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                'No entries yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Time since last hit will appear here',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.timer,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Time Since Last Hit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _formatDuration(_timeSinceLastHit!),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

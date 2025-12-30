import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/enums.dart';
import '../services/log_record_service.dart';
import '../providers/account_provider.dart';
import '../providers/log_record_provider.dart';

/// Minimal quick-log widget for home screen
/// Features:
/// - Press-and-hold to record duration (acts as submit on release)
/// - Mood rating slider (1-10, optional)
/// - Physical rating slider (1-10, optional)
/// - Reason filter chips (multi-select)
/// - Hard-coded: eventType = vape, unit = seconds
class HomeQuickLogWidget extends ConsumerStatefulWidget {
  final VoidCallback? onLogCreated;

  const HomeQuickLogWidget({super.key, this.onLogCreated});

  @override
  ConsumerState<HomeQuickLogWidget> createState() => _HomeQuickLogWidgetState();
}

class _HomeQuickLogWidgetState extends ConsumerState<HomeQuickLogWidget> {
  // Duration recording state
  bool _isRecording = false;
  DateTime? _recordingStartTime;
  Timer? _recordingTimer;
  Duration _recordedDuration = Duration.zero;

  // Form state
  double? _moodRating;
  double? _physicalRating;
  final Set<LogReason> _selectedReasons = {};

  void _handleLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isRecording = true;
      _recordingStartTime = DateTime.now();
      _recordedDuration = Duration.zero;
    });

    // Update duration every 100ms while recording
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      if (_recordingStartTime != null && mounted) {
        setState(() {
          _recordedDuration = DateTime.now().difference(_recordingStartTime!);
        });
      }
    });
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _recordingTimer?.cancel();
    if (_isRecording && _recordingStartTime != null) {
      final durationMs =
          DateTime.now().difference(_recordingStartTime!).inMilliseconds;
      _createVapeLog(durationMs);
      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
        _recordedDuration = Duration.zero;
      });
    }
  }

  void _handleTapCancel() {
    _recordingTimer?.cancel();
    if (_isRecording && mounted) {
      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
        _recordedDuration = Duration.zero;
      });
    }
  }

  Future<void> _createVapeLog(int durationMs) async {
    final activeAccount = await ref.read(activeAccountProvider.future);
    if (activeAccount == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active account selected')),
        );
      }
      return;
    }

    final service = LogRecordService();

    try {
      // Check minimum threshold
      if (durationMs < 1000) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Duration too short (minimum 1 second)'),
              duration: Duration(seconds: 1),
            ),
          );
        }
        return;
      }

      final durationSeconds = durationMs / 1000.0;

      final record = await service.createLogRecord(
        accountId: activeAccount.userId,
        eventType: EventType.vape,
        duration: durationSeconds,
        unit: Unit.seconds,
        moodRating: _moodRating,
        physicalRating: _physicalRating,
        reasons: _selectedReasons.isNotEmpty ? _selectedReasons.toList() : null,
      );

      if (mounted) {
        final durationStr = durationSeconds.toStringAsFixed(1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged vape (${durationStr}s)'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () async {
                await service.deleteLogRecord(record);
              },
            ),
          ),
        );

        // Reset form
        setState(() {
          _moodRating = null;
          _physicalRating = null;
          _selectedReasons.clear();
        });

        widget.onLogCreated?.call();
        ref.invalidate(activeAccountLogRecordsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleReason(LogReason reason) {
    setState(() {
      if (_selectedReasons.contains(reason)) {
        _selectedReasons.remove(reason);
      } else {
        _selectedReasons.add(reason);
      }
    });
  }

  void _resetMoodRating() {
    setState(() {
      _moodRating = null;
    });
  }

  void _resetPhysicalRating() {
    setState(() {
      _physicalRating = null;
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mood', style: Theme.of(context).textTheme.labelMedium),
                if (_moodRating != null)
                  TextButton(
                    onPressed: _resetMoodRating,
                    child: const Text('Reset'),
                  ),
              ],
            ),
            if (_moodRating != null)
              Text(
                _moodRating!.toStringAsFixed(0),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            Slider(
              value: _moodRating ?? 5.5,
              min: 1,
              max: 10,
              divisions: 9,
              label: (_moodRating ?? 5.5).toStringAsFixed(0),
              onChanged: (value) {
                setState(() {
                  _moodRating = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Physical Rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Physical',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                if (_physicalRating != null)
                  TextButton(
                    onPressed: _resetPhysicalRating,
                    child: const Text('Reset'),
                  ),
              ],
            ),
            if (_physicalRating != null)
              Text(
                _physicalRating!.toStringAsFixed(0),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            Slider(
              value: _physicalRating ?? 5.5,
              min: 1,
              max: 10,
              divisions: 9,
              label: (_physicalRating ?? 5.5).toStringAsFixed(0),
              onChanged: (value) {
                setState(() {
                  _physicalRating = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Reasons
            Text('Reasons', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  LogReason.values
                      .map(
                        (reason) => FilterChip(
                          selected: _selectedReasons.contains(reason),
                          onSelected: (selected) => _toggleReason(reason),
                          label: Text(reason.displayName),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 16),

            // Press-and-hold duration button
            GestureDetector(
              onLongPressStart: _handleLongPressStart,
              onLongPressEnd: _handleLongPressEnd,
              onLongPressCancel: _handleTapCancel,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      _isRecording
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isRecording ? Icons.pause : Icons.touch_app,
                      size: 32,
                      color:
                          _isRecording
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    if (_isRecording)
                      Text(
                        '${_recordedDuration.inSeconds}s',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    else
                      Text(
                        'Hold to record duration',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

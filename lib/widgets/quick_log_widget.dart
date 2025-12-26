import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:ui';
import '../models/enums.dart';
import '../services/log_record_service.dart';
import '../services/validation_service.dart';
import 'package:intl/intl.dart';
import '../providers/account_provider.dart';

/// Quick log widget with long-press time adjustment
class QuickLogWidget extends ConsumerStatefulWidget {
  final EventType? defaultEventType;
  final double? defaultValue;
  final Unit? defaultUnit;
  final VoidCallback? onLogCreated;

  const QuickLogWidget({
    Key? key,
    this.defaultEventType,
    this.defaultValue,
    this.defaultUnit,
    this.onLogCreated,
  }) : super(key: key);

  @override
  ConsumerState<QuickLogWidget> createState() => _QuickLogWidgetState();
}

class _QuickLogWidgetState extends ConsumerState<QuickLogWidget> {
  // Time adjustment mode (existing functionality)
  bool _isLongPressing = false;
  Timer? _longPressTimer;
  DateTime? _adjustedTime;
  int _timeOffset = 0; // seconds

  // Duration recording mode (new functionality)
  bool _isRecording = false;
  DateTime? _recordingStartTime;
  Timer? _recordingTimer;
  Duration _recordedDuration = Duration.zero;

  void _handleTapDown(TapDownDetails details) {
    // Start timer to detect which mode to enter
    _longPressTimer = Timer(const Duration(milliseconds: 800), () {
      // Enter time adjustment mode (800ms threshold)
      setState(() {
        _isLongPressing = true;
        _adjustedTime = DateTime.now();
        _timeOffset = 0;
      });
    });
  }

  void _handleLongPressStart(LongPressStartDetails details) {
    // This fires at 500ms - enter recording mode
    _longPressTimer?.cancel();
    if (!_isLongPressing) {
      setState(() {
        _isRecording = true;
        _recordingStartTime = DateTime.now();
        _recordedDuration = Duration.zero;
      });

      // Update duration every 100ms while recording
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (
        timer,
      ) {
        if (_recordingStartTime != null) {
          setState(() {
            _recordedDuration = DateTime.now().difference(_recordingStartTime!);
          });
        }
      });
    }
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _recordingTimer?.cancel();
    if (_isRecording && _recordingStartTime != null) {
      final durationMs =
          DateTime.now().difference(_recordingStartTime!).inMilliseconds;
      _createDurationLog(durationMs);
      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
        _recordedDuration = Duration.zero;
      });
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _longPressTimer?.cancel();
    if (_isLongPressing) {
      // Complete the log with adjusted time
      _createQuickLog(adjustedTime: _adjustedTime);
      setState(() {
        _isLongPressing = false;
        _adjustedTime = null;
        _timeOffset = 0;
      });
    } else {
      // Quick tap - log now
      _createQuickLog();
    }
  }

  void _handleTapCancel() {
    _longPressTimer?.cancel();
    _recordingTimer?.cancel();
    if (_isLongPressing) {
      setState(() {
        _isLongPressing = false;
        _adjustedTime = null;
        _timeOffset = 0;
      });
    }
    if (_isRecording) {
      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
        _recordedDuration = Duration.zero;
      });
    }
  }

  void _adjustTime(int seconds) {
    setState(() {
      _timeOffset += seconds;
      _adjustedTime = DateTime.now().add(Duration(seconds: _timeOffset));
    });
  }

  Future<void> _createDurationLog(int durationMs) async {
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

      final eventType = widget.defaultEventType ?? EventType.inhale;

      final record = await service.recordDurationLog(
        accountId: activeAccount.userId,
        durationMs: durationMs,
        eventType: eventType,
      );

      if (mounted) {
        final durationSeconds = (durationMs / 1000).toStringAsFixed(1);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged ${eventType.name} (${durationSeconds}s)'),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () async {
                await service.deleteLogRecord(record);
              },
            ),
          ),
        );

        widget.onLogCreated?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging duration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createQuickLog({DateTime? adjustedTime}) async {
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
      final eventType = widget.defaultEventType ?? EventType.inhale;
      final value = widget.defaultValue ?? 1.0;
      final unit = widget.defaultUnit ?? Unit.count;

      // Validate value
      final validatedValue = ValidationService.clampValue(value, unit);

      final record =
          adjustedTime != null
              ? await service.backdateLog(
                accountId: activeAccount.userId,
                eventType: eventType,
                value: validatedValue,
                unit: unit,
                eventAt: adjustedTime,
              )
              : await service.quickLog(
                accountId: activeAccount.userId,
                eventType: eventType,
                value: validatedValue,
                unit: unit,
              );

      if (mounted) {
        final timeMsg =
            adjustedTime != null
                ? ' at ${DateFormat.jm().format(adjustedTime)}'
                : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged ${eventType.name}$timeMsg'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () async {
                await service.deleteLogRecord(record);
              },
            ),
          ),
        );

        widget.onLogCreated?.call();
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

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isRecording) {
      return _buildRecordingOverlay();
    }

    if (_isLongPressing) {
      return _buildTimeAdjustmentOverlay();
    }

    return Listener(
      onPointerExit: (_) {
        // Cancel any active gestures when pointer leaves the button
        // This is crucial for web where mouse can leave the button area
        if (_isRecording || _isLongPressing) {
          _handleTapCancel();
        }
      },
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onLongPressStart: _handleLongPressStart,
        onLongPressEnd: _handleLongPressEnd,
        child: FloatingActionButton.extended(
          heroTag: 'quick_log',
          onPressed: () {}, // Handled by GestureDetector
          icon: const Icon(Icons.add),
          label: const Text('Quick Log'),
        ),
      ),
    );
  }

  Widget _buildRecordingOverlay() {
    final theme = Theme.of(context);
    final seconds = _recordedDuration.inSeconds;
    final milliseconds = (_recordedDuration.inMilliseconds % 1000) ~/ 100;

    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing circle animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.9, end: 1.1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primaryContainer.withOpacity(
                        0.3,
                      ),
                      border: Border.all(
                        color: theme.colorScheme.primary,
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '$seconds.$milliseconds',
                            style: theme.textTheme.displayLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontFeatures: [
                                const FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          Text(
                            'seconds',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              onEnd: () {
                // Loop the animation by triggering rebuild
                if (_isRecording && mounted) {
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 48),
            Text(
              'Release to save',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Swipe away to cancel',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeAdjustmentOverlay() {
    final theme = Theme.of(context);
    final adjustedTime = _adjustedTime ?? DateTime.now();
    final difference = adjustedTime.difference(DateTime.now());

    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Adjust Time', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 16),
                Text(
                  DateFormat.jms().format(adjustedTime),
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDifference(difference),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildTimeButton('-5m', () => _adjustTime(-300)),
                    _buildTimeButton('-1m', () => _adjustTime(-60)),
                    _buildTimeButton('-30s', () => _adjustTime(-30)),
                    _buildTimeButton('-5s', () => _adjustTime(-5)),
                    _buildTimeButton('-1s', () => _adjustTime(-1)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildTimeButton('+1s', () => _adjustTime(1)),
                    _buildTimeButton('+5s', () => _adjustTime(5)),
                    _buildTimeButton('+30s', () => _adjustTime(30)),
                    _buildTimeButton('+1m', () => _adjustTime(60)),
                    _buildTimeButton('+5m', () => _adjustTime(300)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLongPressing = false;
                          _adjustedTime = null;
                          _timeOffset = 0;
                        });
                      },
                      child: const Text('CANCEL'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () {
                        _createQuickLog(adjustedTime: adjustedTime);
                        setState(() {
                          _isLongPressing = false;
                          _adjustedTime = null;
                          _timeOffset = 0;
                        });
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('LOG IT'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(minimumSize: const Size(60, 40)),
      child: Text(label),
    );
  }

  String _formatDifference(Duration difference) {
    if (difference.isNegative) {
      final positive = -difference;
      if (positive.inMinutes > 0) {
        return '${positive.inMinutes}m ${positive.inSeconds % 60}s ago';
      }
      return '${positive.inSeconds}s ago';
    } else if (difference.inSeconds == 0) {
      return 'now';
    } else {
      if (difference.inMinutes > 0) {
        return 'in ${difference.inMinutes}m ${difference.inSeconds % 60}s';
      }
      return 'in ${difference.inSeconds}s';
    }
  }
}

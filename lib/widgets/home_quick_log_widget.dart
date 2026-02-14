import 'package:flutter/material.dart';
import '../logging/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/app_error.dart';
import '../models/enums.dart';
import '../models/account.dart';
import '../services/log_record_service.dart';
import '../providers/account_provider.dart';
import '../providers/log_record_provider.dart';
import '../services/location_service.dart';
import '../utils/error_display.dart';
import 'reason_chips_grid.dart';

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
  static final _log = AppLogger.logger('HomeQuickLogWidget');
  // Duration recording state
  bool _isRecording = false;
  DateTime? _recordingStartTime;
  Timer? _recordingTimer;
  Duration _recordedDuration = Duration.zero;

  // Form state
  double? _moodRating;
  double? _physicalRating;
  final Set<LogReason> _selectedReasons = {};

  // Track current account ID to detect account switches
  String? _currentAccountId;

  // Location service
  final LocationService _locationService = LocationService();

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
    // ── DIAGNOSTIC: Log the full pipeline for multi-account debugging ──
    // Uses .w() (warning level) so these are visible in release/TestFlight.
    _log.w(
      '[QUICK_LOG_START] durationMs=$durationMs, '
      'widgetAccountId=$_currentAccountId, mounted=$mounted',
    );

    // Get the current active account - wait for it if loading
    Account? activeAccount;
    final activeAccountAsync = ref.read(activeAccountProvider);

    _log.w(
      '[QUICK_LOG] activeAccountProvider state: '
      'isLoading=${activeAccountAsync.isLoading}, '
      'hasValue=${activeAccountAsync.hasValue}, '
      'hasError=${activeAccountAsync.hasError}',
    );

    if (activeAccountAsync.isLoading) {
      // Wait for account to load — but with a timeout so we don't hang forever
      _log.w(
        '[QUICK_LOG] Provider is loading — awaiting future (5s timeout)...',
      );
      try {
        activeAccount = await ref
            .read(activeAccountProvider.future)
            .timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                _log.e(
                  '[QUICK_LOG] TIMEOUT waiting for activeAccountProvider.future! '
                  'The provider never left the Loading state within 5 seconds. '
                  'This likely means the account stream did not emit after '
                  'invalidation during account switch.',
                );
                return null;
              },
            );
        _log.w(
          '[QUICK_LOG] Provider resolved: '
          'userId=${activeAccount?.userId}, email=${activeAccount?.email}',
        );
      } catch (e, st) {
        _log.e(
          '[QUICK_LOG] Error loading active account',
          error: e,
          stackTrace: st,
        );
      }
    } else if (activeAccountAsync.hasError) {
      _log.e(
        '[QUICK_LOG] Provider is in ERROR state: '
        '${activeAccountAsync.error}',
        error: activeAccountAsync.error,
        stackTrace: activeAccountAsync.stackTrace,
      );
    } else {
      activeAccount = activeAccountAsync.asData?.value;
      _log.w(
        '[QUICK_LOG] Provider already loaded: '
        'userId=${activeAccount?.userId}, email=${activeAccount?.email}',
      );
    }

    if (activeAccount == null) {
      _log.e(
        '[QUICK_LOG] ABORT — No active account! '
        'Provider state: isLoading=${activeAccountAsync.isLoading}, '
        'hasValue=${activeAccountAsync.hasValue}, '
        'hasError=${activeAccountAsync.hasError}, '
        'error=${activeAccountAsync.error}, '
        'widgetAccountId=$_currentAccountId',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No active account — try switching accounts again'),
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Double-check we're using the correct account (in case it changed during async operations)
    final currentAccountAsync = ref.read(activeAccountProvider);
    final currentAccount = currentAccountAsync.asData?.value;
    if (currentAccount != null &&
        currentAccount.userId != activeAccount.userId) {
      // Account changed while we were processing - use the new account
      _log.w(
        '[QUICK_LOG] ACCOUNT CHANGED during log creation! '
        'Original: ${activeAccount.userId}/${activeAccount.email} → '
        'New: ${currentAccount.userId}/${currentAccount.email}',
      );
      activeAccount = currentAccount;
    }

    // Cross-check with widget-level tracked account ID
    if (_currentAccountId != null &&
        _currentAccountId != activeAccount.userId) {
      _log.w(
        '[QUICK_LOG] MISMATCH: widget._currentAccountId=$_currentAccountId '
        'but provider says ${activeAccount.userId}. '
        'Possible race between account switch and gesture.',
      );
    }

    final service = LogRecordService(
      accountService: ref.read(accountServiceProvider),
    );

    // Verify account exists in the database before attempting to create a record
    try {
      final accountService = ref.read(accountServiceProvider);
      final exists = await accountService.accountExists(activeAccount.userId);
      _log.w('[QUICK_LOG] accountExists(${activeAccount.userId}) = $exists');
      if (!exists) {
        _log.e(
          '[QUICK_LOG] ABORT — account ${activeAccount.userId} / '
          '${activeAccount.email} does NOT exist in the database! '
          'Account may not be fully saved after switch.',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account not ready yet — please wait and try again',
              ),
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }
    } catch (e, st) {
      _log.e(
        '[QUICK_LOG] Exception checking accountExists',
        error: e,
        stackTrace: st,
      );
    }

    try {
      // Check minimum threshold
      if (durationMs < 1000) {
        _log.w('[QUICK_LOG] ABORT — Duration too short: ${durationMs}ms');
        if (mounted) {
          ErrorDisplay.showSnackBar(
            context,
            const AppError.validation(
              message: 'Duration too short (minimum 1 second)',
              code: 'VALIDATION_DURATION_SHORT',
            ),
            reportContext: 'QuickLog.submit',
          );
        }
        return;
      }

      final durationSeconds = durationMs / 1000.0;

      // Capture location before creating log
      double? latitude;
      double? longitude;
      try {
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          latitude = position.latitude;
          longitude = position.longitude;
          _log.d('[QUICK_LOG] Location captured: $latitude, $longitude');
        } else {
          _log.d('[QUICK_LOG] No location available');
        }
      } catch (e) {
        _log.w('[QUICK_LOG] Failed to capture location', error: e);
      }

      _log.w(
        '[QUICK_LOG] Creating record: '
        'accountId=${activeAccount.userId}, '
        'email=${activeAccount.email}, '
        'duration=${durationSeconds.toStringAsFixed(1)}s, '
        'mood=$_moodRating, physical=$_physicalRating, '
        'reasons=${_selectedReasons.length}',
      );

      final record = await service.createLogRecord(
        accountId: activeAccount.userId,
        eventType: EventType.vape,
        duration: durationSeconds,
        unit: Unit.seconds,
        moodRating: _moodRating,
        physicalRating: _physicalRating,
        reasons: _selectedReasons.isNotEmpty ? _selectedReasons.toList() : null,
        latitude: latitude,
        longitude: longitude,
      );

      _log.w(
        '[QUICK_LOG] Record CREATED: '
        'logId=${record.logId}, '
        'accountId=${record.accountId}, '
        'eventAt=${record.eventAt}, '
        'syncState=${record.syncState.name}',
      );

      if (mounted) {
        final durationStr = durationSeconds.toStringAsFixed(1);
        final locationMessage =
            latitude != null && longitude != null
                ? 'Logged vape (${durationStr}s). Location captured.'
                : 'Logged vape (${durationStr}s)';

        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          SnackBar(
            content: Text(locationMessage),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () async {
                _log.w('[QUICK_LOG] UNDO tapped for logId=${record.logId}');
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
        _log.w('[QUICK_LOG] Invalidating providers...');
        ref.invalidate(activeAccountLogRecordsProvider);
        ref.invalidate(logRecordStatsProvider);
        _log.w('[QUICK_LOG_END] Success — snackbar displayed');
      } else {
        _log.w('[QUICK_LOG_END] Record saved but widget no longer mounted');
      }
    } catch (e, st) {
      _log.e(
        '[QUICK_LOG] EXCEPTION during log creation',
        error: e,
        stackTrace: st,
      );
      if (mounted) {
        ErrorDisplay.showException(
          context,
          e,
          stackTrace: st,
          reportContext: 'QuickLog.submit',
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

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _resetFormState() {
    if (mounted) {
      setState(() {
        _moodRating = null;
        _physicalRating = null;
        _selectedReasons.clear();
      });
    }
  }

  void _cancelRecording() {
    _recordingTimer?.cancel();
    if (_isRecording && mounted) {
      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
        _recordedDuration = Duration.zero;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch active account to detect account switches and reset form state
    final activeAccountAsync = ref.watch(activeAccountProvider);
    final activeAccount = activeAccountAsync.asData?.value;

    // Only cancel recording on account change (so we don't log to wrong account).
    // Do not reset form values; the form only resets when the user taps "Clear
    // form" or after successfully finishing a log.
    if (activeAccountAsync.isLoading) {
      // Loading: do nothing; keep current state
      _log.w(
        '[QUICK_LOG_BUILD] activeAccountProvider is LOADING. '
        'widgetAccountId=$_currentAccountId. '
        'Quick-log button will use stale _currentAccountId until resolved.',
      );
    } else if (activeAccountAsync.hasError) {
      _log.e(
        '[QUICK_LOG_BUILD] activeAccountProvider has ERROR: '
        '${activeAccountAsync.error}',
        error: activeAccountAsync.error,
      );
    } else if (activeAccount != null &&
        activeAccount.userId != _currentAccountId) {
      _log.w(
        '[QUICK_LOG_BUILD] Account CHANGED: '
        '$_currentAccountId → ${activeAccount.userId} '
        '(${activeAccount.email})',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentAccountId != null) _cancelRecording();
        _currentAccountId = activeAccount.userId;
        _log.w(
          '[QUICK_LOG_BUILD] _currentAccountId updated to '
          '${activeAccount.userId} (post-frame)',
        );
      });
    } else if (activeAccount == null && _currentAccountId != null) {
      _log.w('[QUICK_LOG_BUILD] Account went NULL (was $_currentAccountId)');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cancelRecording();
        _currentAccountId = null;
      });
    }

    final hasFormValues =
        _moodRating != null ||
        _physicalRating != null ||
        _selectedReasons.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood — muted until user slides (then uses theme primary)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Mood',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color:
                          _moodRating == null
                              ? Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6)
                              : null,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor:
                          _moodRating == null
                              ? Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest
                              : null,
                      inactiveTrackColor:
                          _moodRating == null
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.6)
                              : null,
                      thumbColor:
                          _moodRating == null
                              ? Theme.of(context).colorScheme.outline
                              : null,
                    ),
                    child: Slider(
                      key: const Key('quick_log_mood_slider'),
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Physical — muted until user slides (then uses theme primary)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Physical',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color:
                          _physicalRating == null
                              ? Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6)
                              : null,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor:
                          _physicalRating == null
                              ? Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest
                              : null,
                      inactiveTrackColor:
                          _physicalRating == null
                              ? Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.6)
                              : null,
                      thumbColor:
                          _physicalRating == null
                              ? Theme.of(context).colorScheme.outline
                              : null,
                    ),
                    child: Slider(
                      key: const Key('quick_log_physical_slider'),
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Reasons
            Text('Reasons', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            ReasonChipsGrid(
              key: const Key('quick_log_reasons'),
              selected: _selectedReasons,
              onToggle: _toggleReason,
              showIcons: true,
            ),
            const SizedBox(height: 16),

            // Clear form button
            if (hasFormValues)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      key: const Key('quick_log_clear_form'),
                      onPressed: _resetFormState,
                      icon: const Icon(Icons.clear_all, size: 18),
                      label: const Text('Clear form'),
                    ),
                  ],
                ),
              ),

            // Press-and-hold duration button
            Semantics(
              label: 'Hold to record duration',
              button: true,
              child: Center(
                child: GestureDetector(
                  key: const Key('hold_to_record_button'),
                  onLongPressStart: _handleLongPressStart,
                  onLongPressEnd: _handleLongPressEnd,
                  onLongPressCancel: _handleTapCancel,
                  child: Container(
                    width: double.infinity,
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
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isRecording ? Icons.pause : Icons.touch_app,
                          size: 28,
                          color:
                              _isRecording
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        if (_isRecording)
                          Text(
                            '${(_recordedDuration.inMilliseconds / 1000).toStringAsFixed(2)}s',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        else
                          Text(
                            'Hold to record duration',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../providers/log_record_provider.dart';
import '../widgets/backdate_dialog.dart';
import '../services/log_record_service.dart';
import 'dart:async';

/// Dedicated logging screen for detailed event entry
/// Primary interface: Long-press to record duration (design-recommended pattern)
/// Secondary interface: Manual entry for backdate events
class LoggingScreen extends ConsumerStatefulWidget {
  const LoggingScreen({super.key});

  @override
  ConsumerState<LoggingScreen> createState() => _LoggingScreenState();
}

class _LoggingScreenState extends ConsumerState<LoggingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountId = ref.watch(activeAccountIdProvider);

    if (accountId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Log Event')),
        body: const Center(child: Text('Please select an account first')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Event'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.edit_note), text: 'Detailed'),
            Tab(icon: Icon(Icons.history), text: 'Backdate'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _DetailedLogTab(accountId: accountId),
          _BackdateLogTab(accountId: accountId),
        ],
      ),
    );
  }
}

/// Detailed log tab - Primary interface with press-and-hold duration recording
/// Pattern: User fills optional form fields, then presses & holds button to record duration
class _DetailedLogTab extends ConsumerStatefulWidget {
  final String accountId;

  const _DetailedLogTab({required this.accountId});

  @override
  ConsumerState<_DetailedLogTab> createState() => _DetailedLogTabState();
}

class _DetailedLogTabState extends ConsumerState<_DetailedLogTab> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Form controllers
  final _durationController = TextEditingController();
  final _noteController = TextEditingController();

  // Press-and-hold state
  Timer? _longPressTimer;
  DateTime? _recordingStartTime;
  Timer? _recordingTimer;
  Duration _recordedDuration = Duration.zero;
  bool _isRecording = false;

  @override
  void dispose() {
    _durationController.dispose();
    _noteController.dispose();
    _longPressTimer?.cancel();
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(logDraftProvider);
    final draftNotifier = ref.read(logDraftProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event Type
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Event Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<EventType>(
                      value: draft.eventType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          EventType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(_formatEnumName(type.name)),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          draftNotifier.setEventType(value);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Duration and Unit (manual entry)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Duration (or use long-press button below)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _durationController,
                            decoration: const InputDecoration(
                              labelText: 'Seconds',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (value) {
                              draftNotifier.setDuration(double.tryParse(value));
                            },
                          ),
                        ),
                        // Commented out - using seconds only
                        // const SizedBox(width: 12),
                        // Expanded(
                        //   flex: 2,
                        //   child: DropdownButtonFormField<Unit>(
                        //     value: draft.unit,
                        //     decoration: const InputDecoration(
                        //       labelText: 'Unit',
                        //       border: OutlineInputBorder(),
                        //     ),
                        //     items:
                        //         Unit.values.map((unit) {
                        //           return DropdownMenuItem(
                        //             value: unit,
                        //             child: Text(_formatEnumName(unit.name)),
                        //           );
                        //         }).toList(),
                        //     onChanged: (value) {
                        //       if (value != null) {
                        //         draftNotifier.setUnit(value);
                        //       }
                        //     },
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Press-and-Hold Duration Recording Button (Primary pattern)
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Press & Hold to Record Duration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isRecording ? 'Recording...' : 'Hold down the button',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onLongPressStart:
                          (_) => _startDurationRecording(draftNotifier),
                      onLongPressEnd:
                          (_) => _endDurationRecording(draft, draftNotifier),
                      onLongPressCancel: () => _cancelDurationRecording(),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _isRecording
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer
                                      .withOpacity(0.1),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isRecording ? Icons.pause : Icons.touch_app,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _recordedDuration.inSeconds > 0
                                  ? '${_recordedDuration.inSeconds}s'
                                  : 'Hold',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
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
            ),
            const SizedBox(height: 12),

            // Reason
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reason (optional, can select multiple)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          LogReason.values.map((reason) {
                            final isSelected =
                                draft.reasons?.contains(reason) ?? false;
                            return FilterChip(
                              avatar: Icon(reason.icon, size: 18),
                              label: Text(reason.displayName),
                              selected: isSelected,
                              onSelected:
                                  (_) => draftNotifier.toggleReason(reason),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Mood and Physical Rating (optional, null by default per design)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How are you feeling? (optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mood slider
                    Row(
                      children: [
                        const SizedBox(width: 80, child: Text('Mood')),
                        const Icon(Icons.sentiment_very_dissatisfied, size: 20),
                        Expanded(
                          child: Slider(
                            value: draft.moodRating ?? 5.0,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label:
                                draft.moodRating?.toStringAsFixed(1) ??
                                'Not set',
                            onChanged:
                                (value) => draftNotifier.setMoodRating(value),
                          ),
                        ),
                        const Icon(Icons.sentiment_very_satisfied, size: 20),
                        SizedBox(
                          width: 50,
                          child: Text(
                            draft.moodRating?.toStringAsFixed(1) ?? '-',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          tooltip: 'Reset',
                          onPressed: () => draftNotifier.setMoodRating(null),
                        ),
                      ],
                    ),

                    // Physical rating slider
                    Row(
                      children: [
                        const SizedBox(width: 80, child: Text('Physical')),
                        const Icon(Icons.sentiment_very_dissatisfied, size: 20),
                        Expanded(
                          child: Slider(
                            value: draft.physicalRating ?? 5.0,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label:
                                draft.physicalRating?.toStringAsFixed(1) ??
                                'Not set',
                            activeColor:
                                Theme.of(context).colorScheme.secondary,
                            onChanged:
                                (value) =>
                                    draftNotifier.setPhysicalRating(value),
                          ),
                        ),
                        const Icon(Icons.sentiment_very_satisfied, size: 20),
                        SizedBox(
                          width: 50,
                          child: Text(
                            draft.physicalRating?.toStringAsFixed(1) ?? '-',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          tooltip: 'Reset',
                          onPressed:
                              () => draftNotifier.setPhysicalRating(null),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Notes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                        hintText: 'Add any notes...',
                      ),
                      maxLines: 3,
                      onChanged: (value) => draftNotifier.setNote(value),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isSubmitting
                            ? null
                            : () {
                              draftNotifier.reset();
                              _durationController.clear();
                              _noteController.clear();
                              setState(() {
                                _recordedDuration = Duration.zero;
                              });
                            },
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : () => _submitLog(draft),
                    child:
                        _isSubmitting
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Log Event'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _startDurationRecording(LogDraftNotifier draftNotifier) {
    setState(() {
      _isRecording = true;
      _recordingStartTime = DateTime.now();
      _recordedDuration = Duration.zero;
    });

    // Update duration every 100ms
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_recordingStartTime != null && mounted) {
        setState(() {
          _recordedDuration = DateTime.now().difference(_recordingStartTime!);
        });
      }
    });
  }

  void _endDurationRecording(LogDraft draft, LogDraftNotifier draftNotifier) {
    _recordingTimer?.cancel();

    if (_recordingStartTime != null) {
      final durationSeconds = _recordedDuration.inMilliseconds / 1000.0;

      // Minimum threshold: 1 second
      if (durationSeconds >= 1.0) {
        // Auto-populate the duration field
        _durationController.text = durationSeconds.toStringAsFixed(1);
        draftNotifier.setDuration(durationSeconds);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Recorded ${durationSeconds.toStringAsFixed(1)}s duration',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Duration too short (minimum 1 second)'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
      });
    }
  }

  void _cancelDurationRecording() {
    _recordingTimer?.cancel();
    if (mounted) {
      setState(() {
        _isRecording = false;
        _recordingStartTime = null;
      });
    }
  }

  String _formatEnumName(String name) {
    final result = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return result[0].toUpperCase() + result.substring(1);
  }

  Future<void> _submitLog(LogDraft draft) async {
    if (!draft.isValid) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please check your input')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final service = LogRecordService();

      await service.createLogRecord(
        accountId: widget.accountId,
        eventType: draft.eventType,
        eventAt: draft.eventTime,
        duration: draft.duration ?? 0,
        unit: draft.unit,
        note: draft.note,
        moodRating: draft.moodRating,
        physicalRating: draft.physicalRating,
        reasons: draft.reasons,
        latitude: draft.latitude,
        longitude: draft.longitude,
      );

      if (mounted) {
        // Reset form
        ref.read(logDraftProvider.notifier).reset();
        _durationController.clear();
        _noteController.clear();
        setState(() {
          _recordedDuration = Duration.zero;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event logged successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

/// Backdate log tab - log events from the past (manual entry like detailed but with time override)
class _BackdateLogTab extends ConsumerWidget {
  final String accountId;

  const _BackdateLogTab({required this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.history, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Backdate Entry',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Log an event that happened in the past (up to 30 days)',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const BackdateDialog(),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Backdated Entry'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Info card
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Backdated entries are marked with lower time confidence and will be clearly identified in your timeline.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

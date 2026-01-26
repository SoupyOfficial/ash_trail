import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../providers/log_record_provider.dart';
import '../widgets/backdate_dialog.dart';
import '../services/log_record_service.dart';
import '../services/location_service.dart';
import '../widgets/location_map_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  // Location state
  bool _isFetchingLocation = false;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    // Automatically check and capture location when screen opens
    _checkAndCaptureInitialLocation();
  }

  /// Check for location permission and capture location automatically
  Future<void> _checkAndCaptureInitialLocation() async {
    final draftNotifier = ref.read(logDraftProvider.notifier);

    // Check if we already have location permission
    final hasPermission = await _locationService.hasLocationPermission();

    if (hasPermission) {
      // Silently capture location in the background
      _captureLocationSilently(draftNotifier);
    } else {
      // Prompt user for permission
      if (mounted) {
        _promptForLocationPermission(draftNotifier);
      }
    }
  }

  /// Silently capture location without showing dialogs
  Future<void> _captureLocationSilently(LogDraftNotifier draftNotifier) async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null && mounted) {
        draftNotifier.setLocation(position.latitude, position.longitude);
        debugPrint(
          '✅ Location auto-captured: ${position.latitude}, ${position.longitude}',
        );
        // Show notification that location was captured
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location captured'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ Failed to auto-capture location: $e');
    }
  }

  /// Prompt user for location permission with explanation
  Future<void> _promptForLocationPermission(
    LogDraftNotifier draftNotifier,
  ) async {
    final shouldRequest = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Access'),
            content: const Text(
              'Ash Trail requires location access to automatically tag your logs. '
              'This helps you track where events occur. '
              'Location will be collected automatically when you create logs.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Not Now'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Allow'),
              ),
            ],
          ),
    );

    if (shouldRequest == true && mounted) {
      final granted = await _locationService.requestLocationPermission();
      if (granted && mounted) {
        // Capture location after permission granted
        _captureLocationSilently(draftNotifier);
      }
    }
  }

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
                                      .withValues(alpha: 0.1),
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

                    // Mood slider section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 60, child: Text('Mood')),
                            const Icon(
                              Icons.sentiment_very_dissatisfied,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Slider(
                                value: draft.moodRating ?? 5.5,
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label:
                                    draft.moodRating?.toStringAsFixed(1) ??
                                    'Tap to set',
                                inactiveColor:
                                    draft.moodRating == null
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest
                                        : null,
                                onChanged:
                                    (value) =>
                                        draftNotifier.setMoodRating(value),
                              ),
                            ),
                            const Icon(
                              Icons.sentiment_very_satisfied,
                              size: 18,
                            ),
                            SizedBox(
                              width: 30,
                              child: Text(
                                draft.moodRating?.toStringAsFixed(1) ?? '-',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      draft.moodRating == null
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant
                                          : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed:
                                draft.moodRating != null
                                    ? () => draftNotifier.setMoodRating(null)
                                    : null,
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  draft.moodRating != null
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.3),
                            ),
                            icon: const Icon(Icons.clear, size: 16),
                            label: Text(
                              draft.moodRating != null ? 'Clear' : 'Not set',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Physical rating slider section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 60, child: Text('Physical')),
                            const Icon(
                              Icons.sentiment_very_dissatisfied,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Slider(
                                value: draft.physicalRating ?? 5.5,
                                min: 1,
                                max: 10,
                                divisions: 9,
                                label:
                                    draft.physicalRating?.toStringAsFixed(1) ??
                                    'Tap to set',
                                activeColor:
                                    Theme.of(context).colorScheme.secondary,
                                inactiveColor:
                                    draft.physicalRating == null
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest
                                        : null,
                                onChanged:
                                    (value) =>
                                        draftNotifier.setPhysicalRating(value),
                              ),
                            ),
                            const Icon(
                              Icons.sentiment_very_satisfied,
                              size: 18,
                            ),
                            SizedBox(
                              width: 30,
                              child: Text(
                                draft.physicalRating?.toStringAsFixed(1) ?? '-',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      draft.physicalRating == null
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant
                                          : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed:
                                draft.physicalRating != null
                                    ? () =>
                                        draftNotifier.setPhysicalRating(null)
                                    : null,
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  draft.physicalRating != null
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.3),
                            ),
                            icon: const Icon(Icons.clear, size: 16),
                            label: Text(
                              draft.physicalRating != null
                                  ? 'Clear'
                                  : 'Not set',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
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
            const SizedBox(height: 12),

            // Location
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Location (auto-collected)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (draft.latitude != null && draft.longitude != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 24,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Location Captured',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${draft.latitude!.toStringAsFixed(6)}, ${draft.longitude!.toStringAsFixed(6)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer
                                              .withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.check_circle,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed:
                                      () => _openMapPicker(draftNotifier),
                                  icon: const Icon(Icons.map, size: 18),
                                  label: const Text('Edit on Map'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed:
                                      () => _captureLocation(draftNotifier),
                                  icon: const Icon(Icons.my_location, size: 18),
                                  label: const Text('Recapture'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.errorContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Location not available',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.icon(
                            onPressed:
                                _isFetchingLocation
                                    ? null
                                    : () => _captureLocation(draftNotifier),
                            icon:
                                _isFetchingLocation
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.my_location),
                            label: Text(
                              _isFetchingLocation
                                  ? 'Getting location...'
                                  : 'Enable Location',
                            ),
                          ),
                        ],
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

  /// Open map picker to select or edit location
  Future<void> _openMapPicker(LogDraftNotifier draftNotifier) async {
    final draft = ref.read(logDraftProvider);

    final result = await Navigator.push<LatLng?>(
      context,
      MaterialPageRoute(
        builder:
            (context) => LocationMapPicker(
              initialLatitude: draft.latitude,
              initialLongitude: draft.longitude,
              title: 'Select Location',
            ),
      ),
    );

    if (result != null && mounted) {
      draftNotifier.setLocation(result.latitude, result.longitude);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (result == null && mounted) {
      // User cleared location
      draftNotifier.setLocation(null, null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location cleared'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _captureLocation(LogDraftNotifier draftNotifier) async {
    setState(() => _isFetchingLocation = true);

    try {
      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        draftNotifier.setLocation(position.latitude, position.longitude);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location captured successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          // Show dialog explaining permission needed
          final shouldRequest = await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Location Permission'),
                  content: const Text(
                    'Ash Trail needs location permission to tag your logs with location data. '
                    'This helps you track where events occur.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Grant Permission'),
                    ),
                  ],
                ),
          );

          if (shouldRequest == true && mounted) {
            final granted = await _locationService.requestLocationPermission();
            if (granted && mounted) {
              // Try again after permission granted
              _captureLocation(draftNotifier);
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isFetchingLocation = false);
      }
    }
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

        // Show success message with location info if available
        final locationMessage = draft.latitude != null && draft.longitude != null
            ? 'Event logged successfully! Location captured.'
            : 'Event logged successfully!';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(locationMessage)),
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

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../providers/log_record_provider.dart';
import '../services/location_service.dart';
import 'reason_chips_grid.dart';

/// Dialog for creating a new log entry
class CreateLogEntryDialog extends ConsumerStatefulWidget {
  const CreateLogEntryDialog({super.key});

  @override
  ConsumerState<CreateLogEntryDialog> createState() =>
      _CreateLogEntryDialogState();
}

class _CreateLogEntryDialogState extends ConsumerState<CreateLogEntryDialog> {
  final _formKey = GlobalKey<FormState>();

  EventType _selectedEventType = EventType.vape;
  Unit _selectedUnit = Unit.seconds;
  double? _duration;
  String? _note;
  DateTime _eventTime = DateTime.now();
  double? _moodRating;
  double? _physicalRating;
  List<LogReason>? _reasons;

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Log Event'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event Type Dropdown
              DropdownButtonFormField<EventType>(
                value: _selectedEventType,
                decoration: const InputDecoration(
                  labelText: 'Event Type',
                  border: OutlineInputBorder(),
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
                    setState(() {
                      _selectedEventType = value;
                      // Auto-select appropriate unit
                      switch (value) {
                        case EventType.vape:
                          _selectedUnit = Unit.seconds;
                          break;
                        case EventType.inhale:
                          _selectedUnit = Unit.hits;
                          break;
                        case EventType.sessionStart:
                        case EventType.sessionEnd:
                          _selectedUnit = Unit.seconds;
                          break;
                        default:
                          _selectedUnit = Unit.none;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Duration Input
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {
                        _duration = double.tryParse(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<Unit>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          Unit.values.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(_formatEnumName(unit.name)),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedUnit = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Event Time Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Event Time'),
                subtitle: Text(
                  '${_eventTime.toLocal()}'.split('.')[0],
                  style: const TextStyle(fontSize: 14),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _eventTime,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );

                  if (!mounted) return;

                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_eventTime),
                    );

                    if (time != null) {
                      if (!mounted) return;

                      setState(() {
                        _eventTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Add any additional notes...',
                ),
                maxLines: 3,
                onChanged: (value) {
                  _note = value.isEmpty ? null : value;
                },
              ),
              const SizedBox(height: 16),

              // Reason Selection - Multiselect chips
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Reasons (optional)'),
                      if (_reasons != null && _reasons!.isNotEmpty)
                        TextButton(
                          onPressed: () => setState(() => _reasons = null),
                          child: const Text('Clear'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ReasonChipsGrid(
                    selected: Set.from(_reasons ?? []),
                    showIcons: true,
                    onToggle: (reason) {
                      setState(() {
                        final currentReasons = _reasons ?? [];
                        if (currentReasons.contains(reason)) {
                          _reasons = currentReasons
                              .where((r) => r != reason)
                              .toList();
                          if (_reasons!.isEmpty) _reasons = null;
                        } else {
                          _reasons = [...currentReasons, reason];
                        }
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mood Rating Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Mood Rating (optional)'),
                      Text(
                        _moodRating != null
                            ? _moodRating!.toStringAsFixed(1)
                            : 'Not set',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.sentiment_very_dissatisfied, size: 20),
                      Expanded(
                        child: Slider(
                          value: _moodRating ?? 5.0,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: _moodRating?.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() => _moodRating = value);
                          },
                        ),
                      ),
                      const Icon(Icons.sentiment_very_satisfied, size: 20),
                    ],
                  ),
                  if (_moodRating != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => _moodRating = null),
                        child: const Text('Clear'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Physical Rating Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Physical Rating (optional)'),
                      Text(
                        _physicalRating != null
                            ? _physicalRating!.toStringAsFixed(1)
                            : 'Not set',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.fitness_center, size: 20),
                      Expanded(
                        child: Slider(
                          value: _physicalRating ?? 5.0,
                          min: 1,
                          max: 10,
                          divisions: 9,
                          label: _physicalRating?.toStringAsFixed(1),
                          activeColor: Theme.of(context).colorScheme.secondary,
                          onChanged: (value) {
                            setState(() => _physicalRating = value);
                          },
                        ),
                      ),
                      const Icon(Icons.self_improvement, size: 20),
                    ],
                  ),
                  if (_physicalRating != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => setState(() => _physicalRating = null),
                        child: const Text('Clear'),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submitLog,
          child:
              _isSubmitting
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Log'),
        ),
      ],
    );
  }

  String _formatEnumName(String name) {
    // Convert camelCase to Title Case
    final result = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return result[0].toUpperCase() + result.substring(1);
  }

  Future<void> _submitLog() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final service = ref.read(logRecordServiceProvider);
      final accountId = ref.read(activeAccountIdProvider);

      if (accountId == null) {
        throw Exception('No active account');
      }

      await service.createLogRecord(
        accountId: accountId,
        eventType: _selectedEventType,
        eventAt: _eventTime,
        duration: _duration ?? 0,
        unit: _selectedUnit,
        note: _note,
        moodRating: _moodRating,
        physicalRating: _physicalRating,
        reasons: _reasons,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event logged successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging event: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

/// Quick log button with preset
class QuickLogButton extends ConsumerWidget {
  final EventType eventType;
  final String label;
  final IconData icon;
  final Unit? defaultUnit;
  final double? defaultDuration;

  const QuickLogButton({
    super.key,
    required this.eventType,
    required this.label,
    required this.icon,
    this.defaultUnit,
    this.defaultDuration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () async {
        final service = ref.read(logRecordServiceProvider);
        final accountId = ref.read(activeAccountIdProvider);

        if (accountId == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No active account')));
          return;
        }

        try {
          // Capture location before creating log
          final locationService = LocationService();
          double? latitude;
          double? longitude;
          try {
            final position = await locationService.getCurrentLocation();
            if (position != null) {
              latitude = position.latitude;
              longitude = position.longitude;
            }
          } catch (e) {
            debugPrint('⚠️ Failed to capture location for quick log: $e');
          }

          await service.createLogRecord(
            accountId: accountId,
            eventType: eventType,
            duration: defaultDuration ?? 0,
            unit: defaultUnit ?? Unit.none,
            latitude: latitude,
            longitude: longitude,
          );

          if (context.mounted) {
            final locationMessage = latitude != null && longitude != null
                ? '$label logged. Location captured.'
                : '$label logged';
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(locationMessage)));
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
      },
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

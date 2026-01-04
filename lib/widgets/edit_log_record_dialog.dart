import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/enums.dart';
import '../models/log_record.dart';
import '../providers/log_record_provider.dart';
import '../services/validation_service.dart';

/// Dialog for editing an existing log record
class EditLogRecordDialog extends ConsumerStatefulWidget {
  final LogRecord record;

  const EditLogRecordDialog({super.key, required this.record});

  @override
  ConsumerState<EditLogRecordDialog> createState() =>
      _EditLogRecordDialogState();
}

class _EditLogRecordDialogState extends ConsumerState<EditLogRecordDialog> {
  late DateTime _selectedDateTime;
  late EventType _eventType;
  late double _duration;
  late Unit _unit;
  late TextEditingController _notesController;
  late double? _moodRating;
  late double? _physicalRating;
  late List<LogReason> _reasons;
  late double? _latitude;
  late double? _longitude;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing values
    _selectedDateTime = widget.record.eventAt;
    _eventType = widget.record.eventType;
    _duration = widget.record.duration;
    _unit = widget.record.unit;
    _notesController = TextEditingController(text: widget.record.note);
    _moodRating = widget.record.moodRating;
    _physicalRating = widget.record.physicalRating;
    _reasons = List.from(widget.record.reasons ?? []);
    _latitude = widget.record.latitude;
    _longitude = widget.record.longitude;
    _latitudeController = TextEditingController(
      text: _latitude?.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: _longitude?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _updateLog() async {
    if (_isSubmitting) return;

    // Validate location if provided
    if (!ValidationService.isValidLocationPair(_latitude, _longitude)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location must have both latitude and longitude, or neither',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate ratings
    if (_moodRating != null && (_moodRating! < 1 || _moodRating! > 10)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mood rating must be between 1 and 10'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_physicalRating != null &&
        (_physicalRating! < 1 || _physicalRating! > 10)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Physical rating must be between 1 and 10'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Validate duration
      final validatedDuration =
          ValidationService.clampValue(_duration, _unit) ?? _duration;

      await ref
          .read(logRecordNotifierProvider.notifier)
          .updateLogRecord(
            widget.record,
            eventType: _eventType,
            eventAt: _selectedDateTime,
            duration: validatedDuration,
            unit: _unit,
            note: _notesController.text.isEmpty ? null : _notesController.text,
            moodRating: _moodRating,
            physicalRating: _physicalRating,
            reasons: _reasons,
            latitude: _latitude,
            longitude: _longitude,
          );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Log updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating log: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _formatEnumName(String name) {
    final result = name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return result[0].toUpperCase() + result.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Log', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 24),

              // Date/Time Display
              Card(
                color: theme.colorScheme.primaryContainer,
                child: InkWell(
                  onTap: _selectDateTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.access_time,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat.yMd().add_jm().format(_selectedDateTime),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Event Type Dropdown
              DropdownButtonFormField<EventType>(
                value: _eventType,
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
                      _eventType = value;
                      // Auto-select appropriate unit
                      switch (value) {
                        case EventType.vape:
                          _unit = Unit.seconds;
                          break;
                        case EventType.inhale:
                          _unit = Unit.hits;
                          break;
                        case EventType.sessionStart:
                        case EventType.sessionEnd:
                          _unit = Unit.seconds;
                          break;
                        default:
                          _unit = Unit.none;
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
                    flex: 2,
                    child: TextFormField(
                      initialValue: _duration.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        if (parsed != null) {
                          setState(() {
                            _duration = parsed;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<Unit>(
                      value: _unit,
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
                          setState(() {
                            _unit = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notes Input
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  hintText: 'Add any notes...',
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Mood Rating
              Text(
                'Mood Rating (optional)',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _moodRating ?? 5.0,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _moodRating?.toStringAsFixed(1) ?? 'Not set',
                      onChanged: (value) {
                        setState(() {
                          _moodRating = value;
                        });
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _moodRating = null;
                      });
                    },
                    child: Text(_moodRating == null ? 'Not set' : 'Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Physical Rating
              Text(
                'Physical Rating (optional)',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _physicalRating ?? 5.0,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _physicalRating?.toStringAsFixed(1) ?? 'Not set',
                      onChanged: (value) {
                        setState(() {
                          _physicalRating = value;
                        });
                      },
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _physicalRating = null;
                      });
                    },
                    child: Text(_physicalRating == null ? 'Not set' : 'Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Reasons
              Text('Reasons (optional)', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    LogReason.values
                        .map(
                          (reason) => FilterChip(
                            label: Text(reason.displayName),
                            selected: _reasons.contains(reason),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _reasons.add(reason);
                                } else {
                                  _reasons.remove(reason);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 24),

              // Location (Latitude/Longitude)
              Text(
                'Location (optional - both or neither)',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        border: OutlineInputBorder(),
                        hintText: '-90 to 90',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        setState(() {
                          _latitude = parsed;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        border: OutlineInputBorder(),
                        hintText: '-180 to 180',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(value);
                        setState(() {
                          _longitude = parsed;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _updateLog,
                    child:
                        _isSubmitting
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Update'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

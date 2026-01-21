import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/enums.dart';
import '../models/log_record.dart';
import '../providers/log_record_provider.dart';
import '../services/validation_service.dart';
import 'location_map_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Log Entry'),
            content: Text(
              'Are you sure you want to delete this ${widget.record.eventType.name} entry from ${DateFormat('MMM d, y h:mm a').format(widget.record.eventAt)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      await _deleteLog();
    }
  }

  Future<void> _deleteLog() async {
    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(logRecordNotifierProvider.notifier)
          .deleteLogRecord(widget.record);

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Entry deleted'),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              await ref
                  .read(logRecordNotifierProvider.notifier)
                  .restoreLogRecord(widget.record);
              // Invalidate to refresh all widgets
              ref.invalidate(activeAccountLogRecordsProvider);
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting entry: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
                    flex: 1,
                    child: Center(
                      child: Text(
                        _formatEnumName(_unit.name),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
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
                      value: _moodRating ?? 5.5,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: _moodRating?.toStringAsFixed(1) ?? 'Tap to set',
                      inactiveColor:
                          _moodRating == null
                              ? theme.colorScheme.surfaceContainerHighest
                              : null,
                      onChanged: (value) {
                        setState(() {
                          _moodRating = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      _moodRating?.toStringAsFixed(1) ?? 'Not Set',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            _moodRating == null
                                ? theme.colorScheme.onSurfaceVariant
                                : null,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        _moodRating != null
                            ? () {
                              setState(() {
                                _moodRating = null;
                              });
                            }
                            : () {},
                    style: TextButton.styleFrom(
                      foregroundColor:
                          _moodRating != null
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant.withOpacity(
                                0.3,
                              ),
                    ),
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
                      value: _physicalRating ?? 5.5,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label:
                          _physicalRating?.toStringAsFixed(1) ?? 'Tap to set',
                      inactiveColor:
                          _physicalRating == null
                              ? theme.colorScheme.surfaceContainerHighest
                              : null,
                      onChanged: (value) {
                        setState(() {
                          _physicalRating = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: Text(
                      _physicalRating?.toStringAsFixed(1) ?? 'Not Set',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            _physicalRating == null
                                ? theme.colorScheme.onSurfaceVariant
                                : null,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed:
                        _physicalRating != null
                            ? () {
                              setState(() {
                                _physicalRating = null;
                              });
                            }
                            : () {},
                    style: TextButton.styleFrom(
                      foregroundColor:
                          _physicalRating != null
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant.withOpacity(
                                0.3,
                              ),
                    ),
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
              Text('Location', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_latitude != null && _longitude != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 24,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Location Set',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onPrimaryContainer
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openMapPicker,
                            icon: const Icon(Icons.map, size: 18),
                            label: const Text('Edit on Map'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                _latitude = null;
                                _longitude = null;
                                _latitudeController.clear();
                                _longitudeController.clear();
                              });
                            },
                            icon: const Icon(Icons.clear, size: 18),
                            label: const Text('Clear'),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                FilledButton.icon(
                  onPressed: _openMapPicker,
                  icon: const Icon(Icons.map),
                  label: const Text('Select Location on Map'),
                ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: _isSubmitting ? null : _confirmDelete,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  Row(
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text('Update'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Open map picker to select or edit location
  Future<void> _openMapPicker() async {
    final result = await Navigator.push<LatLng?>(
      context,
      MaterialPageRoute(
        builder:
            (context) => LocationMapPicker(
              initialLatitude: _latitude,
              initialLongitude: _longitude,
              title: 'Select Location',
            ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
        _latitudeController.text = result.latitude.toString();
        _longitudeController.text = result.longitude.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location updated'),
          duration: Duration(seconds: 2),
        ),
      );
    } else if (result == null && mounted) {
      // User cleared location
      setState(() {
        _latitude = null;
        _longitude = null;
        _latitudeController.clear();
        _longitudeController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location cleared'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

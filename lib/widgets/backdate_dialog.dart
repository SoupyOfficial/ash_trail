import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/enums.dart';
import '../services/log_record_service.dart';
import '../services/validation_service.dart';
import '../providers/account_provider.dart';

/// Dialog for backdating a log entry
class BackdateDialog extends ConsumerStatefulWidget {
  final EventType? defaultEventType;
  final double? defaultDuration;
  final Unit? defaultUnit;

  const BackdateDialog({
    Key? key,
    this.defaultEventType,
    this.defaultDuration,
    this.defaultUnit,
  }) : super(key: key);

  @override
  ConsumerState<BackdateDialog> createState() => _BackdateDialogState();
}

class _BackdateDialogState extends ConsumerState<BackdateDialog> {
  DateTime _selectedDateTime = DateTime.now();
  EventType _eventType = EventType.inhale;
  double _duration = 1.0;
  Unit _unit = Unit.count;
  final _notesController = TextEditingController();
  double? _moodRating;
  double? _physicalRating;

  @override
  void initState() {
    super.initState();
    _eventType = widget.defaultEventType ?? EventType.inhale;
    _duration = widget.defaultDuration ?? 1.0;
    _unit = widget.defaultUnit ?? Unit.count;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
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

  void _setQuickTime(Duration offset) {
    setState(() {
      _selectedDateTime = DateTime.now().add(offset);
    });
  }

  Future<void> _createBackdatedLog() async {
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
      // Validate duration
      final validatedDuration =
          ValidationService.clampValue(_duration, _unit) ?? _duration;

      final record = await service.backdateLog(
        accountId: activeAccount.userId,
        eventType: _eventType,
        duration: validatedDuration,
        unit: _unit,
        eventAt: _selectedDateTime,
        note: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (mounted) {
        Navigator.pop(context, record);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Logged ${_eventType.name} at ${DateFormat.yMd().add_jm().format(_selectedDateTime)}',
            ),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () async {
                await service.deleteLogRecord(record);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating log: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final difference = now.difference(_selectedDateTime);

    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Backdate Log', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 24),

              // Date/Time Display
              Card(
                color: theme.colorScheme.primaryContainer,
                child: InkWell(
                  onTap: _selectDateTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat.yMd().add_jm().format(
                                _selectedDateTime,
                              ),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTimeDifference(difference),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick time buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _buildQuickTimeChip(
                    '10 min ago',
                    const Duration(minutes: -10),
                  ),
                  _buildQuickTimeChip(
                    '30 min ago',
                    const Duration(minutes: -30),
                  ),
                  _buildQuickTimeChip('1 hour ago', const Duration(hours: -1)),
                  _buildQuickTimeChip('2 hours ago', const Duration(hours: -2)),
                  _buildQuickTimeChip('6 hours ago', const Duration(hours: -6)),
                  _buildQuickTimeChip(
                    '12 hours ago',
                    const Duration(hours: -12),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Event Type
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
                        child: Text(type.name),
                      );
                    }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _eventType = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              // Duration and Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _duration = double.tryParse(value) ?? 1.0;
                      },
                      controller: TextEditingController(
                        text: _duration.toString(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
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
                              child: Text(unit.name),
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

              // Mood rating slider
              Text(
                'Mood Rating (optional)',
                style: theme.textTheme.labelMedium,
              ),
              Slider(
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

              // Physical rating slider
              Text(
                'Physical Rating (optional)',
                style: theme.textTheme.labelMedium,
              ),
              Slider(
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

              const SizedBox(height: 16),

              // Notes
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _createBackdatedLog,
                    icon: const Icon(Icons.check),
                    label: const Text('CREATE LOG'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTimeChip(String label, Duration offset) {
    return ActionChip(
      label: Text(label),
      onPressed: () => _setQuickTime(offset),
    );
  }

  String _formatTimeDifference(Duration difference) {
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'just now';
    }
  }
}

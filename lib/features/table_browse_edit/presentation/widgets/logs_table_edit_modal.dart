// Edit modal widget for logs table
// Provides inline editing interface for smoke log data

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/models/smoke_log.dart';

/// Modal for editing smoke log data
/// Provides form interface for updating duration and notes
class LogsTableEditModal extends StatefulWidget {
  final SmokeLog log;
  final Future<void> Function(SmokeLog) onSave;

  const LogsTableEditModal({
    super.key,
    required this.log,
    required this.onSave,
  });

  @override
  State<LogsTableEditModal> createState() => _LogsTableEditModalState();
}

class _LogsTableEditModalState extends State<LogsTableEditModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _durationController;
  late final TextEditingController _notesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _durationController = TextEditingController(
      text: (widget.log.durationMs / 60000).round().toString(),
    );
    _notesController = TextEditingController(
      text: widget.log.notes ?? '',
    );
  }

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Edit Log',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const Spacer(),
                    TextButton(
                      key: const Key('logs_edit_cancel_top'),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      key: const Key('logs_edit_save_top'),
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ],
                ),
              ),

              // Form content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Log info (read-only)
                      _buildInfoSection(context),

                      const SizedBox(height: 24),

                      // Duration field
                      _buildDurationField(context),

                      const SizedBox(height: 16),

                      // Notes field
                      _buildNotesField(context),

                      const SizedBox(height: 24),

                      // Save/Cancel buttons (mobile-friendly)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              key: const Key('logs_edit_cancel'),
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              key: const Key('logs_edit_save'),
                              onPressed: _isSaving ? null : _handleSave,
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Text('Save Changes'),
                            ),
                          ),
                        ],
                      ),

                      // Bottom padding for keyboard
                      SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build log info section (read-only data)
  Widget _buildInfoSection(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Date', _formatDateTime(widget.log.ts)),
            _buildInfoRow('Method', widget.log.methodId ?? 'Unknown'),
            _buildInfoRow('Mood Score', widget.log.moodScore.toString()),
            _buildInfoRow(
                'Physical Score', widget.log.physicalScore.toString()),
            if (widget.log.potency != null)
              _buildInfoRow('Potency', widget.log.potency.toString()),
          ],
        ),
      ),
    );
  }

  /// Build info row for read-only data
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  /// Build duration field
  Widget _buildDurationField(BuildContext context) {
    return TextFormField(
      key: const Key('logs_edit_duration'),
      controller: _durationController,
      decoration: const InputDecoration(
        labelText: 'Duration (minutes)',
        helperText: 'How long did this session last?',
        prefixIcon: Icon(Icons.timer),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a duration';
        }

        final minutes = int.tryParse(value);
        if (minutes == null) {
          return 'Please enter a valid number';
        }

        if (minutes <= 0) {
          return 'Duration must be greater than 0';
        }

        if (minutes > 480) {
          // 8 hours max
          return 'Duration cannot exceed 8 hours';
        }

        return null;
      },
    );
  }

  /// Build notes field
  Widget _buildNotesField(BuildContext context) {
    return TextFormField(
      key: const Key('logs_edit_notes'),
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes (optional)',
        helperText: 'Add any additional details about this session',
        prefixIcon: Icon(Icons.note),
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  /// Handle save button press
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final durationMinutes = int.parse(_durationController.text);
      final updatedLog = widget.log.copyWith(
        durationMs: durationMinutes * 60000, // Convert minutes to milliseconds
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await widget.onSave(updatedLog);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Log updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update log: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Format datetime for display
  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour =
        date.hour == 0 ? 12 : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour < 12 ? 'AM' : 'PM';

    return '$month/$day/$year at $hour:$minute $period';
  }
}

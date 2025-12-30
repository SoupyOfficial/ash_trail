import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../providers/log_record_provider.dart';
import '../widgets/quick_log_widget.dart';
import '../widgets/template_selector_widget.dart';
import '../widgets/backdate_dialog.dart';

/// Dedicated logging screen for detailed event entry
/// Provides a full-screen experience for creating log entries with all options
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
    _tabController = TabController(length: 3, vsync: this);
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
            Tab(icon: Icon(Icons.bolt), text: 'Quick'),
            Tab(icon: Icon(Icons.edit_note), text: 'Detailed'),
            Tab(icon: Icon(Icons.history), text: 'Backdate'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _QuickLogTab(accountId: accountId),
          _DetailedLogTab(accountId: accountId),
          _BackdateLogTab(accountId: accountId),
        ],
      ),
    );
  }
}

/// Quick log tab - fast single-tap logging
class _QuickLogTab extends ConsumerWidget {
  final String accountId;

  const _QuickLogTab({required this.accountId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Main quick log button
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text(
                    'Quick Log',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap for instant log • Long press for duration',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: QuickLogWidget(
                      onLogCreated: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Event logged!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Templates section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Templates',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Quick access to your saved templates',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TemplateSelectorWidget(
                    onTemplateUsed: () {
                      // Template logging is handled by the widget
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick event type buttons
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Events',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _QuickEventChip(
                        eventType: EventType.inhale,
                        label: 'Inhale',
                        icon: Icons.air,
                        accountId: accountId,
                      ),
                      _QuickEventChip(
                        eventType: EventType.note,
                        label: 'Note',
                        icon: Icons.note,
                        accountId: accountId,
                      ),
                      _QuickEventChip(
                        eventType: EventType.tolerance,
                        label: 'Tolerance',
                        icon: Icons.trending_up,
                        accountId: accountId,
                      ),
                      _QuickEventChip(
                        eventType: EventType.symptomRelief,
                        label: 'Relief',
                        icon: Icons.healing,
                        accountId: accountId,
                      ),
                    ],
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

/// Quick event chip for fast logging
class _QuickEventChip extends ConsumerWidget {
  final EventType eventType;
  final String label;
  final IconData icon;
  final String accountId;

  const _QuickEventChip({
    required this.eventType,
    required this.label,
    required this.icon,
    required this.accountId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () async {
        final service = ref.read(logRecordServiceProvider);
        try {
          await service.createLogRecord(
            accountId: accountId,
            eventType: eventType,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('$label logged')));
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        }
      },
    );
  }
}

/// Detailed log tab - full form with all options
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
  final _valueController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagsController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _valueController.dispose();
    _noteController.dispose();
    _tagsController.dispose();
    _locationController.dispose();
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

            // Value and Unit
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Value',
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
                            controller: _valueController,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (value) {
                              draftNotifier.setValue(double.tryParse(value));
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<Unit>(
                            value: draft.unit,
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
                                draftNotifier.setUnit(value);
                              }
                            },
                          ),
                        ),
                      ],
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
                      'Reason (optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('None'),
                          selected: draft.reason == null,
                          onSelected: (_) => draftNotifier.setReason(null),
                        ),
                        ...LogReason.values.map((reason) {
                          return ChoiceChip(
                            avatar: Icon(reason.icon, size: 18),
                            label: Text(reason.displayName),
                            selected: draft.reason == reason,
                            onSelected: (_) => draftNotifier.setReason(reason),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Mood and Craving
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How are you feeling?',
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
                            value: draft.mood ?? 5.0,
                            min: 0,
                            max: 10,
                            divisions: 20,
                            label: draft.mood?.toStringAsFixed(1) ?? 'Not set',
                            onChanged: (value) => draftNotifier.setMood(value),
                          ),
                        ),
                        const Icon(Icons.sentiment_very_satisfied, size: 20),
                        SizedBox(
                          width: 50,
                          child: Text(
                            draft.mood?.toStringAsFixed(1) ?? '-',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),

                    // Craving slider
                    Row(
                      children: [
                        const SizedBox(width: 80, child: Text('Craving')),
                        const Icon(Icons.thumb_down, size: 20),
                        Expanded(
                          child: Slider(
                            value: draft.craving ?? 5.0,
                            min: 0,
                            max: 10,
                            divisions: 20,
                            label:
                                draft.craving?.toStringAsFixed(1) ?? 'Not set',
                            activeColor:
                                Theme.of(context).colorScheme.secondary,
                            onChanged:
                                (value) => draftNotifier.setCraving(value),
                          ),
                        ),
                        const Icon(Icons.thumb_up, size: 20),
                        SizedBox(
                          width: 50,
                          child: Text(
                            draft.craving?.toStringAsFixed(1) ?? '-',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Notes and Tags
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Details',
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma-separated)',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., morning, relaxation',
                      ),
                      onChanged: (value) {
                        final tags =
                            value
                                .split(',')
                                .map((s) => s.trim())
                                .where((s) => s.isNotEmpty)
                                .toList();
                        draftNotifier.setTags(tags);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                        hintText: 'e.g., home, work',
                      ),
                      onChanged: (value) => draftNotifier.setLocation(value),
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
                              _valueController.clear();
                              _noteController.clear();
                              _tagsController.clear();
                              _locationController.clear();
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
      final service = ref.read(logRecordServiceProvider);

      await service.createLogRecord(
        accountId: widget.accountId,
        eventType: draft.eventType,
        eventAt: draft.eventTime,
        value: draft.value,
        unit: draft.unit,
        note: draft.note,
        tags: draft.tags.isEmpty ? null : draft.tags,
        mood: draft.mood,
        craving: draft.craving,
        reason: draft.reason,
        location: draft.location,
      );

      if (mounted) {
        // Reset form
        ref.read(logDraftProvider.notifier).reset();
        _valueController.clear();
        _noteController.clear();
        _tagsController.clear();
        _locationController.clear();

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

/// Backdate log tab - log events from the past
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
                    'Log an event that happened in the past',
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

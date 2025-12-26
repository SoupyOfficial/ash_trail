import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../models/session.dart';
import '../providers/session_provider.dart';

/// Session controls widget with start/stop and live timer
class SessionControlsWidget extends ConsumerStatefulWidget {
  final bool compact;

  const SessionControlsWidget({Key? key, this.compact = false})
    : super(key: key);

  @override
  ConsumerState<SessionControlsWidget> createState() =>
      _SessionControlsWidgetState();
}

class _SessionControlsWidgetState extends ConsumerState<SessionControlsWidget> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Update UI every second when session is active
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _startSession() async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => const _StartSessionDialog(),
    );

    if (result != null) {
      final notifier = ref.read(sessionNotifierProvider.notifier);
      await notifier.startSession(
        name: result['name'] as String?,
        notes: result['notes'] as String?,
        tags: result['tags'] as List<String>?,
        location: result['location'] as String?,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session started'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _endSession(Session session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('End Session?'),
            content: Text(
              'End "${session.name ?? 'Unnamed Session'}"?\n\n'
              'Duration: ${_formatDuration(session.currentDuration)}\n'
              'Logs: ${session.entryCount}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('END SESSION'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final notifier = ref.read(sessionNotifierProvider.notifier);
      await notifier.endSession(session);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Session ended - ${session.entryCount} logs in ${_formatDuration(session.currentDuration)}',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(activeSessionProvider);

    return sessionAsync.when(
      data: (session) {
        if (session == null) {
          return _buildStartButton();
        }
        return widget.compact
            ? _buildCompactSessionDisplay(session)
            : _buildFullSessionDisplay(session);
      },
      loading:
          () => const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      error: (_, __) => _buildStartButton(),
    );
  }

  Widget _buildStartButton() {
    if (widget.compact) {
      return IconButton(
        icon: const Icon(Icons.play_circle_outline),
        tooltip: 'Start Session',
        onPressed: _startSession,
      );
    }

    return OutlinedButton.icon(
      onPressed: _startSession,
      icon: const Icon(Icons.play_circle_outline),
      label: const Text('Start Session'),
    );
  }

  Widget _buildCompactSessionDisplay(Session session) {
    final theme = Theme.of(context);
    final duration = session.currentDuration;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            _formatDuration(duration),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _endSession(session),
            child: Icon(
              Icons.stop_circle,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullSessionDisplay(Session session) {
    final theme = Theme.of(context);
    final duration = session.currentDuration;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle, size: 12, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    session.name ?? 'Active Session',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.stop_circle),
                  color: theme.colorScheme.error,
                  onPressed: () => _endSession(session),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetric(
                  'Duration',
                  _formatDuration(duration),
                  Icons.timer_outlined,
                ),
                _buildMetric('Logs', '${session.entryCount}', Icons.list),
                if (session.averageValue != null)
                  _buildMetric(
                    'Average',
                    session.averageValue!.toStringAsFixed(1),
                    Icons.analytics_outlined,
                  ),
              ],
            ),
            if (session.notes != null && session.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                session.notes!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

/// Dialog for starting a new session
class _StartSessionDialog extends StatefulWidget {
  const _StartSessionDialog({Key? key}) : super(key: key);

  @override
  State<_StartSessionDialog> createState() => _StartSessionDialogState();
}

class _StartSessionDialogState extends State<_StartSessionDialog> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  final List<String> _tags = [];

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final cleaned = tag.trim();
    if (cleaned.isNotEmpty && !_tags.contains(cleaned)) {
      setState(() {
        _tags.add(cleaned);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Start Session'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Session Name (optional)',
                hintText: 'e.g., Morning routine',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'Additional details',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (optional)',
                hintText: 'e.g., Home',
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ..._tags.map(
                  (tag) =>
                      Chip(label: Text(tag), onDeleted: () => _removeTag(tag)),
                ),
                ActionChip(
                  label: const Text('+ Tag'),
                  onPressed: () async {
                    final tag = await showDialog<String>(
                      context: context,
                      builder: (context) => _AddTagDialog(),
                    );
                    if (tag != null) {
                      _addTag(tag);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context, {
              'name':
                  _nameController.text.isEmpty ? null : _nameController.text,
              'notes':
                  _notesController.text.isEmpty ? null : _notesController.text,
              'location':
                  _locationController.text.isEmpty
                      ? null
                      : _locationController.text,
              'tags': _tags.isEmpty ? null : _tags,
            });
          },
          icon: const Icon(Icons.play_circle),
          label: const Text('START'),
        ),
      ],
    );
  }
}

/// Dialog for adding a tag
class _AddTagDialog extends StatefulWidget {
  @override
  State<_AddTagDialog> createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<_AddTagDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Tag'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Tag',
          hintText: 'e.g., stress',
        ),
        autofocus: true,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.pop(context, value.trim());
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        FilledButton(
          onPressed: () {
            if (_controller.text.trim().isNotEmpty) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          child: const Text('ADD'),
        ),
      ],
    );
  }
}

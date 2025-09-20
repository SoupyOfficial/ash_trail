// Widget for displaying Siri shortcuts configuration and status.
// Provides UI for managing shortcut donations and status.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/siri_shortcuts_entity.dart';
import '../providers/siri_shortcuts_providers.dart';

class SiriShortcutsWidget extends ConsumerWidget {
  const SiriShortcutsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(siriShortcutsControllerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.mic, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Siri Shortcuts',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!state.isSupported) ...[
              const Text(
                'Siri shortcuts are not supported on this platform.',
                style: TextStyle(color: Colors.grey),
              ),
            ] else ...[
              _buildShortcutsList(context, state),
              const SizedBox(height: 16),
              _buildDonateButton(context, ref, state),
            ],
            if (state.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutsList(BuildContext context, SiriShortcutsState state) {
    if (state.status == SiriShortcutsStatus.loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state.shortcuts.isEmpty) {
      return const Text(
        'No shortcuts configured. Tap "Donate Shortcuts" to set up Siri shortcuts.',
        style: TextStyle(color: Colors.grey),
      );
    }

    return Column(
      children: state.shortcuts.map((shortcut) {
        return _ShortcutTile(shortcut: shortcut);
      }).toList(),
    );
  }

  Widget _buildDonateButton(
      BuildContext context, WidgetRef ref, SiriShortcutsState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: state.isDonating
            ? null
            : () => ref
                .read(siriShortcutsControllerProvider.notifier)
                .donateShortcuts(),
        icon: state.isDonating
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.upload_outlined),
        label: Text(state.isDonating ? 'Donating...' : 'Donate Shortcuts'),
      ),
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({required this.shortcut});

  final SiriShortcutsEntity shortcut;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        shortcut.isDonated ? Icons.check_circle : Icons.radio_button_unchecked,
        color: shortcut.isDonated
            ? Theme.of(context).colorScheme.primary
            : Colors.grey,
      ),
      title: Text(shortcut.type.displayName),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('"${shortcut.effectivePhrase}"'),
          if (shortcut.invocationCount > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Used ${shortcut.invocationCount} time${shortcut.invocationCount == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
      trailing: shortcut.isDonated
          ? Chip(
              label: const Text('Active'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            )
          : const Chip(
              label: Text('Not Donated'),
              backgroundColor: Colors.grey,
            ),
    );
  }
}

// Screen for full Siri shortcuts management
class SiriShortcutsScreen extends ConsumerWidget {
  const SiriShortcutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Siri Shortcuts'),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(siriShortcutsControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Siri Shortcuts allow you to quickly access AshTrail features using voice commands or the Shortcuts app.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              const SiriShortcutsWidget(),
              const SizedBox(height: 24),
              const _ShortcutInstructionsWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutInstructionsWidget extends StatelessWidget {
  const _ShortcutInstructionsWidget();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 8),
                Text(
                  'How to Use',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
                '1. Tap "Donate Shortcuts" to make them available to Siri'),
            const SizedBox(height: 8),
            const Text(
                '2. Say "Hey Siri, Record my smoke" to add a quick log entry'),
            const SizedBox(height: 8),
            const Text(
                '3. Say "Hey Siri, Start timing my smoke" to begin a timed session'),
            const SizedBox(height: 8),
            const Text(
                '4. You can also find these shortcuts in the Shortcuts app'),
          ],
        ),
      ),
    );
  }
}

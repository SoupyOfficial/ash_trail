import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/models/tag.dart';
import '../providers/quick_tagging_providers.dart';

/// Displays top suggested tags as chips and allows selecting multiple.
/// Also provides an entry point to browse all tags.
class TagSuggestionChips extends ConsumerWidget {
  const TagSuggestionChips({super.key, required this.accountId});

  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestedAsync = ref.watch(suggestedTagsProvider(accountId));
    final selected = ref.watch(selectedTagsProvider);

    return suggestedAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
                strokeWidth: 2, key: ValueKey('tag_suggestions_loading')),
          ),
        ),
      ),
      error: (err, _) => _ErrorBanner(
          onRetry: () => ref.refresh(suggestedTagsProvider(accountId))),
      data: (tags) {
        return Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    for (final tag in tags)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(tag.name),
                          selected: selected.contains(tag.id),
                          onSelected: (_) => ref
                              .read(selectedTagsProvider.notifier)
                              .toggle(tag.id),
                          shape: const StadiumBorder(),
                          labelStyle: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ActionChip(
                      label: const Text('More'),
                      onPressed: () => _showAllTagsSheet(context, ref),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAllTagsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final asyncAll = ref.watch(allTagsProvider(accountId));
        final selected = ref.watch(selectedTagsProvider);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: asyncAll.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Failed to load tags'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => ref.refresh(allTagsProvider(accountId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
              data: (tags) => _AllTagsList(
                tags: tags,
                selected: selected,
                onToggle: (id) =>
                    ref.read(selectedTagsProvider.notifier).toggle(id),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Skeleton removed; using small CircularProgressIndicator instead

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          const Expanded(child: Text('Unable to load tags')),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _AllTagsList extends StatelessWidget {
  const _AllTagsList({
    required this.tags,
    required this.selected,
    required this.onToggle,
  });

  final List<Tag> tags;
  final Set<String> selected;
  final void Function(String id) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 4,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text('All Tags',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (_, i) {
              final tag = tags[i];
              final isSelected = selected.contains(tag.id);
              return ListTile(
                title: Text(tag.name),
                trailing: isSelected ? const Icon(Icons.check) : null,
                onTap: () => onToggle(tag.id),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: tags.length,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ),
      ],
    );
  }
}

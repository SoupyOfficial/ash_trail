import 'package:flutter/material.dart';
import '../services/validation_service.dart';

/// Widget for selecting and managing tags with quick presets
class TagsWidget extends StatefulWidget {
  final List<String> selectedTags;
  final ValueChanged<List<String>> onTagsChanged;
  final List<String>? quickTags;

  const TagsWidget({
    Key? key,
    required this.selectedTags,
    required this.onTagsChanged,
    this.quickTags,
  }) : super(key: key);

  @override
  State<TagsWidget> createState() => _TagsWidgetState();
}

class _TagsWidgetState extends State<TagsWidget> {
  final _customTagController = TextEditingController();
  late List<String> _tags;

  static const List<String> _defaultQuickTags = [
    'stress',
    'social',
    'bored',
    'sleepy',
    'anxious',
    'happy',
    'work',
    'home',
    'craving',
    'tired',
  ];

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.selectedTags);
  }

  @override
  void dispose() {
    _customTagController.dispose();
    super.dispose();
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_tags.contains(tag)) {
        _tags.remove(tag);
      } else {
        _tags.add(tag);
      }
      // Clean and notify
      _tags = ValidationService.cleanTags(_tags);
      widget.onTagsChanged(_tags);
    });
  }

  void _addCustomTag() {
    final tag = _customTagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tags = ValidationService.cleanTags(_tags);
        widget.onTagsChanged(_tags);
        _customTagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      widget.onTagsChanged(_tags);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quickTags = widget.quickTags ?? _defaultQuickTags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tags', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),

        // Quick tags
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              quickTags.map((tag) {
                final isSelected = _tags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (_) => _toggleTag(tag),
                  avatar:
                      isSelected
                          ? Icon(
                            Icons.check,
                            size: 16,
                            color: theme.colorScheme.onSecondaryContainer,
                          )
                          : null,
                );
              }).toList(),
        ),

        const SizedBox(height: 16),

        // Selected custom tags (not in quick tags)
        if (_tags.any((tag) => !quickTags.contains(tag))) ...[
          Text(
            'Custom Tags',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _tags
                    .where((tag) => !quickTags.contains(tag))
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => _removeTag(tag),
                        deleteIcon: const Icon(Icons.close, size: 18),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Add custom tag input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _customTagController,
                decoration: InputDecoration(
                  labelText: 'Add custom tag',
                  hintText: 'e.g., meeting',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addCustomTag,
                  ),
                ),
                onSubmitted: (_) => _addCustomTag(),
              ),
            ),
          ],
        ),

        if (_tags.length > 5) ...[
          const SizedBox(height: 8),
          Text(
            'Note: Consider using fewer tags for better organization',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact tags display widget
class TagsDisplayWidget extends StatelessWidget {
  final List<String> tags;
  final int maxDisplay;
  final VoidCallback? onTap;

  const TagsDisplayWidget({
    Key? key,
    required this.tags,
    this.maxDisplay = 3,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayTags = tags.take(maxDisplay).toList();
    final remainingCount = tags.length - displayTags.length;

    return InkWell(
      onTap: onTap,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          ...displayTags.map(
            (tag) => Chip(
              label: Text(tag, style: theme.textTheme.labelSmall),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
          if (remainingCount > 0)
            Chip(
              label: Text(
                '+$remainingCount',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              visualDensity: VisualDensity.compact,
              backgroundColor: theme.colorScheme.primaryContainer,
            ),
        ],
      ),
    );
  }
}

/// Tags input bottom sheet for quick tag selection
class TagsBottomSheet extends StatefulWidget {
  final List<String> initialTags;
  final List<String>? quickTags;

  const TagsBottomSheet({Key? key, required this.initialTags, this.quickTags})
    : super(key: key);

  static Future<List<String>?> show(
    BuildContext context, {
    required List<String> initialTags,
    List<String>? quickTags,
  }) {
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      builder:
          (context) =>
              TagsBottomSheet(initialTags: initialTags, quickTags: quickTags),
    );
  }

  @override
  State<TagsBottomSheet> createState() => _TagsBottomSheetState();
}

class _TagsBottomSheetState extends State<TagsBottomSheet> {
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Tags',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _tags.clear();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tags widget
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: TagsWidget(
                    selectedTags: _tags,
                    onTagsChanged: (tags) {
                      setState(() {
                        _tags = tags;
                      });
                    },
                    quickTags: widget.quickTags,
                  ),
                ),
              ),

              const SizedBox(height: 16),

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
                    onPressed: () => Navigator.pop(context, _tags),
                    icon: const Icon(Icons.check),
                    label: Text('APPLY (${_tags.length})'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/log_template.dart';
import '../services/log_record_service.dart';
import '../providers/template_provider.dart';
import '../providers/account_provider.dart';

/// Template selector widget for quick logging from presets
class TemplateSelectorWidget extends ConsumerStatefulWidget {
  final VoidCallback? onTemplateUsed;

  const TemplateSelectorWidget({Key? key, this.onTemplateUsed})
    : super(key: key);

  @override
  ConsumerState<TemplateSelectorWidget> createState() =>
      _TemplateSelectorWidgetState();
}

class _TemplateSelectorWidgetState
    extends ConsumerState<TemplateSelectorWidget> {
  bool _showAllTemplates = false;

  Future<void> _useTemplate(LogTemplate template) async {
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
      // Record usage
      final notifier = ref.read(templateNotifierProvider.notifier);
      await notifier.recordUsage(template);

      // Create log from template
      final record = await service.createFromTemplate(
        accountId: activeAccount.userId,
        eventType: template.eventType,
        defaultValue: template.defaultValue,
        defaultUnit: template.unit,
        defaultTags: template.defaultTags,
        noteTemplate: template.noteTemplate,
        defaultLocation: template.defaultLocation,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged from template: ${template.name}'),
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () async {
                await service.deleteLogRecord(record);
              },
            ),
          ),
        );

        widget.onTemplateUsed?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error using template: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(templatesProvider);
    final mostUsedAsync = ref.watch(mostUsedTemplatesProvider);
    final recentAsync = ref.watch(recentTemplatesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quick Templates',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showAllTemplates = !_showAllTemplates;
                  });
                },
                icon: Icon(
                  _showAllTemplates ? Icons.expand_less : Icons.expand_more,
                ),
                label: Text(_showAllTemplates ? 'Show Less' : 'Show All'),
              ),
            ],
          ),
        ),
        if (!_showAllTemplates) ...[
          // Most used section
          mostUsedAsync.when(
            data: (templates) {
              if (templates.isEmpty) return const SizedBox.shrink();
              return _buildTemplateSection('Most Used', templates);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          // Recent section
          recentAsync.when(
            data: (templates) {
              if (templates.isEmpty) return const SizedBox.shrink();
              return _buildTemplateSection('Recently Used', templates);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ] else ...[
          // All templates
          templatesAsync.when(
            data: (templates) {
              if (templates.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No templates yet. Create one to get started!'),
                  ),
                );
              }
              return _buildTemplateGrid(templates);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (error, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading templates: $error'),
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildTemplateSection(String title, List<LogTemplate> templates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              return _buildTemplateCard(templates[index], compact: true);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTemplateGrid(List<LogTemplate> templates) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return _buildTemplateCard(templates[index]);
      },
    );
  }

  Widget _buildTemplateCard(LogTemplate template, {bool compact = false}) {
    final theme = Theme.of(context);
    final color = _parseColor(template.color) ?? theme.colorScheme.primary;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _useTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  if (template.icon != null)
                    Icon(
                      _parseIcon(template.icon!),
                      color: color,
                      size: compact ? 24 : 32,
                    )
                  else
                    Icon(Icons.bookmark, color: color, size: compact ? 24 : 32),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      template.name,
                      style:
                          compact
                              ? theme.textTheme.titleSmall
                              : theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (!compact && template.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  template.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${template.usageCount} uses',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color? _parseColor(String? colorString) {
    if (colorString == null) return null;
    try {
      // Support hex colors like "#FF5733" or "0xFFFF5733"
      final hexString = colorString.replaceAll('#', '0xff');
      return Color(int.parse(hexString));
    } catch (e) {
      return null;
    }
  }

  IconData _parseIcon(String iconString) {
    // Simple icon name to IconData mapping
    final iconMap = {
      'smoke': Icons.smoking_rooms,
      'coffee': Icons.coffee,
      'water': Icons.water_drop,
      'exercise': Icons.fitness_center,
      'food': Icons.restaurant,
      'sleep': Icons.bedtime,
      'mood': Icons.sentiment_satisfied,
      'star': Icons.star,
      'favorite': Icons.favorite,
      'check': Icons.check_circle,
      'alert': Icons.warning,
    };

    return iconMap[iconString.toLowerCase()] ?? Icons.bookmark;
  }
}

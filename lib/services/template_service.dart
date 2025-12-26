import 'package:uuid/uuid.dart';
import '../models/log_template.dart';
import '../models/enums.dart';
import '../repositories/template_repository.dart';
import 'database_service.dart';

/// TemplateService manages logging templates/presets
/// Provides CRUD operations for quick logging templates
class TemplateService {
  late final TemplateRepository _repository;
  final Uuid _uuid = const Uuid();

  TemplateService() {
    // Initialize repository with Hive database
    final dbService = DatabaseService.instance;
    final dbBoxes = dbService.boxes;

    _repository = createTemplateRepository(
      dbBoxes is Map<String, dynamic> ? dbBoxes : null,
    );
  }

  /// Create a new template
  Future<LogTemplate> createTemplate({
    required String accountId,
    String? profileId,
    required String name,
    String? description,
    required EventType eventType,
    double? defaultValue,
    Unit unit = Unit.none,
    String? noteTemplate,
    List<String>? defaultTags,
    String? defaultLocation,
    String? icon,
    String? color,
    int sortOrder = 0,
  }) async {
    final templateId = _uuid.v4();
    final now = DateTime.now();

    final template = LogTemplate.create(
      templateId: templateId,
      accountId: accountId,
      profileId: profileId,
      name: name,
      description: description,
      eventType: eventType,
      defaultValue: defaultValue,
      unit: unit,
      noteTemplate: noteTemplate,
      defaultTagsString: defaultTags?.join(','),
      defaultLocation: defaultLocation,
      icon: icon,
      color: color,
      sortOrder: sortOrder,
      createdAt: now,
      isActive: true,
    );

    return await _repository.create(template);
  }

  /// Update an existing template
  Future<LogTemplate> updateTemplate(
    LogTemplate template, {
    String? name,
    String? description,
    EventType? eventType,
    double? defaultValue,
    Unit? unit,
    String? noteTemplate,
    List<String>? defaultTags,
    String? defaultLocation,
    String? icon,
    String? color,
    int? sortOrder,
    bool? isActive,
  }) async {
    final updated = template.copyWith(
      name: name,
      description: description,
      eventType: eventType,
      defaultValue: defaultValue,
      unit: unit,
      noteTemplate: noteTemplate,
      defaultTagsString: defaultTags?.join(','),
      defaultLocation: defaultLocation,
      icon: icon,
      color: color,
      sortOrder: sortOrder,
      updatedAt: DateTime.now(),
      isActive: isActive,
    );

    return await _repository.update(updated);
  }

  /// Delete a template (soft delete)
  Future<void> deleteTemplate(LogTemplate template) async {
    template.softDelete();
    await _repository.delete(template);
  }

  /// Hard delete a template
  Future<void> hardDeleteTemplate(LogTemplate template) async {
    await _repository.delete(
      template,
    ); // Repository delete is already hard delete for this case
  }

  /// Get template by ID
  Future<LogTemplate?> getTemplate(String templateId) async {
    return await _repository.getByTemplateId(templateId);
  }

  /// Get all templates for an account
  Future<List<LogTemplate>> getTemplates({
    required String accountId,
    String? profileId,
    bool includeDeleted = false,
    bool activeOnly = true,
  }) async {
    // Get templates from repository and filter in memory
    List<LogTemplate> templates;

    if (activeOnly) {
      templates = await _repository.getActiveByAccount(accountId);
    } else {
      // Get all by fetching active and filtering
      templates = await _repository.getActiveByAccount(accountId);
      // For non-active, we'd need to fetch all - for now just return active
      // A full implementation would need a getAll method in repository
    }

    // Apply additional filters
    templates =
        templates.where((template) {
          if (!includeDeleted && template.isDeleted) return false;
          if (profileId != null && template.profileId != profileId)
            return false;
          return true;
        }).toList();

    // Sort by sortOrder then name
    templates.sort((a, b) {
      final orderCompare = a.sortOrder.compareTo(b.sortOrder);
      if (orderCompare != 0) return orderCompare;
      return a.name.compareTo(b.name);
    });

    return templates;
  }

  /// Record template usage
  Future<void> recordUsage(LogTemplate template) async {
    template.recordUsage();
    await _repository.update(template);
  }

  /// Get most used templates
  Future<List<LogTemplate>> getMostUsedTemplates({
    required String accountId,
    String? profileId,
    int limit = 5,
  }) async {
    final templates = await _repository.getActiveByAccount(accountId);

    // Filter by profile if needed
    final filtered =
        profileId == null
            ? templates
            : templates.where((t) => t.profileId == profileId).toList();

    // Sort by usage count descending
    filtered.sort((a, b) => b.usageCount.compareTo(a.usageCount));

    return filtered.take(limit).toList();
  }

  /// Get recently used templates
  Future<List<LogTemplate>> getRecentlyUsedTemplates({
    required String accountId,
    String? profileId,
    int limit = 5,
  }) async {
    final templates = await _repository.getActiveByAccount(accountId);

    // Filter by profile and lastUsedAt
    final filtered =
        templates.where((t) {
          if (t.lastUsedAt == null) return false;
          if (profileId != null && t.profileId != profileId) return false;
          return true;
        }).toList();

    // Sort by lastUsedAt descending
    filtered.sort((a, b) => b.lastUsedAt!.compareTo(a.lastUsedAt!));

    return filtered.take(limit).toList();
  }

  /// Reorder templates
  Future<void> reorderTemplates(List<LogTemplate> templates) async {
    for (int i = 0; i < templates.length; i++) {
      templates[i] = templates[i].copyWith(
        sortOrder: i,
        updatedAt: DateTime.now(),
      );
      await _repository.update(templates[i]);
    }
  }

  /// Watch templates for real-time updates
  Stream<List<LogTemplate>> watchTemplates({
    required String accountId,
    String? profileId,
    bool activeOnly = true,
  }) {
    Stream<List<LogTemplate>> stream;

    if (activeOnly) {
      stream = _repository.watchActiveByAccount(accountId);
    } else {
      stream = _repository.watchByAccount(accountId);
    }

    return stream.map((templates) {
      // Filter by profile if needed
      var filtered =
          profileId == null
              ? templates
              : templates.where((t) => t.profileId == profileId).toList();

      // Sort by sortOrder then name
      filtered.sort((a, b) {
        final orderCompare = a.sortOrder.compareTo(b.sortOrder);
        if (orderCompare != 0) return orderCompare;
        return a.name.compareTo(b.name);
      });

      return filtered;
    });
  }

  /// Create default templates for a new account
  Future<List<LogTemplate>> createDefaultTemplates({
    required String accountId,
    String? profileId,
  }) async {
    final templates = [
      await createTemplate(
        accountId: accountId,
        profileId: profileId,
        name: 'Quick Hit',
        description: 'Standard single inhale',
        eventType: EventType.inhale,
        defaultValue: 6,
        unit: Unit.seconds,
        icon: '💨',
        sortOrder: 0,
      ),
      await createTemplate(
        accountId: accountId,
        profileId: profileId,
        name: 'Morning',
        description: 'Morning session',
        eventType: EventType.sessionStart,
        noteTemplate: 'Morning session',
        defaultTags: ['morning', 'routine'],
        icon: '☀️',
        sortOrder: 1,
      ),
      await createTemplate(
        accountId: accountId,
        profileId: profileId,
        name: 'Evening',
        description: 'Evening session',
        eventType: EventType.sessionStart,
        noteTemplate: 'Evening session',
        defaultTags: ['evening', 'routine'],
        icon: '🌙',
        sortOrder: 2,
      ),
      await createTemplate(
        accountId: accountId,
        profileId: profileId,
        name: 'Social',
        description: 'Social setting',
        eventType: EventType.inhale,
        defaultValue: 5,
        unit: Unit.seconds,
        defaultTags: ['social'],
        icon: '👥',
        sortOrder: 3,
      ),
    ];

    return templates;
  }
}

import '../models/log_template.dart';
import '../models/enums.dart';
import 'template_repository_hive.dart';

/// Abstract repository interface for LogTemplate data access
/// Uses Hive for local storage on all platforms
abstract class TemplateRepository {
  /// Create a new template
  Future<LogTemplate> create(LogTemplate template);

  /// Update an existing template
  Future<LogTemplate> update(LogTemplate template);

  /// Delete a template (soft delete)
  Future<void> delete(LogTemplate template);

  /// Get template by templateId
  Future<LogTemplate?> getByTemplateId(String templateId);

  /// Get all active templates for an account
  Future<List<LogTemplate>> getActiveByAccount(String accountId);

  /// Get templates by event type
  Future<List<LogTemplate>> getByEventType(
    String accountId,
    EventType eventType,
  );

  /// Get favorite templates
  Future<List<LogTemplate>> getFavorites(String accountId);

  /// Count templates for account
  Future<int> countByAccount(String accountId);

  /// Watch all templates for account
  Stream<List<LogTemplate>> watchByAccount(String accountId);

  /// Watch active templates
  Stream<List<LogTemplate>> watchActiveByAccount(String accountId);
}

/// Factory to create TemplateRepository using Hive
TemplateRepository createTemplateRepository([dynamic context]) {
  return TemplateRepositoryHive(context as Map<String, dynamic>);
}

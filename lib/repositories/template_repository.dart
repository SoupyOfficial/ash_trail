import '../models/log_template.dart';
import '../models/enums.dart';
import 'template_repository_stub.dart'
    if (dart.library.io) 'template_repository_native.dart'
    if (dart.library.js_interop) 'template_repository_web.dart';

/// Abstract repository interface for LogTemplate data access
/// Platform-specific implementations handle Isar (native) or Hive (web)
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

/// Factory to create platform-specific TemplateRepository
TemplateRepository createTemplateRepository([dynamic context]) {
  if (context is Map<String, dynamic>) {
    return TemplateRepositoryWeb(context);
  }
  return TemplateRepositoryNative();
}

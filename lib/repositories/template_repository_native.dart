import 'package:isar/isar.dart';
import '../models/log_template.dart';
import '../models/enums.dart';
import '../services/isar_service.dart';
import 'template_repository.dart';

/// Native implementation of TemplateRepository using Isar
class TemplateRepositoryNative implements TemplateRepository {
  final Isar _isar = IsarService.instance;

  @override
  Future<LogTemplate> create(LogTemplate template) async {
    await _isar.writeTxn(() async {
      await _isar.logTemplates.put(template);
    });
    return template;
  }

  @override
  Future<LogTemplate> update(LogTemplate template) async {
    await _isar.writeTxn(() async {
      await _isar.logTemplates.put(template);
    });
    return template;
  }

  @override
  Future<void> delete(LogTemplate template) async {
    await _isar.writeTxn(() async {
      await _isar.logTemplates.put(template);
    });
  }

  @override
  Future<LogTemplate?> getByTemplateId(String templateId) async {
    return await _isar.logTemplates
        .filter()
        .templateIdEqualTo(templateId)
        .findFirst();
  }

  @override
  Future<List<LogTemplate>> getActiveByAccount(String accountId) async {
    return await _isar.logTemplates
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .isActiveEqualTo(true)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .sortBySortOrder()
        .findAll();
  }

  @override
  Future<List<LogTemplate>> getByEventType(
    String accountId,
    EventType eventType,
  ) async {
    return await _isar.logTemplates
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .eventTypeEqualTo(eventType)
        .and()
        .isActiveEqualTo(true)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .sortBySortOrder()
        .findAll();
  }

  @override
  Future<List<LogTemplate>> getFavorites(String accountId) async {
    // Since LogTemplate doesn't have isFavorite, return empty list or implement differently
    return [];
  }

  @override
  Future<int> countByAccount(String accountId) async {
    return await _isar.logTemplates
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .count();
  }

  @override
  Stream<List<LogTemplate>> watchByAccount(String accountId) {
    return _isar.logTemplates
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<LogTemplate>> watchActiveByAccount(String accountId) {
    return _isar.logTemplates
        .filter()
        .accountIdEqualTo(accountId)
        .and()
        .isActiveEqualTo(true)
        .and()
        .not()
        .isDeletedEqualTo(true)
        .watch(fireImmediately: true);
  }
}

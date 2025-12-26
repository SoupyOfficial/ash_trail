import '../models/log_template.dart';
import '../models/enums.dart';
import 'template_repository.dart';

class TemplateRepositoryStub implements TemplateRepository {
  @override
  Future<LogTemplate> create(LogTemplate template) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<LogTemplate> update(LogTemplate template) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<void> delete(LogTemplate template) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<LogTemplate?> getByTemplateId(String templateId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<List<LogTemplate>> getActiveByAccount(String accountId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<List<LogTemplate>> getByEventType(
    String accountId,
    EventType eventType,
  ) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<List<LogTemplate>> getFavorites(String accountId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Future<int> countByAccount(String accountId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Stream<List<LogTemplate>> watchByAccount(String accountId) {
    throw UnsupportedError('Platform not supported');
  }

  @override
  Stream<List<LogTemplate>> watchActiveByAccount(String accountId) {
    throw UnsupportedError('Platform not supported');
  }
}

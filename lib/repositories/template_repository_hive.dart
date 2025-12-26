import 'dart:async';
import 'package:hive/hive.dart';
import '../models/log_template.dart';
import '../models/web_models.dart';
import '../models/model_converters.dart';
import '../models/enums.dart';
import 'template_repository.dart';

/// Web implementation of TemplateRepository using Hive
class TemplateRepositoryHive implements TemplateRepository {
  late final Box _box;
  final _controller = StreamController<List<LogTemplate>>.broadcast();

  TemplateRepositoryHive(Map<String, dynamic> boxes) {
    _box = boxes['templates'] as Box;
    _box.watch().listen((_) => _emitChanges());
    // Emit initial state
    _emitChanges();
  }

  void _emitChanges() {
    _controller.add(_getAllTemplates());
  }

  List<LogTemplate> _getAllTemplates() {
    final templates = <LogTemplate>[];
    for (var key in _box.keys) {
      final json = Map<String, dynamic>.from(_box.get(key));
      final webTemplate = WebLogTemplate.fromJson(json);
      templates.add(
        LogTemplateWebConversion.fromWebModel(
          webTemplate,
          id: int.tryParse(webTemplate.id) ?? 0,
        ),
      );
    }
    return templates;
  }

  @override
  Future<LogTemplate> create(LogTemplate template) async {
    final webTemplate = template.toWebModel();
    await _box.put(template.templateId, webTemplate.toJson());
    return template;
  }

  @override
  Future<LogTemplate> update(LogTemplate template) async {
    final webTemplate = template.toWebModel();
    await _box.put(template.templateId, webTemplate.toJson());
    return template;
  }

  @override
  Future<void> delete(LogTemplate template) async {
    final webTemplate = template.toWebModel();
    await _box.put(template.templateId, webTemplate.toJson());
  }

  @override
  Future<LogTemplate?> getByTemplateId(String templateId) async {
    final json = _box.get(templateId);
    if (json == null) return null;
    final webTemplate = WebLogTemplate.fromJson(
      Map<String, dynamic>.from(json),
    );
    return LogTemplateWebConversion.fromWebModel(
      webTemplate,
      id: int.tryParse(webTemplate.id) ?? 0,
    );
  }

  @override
  Future<List<LogTemplate>> getActiveByAccount(String accountId) async {
    final templates =
        _getAllTemplates()
            .where(
              (t) => t.accountId == accountId && t.isActive && !t.isDeleted,
            )
            .toList();
    templates.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return templates;
  }

  @override
  Future<List<LogTemplate>> getByEventType(
    String accountId,
    EventType eventType,
  ) async {
    final templates =
        _getAllTemplates()
            .where(
              (t) =>
                  t.accountId == accountId &&
                  t.eventType == eventType &&
                  t.isActive &&
                  !t.isDeleted,
            )
            .toList();
    templates.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return templates;
  }

  @override
  Future<List<LogTemplate>> getFavorites(String accountId) async {
    // Since LogTemplate doesn't have isFavorite, return empty list or implement differently
    return [];
  }

  @override
  Future<int> countByAccount(String accountId) async {
    return _getAllTemplates()
        .where((t) => t.accountId == accountId && !t.isDeleted)
        .length;
  }

  @override
  Stream<List<LogTemplate>> watchByAccount(String accountId) {
    return _controller.stream.map(
      (templates) =>
          templates
              .where((t) => t.accountId == accountId && !t.isDeleted)
              .toList(),
    );
  }

  @override
  Stream<List<LogTemplate>> watchActiveByAccount(String accountId) {
    return _controller.stream.map(
      (templates) =>
          templates
              .where(
                (t) => t.accountId == accountId && t.isActive && !t.isDeleted,
              )
              .toList(),
    );
  }
}

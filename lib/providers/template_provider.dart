import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/log_template.dart';
import '../services/template_service.dart';
import 'account_provider.dart';

/// Template service provider
final templateServiceProvider = Provider<TemplateService>((ref) {
  return TemplateService();
});

/// Templates stream for active account
final templatesProvider = StreamProvider<List<LogTemplate>>((ref) {
  final activeAccount = ref.watch(activeAccountProvider);

  return activeAccount.when(
    data: (account) {
      if (account == null) {
        return Stream.value([]);
      }
      final service = ref.watch(templateServiceProvider);
      return service.watchTemplates(
        accountId: account.userId,
        activeOnly: true,
      );
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Most used templates
final mostUsedTemplatesProvider = FutureProvider<List<LogTemplate>>((
  ref,
) async {
  final activeAccount = await ref.watch(activeAccountProvider.future);

  if (activeAccount == null) {
    return [];
  }

  final service = ref.watch(templateServiceProvider);
  return service.getMostUsedTemplates(
    accountId: activeAccount.userId,
    limit: 5,
  );
});

/// Recently used templates
final recentTemplatesProvider = FutureProvider<List<LogTemplate>>((ref) async {
  final activeAccount = await ref.watch(activeAccountProvider.future);

  if (activeAccount == null) {
    return [];
  }

  final service = ref.watch(templateServiceProvider);
  return service.getRecentlyUsedTemplates(
    accountId: activeAccount.userId,
    limit: 5,
  );
});

/// Selected template state
final selectedTemplateProvider = StateProvider<LogTemplate?>((ref) => null);

/// Template CRUD notifier
final templateNotifierProvider =
    StateNotifierProvider<TemplateNotifier, AsyncValue<LogTemplate?>>((ref) {
      return TemplateNotifier(ref);
    });

class TemplateNotifier extends StateNotifier<AsyncValue<LogTemplate?>> {
  final Ref _ref;

  TemplateNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> createTemplate({
    required String name,
    String? description,
    required eventType,
    double? defaultValue,
    unit,
    String? noteTemplate,
    List<String>? defaultTags,
    String? defaultLocation,
    String? icon,
    String? color,
    int sortOrder = 0,
  }) async {
    state = const AsyncValue.loading();
    try {
      final activeAccount = await _ref.read(activeAccountProvider.future);

      if (activeAccount == null) {
        throw Exception('No active account selected');
      }

      final service = _ref.read(templateServiceProvider);
      final template = await service.createTemplate(
        accountId: activeAccount.userId,
        name: name,
        description: description,
        eventType: eventType,
        defaultValue: defaultValue,
        unit: unit,
        noteTemplate: noteTemplate,
        defaultTags: defaultTags,
        defaultLocation: defaultLocation,
        icon: icon,
        color: color,
        sortOrder: sortOrder,
      );

      state = AsyncValue.data(template);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTemplate(
    LogTemplate template, {
    String? name,
    String? description,
    eventType,
    double? defaultValue,
    unit,
    String? noteTemplate,
    List<String>? defaultTags,
    String? defaultLocation,
    String? icon,
    String? color,
    int? sortOrder,
    bool? isActive,
  }) async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(templateServiceProvider);
      final updated = await service.updateTemplate(
        template,
        name: name,
        description: description,
        eventType: eventType,
        defaultValue: defaultValue,
        unit: unit,
        noteTemplate: noteTemplate,
        defaultTags: defaultTags,
        defaultLocation: defaultLocation,
        icon: icon,
        color: color,
        sortOrder: sortOrder,
        isActive: isActive,
      );

      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteTemplate(LogTemplate template) async {
    state = const AsyncValue.loading();
    try {
      final service = _ref.read(templateServiceProvider);
      await service.deleteTemplate(template);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> recordUsage(LogTemplate template) async {
    try {
      final service = _ref.read(templateServiceProvider);
      await service.recordUsage(template);
    } catch (e) {
      // Silently fail - usage tracking is non-critical
    }
  }
}

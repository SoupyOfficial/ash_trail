// Repository implementation for managing accessibility configuration preferences.
// Provides a lightweight in-memory cache with platform capability integration.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:fpdart/fpdart.dart';

import '../../../../core/failures/app_failure.dart';
import '../../domain/entities/accessibility_config.dart';
import '../../domain/repositories/accessibility_config_repository.dart';
import '../models/accessibility_config_model.dart';

typedef SystemCapabilitiesResolver = Future<Map<String, dynamic>> Function();
typedef DateTimeProvider = DateTime Function();

class AccessibilityConfigRepositoryImpl
    implements AccessibilityConfigRepository {
  AccessibilityConfigRepositoryImpl({
    Map<String, AccessibilityConfigModel>? initialConfigs,
    SystemCapabilitiesResolver? systemCapabilitiesResolver,
    DateTimeProvider? now,
  })  : _cache = Map<String, AccessibilityConfigModel>.from(
            initialConfigs ?? const {}),
        _systemCapabilitiesResolver =
            systemCapabilitiesResolver ?? _defaultSystemCapabilitiesResolver,
        _now = now ?? DateTime.now;

  final Map<String, AccessibilityConfigModel> _cache;
  final SystemCapabilitiesResolver _systemCapabilitiesResolver;
  final DateTimeProvider _now;

  static Future<Map<String, dynamic>>
      _defaultSystemCapabilitiesResolver() async {
    final dispatcher = ui.PlatformDispatcher.instance;
    final features = dispatcher.accessibilityFeatures;

    double textScaleFactor = 1.0;
    try {
      textScaleFactor = dispatcher.textScaleFactor;
      if (!textScaleFactor.isFinite || textScaleFactor <= 0) {
        textScaleFactor = 1.0;
      }
    } catch (_) {
      textScaleFactor = 1.0;
    }

    return <String, dynamic>{
      'isScreenReaderEnabled': features.accessibleNavigation,
      'isBoldTextEnabled': features.boldText,
      'isReduceMotionEnabled': features.disableAnimations,
      'isHighContrastEnabled': features.highContrast,
      'textScaleFactor': textScaleFactor,
    };
  }

  AccessibilityConfigModel _createDefaultModel(String userId) {
    final now = _now();
    return AccessibilityConfigModel(
      userId: userId,
      createdAt: now,
      updatedAt: now,
      isScreenReaderEnabled: false,
      isBoldTextEnabled: false,
      isReduceMotionEnabled: false,
      isHighContrastEnabled: false,
      textScaleFactor: 1.0,
      enableHapticFeedback: true,
      enableSemanticLabels: true,
      minTapTargetSize: 48.0,
      enableFocusIndicators: true,
      enableCustomFocusOrder: true,
    );
  }

  @override
  Future<Either<AppFailure, AccessibilityConfig>> getConfig(
      String userId) async {
    try {
      final existing = _cache[userId] ?? _createDefaultModel(userId);
      _cache[userId] = existing;
      return right(existing.toEntity());
    } catch (error) {
      return left(AppFailure.cache(
        message: 'Failed to load accessibility configuration: $error',
      ));
    }
  }

  @override
  Future<Either<AppFailure, AccessibilityConfig>> updateConfig(
      AccessibilityConfig config) async {
    try {
      final updatedModel = AccessibilityConfigModel.fromEntity(
        config.copyWith(updatedAt: _now()),
      );
      _cache[config.userId] = updatedModel;
      return right(updatedModel.toEntity());
    } catch (error) {
      return left(AppFailure.cache(
        message: 'Failed to update accessibility configuration: $error',
      ));
    }
  }

  @override
  Future<Either<AppFailure, Map<String, dynamic>>>
      getSystemCapabilities() async {
    try {
      final capabilities = await _systemCapabilitiesResolver();
      return right(capabilities);
    } catch (error, stackTrace) {
      return left(AppFailure.unexpected(
        message: 'Failed to load system accessibility capabilities',
        cause: error,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<AppFailure, AccessibilityConfig>> initializeDefaults(
      String userId) async {
    try {
      final model = _createDefaultModel(userId);
      _cache[userId] = model;
      return right(model.toEntity());
    } catch (error) {
      return left(AppFailure.cache(
        message: 'Failed to initialize accessibility configuration: $error',
      ));
    }
  }
}

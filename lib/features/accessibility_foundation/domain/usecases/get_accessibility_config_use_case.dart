// Spec Header:
// Get Accessibility Configuration Use Case
// Retrieves current accessibility settings for a user including system capabilities.
// Assumption: Integrates system settings with user preferences for comprehensive config.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/accessibility_config.dart';
import '../repositories/accessibility_config_repository.dart';

class GetAccessibilityConfigUseCase {
  final AccessibilityConfigRepository _repository;

  const GetAccessibilityConfigUseCase({
    required AccessibilityConfigRepository repository,
  }) : _repository = repository;

  /// Get accessibility configuration for user, merging with system capabilities
  Future<Either<AppFailure, AccessibilityConfig>> call(String userId) async {
    // Get user config first
    final userConfigResult = await _repository.getConfig(userId);
    return userConfigResult
        .fold<Future<Either<AppFailure, AccessibilityConfig>>>(
      (failure) async => left(failure),
      (userConfig) async {
        final capabilitiesResult = await _repository.getSystemCapabilities();

        return capabilitiesResult.map((capabilities) {
          // Merge system capabilities with user config
          return userConfig.copyWith(
            isScreenReaderEnabled:
                capabilities['isScreenReaderEnabled'] as bool? ??
                    userConfig.isScreenReaderEnabled,
            isBoldTextEnabled: capabilities['isBoldTextEnabled'] as bool? ??
                userConfig.isBoldTextEnabled,
            isReduceMotionEnabled:
                capabilities['isReduceMotionEnabled'] as bool? ??
                    userConfig.isReduceMotionEnabled,
            isHighContrastEnabled:
                capabilities['isHighContrastEnabled'] as bool? ??
                    userConfig.isHighContrastEnabled,
            textScaleFactor: capabilities['textScaleFactor'] as double? ??
                userConfig.textScaleFactor,
          );
        });
      },
    );
  }
}

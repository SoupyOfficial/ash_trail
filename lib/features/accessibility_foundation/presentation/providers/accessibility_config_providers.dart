// Riverpod providers for accessibility configuration domain dependencies.
// Wires the accessibility repository and use case for the presentation layer.

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/repositories/accessibility_config_repository.dart';
import '../../domain/usecases/get_accessibility_config_use_case.dart';
import '../../data/repositories/accessibility_config_repository_impl.dart';

part 'accessibility_config_providers.g.dart';

@riverpod
AccessibilityConfigRepository accessibilityConfigRepository(
  AccessibilityConfigRepositoryRef ref,
) {
  return AccessibilityConfigRepositoryImpl();
}

@riverpod
GetAccessibilityConfigUseCase getAccessibilityConfigUseCase(
  GetAccessibilityConfigUseCaseRef ref,
) {
  return GetAccessibilityConfigUseCase(
    repository: ref.watch(accessibilityConfigRepositoryProvider),
  );
}

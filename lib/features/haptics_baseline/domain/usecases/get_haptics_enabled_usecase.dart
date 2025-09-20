// Use case for checking haptics availability and configuration
// Pure business logic for haptics settings following Clean Architecture.

import 'package:fpdart/fpdart.dart';
import '../repositories/haptics_repository.dart';
import '../../../../core/failures/app_failure.dart';

/// Use case for checking if haptics should be enabled based on all conditions
class GetHapticsEnabledUseCase {
  const GetHapticsEnabledUseCase(this._repository);

  final HapticsRepository _repository;

  /// Determines if haptics should be enabled based on:
  /// 1. User preference
  /// 2. System haptics support
  /// 3. Accessibility settings (reduce motion)
  Future<Either<AppFailure, bool>> call() async {
    try {
      // Check user preference
      final userPreferenceResult = await _repository.getHapticsEnabled();
      final userPreference = userPreferenceResult.fold((l) => true, (r) => r);

      if (!userPreference) {
        return const Right(false);
      }

      // Check system support
      final systemSupportResult = await _repository.isHapticsSupported();
      final systemSupport = systemSupportResult.fold((l) => false, (r) => r);

      if (!systemSupport) {
        return const Right(false);
      }

      // Check accessibility settings
      final reduceMotionResult = await _repository.isReduceMotionEnabled();
      final reduceMotion = reduceMotionResult.fold((l) => false, (r) => r);

      if (reduceMotion) {
        return const Right(false);
      }

      return const Right(true);
    } catch (e, stackTrace) {
      return Left(AppFailure.unexpected(
        message: 'Failed to check haptics enabled state',
        cause: e,
        stackTrace: stackTrace,
      ));
    }
  }
}

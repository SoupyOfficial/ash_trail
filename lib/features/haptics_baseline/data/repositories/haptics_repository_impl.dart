// Repository implementation for haptics configuration
// Manages haptics settings using SharedPreferences and system APIs.

import 'dart:ui';
import 'package:fpdart/fpdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import '../../domain/repositories/haptics_repository.dart';
import '../../../../core/failures/app_failure.dart';

/// Implementation of HapticsRepository using SharedPreferences and system APIs
class HapticsRepositoryImpl implements HapticsRepository {
  const HapticsRepositoryImpl(this._prefs);

  static const String _hapticsEnabledKey = 'haptics_enabled';

  final SharedPreferences _prefs;

  @override
  Future<Either<AppFailure, bool>> getHapticsEnabled() async {
    try {
      final enabled =
          _prefs.getBool(_hapticsEnabledKey) ?? true; // Default enabled
      return Right(enabled);
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to get haptics enabled preference',
      ));
    }
  }

  @override
  Future<Either<AppFailure, void>> setHapticsEnabled(bool enabled) async {
    try {
      await _prefs.setBool(_hapticsEnabledKey, enabled);
      return const Right(null);
    } catch (e) {
      return Left(AppFailure.cache(
        message: 'Failed to save haptics enabled preference',
      ));
    }
  }

  @override
  Future<Either<AppFailure, bool>> isHapticsSupported() async {
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      return Right(hasVibrator);
    } catch (e, stackTrace) {
      return Left(AppFailure.unexpected(
        message: 'Failed to check haptics support',
        cause: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<AppFailure, bool>> isReduceMotionEnabled() async {
    try {
      // Check for reduce motion accessibility setting
      final window = PlatformDispatcher.instance.views.first;
      final accessibilityFeatures =
          window.platformDispatcher.accessibilityFeatures;
      final reduceMotion = accessibilityFeatures.reduceMotion;
      return Right(reduceMotion);
    } catch (e, stackTrace) {
      return Left(AppFailure.unexpected(
        message: 'Failed to check reduce motion setting',
        cause: e,
        stackTrace: stackTrace,
      ));
    }
  }
}

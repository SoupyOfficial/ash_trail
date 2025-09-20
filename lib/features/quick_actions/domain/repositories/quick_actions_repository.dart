// Repository interface for managing quick actions
// Domain layer contract - implementation in data layer

import 'package:fpdart/fpdart.dart';
import '../entities/quick_action_entity.dart';
import '../../../../core/failures/app_failure.dart';

abstract class QuickActionsRepository {
  /// Initialize quick actions with the platform (iOS/Android)
  Future<Either<AppFailure, void>> initialize();

  /// Get all available quick actions
  Future<Either<AppFailure, List<QuickActionEntity>>> getAvailableActions();

  /// Set up quick actions on the platform
  Future<Either<AppFailure, void>> setupActions(
      List<QuickActionEntity> actions);

  /// Clear all quick actions from the platform
  Future<Either<AppFailure, void>> clearActions();

  /// Stream of quick action invocations
  Stream<QuickActionEntity> get actionStream;
}

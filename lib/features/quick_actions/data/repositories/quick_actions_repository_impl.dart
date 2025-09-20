// Repository implementation for quick actions
// Implements the domain contract using platform data source

import 'package:fpdart/fpdart.dart';
import '../../domain/entities/quick_action_entity.dart';
import '../../domain/repositories/quick_actions_repository.dart';
import '../models/quick_action_model.dart';
import '../datasources/quick_actions_data_source.dart';
import '../../../../core/failures/app_failure.dart';

class QuickActionsRepositoryImpl implements QuickActionsRepository {
  const QuickActionsRepositoryImpl(this._dataSource);

  final QuickActionsDataSource _dataSource;

  @override
  Future<Either<AppFailure, void>> initialize() async {
    try {
      await _dataSource.initialize();
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(AppFailure.unexpected(
        message: 'Failed to initialize quick actions',
        cause: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<AppFailure, List<QuickActionEntity>>>
      getAvailableActions() async {
    try {
      // Return predefined available actions
      final actions = [
        const QuickActionEntity(
          type: QuickActionTypes.logHit,
          localizedTitle: 'Log Hit',
          localizedSubtitle: 'Quick record smoking session',
          icon: 'add',
        ),
        const QuickActionEntity(
          type: QuickActionTypes.viewLogs,
          localizedTitle: 'View Logs',
          localizedSubtitle: 'See your smoking history',
          icon: 'list',
        ),
        const QuickActionEntity(
          type: QuickActionTypes.startTimedLog,
          localizedTitle: 'Start Timed Log',
          localizedSubtitle: 'Begin timing session',
          icon: 'timer',
        ),
      ];
      return Right(actions);
    } catch (e, stackTrace) {
      return Left(AppFailure.unexpected(
        message: 'Failed to get available actions',
        cause: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<AppFailure, void>> setupActions(
      List<QuickActionEntity> actions) async {
    try {
      final models =
          actions.map((entity) => QuickActionModel.fromEntity(entity)).toList();

      await _dataSource.setShortcutItems(models);
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(AppFailure.unexpected(
        message: 'Failed to setup quick actions',
        cause: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<AppFailure, void>> clearActions() async {
    try {
      await _dataSource.clearShortcutItems();
      return const Right(null);
    } catch (e, stackTrace) {
      return Left(AppFailure.unexpected(
        message: 'Failed to clear quick actions',
        cause: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Stream<QuickActionEntity> get actionStream => _dataSource.actionStream;
}

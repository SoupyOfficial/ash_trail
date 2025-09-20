// Repository implementation for live activity recording sessions.
// Manages persistence and business logic coordination.

import 'dart:async';
import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../domain/entities/live_activity_entity.dart';
import '../../domain/repositories/live_activity_repository.dart';
import '../datasources/live_activity_data_source.dart';
import '../models/live_activity_model.dart';

class LiveActivityRepositoryImpl implements LiveActivityRepository {
  const LiveActivityRepositoryImpl(this._dataSource);

  final LiveActivityDataSource _dataSource;

  @override
  Future<Either<AppFailure, LiveActivityEntity?>> getCurrentActivity() async {
    final result = _dataSource.getCurrentActivity();
    return result.map((model) => model?.toEntity());
  }

  @override
  Future<Either<AppFailure, LiveActivityEntity>> startActivity() async {
    final now = DateTime.now();
    final id = 'activity_${now.millisecondsSinceEpoch}';
    
    final entity = LiveActivityEntity(
      id: id,
      startedAt: now,
      status: LiveActivityStatus.active,
    );
    
    final model = LiveActivityModel.fromEntity(entity);
    final result = await _dataSource.saveCurrentActivity(model);
    
    return result.fold(
      (failure) => Left(failure),
      (_) => Right(entity),
    );
  }

  @override
  Future<Either<AppFailure, LiveActivityEntity>> completeActivity(String activityId) async {
    final getResult = _dataSource.getActivityById(activityId);
    
    return getResult.fold(
      (failure) => Left(failure),
      (model) async {
        if (model == null) {
          return const Left(AppFailure.notFound(
            message: 'Activity not found',
          ));
        }
        
        final entity = model.toEntity();
        if (!entity.isActive) {
          return const Left(AppFailure.validation(
            message: 'Activity is not active',
          ));
        }
        
        final completedEntity = entity.copyWith(
          endedAt: DateTime.now(),
          status: LiveActivityStatus.completed,
        );
        
        final completedModel = LiveActivityModel.fromEntity(completedEntity);
        
        // Add to history and clear current
        final historyResult = await _dataSource.addToHistory(completedModel);
        if (historyResult.isLeft()) {
          return historyResult.fold(
            (failure) => Left(failure),
            (_) => throw StateError('Unexpected state'),
          );
        }
        
        final clearResult = await _dataSource.clearCurrentActivity();
        if (clearResult.isLeft()) {
          return clearResult.fold(
            (failure) => Left(failure),
            (_) => throw StateError('Unexpected state'),
          );
        }
        
        return Right(completedEntity);
      },
    );
  }

  @override
  Future<Either<AppFailure, LiveActivityEntity>> cancelActivity(
    String activityId, {
    String? reason,
  }) async {
    final getResult = _dataSource.getActivityById(activityId);
    
    return getResult.fold(
      (failure) => Left(failure),
      (model) async {
        if (model == null) {
          return const Left(AppFailure.notFound(
            message: 'Activity not found',
          ));
        }
        
        final entity = model.toEntity();
        if (!entity.isActive) {
          return const Left(AppFailure.validation(
            message: 'Activity is not active',
          ));
        }
        
        final cancelledEntity = entity.copyWith(
          endedAt: DateTime.now(),
          status: LiveActivityStatus.cancelled,
          cancelReason: reason,
        );
        
        final cancelledModel = LiveActivityModel.fromEntity(cancelledEntity);
        
        // Add to history and clear current
        final historyResult = await _dataSource.addToHistory(cancelledModel);
        if (historyResult.isLeft()) {
          return historyResult.fold(
            (failure) => Left(failure),
            (_) => throw StateError('Unexpected state'),
          );
        }
        
        final clearResult = await _dataSource.clearCurrentActivity();
        if (clearResult.isLeft()) {
          return clearResult.fold(
            (failure) => Left(failure),
            (_) => throw StateError('Unexpected state'),
          );
        }
        
        return Right(cancelledEntity);
      },
    );
  }

  @override
  Future<Either<AppFailure, LiveActivityEntity>> getActivityById(String id) async {
    final result = _dataSource.getActivityById(id);
    return result.fold(
      (failure) => Left(failure),
      (model) {
        if (model == null) {
          return const Left(AppFailure.notFound(
            message: 'Activity not found',
          ));
        }
        return Right(model.toEntity());
      },
    );
  }

  @override
  Stream<LiveActivityEntity?> watchCurrentActivity() {
    return _dataSource.watchCurrentActivity()
        .map((model) => model?.toEntity());
  }

  @override
  Future<Either<AppFailure, void>> cleanupOrphanedActivities() async {
    final currentResult = _dataSource.getCurrentActivity();
    
    return currentResult.fold(
      (failure) => Left(failure),
      (model) async {
        if (model == null) {
          // No current activity, nothing to clean up
          return right(null);
        }
        
        final entity = model.toEntity();
        if (entity.isActive) {
          // Mark as cancelled due to orphaning
          final cancelledEntity = entity.copyWith(
            endedAt: DateTime.now(),
            status: LiveActivityStatus.cancelled,
            cancelReason: 'App terminated unexpectedly',
          );
          
          final cancelledModel = LiveActivityModel.fromEntity(cancelledEntity);
          
          // Add to history and clear current
          final historyResult = await _dataSource.addToHistory(cancelledModel);
          if (historyResult.isLeft()) {
            return historyResult.fold(
              (failure) => Left(failure),
              (_) => throw StateError('Unexpected state'),
            );
          }
          
          final clearResult = await _dataSource.clearCurrentActivity();
          return clearResult.fold(
            (failure) => Left(failure),
            (_) => right(null),
          );
        }
        
        return right(null);
      },
    );
  }
}
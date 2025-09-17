// Repository implementation for Siri shortcuts.
// Combines local and remote data sources following Repository pattern.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../../domain/entities/siri_shortcuts_entity.dart';
import '../../domain/entities/siri_shortcut_type.dart';
import '../../domain/repositories/siri_shortcuts_repository.dart';
import '../datasources/siri_shortcuts_local_data_source.dart';
import '../datasources/siri_shortcuts_remote_data_source.dart';
import '../models/siri_shortcuts_model.dart';

class SiriShortcutsRepositoryImpl implements SiriShortcutsRepository {
  const SiriShortcutsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final SiriShortcutsLocalDataSource localDataSource;
  final SiriShortcutsRemoteDataSource remoteDataSource;

  @override
  Future<Either<AppFailure, List<SiriShortcutsEntity>>> getShortcuts() async {
    try {
      final shortcuts = await localDataSource.getShortcuts();
      return Right(shortcuts.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to get shortcuts: $e'));
    }
  }

  @override
  Future<Either<AppFailure, SiriShortcutsEntity>> getShortcutById(String id) async {
    try {
      final shortcut = await localDataSource.getShortcutById(id);
      if (shortcut == null) {
        return Left(AppFailure.notFound(message: 'Shortcut not found', resourceId: id));
      }
      return Right(shortcut.toEntity());
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to get shortcut: $e'));
    }
  }

  @override
  Future<Either<AppFailure, List<SiriShortcutsEntity>>> getShortcutsByType(
    SiriShortcutType type,
  ) async {
    try {
      final allShortcuts = await localDataSource.getShortcuts();
      final filteredShortcuts = allShortcuts
          .where((model) => _typeMatches(model, type))
          .map((model) => model.toEntity())
          .toList();
      return Right(filteredShortcuts);
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to get shortcuts by type: $e'));
    }
  }

  @override
  Future<Either<AppFailure, SiriShortcutsEntity>> createShortcut(
    SiriShortcutsEntity shortcut,
  ) async {
    try {
      final model = SiriShortcutsModel.fromEntity(shortcut);
      await localDataSource.saveShortcut(model);
      return Right(shortcut);
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to create shortcut: $e'));
    }
  }

  @override
  Future<Either<AppFailure, SiriShortcutsEntity>> updateShortcut(
    SiriShortcutsEntity shortcut,
  ) async {
    try {
      final model = SiriShortcutsModel.fromEntity(shortcut);
      await localDataSource.saveShortcut(model);
      return Right(shortcut);
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to update shortcut: $e'));
    }
  }

  @override
  Future<Either<AppFailure, void>> deleteShortcut(String id) async {
    try {
      await localDataSource.removeShortcut(id);
      return const Right(null);
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to delete shortcut: $e'));
    }
  }

  @override
  Future<Either<AppFailure, void>> donateShortcut(
    SiriShortcutsEntity shortcut,
  ) async {
    try {
      final model = SiriShortcutsModel.fromEntity(shortcut);
      await remoteDataSource.donateShortcut(model);
      
      // Update local storage to mark as donated
      final updatedShortcut = shortcut.withDonation();
      final updatedModel = SiriShortcutsModel.fromEntity(updatedShortcut);
      await localDataSource.saveShortcut(updatedModel);
      
      return const Right(null);
    } catch (e) {
      return Left(AppFailure.network(message: 'Failed to donate shortcut: $e'));
    }
  }

  @override
  Future<Either<AppFailure, void>> donateShortcuts(
    List<SiriShortcutsEntity> shortcuts,
  ) async {
    try {
      final models = shortcuts.map(SiriShortcutsModel.fromEntity).toList();
      await remoteDataSource.donateShortcuts(models);
      
      // Update local storage to mark all as donated
      for (final shortcut in shortcuts) {
        final updatedShortcut = shortcut.withDonation();
        final updatedModel = SiriShortcutsModel.fromEntity(updatedShortcut);
        await localDataSource.saveShortcut(updatedModel);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(AppFailure.network(message: 'Failed to donate shortcuts: $e'));
    }
  }

  @override
  Future<Either<AppFailure, bool>> isSiriShortcutsSupported() async {
    try {
      final isSupported = await remoteDataSource.isSiriShortcutsSupported();
      return Right(isSupported);
    } catch (e) {
      return Left(AppFailure.unexpected(message: 'Failed to check support: $e'));
    }
  }

  @override
  Future<Either<AppFailure, void>> recordShortcutInvocation({
    required String shortcutId,
    required SiriShortcutType type,
    required DateTime invokedAt,
  }) async {
    try {
      // Record telemetry remotely
      await remoteDataSource.recordShortcutInvocation(
        shortcutId: shortcutId,
        type: type,
        invokedAt: invokedAt,
      );

      // Update local shortcut with invocation tracking
      final shortcut = await localDataSource.getShortcutById(shortcutId);
      if (shortcut != null) {
        final entity = shortcut.toEntity();
        final updatedEntity = entity.withInvocation();
        final updatedModel = SiriShortcutsModel.fromEntity(updatedEntity);
        await localDataSource.saveShortcut(updatedModel);
      }

      return const Right(null);
    } catch (e) {
      return Left(AppFailure.network(message: 'Failed to record invocation: $e'));
    }
  }

  @override
  Future<Either<AppFailure, List<SiriShortcutsEntity>>> getShortcutsNeedingDonation() async {
    try {
      final allShortcuts = await localDataSource.getShortcuts();
      final needingDonation = allShortcuts
          .map((model) => model.toEntity())
          .where((entity) => entity.needsReDonation)
          .toList();
      return Right(needingDonation);
    } catch (e) {
      return Left(AppFailure.cache(message: 'Failed to get shortcuts needing donation: $e'));
    }
  }

  /// Helper method to check if a model matches a given type
  bool _typeMatches(SiriShortcutsModel model, SiriShortcutType type) {
    try {
      final modelType = SiriShortcutsModel.stringToType(model.type);
      return modelType == type;
    } catch (e) {
      return false;
    }
  }
}
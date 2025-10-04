// Repository implementation for log detail data access
// Coordinates between local and remote data sources following offline-first strategy

import 'package:fpdart/fpdart.dart';
import '../../domain/entities/log_detail_entity.dart';
import '../../domain/repositories/log_detail_repository.dart';
import '../datasources/log_detail_datasource.dart';
import '../../../../core/failures/app_failure.dart';

class LogDetailRepositoryImpl implements LogDetailRepository {
  const LogDetailRepositoryImpl({
    required LogDetailLocalDataSource localDataSource,
    required LogDetailRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  final LogDetailLocalDataSource _localDataSource;
  final LogDetailRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppFailure, LogDetailEntity>> getLogDetail(String logId) async {
    // Offline-first: Try local data first
    final localResult = await _localDataSource.getLogDetail(logId);
    
    return localResult.fold(
      (failure) async {
        // If local fails, try remote
        final remoteResult = await _remoteDataSource.getLogDetail(logId);
        return remoteResult.fold(
          (remoteFailure) => Left(remoteFailure),
          (model) async {
            // Cache successful remote fetch
            await _localDataSource.cacheLogDetail(model);
            return Right(model.toEntity());
          },
        );
      },
      (model) => Right(model.toEntity()),
    );
  }

  @override
  Future<Either<AppFailure, bool>> logExists(String logId) async {
    // Check local first
    final localExists = await _localDataSource.logExists(logId);
    
    return localExists.fold(
      (failure) => _remoteDataSource.logExists(logId),
      (exists) => exists 
          ? const Right(true) 
          : _remoteDataSource.logExists(logId), // Check remote if not local
    );
  }

  @override
  Future<Either<AppFailure, LogDetailEntity>> refreshLogDetail(String logId) async {
    // Force refresh from remote
    final remoteResult = await _remoteDataSource.refreshLogDetail(logId);
    
    return remoteResult.fold(
      (failure) => Left(failure),
      (model) async {
        // Cache the fresh data
        await _localDataSource.cacheLogDetail(model);
        return Right(model.toEntity());
      },
    );
  }
}
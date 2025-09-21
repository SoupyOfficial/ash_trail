// Use case to refresh log detail from remote source
// Handles manual refresh requests from the UI

import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../entities/log_detail_entity.dart';
import '../repositories/log_detail_repository.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/usecases/usecase.dart';

part 'refresh_log_detail_usecase.freezed.dart';

class RefreshLogDetailUseCase implements UseCase<LogDetailEntity, RefreshLogDetailParams> {
  const RefreshLogDetailUseCase(this._repository);

  final LogDetailRepository _repository;

  @override
  Future<Either<AppFailure, LogDetailEntity>> call(RefreshLogDetailParams params) {
    return _repository.refreshLogDetail(params.logId);
  }
}

@freezed
class RefreshLogDetailParams with _$RefreshLogDetailParams {
  const factory RefreshLogDetailParams({required String logId}) = _RefreshLogDetailParams;
}
// Use case to retrieve log detail information
// Orchestrates fetching log with its related data (tags, reasons, method)

import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../entities/log_detail_entity.dart';
import '../repositories/log_detail_repository.dart';
import '../../../../core/failures/app_failure.dart';
import '../../../../core/usecases/usecase.dart';

part 'get_log_detail_usecase.freezed.dart';

class GetLogDetailUseCase implements UseCase<LogDetailEntity, GetLogDetailParams> {
  const GetLogDetailUseCase(this._repository);

  final LogDetailRepository _repository;

  @override
  Future<Either<AppFailure, LogDetailEntity>> call(GetLogDetailParams params) {
    return _repository.getLogDetail(params.logId);
  }
}

@freezed
class GetLogDetailParams with _$GetLogDetailParams {
  const factory GetLogDetailParams({required String logId}) = _GetLogDetailParams;
}
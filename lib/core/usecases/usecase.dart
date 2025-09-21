// Base usecase interface for Clean Architecture
// Provides a contract for all use cases with typed inputs and outputs

import 'package:fpdart/fpdart.dart';
import '../failures/app_failure.dart';

/// Base interface for all use cases
/// 
/// [Type] - The return type wrapped in Either<AppFailure, Type>
/// [Params] - The input parameters for the use case
abstract class UseCase<Type, Params> {
  /// Execute the use case with the given parameters
  Future<Either<AppFailure, Type>> call(Params params);
}

/// Special case for use cases that don't require any parameters
class NoParams {
  const NoParams();
}
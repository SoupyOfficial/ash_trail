// Base use case interface following Clean Architecture pattern.
// Provides contract for all domain use cases.

import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';

abstract class UseCase<Type, Params> {
  Future<Either<AppFailure, Type>> call(Params params);
}

/// Parameter class for use cases that don't require parameters
class NoParams {
  const NoParams();
}

/// Base parameters with account ID (common requirement)
class AccountParams {
  const AccountParams({required this.accountId});
  final String accountId;
}

/// Parameters for widget-specific operations
class WidgetParams {
  const WidgetParams({required this.widgetId});
  final String widgetId;
}

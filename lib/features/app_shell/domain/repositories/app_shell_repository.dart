import 'package:fpdart/fpdart.dart';
import '../entities/app_tab.dart';
import '../../../../core/failures/app_failure.dart';

abstract class AppShellRepository {
  Future<Either<AppFailure, AppTab>> readLastActiveTab();
  Future<Either<AppFailure, Unit>> saveLastActiveTab(AppTab tab);
}

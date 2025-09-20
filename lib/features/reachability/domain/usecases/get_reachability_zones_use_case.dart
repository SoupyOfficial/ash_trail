// Use case for generating reachability zones based on screen size
// Provides thumb zone definitions for ergonomic analysis

import 'package:fpdart/fpdart.dart';
import 'package:flutter/painting.dart';
import '../entities/reachability_zone.dart';
import '../repositories/reachability_repository.dart';
import '../../../../core/failures/app_failure.dart';

class GetReachabilityZonesUseCase {
  const GetReachabilityZonesUseCase(this._repository);
  
  final ReachabilityRepository _repository;
  
  Future<Either<AppFailure, List<ReachabilityZone>>> call(Size screenSize) async {
    return _repository.getReachabilityZones(screenSize);
  }
}
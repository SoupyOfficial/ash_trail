// Riverpod providers for reachability audit functionality
// State management for audit reports and zone configurations

import 'package:flutter/painting.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/reachability_audit_report.dart';
import '../../domain/entities/reachability_zone.dart';
import '../../domain/entities/ui_element.dart';
import '../../domain/usecases/perform_reachability_audit_use_case.dart';
import '../../domain/usecases/get_audit_reports_use_case.dart';
import '../../domain/usecases/get_reachability_zones_use_case.dart';
import '../../domain/usecases/save_audit_report_use_case.dart';
import '../../data/repositories/reachability_repository_impl.dart';
import '../../data/datasources/reachability_local_datasource.dart';
import '../../data/datasources/reachability_zone_factory.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'reachability_providers.g.dart';

// Repository provider
@riverpod
Future<ReachabilityRepositoryImpl> reachabilityRepository(
    ReachabilityRepositoryRef ref) async {
  final localDataSource =
      await ref.watch(reachabilityLocalDataSourceProvider.future);
  final zoneFactory = const ReachabilityZoneFactory();
  return ReachabilityRepositoryImpl(localDataSource, zoneFactory);
}

// Local data source provider
@riverpod
Future<ReachabilityLocalDataSource> reachabilityLocalDataSource(
  ReachabilityLocalDataSourceRef ref,
) async {
  final prefs = await SharedPreferences.getInstance();
  return ReachabilityLocalDataSourceImpl(prefs);
}

// Use case providers
@riverpod
Future<PerformReachabilityAuditUseCase> performReachabilityAuditUseCase(
  PerformReachabilityAuditUseCaseRef ref,
) async {
  final repository = await ref.watch(reachabilityRepositoryProvider.future);
  return PerformReachabilityAuditUseCase(repository);
}

@riverpod
Future<GetAuditReportsUseCase> getAuditReportsUseCase(
    GetAuditReportsUseCaseRef ref) async {
  final repository = await ref.watch(reachabilityRepositoryProvider.future);
  return GetAuditReportsUseCase(repository);
}

@riverpod
Future<GetReachabilityZonesUseCase> getReachabilityZonesUseCase(
  GetReachabilityZonesUseCaseRef ref,
) async {
  final repository = await ref.watch(reachabilityRepositoryProvider.future);
  return GetReachabilityZonesUseCase(repository);
}

@riverpod
Future<SaveAuditReportUseCase> saveAuditReportUseCase(
    SaveAuditReportUseCaseRef ref) async {
  final repository = await ref.watch(reachabilityRepositoryProvider.future);
  return SaveAuditReportUseCase(repository);
}

// State providers for audit functionality
@riverpod
class AuditReportsList extends _$AuditReportsList {
  @override
  Future<List<ReachabilityAuditReport>> build() async {
    final useCase = await ref.read(getAuditReportsUseCaseProvider.future);
    final result = await useCase();

    return result.fold(
      (failure) => throw failure,
      (reports) => reports,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }

  Future<void> deleteReport(String reportId) async {
    state = const AsyncValue.loading();

    // Delete from repository
    final repository = await ref.read(reachabilityRepositoryProvider.future);
    final result = await repository.deleteAuditReport(reportId);

    await result.fold(
      (failure) => throw failure,
      (_) => refresh(),
    );
  }
}

@riverpod
Future<List<ReachabilityZone>> reachabilityZones(
  ReachabilityZonesRef ref,
  Size screenSize,
) async {
  final useCase = await ref.read(getReachabilityZonesUseCaseProvider.future);
  final result = await useCase(screenSize);

  return result.fold(
    (failure) => throw failure,
    (zones) => zones,
  );
}

@riverpod
class CurrentAuditReport extends _$CurrentAuditReport {
  @override
  ReachabilityAuditReport? build() => null;

  void setCurrentReport(ReachabilityAuditReport report) {
    state = report;
  }

  void clearCurrentReport() {
    state = null;
  }

  Future<void> performAudit({
    required String screenName,
    required Size screenSize,
    required List<UiElement> elements,
  }) async {
    final useCase =
        await ref.read(performReachabilityAuditUseCaseProvider.future);

    final result = await useCase(
      screenName: screenName,
      screenSize: screenSize,
      elements: elements,
    );

    result.fold(
      (failure) => throw failure,
      (report) {
        state = report;
        // Also refresh the reports list to include the new report
        ref.read(auditReportsListProvider.notifier).refresh();
      },
    );
  }

  Future<void> saveCurrentReport() async {
    final currentReport = state;
    if (currentReport == null) return;

    final useCase = await ref.read(saveAuditReportUseCaseProvider.future);
    final result = await useCase(currentReport);

    result.fold(
      (failure) => throw failure,
      (savedReport) {
        state = savedReport;
        // Refresh the reports list
        ref.read(auditReportsListProvider.notifier).refresh();
      },
    );
  }
}

// Utility providers
@riverpod
bool isAuditInProgress(IsAuditInProgressRef ref) {
  final currentReport = ref.watch(currentAuditReportProvider);
  return currentReport != null;
}

@riverpod
double auditComplianceScore(AuditComplianceScoreRef ref) {
  final currentReport = ref.watch(currentAuditReportProvider);
  return currentReport?.complianceScore ?? 0.0;
}

@riverpod
bool auditPassesThreshold(AuditPassesThresholdRef ref) {
  final currentReport = ref.watch(currentAuditReportProvider);
  return currentReport?.passesAudit ?? false;
}

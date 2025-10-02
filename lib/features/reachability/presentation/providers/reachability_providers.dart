// Riverpod providers for reachability audit functionality
// State management for audit reports and zone configurations

import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// Repository provider
final reachabilityRepositoryProvider =
    FutureProvider<ReachabilityRepositoryImpl>((ref) async {
  final localDataSource =
      await ref.watch(reachabilityLocalDataSourceProvider.future);
  const zoneFactory = ReachabilityZoneFactory();
  return ReachabilityRepositoryImpl(localDataSource, zoneFactory);
});

// Local data source provider
final reachabilityLocalDataSourceProvider =
    FutureProvider<ReachabilityLocalDataSource>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return ReachabilityLocalDataSourceImpl(prefs);
});

// Use case providers
final performReachabilityAuditUseCaseProvider =
    FutureProvider<PerformReachabilityAuditUseCase>((ref) async {
  final repository = await ref.watch(reachabilityRepositoryProvider.future);
  return PerformReachabilityAuditUseCase(repository);
});

final getAuditReportsUseCaseProvider =
    FutureProvider<GetAuditReportsUseCase>((ref) async {
  final repository = await ref.watch(reachabilityRepositoryProvider.future);
  return GetAuditReportsUseCase(repository);
});

final getReachabilityZonesUseCaseProvider =
    FutureProvider<GetReachabilityZonesUseCase>((ref) async {
  final repository = await ref.watch(reachabilityRepositoryProvider.future);
  return GetReachabilityZonesUseCase(repository);
});

final saveAuditReportUseCaseProvider =
    FutureProvider<SaveAuditReportUseCase>((ref) async {
  final repository = await ref.watch(reachabilityRepositoryProvider.future);
  return SaveAuditReportUseCase(repository);
});

// State providers for audit functionality
class AuditReportsListNotifier
    extends AutoDisposeAsyncNotifier<List<ReachabilityAuditReport>> {
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

    try {
      // Delete from repository
      final repository = await ref.read(reachabilityRepositoryProvider.future);
      final result = await repository.deleteAuditReport(reportId);

      await result.fold(
        (failure) => throw failure,
        (_) => refresh(),
      );
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}

final auditReportsListProvider = AutoDisposeAsyncNotifierProvider<
    AuditReportsListNotifier, List<ReachabilityAuditReport>>(
  AuditReportsListNotifier.new,
);

final reachabilityZonesProvider =
    FutureProvider.family<List<ReachabilityZone>, Size>(
        (ref, screenSize) async {
  final useCase = await ref.read(getReachabilityZonesUseCaseProvider.future);
  final result = await useCase(screenSize);

  return result.fold(
    (failure) => throw failure,
    (zones) => zones,
  );
});

class CurrentAuditReportNotifier
    extends AutoDisposeNotifier<ReachabilityAuditReport?> {
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
    try {
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
    } catch (error) {
      // Handle error appropriately - could set an error state or rethrow
      rethrow;
    }
  }

  Future<void> saveCurrentReport() async {
    final currentReport = state;
    if (currentReport == null) return;

    try {
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
    } catch (error) {
      // Handle error appropriately
      rethrow;
    }
  }
}

final currentAuditReportProvider = AutoDisposeNotifierProvider<
    CurrentAuditReportNotifier, ReachabilityAuditReport?>(
  CurrentAuditReportNotifier.new,
);

// Utility providers
final isAuditInProgressProvider = Provider.autoDispose<bool>((ref) {
  final currentReport = ref.watch(currentAuditReportProvider);
  return currentReport != null;
});

final auditComplianceScoreProvider = Provider.autoDispose<double>((ref) {
  final currentReport = ref.watch(currentAuditReportProvider);
  return currentReport?.complianceScore ?? 0.0;
});

final auditPassesThresholdProvider = Provider.autoDispose<bool>((ref) {
  final currentReport = ref.watch(currentAuditReportProvider);
  return currentReport?.passesAudit ?? false;
});

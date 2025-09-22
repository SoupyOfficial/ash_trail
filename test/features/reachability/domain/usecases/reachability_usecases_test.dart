import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/painting.dart';
import 'package:ash_trail/features/reachability/domain/usecases/get_audit_reports_use_case.dart';
import 'package:ash_trail/features/reachability/domain/usecases/save_audit_report_use_case.dart';
import 'package:ash_trail/features/reachability/domain/usecases/get_reachability_zones_use_case.dart';
import 'package:ash_trail/features/reachability/domain/repositories/reachability_repository.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_audit_report.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_zone.dart';

class _MockRepo extends Mock implements ReachabilityRepository {}

void main() {
  late _MockRepo repo;

  setUp(() {
    repo = _MockRepo();
  });

  test('GetAuditReportsUseCase delegates', () async {
    when(() => repo.getAllAuditReports())
        .thenAnswer((_) async => right(<ReachabilityAuditReport>[]));
    final uc = GetAuditReportsUseCase(repo);
    final res = await uc();
    expect(res.isRight(), isTrue);
  });

  test('SaveAuditReportUseCase delegates', () async {
    final report = ReachabilityAuditReport(
      id: 'r1',
      timestamp: DateTime(2024, 1, 1),
      screenName: 'TestScreen',
      screenSize: const Size(400, 800),
      elements: const [],
      zones: const <ReachabilityZone>[],
      summary: const AuditSummary(
        totalElements: 0,
        interactiveElements: 0,
        elementsInEasyReach: 0,
        elementsWithIssues: 0,
        avgTouchTargetSize: 0.0,
        accessibilityIssues: 0,
      ),
    );

    when(() => repo.saveAuditReport(report))
        .thenAnswer((_) async => right(report));
    final uc = SaveAuditReportUseCase(repo);
    final res = await uc(report);
    expect(res.getRight().toNullable(), equals(report));
  });

  test('GetReachabilityZonesUseCase delegates', () async {
    when(() => repo.getReachabilityZones(const Size(400, 800)))
        .thenAnswer((_) async => right(<ReachabilityZone>[]));
    final uc = GetReachabilityZonesUseCase(repo);
    final res = await uc(const Size(400, 800));
    expect(res.isRight(), isTrue);
  });
}

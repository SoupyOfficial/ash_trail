import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_audit_report.dart';
import 'package:ash_trail/features/reachability/domain/entities/reachability_zone.dart';
import 'package:ash_trail/features/reachability/domain/entities/ui_element.dart';
import 'package:ash_trail/features/reachability/domain/repositories/reachability_repository.dart';
import 'package:ash_trail/features/reachability/domain/usecases/get_audit_reports_use_case.dart';
import 'package:ash_trail/features/reachability/domain/usecases/get_reachability_zones_use_case.dart';
import 'package:ash_trail/features/reachability/domain/usecases/perform_reachability_audit_use_case.dart';
import 'package:ash_trail/features/reachability/domain/usecases/save_audit_report_use_case.dart';
import 'package:ash_trail/features/reachability/presentation/providers/reachability_providers.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _DummyReachabilityRepository implements ReachabilityRepository {
  const _DummyReachabilityRepository();

  @override
  Future<Either<AppFailure, List<ReachabilityAuditReport>>>
      getAllAuditReports() => throw UnimplementedError();

  @override
  Future<Either<AppFailure, ReachabilityAuditReport>> getAuditReport(
          String id) =>
      throw UnimplementedError();

  @override
  Future<Either<AppFailure, ReachabilityAuditReport>> saveAuditReport(
          ReachabilityAuditReport report) =>
      throw UnimplementedError();

  @override
  Future<Either<AppFailure, void>> deleteAuditReport(String id) =>
      throw UnimplementedError();

  @override
  Future<Either<AppFailure, List<ReachabilityZone>>> getReachabilityZones(
          Size screenSize) =>
      throw UnimplementedError();

  @override
  Future<Either<AppFailure, void>> saveZoneConfiguration(
          Size screenSize, List<ReachabilityZone> zones) =>
      throw UnimplementedError();

  @override
  Future<Either<AppFailure, ReachabilityAuditReport>> performAudit({
    required String screenName,
    required Size screenSize,
    required List<UiElement> elements,
  }) =>
      throw UnimplementedError();
}

class StubGetAuditReportsUseCase extends GetAuditReportsUseCase {
  StubGetAuditReportsUseCase(this._result)
      : super(const _DummyReachabilityRepository());

  final Future<Either<AppFailure, List<ReachabilityAuditReport>>> Function()
      _result;

  @override
  Future<Either<AppFailure, List<ReachabilityAuditReport>>> call() => _result();
}

class StubPerformReachabilityAuditUseCase
    extends PerformReachabilityAuditUseCase {
  StubPerformReachabilityAuditUseCase(this._onCall)
      : super(const _DummyReachabilityRepository());

  final Future<Either<AppFailure, ReachabilityAuditReport>> Function({
    required String screenName,
    required Size screenSize,
    required List<UiElement> elements,
  }) _onCall;

  @override
  Future<Either<AppFailure, ReachabilityAuditReport>> call({
    required String screenName,
    required Size screenSize,
    required List<UiElement> elements,
  }) =>
      _onCall(
        screenName: screenName,
        screenSize: screenSize,
        elements: elements,
      );
}

class StubSaveAuditReportUseCase extends SaveAuditReportUseCase {
  StubSaveAuditReportUseCase(this._onCall)
      : super(const _DummyReachabilityRepository());

  final Future<Either<AppFailure, ReachabilityAuditReport>> Function(
      ReachabilityAuditReport report) _onCall;

  @override
  Future<Either<AppFailure, ReachabilityAuditReport>> call(
          ReachabilityAuditReport report) =>
      _onCall(report);
}

class StubGetReachabilityZonesUseCase extends GetReachabilityZonesUseCase {
  StubGetReachabilityZonesUseCase(this._onCall)
      : super(const _DummyReachabilityRepository());

  final Future<Either<AppFailure, List<ReachabilityZone>>> Function(Size size)
      _onCall;

  @override
  Future<Either<AppFailure, List<ReachabilityZone>>> call(Size screenSize) =>
      _onCall(screenSize);
}

void main() {
  const ReachabilityZone easyZone = ReachabilityZone(
    id: 'zone-easy',
    name: 'Easy',
    bounds: Rect.fromLTWH(0, 500, 360, 300),
    level: ReachabilityLevel.easy,
    description: 'Easy reach zone',
  );

  const UiElement buttonElement = UiElement(
    id: 'btn-1',
    label: 'Submit',
    bounds: Rect.fromLTWH(12, 510, 80, 52),
    type: UiElementType.button,
    isInteractive: true,
    semanticLabel: 'Submit',
    hasAlternativeAccess: true,
  );

  const AuditSummary auditSummary = AuditSummary(
    totalElements: 1,
    interactiveElements: 1,
    elementsInEasyReach: 1,
    elementsWithIssues: 0,
    avgTouchTargetSize: 50,
    accessibilityIssues: 0,
  );

  final ReachabilityAuditReport baseReport = ReachabilityAuditReport(
    id: 'report-1',
    timestamp: DateTime(2024, 1, 1, 12),
    screenName: 'Home',
    screenSize: const Size(360, 800),
    elements: <UiElement>[buttonElement],
    zones: <ReachabilityZone>[easyZone],
    summary: auditSummary,
    recommendations: const <AuditRecommendation>[],
  );

  final ReachabilityAuditReport savedReport =
      baseReport.copyWith(id: 'report-final');

  group('auditReportsListProvider', () {
    test('loads reachability reports successfully', () async {
      int callCount = 0;
      final container = ProviderContainer(
        overrides: <Override>[
          getAuditReportsUseCaseProvider.overrideWith(
            (ref) async => StubGetAuditReportsUseCase(() async {
              callCount += 1;
              return Right(<ReachabilityAuditReport>[baseReport]);
            }),
          ),
          performReachabilityAuditUseCaseProvider
              .overrideWith((ref) async => StubPerformReachabilityAuditUseCase(
                    (
                            {required String screenName,
                            required Size screenSize,
                            required List<UiElement> elements}) async =>
                        Right(baseReport),
                  )),
          saveAuditReportUseCaseProvider
              .overrideWith((ref) async => StubSaveAuditReportUseCase(
                    (report) async => Right(savedReport),
                  )),
          getReachabilityZonesUseCaseProvider
              .overrideWith((ref) async => StubGetReachabilityZonesUseCase(
                    (size) async => const Right(<ReachabilityZone>[easyZone]),
                  )),
        ],
      );
      addTearDown(container.dispose);

      final reports = await container.read(auditReportsListProvider.future);
      expect(reports, hasLength(1));
      expect(reports.first.id, baseReport.id);
      expect(callCount, 1);

      await container.read(auditReportsListProvider.notifier).refresh();
      expect(callCount, 2);
    });

    test('emits error when audit reports use case fails', () async {
      const failure = AppFailure.unexpected(message: 'load failed');
      final container = ProviderContainer(
        overrides: <Override>[
          getAuditReportsUseCaseProvider.overrideWith(
            (ref) async =>
                StubGetAuditReportsUseCase(() async => const Left(failure)),
          ),
          performReachabilityAuditUseCaseProvider
              .overrideWith((ref) async => StubPerformReachabilityAuditUseCase(
                    (
                            {required String screenName,
                            required Size screenSize,
                            required List<UiElement> elements}) async =>
                        Right(baseReport),
                  )),
          saveAuditReportUseCaseProvider
              .overrideWith((ref) async => StubSaveAuditReportUseCase(
                    (report) async => Right(savedReport),
                  )),
          getReachabilityZonesUseCaseProvider
              .overrideWith((ref) async => StubGetReachabilityZonesUseCase(
                    (size) async => const Right(<ReachabilityZone>[easyZone]),
                  )),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(auditReportsListProvider.future),
        throwsA(equals(failure)),
      );
    });
  });

  group('currentAuditReportProvider', () {
    test('performAudit stores report and updates derived providers', () async {
      final container = ProviderContainer(
        overrides: <Override>[
          getAuditReportsUseCaseProvider.overrideWith(
            (ref) async => StubGetAuditReportsUseCase(
                () async => Right(<ReachabilityAuditReport>[baseReport])),
          ),
          performReachabilityAuditUseCaseProvider.overrideWith(
            (ref) async => StubPerformReachabilityAuditUseCase(
              (
                      {required String screenName,
                      required Size screenSize,
                      required List<UiElement> elements}) async =>
                  Right(baseReport),
            ),
          ),
          saveAuditReportUseCaseProvider.overrideWith(
            (ref) async => StubSaveAuditReportUseCase(
              (report) async => Right(savedReport),
            ),
          ),
          getReachabilityZonesUseCaseProvider.overrideWith(
            (ref) async => StubGetReachabilityZonesUseCase(
              (size) async => const Right(<ReachabilityZone>[easyZone]),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(currentAuditReportProvider.notifier);

      await notifier.performAudit(
        screenName: 'Home',
        screenSize: const Size(360, 800),
        elements: <UiElement>[buttonElement],
      );

      expect(container.read(currentAuditReportProvider)?.id, baseReport.id);
      expect(container.read(isAuditInProgressProvider), isTrue);
      expect(
          container.read(auditComplianceScoreProvider), closeTo(1.0, 0.0001));
      expect(container.read(auditPassesThresholdProvider), isTrue);
    });

    test('saveCurrentReport persists updates and refreshes list', () async {
      final container = ProviderContainer(
        overrides: <Override>[
          getAuditReportsUseCaseProvider.overrideWith(
            (ref) async => StubGetAuditReportsUseCase(
                () async => Right(<ReachabilityAuditReport>[baseReport])),
          ),
          performReachabilityAuditUseCaseProvider.overrideWith(
            (ref) async => StubPerformReachabilityAuditUseCase(
              (
                      {required String screenName,
                      required Size screenSize,
                      required List<UiElement> elements}) async =>
                  Right(baseReport),
            ),
          ),
          saveAuditReportUseCaseProvider.overrideWith(
            (ref) async => StubSaveAuditReportUseCase(
              (report) async => Right(savedReport),
            ),
          ),
          getReachabilityZonesUseCaseProvider.overrideWith(
            (ref) async => StubGetReachabilityZonesUseCase(
              (size) async => const Right(<ReachabilityZone>[easyZone]),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(currentAuditReportProvider.notifier);
      notifier.setCurrentReport(baseReport);
      await notifier.saveCurrentReport();

      expect(container.read(currentAuditReportProvider)?.id, savedReport.id);
    });

    test('performAudit propagates failures', () async {
      const failure = AppFailure.unexpected(message: 'audit failed');
      final container = ProviderContainer(
        overrides: <Override>[
          getAuditReportsUseCaseProvider.overrideWith(
            (ref) async => StubGetAuditReportsUseCase(
                () async => const Right(<ReachabilityAuditReport>[])),
          ),
          performReachabilityAuditUseCaseProvider.overrideWith(
            (ref) async => StubPerformReachabilityAuditUseCase(
              (
                      {required String screenName,
                      required Size screenSize,
                      required List<UiElement> elements}) async =>
                  const Left(failure),
            ),
          ),
          saveAuditReportUseCaseProvider.overrideWith(
            (ref) async => StubSaveAuditReportUseCase(
              (report) async => Right(savedReport),
            ),
          ),
          getReachabilityZonesUseCaseProvider.overrideWith(
            (ref) async => StubGetReachabilityZonesUseCase(
              (size) async => const Right(<ReachabilityZone>[easyZone]),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(currentAuditReportProvider.notifier);

      await expectLater(
        notifier.performAudit(
          screenName: 'Home',
          screenSize: const Size(360, 800),
          elements: <UiElement>[buttonElement],
        ),
        throwsA(equals(failure)),
      );
      expect(container.read(currentAuditReportProvider), isNull);
    });
  });

  group('reachabilityZonesProvider', () {
    test('returns generated zones from use case', () async {
      final container = ProviderContainer(
        overrides: <Override>[
          getReachabilityZonesUseCaseProvider.overrideWith(
            (ref) async => StubGetReachabilityZonesUseCase(
              (size) async => const Right(<ReachabilityZone>[easyZone]),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final zones = await container.read(
        reachabilityZonesProvider(const Size(360, 800)).future,
      );

      expect(zones, hasLength(1));
      expect(zones.first.id, easyZone.id);
    });

    test('throws when getReachabilityZonesUseCase fails', () async {
      const failure = AppFailure.unexpected(message: 'zones failed');
      final container = ProviderContainer(
        overrides: <Override>[
          getReachabilityZonesUseCaseProvider.overrideWith(
            (ref) async => StubGetReachabilityZonesUseCase(
              (size) async => const Left(failure),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(reachabilityZonesProvider(const Size(360, 800)).future),
        throwsA(equals(failure)),
      );
    });
  });

  group('derived providers fallbacks', () {
    test('return safe defaults when no audit report is active', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(isAuditInProgressProvider), isFalse);
      expect(container.read(auditComplianceScoreProvider), 0.0);
      expect(container.read(auditPassesThresholdProvider), isFalse);
    });
  });
}

import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/features/capture_hit/domain/repositories/smoke_log_repository.dart';
import 'package:ash_trail/features/capture_hit/presentation/providers/smoke_log_providers.dart';
import 'package:ash_trail/features/edit_inline_snackbar/presentation/widgets/inline_edit_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class _FakeRepo implements SmokeLogRepository {
  int updateCalls = 0;
  @override
  Future<Either<AppFailure, SmokeLog>> updateSmokeLog(SmokeLog smokeLog) async {
    updateCalls += 1;
    return Right(smokeLog);
  }

  // Unused in this test
  @override
  Future<Either<AppFailure, SmokeLog>> createSmokeLog(SmokeLog smokeLog) =>
      throw UnimplementedError();
  @override
  Future<Either<AppFailure, void>> deleteSmokeLog(String smokeLogId) =>
      throw UnimplementedError();
  @override
  Future<Either<AppFailure, SmokeLog?>> getLastSmokeLog(String accountId) =>
      throw UnimplementedError();
  @override
  Future<Either<AppFailure, List<SmokeLog>>> getSmokeLogsByDateRange({
    required String accountId,
    required DateTime startDate,
    required DateTime endDate,
    int? limit,
  }) =>
      throw UnimplementedError();
}

void main() {
  late SmokeLog base;
  late _FakeRepo repo;

  setUp(() {
    repo = _FakeRepo();
    base = SmokeLog(
      id: 'log1',
      accountId: 'acc',
      ts: DateTime.now().subtract(const Duration(minutes: 1)),
      durationMs: 10000,
      methodId: null,
      potency: null,
      moodScore: 5,
      physicalScore: 5,
      notes: null,
      deviceLocalId: 'dev',
      createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 1)),
    );
  });

  setUpAll(() {});

  testWidgets('shows controls and saves', (tester) async {
    // fake repo returns Right by default

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          smokeLogRepositoryProvider.overrideWithValue(repo),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: InlineEditSnackbar(
                accountId: 'acc',
                createdLog: base,
                displayDuration: const Duration(seconds: 3),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Expect Save button visible
    expect(find.text('Save'), findsOneWidget);

    // Tap Save triggers repository update
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(repo.updateCalls, 1);
  });
}

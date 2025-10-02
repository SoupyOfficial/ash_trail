import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/features/capture_hit/domain/repositories/smoke_log_repository.dart';
import 'package:ash_trail/features/capture_hit/presentation/providers/smoke_log_providers.dart';
import 'package:ash_trail/features/edit_inline_snackbar/presentation/providers/edit_inline_snackbar_providers.dart';

class _FakeRepo implements SmokeLogRepository {
  _FakeRepo();
  Future<Either<AppFailure, SmokeLog>> Function(SmokeLog log)? onUpdate;
  int updateCalls = 0;

  @override
  Future<Either<AppFailure, SmokeLog>> updateSmokeLog(SmokeLog smokeLog) async {
    updateCalls += 1;
    if (onUpdate != null) return onUpdate!(smokeLog);
    return Right(smokeLog);
  }

  // Unused in these tests
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
  late ProviderContainer container;

  setUpAll(() {});

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

    container = ProviderContainer(overrides: [
      smokeLogRepositoryProvider.overrideWith((ref) => Future.value(repo)),
    ]);
    addTearDown(container.dispose);
  });

  test('initial state mirrors base log', () {
    final state = container.read(inlineEditControllerProvider(base));
    expect(state, isNotNull);
    expect(state!.adjustedDurationMs, base.durationMs);
    expect(state.notes, '');
    expect(state.isSaving, false);
  });

  test('increment/decrement duration clamps within bounds', () {
    final notifier =
        container.read(inlineEditControllerProvider(base).notifier);

    notifier.incrementDuration(5000);
    expect(
        container.read(inlineEditControllerProvider(base))!.adjustedDurationMs,
        15000);

    notifier.decrementDuration(20000); // goes below 1 -> clamp to 1
    expect(
        container.read(inlineEditControllerProvider(base))!.adjustedDurationMs,
        1);

    notifier.incrementDuration(2000000); // above 30m -> clamp
    expect(
        container.read(inlineEditControllerProvider(base))!.adjustedDurationMs,
        1800000);
  });

  test('save success updates state and calls repo', () async {
    repo.onUpdate = (smokeLog) async => Right(smokeLog);

    final notifier =
        container.read(inlineEditControllerProvider(base).notifier);

    // change something
    notifier.incrementDuration(5000);
    final saved = await notifier.save();

    expect(saved, isNotNull);
    final state = container.read(inlineEditControllerProvider(base));
    expect(state!.isSaving, false);
    expect(state.error, isNull);
    expect(repo.updateCalls, 1);
  });

  test('save failure surfaces error', () async {
    repo.onUpdate = (_) async => const Left(AppFailure.cache(message: 'boom'));

    final notifier =
        container.read(inlineEditControllerProvider(base).notifier);

    final saved = await notifier.save();
    expect(saved, isNull);
    final state = container.read(inlineEditControllerProvider(base));
    expect(state!.error, isNotNull);
  });
}

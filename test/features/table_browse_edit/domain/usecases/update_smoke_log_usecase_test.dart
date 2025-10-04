import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/features/table_browse_edit/domain/repositories/logs_table_repository.dart';
import 'package:ash_trail/features/table_browse_edit/domain/usecases/update_smoke_log_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockLogsTableRepository extends Mock implements LogsTableRepository {}

class SmokeLogFake extends Fake implements SmokeLog {}

void main() {
  late MockLogsTableRepository repository;
  late UpdateSmokeLogUseCase useCase;

  setUpAll(() {
    registerFallbackValue(SmokeLogFake());
  });

  setUp(() {
    repository = MockLogsTableRepository();
    useCase = UpdateSmokeLogUseCase(repository: repository);
  });

  SmokeLog baseLog({String id = 'log1', String accountId = 'acct-1'}) =>
      SmokeLog(
        id: id,
        accountId: accountId,
        ts: DateTime.parse('2024-01-01T10:00:00Z'),
        durationMs: 10 * 60000,
        methodId: 'method1',
        potency: 5,
        moodScore: 7,
        physicalScore: 6,
        notes: 'n',
        deviceLocalId: 'dev-1',
        createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
        updatedAt: DateTime.parse('2024-01-01T10:00:00Z'),
      );

  test('successfully updates valid log and touches updatedAt', () async {
    final log = baseLog();
    when(() => repository.updateSmokeLog(any())).thenAnswer((invocation) async {
      final passed = invocation.positionalArguments.first as SmokeLog;
      // Ensure updatedAt has been changed to a recent time (allow small delta)
      expect(passed.updatedAt.isAfter(log.updatedAt), true);
      return Right(passed);
    });

    final result = await useCase(smokeLog: log, accountId: 'acct-1');
    expect(result.isRight(), true);
    verify(() => repository.updateSmokeLog(any())).called(1);
  });

  group('validation', () {
    test('accountId required', () async {
      final res = await useCase(smokeLog: baseLog(), accountId: '');
      expect(res.isLeft(), true);
      res.mapLeft((f) => expect(f.displayMessage, 'Account ID is required'));
    });

    test('id required', () async {
      final res = await useCase(smokeLog: baseLog(id: ''), accountId: 'acct-1');
      expect(res.isLeft(), true);
      res.mapLeft((f) => expect(f.displayMessage, 'Smoke log ID is required'));
    });

    test('account ownership enforced', () async {
      final res = await useCase(
          smokeLog: baseLog(accountId: 'other'), accountId: 'acct-1');
      expect(res.isLeft(), true);
      res.mapLeft((f) =>
          expect(f.displayMessage, 'Cannot update log from different account'));
    });

    test('duration must be > 0', () async {
      final res = await useCase(
          smokeLog: baseLog().copyWith(durationMs: 0), accountId: 'acct-1');
      expect(res.isLeft(), true);
      res.mapLeft(
          (f) => expect(f.displayMessage, 'Duration must be greater than 0'));
    });

    test('duration must be <= 30 minutes', () async {
      final res = await useCase(
          smokeLog: baseLog().copyWith(durationMs: 31 * 60000),
          accountId: 'acct-1');
      expect(res.isLeft(), true);
      res.mapLeft(
          (f) => expect(f.displayMessage, 'Duration cannot exceed 30 minutes'));
    });

    test('mood score between 1 and 10', () async {
      final res = await useCase(
          smokeLog: baseLog().copyWith(moodScore: 0), accountId: 'acct-1');
      expect(res.isLeft(), true);
      res.mapLeft((f) =>
          expect(f.displayMessage, 'Mood score must be between 1 and 10'));
    });

    test('physical score between 1 and 10', () async {
      final res = await useCase(
          smokeLog: baseLog().copyWith(physicalScore: 11), accountId: 'acct-1');
      expect(res.isLeft(), true);
      res.mapLeft((f) =>
          expect(f.displayMessage, 'Physical score must be between 1 and 10'));
    });

    test('potency between 1 and 10 when provided', () async {
      final res = await useCase(
          smokeLog: baseLog().copyWith(potency: 0), accountId: 'acct-1');
      expect(res.isLeft(), true);
      res.mapLeft(
          (f) => expect(f.displayMessage, 'Potency must be between 1 and 10'));
    });

    test('timestamp cannot be in the future', () async {
      final res = await useCase(
          smokeLog: baseLog()
              .copyWith(ts: DateTime.now().add(const Duration(days: 1))),
          accountId: 'acct-1');
      expect(res.isLeft(), true);
      res.mapLeft((f) =>
          expect(f.displayMessage, 'Log timestamp cannot be in the future'));
    });

    test('notes reasonable length limit', () async {
      final res = await useCase(
          smokeLog: baseLog().copyWith(notes: 'x' * 1001), accountId: 'acct-1');
      expect(res.isLeft(), true);
      res.mapLeft((f) =>
          expect(f.displayMessage, 'Notes cannot exceed 1000 characters'));
    });
  });

  test('propagates repository failure', () async {
    when(() => repository.updateSmokeLog(any()))
        .thenAnswer((_) async => const Left(AppFailure.cache(message: 'db')));
    final res = await useCase(smokeLog: baseLog(), accountId: 'acct-1');
    expect(res.isLeft(), true);
    res.mapLeft((f) => expect(f.displayMessage, 'db'));
  });
}

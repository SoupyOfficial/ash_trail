import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/data/models/smoke_log_isar.dart';
import 'package:ash_trail/data/services/isar_service.dart';
import 'package:ash_trail/features/capture_hit/data/datasources/smoke_log_local_datasource_impl.dart';
import 'package:ash_trail/features/capture_hit/data/models/smoke_log_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockIsarSmokeLogService extends Mock implements IsarSmokeLogService {}

void main() {
  late MockIsarSmokeLogService mockService;
  late SmokeLogLocalDataSourceImpl dataSource;

  SmokeLogDto buildDto({
    String id = 'log-1',
    String accountId = 'account-1',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final created = createdAt ?? DateTime.utc(2024, 1, 1, 12);
    final updated = updatedAt ?? created;
    return SmokeLogDto(
      id: id,
      accountId: accountId,
      ts: DateTime.utc(2024, 1, 1, 10),
      durationMs: 90000,
      moodScore: 7,
      physicalScore: 6,
      createdAt: created,
      updatedAt: updated,
    );
  }

  SmokeLogIsar buildIsar(SmokeLogDto dto) {
    final isar = SmokeLogIsar.fromDomain(dto.toEntity());
    isar.id = 1;
    return isar;
  }

  setUpAll(() {
    registerFallbackValue(buildIsar(buildDto()));
  });

  setUp(() {
    mockService = MockIsarSmokeLogService();
    dataSource = SmokeLogLocalDataSourceImpl(mockService);
  });

  group('createSmokeLog', () {
    test('saves dto and marks as pending sync', () async {
      final dto = buildDto();

      when(() => mockService.saveSmokeLog(any()))
          .thenAnswer((invocation) async {
        final isar = invocation.positionalArguments.first as SmokeLogIsar;
        return Right(isar);
      });

      final result = await dataSource.createSmokeLog(dto);

      expect(result.id, dto.id);
      expect(result.isPendingSync, isTrue);
      verify(() => mockService.saveSmokeLog(any())).called(1);
    });

    test('throws failure when save fails', () async {
      final dto = buildDto();
      const failure = AppFailure.cache(message: 'save error');

      when(() => mockService.saveSmokeLog(any()))
          .thenAnswer((_) async => const Left(failure));

      expect(() => dataSource.createSmokeLog(dto), throwsA(failure));
    });
  });

  group('getLastSmokeLog', () {
    test('returns null when no logs', () async {
      when(() => mockService.getSmokeLogsByAccount('account-1'))
          .thenAnswer((_) async => const Right([]));

      final result = await dataSource.getLastSmokeLog('account-1');

      expect(result, isNull);
    });

    test('returns first log when logs exist', () async {
      final dto = buildDto();
      final isar = buildIsar(dto);

      when(() => mockService.getSmokeLogsByAccount('account-1'))
          .thenAnswer((_) async => Right([isar]));

      final result = await dataSource.getLastSmokeLog('account-1');

      expect(result, isNotNull);
      expect(result!.id, dto.id);
    });
  });

  group('deleteSmokeLog', () {
    test('delegates to service', () async {
      when(() => mockService.deleteSmokeLog('log-1'))
          .thenAnswer((_) async => const Right(true));

      await dataSource.deleteSmokeLog('log-1');

      verify(() => mockService.deleteSmokeLog('log-1')).called(1);
    });

    test('throws failure when delete fails', () async {
      const failure = AppFailure.cache(message: 'delete');
      when(() => mockService.deleteSmokeLog('log-1'))
          .thenAnswer((_) async => const Left(failure));

      expect(() => dataSource.deleteSmokeLog('log-1'), throwsA(failure));
    });
  });

  group('getSmokeLogsByDateRange', () {
    test('returns mapped list respecting limit', () async {
      final dto = buildDto();
      final isar = buildIsar(dto);
      final extra = buildIsar(buildDto(id: 'log-2'));

      when(() => mockService.getSmokeLogsInDateRange(
            'account-1',
            any(),
            any(),
          )).thenAnswer((_) async => Right([isar, extra]));

      final result = await dataSource.getSmokeLogsByDateRange(
        accountId: 'account-1',
        startDate: DateTime.utc(2024, 1, 1),
        endDate: DateTime.utc(2024, 1, 2),
        limit: 1,
      );

      expect(result.length, 1);
      expect(result.first.id, dto.id);
    });

    test('throws when service fails', () async {
      const failure = AppFailure.cache(message: 'range');
      when(() => mockService.getSmokeLogsInDateRange(
            'account-1',
            any(),
            any(),
          )).thenAnswer((_) async => const Left(failure));

      expect(
        () => dataSource.getSmokeLogsByDateRange(
          accountId: 'account-1',
          startDate: DateTime.utc(2024, 1, 1),
          endDate: DateTime.utc(2024, 1, 2),
        ),
        throwsA(failure),
      );
    });
  });

  group('updateSmokeLog', () {
    test('marks dto as pending sync with updated timestamp', () async {
      final dto = buildDto(updatedAt: DateTime.utc(2024, 1, 1));

      when(() => mockService.saveSmokeLog(any()))
          .thenAnswer((invocation) async {
        final isar = invocation.positionalArguments.first as SmokeLogIsar;
        return Right(isar);
      });

      final result = await dataSource.updateSmokeLog(dto);

      expect(result.isPendingSync, isTrue);
      expect(result.updatedAt.isAfter(dto.updatedAt), isTrue);
    });

    test('throws when save fails', () async {
      const failure = AppFailure.cache(message: 'update');
      when(() => mockService.saveSmokeLog(any()))
          .thenAnswer((_) async => const Left(failure));

      expect(() => dataSource.updateSmokeLog(buildDto()), throwsA(failure));
    });
  });

  group('getPendingSyncLogs', () {
    test('filters logs by account id', () async {
      final target = buildIsar(buildDto(accountId: 'account-1'));
      final other = buildIsar(buildDto(id: 'log-2', accountId: 'account-2'));

      when(() => mockService.getDirtySmokeLog())
          .thenAnswer((_) async => Right([target, other]));

      final result = await dataSource.getPendingSyncLogs('account-1');

      expect(result.length, 1);
      expect(result.single.accountId, 'account-1');
      expect(result.single.isPendingSync, isTrue);
    });

    test('throws when fetch fails', () async {
      const failure = AppFailure.cache(message: 'dirty');
      when(() => mockService.getDirtySmokeLog())
          .thenAnswer((_) async => const Left(failure));

      expect(
          () => dataSource.getPendingSyncLogs('account-1'), throwsA(failure));
    });
  });

  group('markAsSynced', () {
    test('delegates to service', () async {
      when(() => mockService.markAsSynced('log-1'))
          .thenAnswer((_) async => const Right(null));

      await dataSource.markAsSynced('log-1');

      verify(() => mockService.markAsSynced('log-1')).called(1);
    });

    test('throws when mark fails', () async {
      const failure = AppFailure.cache(message: 'sync');
      when(() => mockService.markAsSynced('log-1'))
          .thenAnswer((_) async => const Left(failure));

      expect(() => dataSource.markAsSynced('log-1'), throwsA(failure));
    });
  });

  group('clearAccountLogs', () {
    test('deletes each log for account', () async {
      final first = buildIsar(buildDto(id: 'log-1'));
      first.logId = 'log-1';
      final second = buildIsar(buildDto(id: 'log-2'));
      second.logId = 'log-2';

      when(() => mockService.getSmokeLogsByAccount('account-1'))
          .thenAnswer((_) async => Right([first, second]));
      when(() => mockService.deleteSmokeLog(any()))
          .thenAnswer((_) async => const Right(true));

      await dataSource.clearAccountLogs('account-1');

      verify(() => mockService.deleteSmokeLog('log-1')).called(1);
      verify(() => mockService.deleteSmokeLog('log-2')).called(1);
    });

    test('throws when listing logs fails', () async {
      const failure = AppFailure.cache(message: 'list');
      when(() => mockService.getSmokeLogsByAccount('account-1'))
          .thenAnswer((_) async => const Left(failure));

      expect(() => dataSource.clearAccountLogs('account-1'), throwsA(failure));
    });
  });

  group('getLogsCount', () {
    test('returns count from service', () async {
      when(() => mockService.getSmokeLogsCount('account-1'))
          .thenAnswer((_) async => const Right(5));

      final result = await dataSource.getLogsCount('account-1');

      expect(result, 5);
    });

    test('throws when count fails', () async {
      const failure = AppFailure.cache(message: 'count');
      when(() => mockService.getSmokeLogsCount('account-1'))
          .thenAnswer((_) async => const Left(failure));

      expect(() => dataSource.getLogsCount('account-1'), throwsA(failure));
    });
  });
}

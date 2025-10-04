import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/data/repositories/smoke_log_repository_provider.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/core/providers/account_providers.dart';

const bool _isFlutterTest =
    bool.fromEnvironment('FLUTTER_TEST', defaultValue: false);

Future<void> seedDevSampleData(ProviderContainer container) async {
  if (kReleaseMode || _isFlutterTest) {
    return;
  }

  final account = container.read(activeAccountProvider);
  if (account == null) {
    return;
  }

  final repository = await container.read(smokeLogRepositoryProvider.future);

  final Either<AppFailure, List<SmokeLog>> existingResult =
      await repository.getSmokeLogsByDateRange(
    accountId: account.id,
    startDate: DateTime.now().subtract(const Duration(days: 30)),
    endDate: DateTime.now().add(const Duration(days: 1)),
    limit: 1,
  );

  final shouldSeed = existingResult.match(
    (AppFailure failure) {
      debugPrint(
          'Dev sample data: unable to inspect existing smoke logs: ${failure.displayMessage}');
      return true;
    },
    (List<SmokeLog> logs) => logs.isEmpty,
  );

  if (!shouldSeed) {
    return;
  }

  for (final SmokeLog log in DevSampleData.smokeLogs(accountId: account.id)) {
    final creationResult = await repository.createSmokeLog(log);
    creationResult.match(
      (AppFailure failure) => debugPrint(
        'Dev sample data: failed to insert ${log.id}: ${failure.displayMessage}',
      ),
      (_) {},
    );
  }
}

class DevSampleData {
  static const String _deviceId = 'dev-sample-device';

  static List<SmokeLog> smokeLogs({required String accountId}) {
    final DateTime now = DateTime.now();
    final DateTime base = DateTime(now.year, now.month, now.day, now.hour);

    return <SmokeLog>[
      _buildSmokeLog(
        accountId: accountId,
        idSuffix: '001',
        timestamp: base.subtract(const Duration(minutes: 15)),
        durationMinutes: 6,
        moodScore: 7,
        physicalScore: 6,
        methodId: 'joint',
        potency: 3,
        notes: 'Quick outdoor break before lunch.',
      ),
      _buildSmokeLog(
        accountId: accountId,
        idSuffix: '002',
        timestamp: base.subtract(const Duration(hours: 4)),
        durationMinutes: 8,
        moodScore: 6,
        physicalScore: 5,
        methodId: 'vape',
        potency: 2,
        notes: 'Tried new flavor cartridge.',
      ),
      _buildSmokeLog(
        accountId: accountId,
        idSuffix: '003',
        timestamp: base.subtract(const Duration(hours: 9)),
        durationMinutes: 5,
        moodScore: 5,
        physicalScore: 4,
        methodId: 'pipe',
        potency: 4,
        notes: 'Late night session while watching a show.',
      ),
      _buildSmokeLog(
        accountId: accountId,
        idSuffix: '004',
        timestamp: base.subtract(const Duration(days: 1, hours: 2)),
        durationMinutes: 7,
        moodScore: 6,
        physicalScore: 6,
        methodId: 'edible',
        potency: 5,
        notes: 'Split a gummy with friend.',
      ),
      _buildSmokeLog(
        accountId: accountId,
        idSuffix: '005',
        timestamp: base.subtract(const Duration(days: 2, hours: 6)),
        durationMinutes: 10,
        moodScore: 8,
        physicalScore: 7,
        methodId: 'bong',
        potency: 3,
        notes: 'Weekend wind-down session.',
      ),
      _buildSmokeLog(
        accountId: accountId,
        idSuffix: '006',
        timestamp: base.subtract(const Duration(days: 4, hours: 3)),
        durationMinutes: 4,
        moodScore: 5,
        physicalScore: 5,
        methodId: 'joint',
        potency: 2,
        notes: 'Short break during walk.',
      ),
      _buildSmokeLog(
        accountId: accountId,
        idSuffix: '007',
        timestamp: base.subtract(const Duration(days: 6, hours: 5)),
        durationMinutes: 9,
        moodScore: 7,
        physicalScore: 6,
        methodId: 'vape',
        potency: 3,
        notes: 'Tracked reaction to new strain.',
      ),
    ];
  }

  static SmokeLog _buildSmokeLog({
    required String accountId,
    required String idSuffix,
    required DateTime timestamp,
    required int durationMinutes,
    required int moodScore,
    required int physicalScore,
    String? methodId,
    int? potency,
    String? notes,
  }) {
    final DateTime createdAt = timestamp.subtract(const Duration(minutes: 1));
    final String id = 'dev-$accountId-log-$idSuffix';
    return SmokeLog(
      id: id,
      accountId: accountId,
      ts: timestamp,
      durationMs: durationMinutes * 60 * 1000,
      methodId: methodId,
      potency: potency,
      moodScore: moodScore,
      physicalScore: physicalScore,
      notes: notes,
      deviceLocalId: _deviceId,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }
}

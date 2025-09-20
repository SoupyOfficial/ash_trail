import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmokeLog JSON', () {
    test('round-trips with optional fields', () {
      final log = SmokeLog(
        id: '1',
        accountId: 'acct',
        ts: DateTime.parse('2024-01-01T10:00:00Z'),
        durationMs: 123456,
        methodId: 'm',
        potency: 3,
        moodScore: 9,
        physicalScore: 4,
        notes: 'note',
        deviceLocalId: 'dev',
        createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
        updatedAt: DateTime.parse('2024-01-02T10:00:00Z'),
      );
      final json = log.toJson();
      final back = SmokeLog.fromJson(json);
      expect(back, equals(log));
    });

    test('handles null optional fields', () {
      final log = SmokeLog(
        id: '1',
        accountId: 'acct',
        ts: DateTime.parse('2024-01-01T10:00:00Z'),
        durationMs: 1000,
        moodScore: 5,
        physicalScore: 5,
        createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
        updatedAt: DateTime.parse('2024-01-01T10:00:00Z'),
      );
      final back = SmokeLog.fromJson(log.toJson());
      expect(back.methodId, isNull);
      expect(back.potency, isNull);
      expect(back.notes, isNull);
      expect(back.deviceLocalId, isNull);
      expect(back, equals(log));
    });
  });
}

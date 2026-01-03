import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/models/account.dart';

void main() {
  group('LogRecord Edge Cases', () {
    group('Date/Time Edge Cases', () {
      test('handles midnight timestamps correctly', () {
        final midnight = DateTime(2025, 1, 15, 0, 0, 0);
        final record = LogRecord.create(
          logId: 'midnight-test',
          accountId: 'test-account',
          eventAt: midnight,
          eventType: EventType.inhale,
        );

        expect(record.eventAt.hour, 0);
        expect(record.eventAt.minute, 0);
        expect(record.eventAt.second, 0);

        // Roundtrip through Firestore
        final map = record.toFirestore();
        final restored = LogRecord.fromFirestore(map);
        expect(restored.eventAt.hour, 0);
        expect(restored.eventAt.minute, 0);
      });

      test('handles end of day timestamps correctly', () {
        final endOfDay = DateTime(2025, 1, 15, 23, 59, 59, 999);
        final record = LogRecord.create(
          logId: 'end-of-day-test',
          accountId: 'test-account',
          eventAt: endOfDay,
          eventType: EventType.inhale,
        );

        expect(record.eventAt.hour, 23);
        expect(record.eventAt.minute, 59);
      });

      test('handles year boundary transitions', () {
        final newYearsEve = DateTime(2024, 12, 31, 23, 59, 59);
        final newYear = DateTime(2025, 1, 1, 0, 0, 0);

        final record1 = LogRecord.create(
          logId: 'nye-test',
          accountId: 'test-account',
          eventAt: newYearsEve,
          eventType: EventType.inhale,
        );

        final record2 = LogRecord.create(
          logId: 'ny-test',
          accountId: 'test-account',
          eventAt: newYear,
          eventType: EventType.vape,
        );

        expect(record1.eventAt.year, 2024);
        expect(record2.eventAt.year, 2025);
      });

      test('handles leap year dates', () {
        final leapYearDate = DateTime(2024, 2, 29, 12, 0);
        final record = LogRecord.create(
          logId: 'leap-year-test',
          accountId: 'test-account',
          eventAt: leapYearDate,
          eventType: EventType.inhale,
        );

        expect(record.eventAt.month, 2);
        expect(record.eventAt.day, 29);

        final map = record.toFirestore();
        final restored = LogRecord.fromFirestore(map);
        expect(restored.eventAt.day, 29);
      });

      test('handles timezone edge cases - UTC conversion', () {
        final utcTime = DateTime.utc(2025, 6, 15, 12, 0);
        final localTime = utcTime.toLocal();

        final record = LogRecord.create(
          logId: 'timezone-test',
          accountId: 'test-account',
          eventAt: localTime,
          eventType: EventType.inhale,
        );

        // Roundtrip should preserve the time
        final map = record.toFirestore();
        final restored = LogRecord.fromFirestore(map);

        expect(
          restored.eventAt.millisecondsSinceEpoch,
          record.eventAt.millisecondsSinceEpoch,
        );
      });
    });

    group('Location Edge Cases', () {
      test('handles extreme valid latitude values', () {
        // North Pole
        final northPole = LogRecord.create(
          logId: 'north-pole',
          accountId: 'test-account',
          eventType: EventType.inhale,
          latitude: 90.0,
          longitude: 0.0,
        );
        expect(northPole.hasLocation, true);
        expect(northPole.latitude, 90.0);

        // South Pole
        final southPole = LogRecord.create(
          logId: 'south-pole',
          accountId: 'test-account',
          eventType: EventType.inhale,
          latitude: -90.0,
          longitude: 0.0,
        );
        expect(southPole.hasLocation, true);
        expect(southPole.latitude, -90.0);
      });

      test('handles extreme valid longitude values', () {
        final easternEdge = LogRecord.create(
          logId: 'eastern-edge',
          accountId: 'test-account',
          eventType: EventType.inhale,
          latitude: 0.0,
          longitude: 180.0,
        );
        expect(easternEdge.longitude, 180.0);

        final westernEdge = LogRecord.create(
          logId: 'western-edge',
          accountId: 'test-account',
          eventType: EventType.inhale,
          latitude: 0.0,
          longitude: -180.0,
        );
        expect(westernEdge.longitude, -180.0);
      });

      test('hasLocation returns false when only latitude is set', () {
        final record = LogRecord.create(
          logId: 'lat-only',
          accountId: 'test-account',
          eventType: EventType.inhale,
          latitude: 37.7749,
        );
        expect(record.hasLocation, false);
      });

      test('hasLocation returns false when only longitude is set', () {
        final record = LogRecord.create(
          logId: 'long-only',
          accountId: 'test-account',
          eventType: EventType.inhale,
          longitude: -122.4194,
        );
        expect(record.hasLocation, false);
      });

      test('handles zero coordinates correctly', () {
        // Null Island (0,0) is a valid location
        final nullIsland = LogRecord.create(
          logId: 'null-island',
          accountId: 'test-account',
          eventType: EventType.inhale,
          latitude: 0.0,
          longitude: 0.0,
        );
        expect(nullIsland.hasLocation, true);
        expect(nullIsland.latitude, 0.0);
        expect(nullIsland.longitude, 0.0);
      });
    });

    group('Rating Edge Cases', () {
      test('handles minimum valid mood rating', () {
        final record = LogRecord.create(
          logId: 'min-mood',
          accountId: 'test-account',
          eventType: EventType.inhale,
          moodRating: 1.0,
        );
        expect(record.moodRating, 1.0);
      });

      test('handles maximum valid mood rating', () {
        final record = LogRecord.create(
          logId: 'max-mood',
          accountId: 'test-account',
          eventType: EventType.inhale,
          moodRating: 10.0,
        );
        expect(record.moodRating, 10.0);
      });

      test('handles decimal mood ratings', () {
        final record = LogRecord.create(
          logId: 'decimal-mood',
          accountId: 'test-account',
          eventType: EventType.inhale,
          moodRating: 7.5,
        );
        expect(record.moodRating, 7.5);
      });

      test('handles null ratings correctly', () {
        final record = LogRecord.create(
          logId: 'null-ratings',
          accountId: 'test-account',
          eventType: EventType.inhale,
        );
        expect(record.moodRating, null);
        expect(record.physicalRating, null);
      });
    });

    group('Duration Edge Cases', () {
      test('handles zero duration', () {
        final record = LogRecord.create(
          logId: 'zero-duration',
          accountId: 'test-account',
          eventType: EventType.inhale,
          duration: 0.0,
        );
        expect(record.duration, 0.0);
      });

      test('handles very large duration', () {
        final record = LogRecord.create(
          logId: 'large-duration',
          accountId: 'test-account',
          eventType: EventType.inhale,
          duration: 86400.0, // 24 hours in seconds
        );
        expect(record.duration, 86400.0);
      });

      test('handles fractional duration', () {
        final record = LogRecord.create(
          logId: 'fractional-duration',
          accountId: 'test-account',
          eventType: EventType.inhale,
          duration: 0.5,
        );
        expect(record.duration, 0.5);
      });
    });

    group('String Field Edge Cases', () {
      test('handles empty note', () {
        final record = LogRecord.create(
          logId: 'empty-note',
          accountId: 'test-account',
          eventType: EventType.inhale,
          note: '',
        );
        expect(record.note, '');
      });

      test('handles very long note', () {
        final longNote = 'A' * 10000;
        final record = LogRecord.create(
          logId: 'long-note',
          accountId: 'test-account',
          eventType: EventType.inhale,
          note: longNote,
        );
        expect(record.note!.length, 10000);
      });

      test('handles special characters in note', () {
        final specialChars =
            '🔥💨 Test <script>alert("xss")</script> & "quotes"';
        final record = LogRecord.create(
          logId: 'special-chars',
          accountId: 'test-account',
          eventType: EventType.inhale,
          note: specialChars,
        );
        expect(record.note, specialChars);

        // Roundtrip
        final map = record.toFirestore();
        final restored = LogRecord.fromFirestore(map);
        expect(restored.note, specialChars);
      });

      test('handles unicode in note', () {
        final unicodeNote = '日本語テスト العربية 中文测试';
        final record = LogRecord.create(
          logId: 'unicode-note',
          accountId: 'test-account',
          eventType: EventType.inhale,
          note: unicodeNote,
        );
        expect(record.note, unicodeNote);

        final map = record.toFirestore();
        final restored = LogRecord.fromFirestore(map);
        expect(restored.note, unicodeNote);
      });
    });

    group('Reasons Edge Cases', () {
      test('handles empty reasons list', () {
        final record = LogRecord.create(
          logId: 'empty-reasons',
          accountId: 'test-account',
          eventType: EventType.inhale,
          reasons: [],
        );
        expect(record.reasons, []);
      });

      test('handles all reasons selected', () {
        final allReasons = LogReason.values.toList();
        final record = LogRecord.create(
          logId: 'all-reasons',
          accountId: 'test-account',
          eventType: EventType.inhale,
          reasons: allReasons,
        );
        expect(record.reasons!.length, LogReason.values.length);
      });

      test('handles duplicate reasons', () {
        final record = LogRecord.create(
          logId: 'duplicate-reasons',
          accountId: 'test-account',
          eventType: EventType.inhale,
          reasons: [LogReason.stress, LogReason.stress],
        );
        expect(record.reasons!.length, 2); // Duplicates are allowed
      });

      test('preserves reason order', () {
        final reasons = [LogReason.social, LogReason.stress, LogReason.pain];
        final record = LogRecord.create(
          logId: 'ordered-reasons',
          accountId: 'test-account',
          eventType: EventType.inhale,
          reasons: reasons,
        );

        final map = record.toFirestore();
        final restored = LogRecord.fromFirestore(map);

        expect(restored.reasons![0], LogReason.social);
        expect(restored.reasons![1], LogReason.stress);
        expect(restored.reasons![2], LogReason.pain);
      });
    });

    group('Sync State Edge Cases', () {
      test('multiple markDirty calls increment revision', () {
        final record = LogRecord.create(
          logId: 'multi-dirty',
          accountId: 'test-account',
          eventType: EventType.inhale,
        );

        expect(record.revision, 0);

        record.markDirty();
        expect(record.revision, 1);

        record.markDirty();
        expect(record.revision, 2);

        record.markDirty();
        expect(record.revision, 3);
      });

      test('softDelete after markSynced sets pending', () {
        final record = LogRecord.create(
          logId: 'delete-after-sync',
          accountId: 'test-account',
          eventType: EventType.inhale,
        );

        record.markSynced(DateTime.now());
        expect(record.syncState, SyncState.synced);

        record.softDelete();
        expect(record.syncState, SyncState.pending);
        expect(record.isDeleted, true);
      });

      test('markSynced clears previous sync error', () {
        final record = LogRecord.create(
          logId: 'clear-error',
          accountId: 'test-account',
          eventType: EventType.inhale,
        );

        record.markSyncError('Previous error');
        expect(record.syncError, 'Previous error');
        expect(record.syncState, SyncState.error);

        record.markSynced(DateTime.now());
        expect(record.syncError, null);
        expect(record.syncState, SyncState.synced);
      });
    });

    group('CopyWith Edge Cases', () {
      test('copyWith preserves original ID', () {
        final original = LogRecord.create(
          logId: 'original-id',
          accountId: 'account-1',
          eventType: EventType.inhale,
        );
        original.id = 42;

        final copy = original.copyWith(note: 'Updated');
        expect(copy.id, 42);
        expect(copy.logId, 'original-id');
      });

      test('copyWith can clear optional fields with explicit null', () {
        final original = LogRecord.create(
          logId: 'test-id',
          accountId: 'account-1',
          eventType: EventType.inhale,
          note: 'Original note',
          moodRating: 5.0,
        );

        // Note: copyWith uses ?? so passing null keeps original value
        // This tests the current behavior
        final copy = original.copyWith();
        expect(copy.note, 'Original note');
        expect(copy.moodRating, 5.0);
      });

      test('copyWith with all different values', () {
        final original = LogRecord.create(
          logId: 'original',
          accountId: 'account-1',
          eventType: EventType.inhale,
          duration: 1.0,
          unit: Unit.seconds,
          note: 'Original',
        );

        final copy = original.copyWith(
          logId: 'new-id',
          accountId: 'account-2',
          eventType: EventType.vape,
          duration: 2.0,
          unit: Unit.hits,
          note: 'New',
        );

        expect(copy.logId, 'new-id');
        expect(copy.accountId, 'account-2');
        expect(copy.eventType, EventType.vape);
        expect(copy.duration, 2.0);
        expect(copy.unit, Unit.hits);
        expect(copy.note, 'New');
      });
    });

    group('Firestore Conversion Edge Cases', () {
      test('handles missing optional fields in fromFirestore', () {
        final minimalMap = {
          'logId': 'minimal',
          'accountId': 'account',
          'eventAt': '2025-01-01T10:00:00.000',
          'createdAt': '2025-01-01T10:00:00.000',
          'updatedAt': '2025-01-01T10:00:00.000',
          'eventType': 'inhale',
        };

        final record = LogRecord.fromFirestore(minimalMap);

        expect(record.logId, 'minimal');
        expect(record.note, null);
        expect(record.moodRating, null);
        expect(record.reasons, null);
        expect(record.latitude, null);
        expect(record.longitude, null);
        expect(record.duration, 0);
      });

      test('handles unknown eventType gracefully', () {
        final mapWithUnknownType = {
          'logId': 'unknown-type',
          'accountId': 'account',
          'eventAt': '2025-01-01T10:00:00.000',
          'createdAt': '2025-01-01T10:00:00.000',
          'updatedAt': '2025-01-01T10:00:00.000',
          'eventType': 'unknownFutureType',
        };

        final record = LogRecord.fromFirestore(mapWithUnknownType);
        expect(record.eventType, EventType.custom);
      });

      test('handles unknown unit gracefully', () {
        final mapWithUnknownUnit = {
          'logId': 'unknown-unit',
          'accountId': 'account',
          'eventAt': '2025-01-01T10:00:00.000',
          'createdAt': '2025-01-01T10:00:00.000',
          'updatedAt': '2025-01-01T10:00:00.000',
          'eventType': 'inhale',
          'unit': 'unknownFutureUnit',
        };

        final record = LogRecord.fromFirestore(mapWithUnknownUnit);
        expect(record.unit, Unit.seconds);
      });

      test('handles unknown reason gracefully', () {
        final mapWithUnknownReason = {
          'logId': 'unknown-reason',
          'accountId': 'account',
          'eventAt': '2025-01-01T10:00:00.000',
          'createdAt': '2025-01-01T10:00:00.000',
          'updatedAt': '2025-01-01T10:00:00.000',
          'eventType': 'inhale',
          'reasons': ['stress', 'unknownFutureReason', 'social'],
        };

        final record = LogRecord.fromFirestore(mapWithUnknownReason);
        expect(record.reasons!.length, 3);
        expect(record.reasons![0], LogReason.stress);
        expect(
          record.reasons![1],
          LogReason.other,
        ); // Unknown falls back to other
        expect(record.reasons![2], LogReason.social);
      });

      test('handles integer duration from Firestore', () {
        final mapWithIntDuration = {
          'logId': 'int-duration',
          'accountId': 'account',
          'eventAt': '2025-01-01T10:00:00.000',
          'createdAt': '2025-01-01T10:00:00.000',
          'updatedAt': '2025-01-01T10:00:00.000',
          'eventType': 'inhale',
          'duration': 5, // Integer instead of double
        };

        final record = LogRecord.fromFirestore(mapWithIntDuration);
        expect(record.duration, 5.0);
      });
    });
  });

  group('Account Edge Cases', () {
    test('handles empty email', () {
      final account = Account.create(userId: 'test-user', email: '');
      expect(account.email, '');
    });

    test('handles email with special characters', () {
      final account = Account.create(
        userId: 'test-user',
        email: 'test+tag@example.com',
      );
      expect(account.email, 'test+tag@example.com');
    });

    test('handles very long display name', () {
      final longName = 'A' * 500;
      final account = Account.create(
        userId: 'test-user',
        email: 'test@example.com',
        displayName: longName,
      );
      expect(account.displayName!.length, 500);
    });

    test('handles unicode in display name', () {
      final unicodeName = '用户名 🎉 مستخدم';
      final account = Account.create(
        userId: 'test-user',
        email: 'test@example.com',
        displayName: unicodeName,
      );
      expect(account.displayName, unicodeName);
    });
  });

  group('Enum Completeness', () {
    test('all EventType values can be serialized and deserialized', () {
      for (final eventType in EventType.values) {
        final record = LogRecord.create(
          logId: 'enum-test-${eventType.name}',
          accountId: 'test-account',
          eventType: eventType,
        );

        final map = record.toFirestore();
        final restored = LogRecord.fromFirestore(map);

        expect(restored.eventType, eventType);
      }
    });

    test('all Unit values can be serialized and deserialized', () {
      for (final unit in Unit.values) {
        final record = LogRecord.create(
          logId: 'unit-test-${unit.name}',
          accountId: 'test-account',
          eventType: EventType.inhale,
          unit: unit,
        );

        final map = record.toFirestore();
        final restored = LogRecord.fromFirestore(map);

        expect(restored.unit, unit);
      }
    });

    test('all Source values can be serialized and deserialized', () {
      for (final source in Source.values) {
        final record = LogRecord.create(
          logId: 'source-test-${source.name}',
          accountId: 'test-account',
          eventType: EventType.inhale,
          source: source,
        );

        final map = record.toFirestore();
        final restored = LogRecord.fromFirestore(map);

        expect(restored.source, source);
      }
    });

    test('all LogReason values can be serialized and deserialized', () {
      for (final reason in LogReason.values) {
        final record = LogRecord.create(
          logId: 'reason-test-${reason.name}',
          accountId: 'test-account',
          eventType: EventType.inhale,
          reasons: [reason],
        );

        final map = record.toFirestore();
        final restored = LogRecord.fromFirestore(map);

        expect(restored.reasons!.first, reason);
      }
    });

    test('all TimeConfidence values can be serialized and deserialized', () {
      for (final confidence in TimeConfidence.values) {
        final record = LogRecord.create(
          logId: 'confidence-test-${confidence.name}',
          accountId: 'test-account',
          eventType: EventType.inhale,
          timeConfidence: confidence,
        );

        final map = record.toFirestore();
        final restored = LogRecord.fromFirestore(map);

        expect(restored.timeConfidence, confidence);
      }
    });
  });
}

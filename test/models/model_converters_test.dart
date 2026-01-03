import 'package:flutter_test/flutter_test.dart';

import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/model_converters.dart';
import 'package:ash_trail/models/web_models.dart';
import 'package:ash_trail/models/enums.dart';

void main() {
  group('Model Converter Tests', () {
    group('Account Web Conversion', () {
      test('toWebModel converts all fields correctly', () {
        final createdAt = DateTime(2024, 1, 1, 10, 0);
        final lastSyncedAt = DateTime(2024, 1, 15, 14, 30);
        final account = Account.create(
          userId: 'user-123',
          email: 'test@example.com',
          displayName: 'Test User',
          photoUrl: 'https://example.com/photo.jpg',
          isActive: true,
          createdAt: createdAt,
          lastSyncedAt: lastSyncedAt,
        )..id = 42;

        final webModel = account.toWebModel();

        expect(webModel.id, equals('42'));
        expect(webModel.userId, equals('user-123'));
        expect(webModel.email, equals('test@example.com'));
        expect(webModel.displayName, equals('Test User'));
        expect(webModel.photoUrl, equals('https://example.com/photo.jpg'));
        expect(webModel.isActive, isTrue);
        expect(webModel.createdAt, equals(createdAt));
        expect(webModel.updatedAt, equals(lastSyncedAt));
      });

      test('toWebModel uses createdAt when lastSyncedAt is null', () {
        final createdAt = DateTime(2024, 1, 1);
        final account = Account.create(
          userId: 'user-456',
          email: 'user@example.com',
          createdAt: createdAt,
        )..id = 1;

        final webModel = account.toWebModel();

        expect(webModel.updatedAt, equals(createdAt));
      });

      test('toWebModel handles null optional fields', () {
        final account = Account.create(
          userId: 'user-789',
          email: 'minimal@example.com',
        )..id = 2;

        final webModel = account.toWebModel();

        expect(webModel.displayName, isNull);
        expect(webModel.photoUrl, isNull);
      });

      test('fromWebModel converts web model back to account', () {
        final createdAt = DateTime(2024, 2, 1, 10, 0);
        final updatedAt = DateTime(2024, 2, 15, 14, 30);
        final webAccount = WebAccount(
          id: '100',
          userId: 'web-user-123',
          email: 'webuser@example.com',
          displayName: 'Web User',
          photoUrl: 'https://example.com/webphoto.jpg',
          isActive: true,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final account = AccountWebConversion.fromWebModel(webAccount, id: 100);

        expect(account.userId, equals('web-user-123'));
        expect(account.email, equals('webuser@example.com'));
        expect(account.displayName, equals('Web User'));
        expect(account.photoUrl, equals('https://example.com/webphoto.jpg'));
        expect(account.isActive, isTrue);
        expect(account.createdAt, equals(createdAt));
        expect(account.lastSyncedAt, equals(updatedAt));
        expect(account.id, equals(100));
      });

      test('fromWebModel uses default id of 0 when not provided', () {
        final webAccount = WebAccount(
          id: '999',
          userId: 'default-id-user',
          email: 'default@example.com',
          isActive: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final account = AccountWebConversion.fromWebModel(webAccount);

        expect(account.id, equals(0));
      });

      test('round-trip conversion preserves data', () {
        final original = Account.create(
          userId: 'roundtrip-user',
          email: 'roundtrip@example.com',
          displayName: 'Roundtrip User',
          photoUrl: 'https://example.com/roundtrip.jpg',
          isActive: true,
          createdAt: DateTime(2024, 3, 1),
          lastSyncedAt: DateTime(2024, 3, 15),
        )..id = 555;

        final webModel = original.toWebModel();
        final restored = AccountWebConversion.fromWebModel(webModel, id: 555);

        expect(restored.userId, equals(original.userId));
        expect(restored.email, equals(original.email));
        expect(restored.displayName, equals(original.displayName));
        expect(restored.photoUrl, equals(original.photoUrl));
        expect(restored.isActive, equals(original.isActive));
        expect(restored.createdAt, equals(original.createdAt));
      });
    });

    group('LogRecord Web Conversion', () {
      test('toWebModel converts all fields correctly', () {
        final eventAt = DateTime(2024, 5, 10, 15, 30);
        final createdAt = DateTime(2024, 5, 10, 15, 30);
        final updatedAt = DateTime(2024, 5, 10, 16, 0);
        final logRecord = LogRecord.create(
          logId: 'log-123',
          accountId: 'account-456',
          eventType: EventType.vape,
          eventAt: eventAt,
          createdAt: createdAt,
          updatedAt: updatedAt,
          duration: 30.0,
          unit: Unit.seconds,
          note: 'Test note',
          reasons: [LogReason.stress, LogReason.social],
          moodRating: 7.0,
          physicalRating: 8.0,
          latitude: 40.7128,
          longitude: -74.0060,
          source: Source.manual,
        )..isDeleted = false;

        final webModel = logRecord.toWebModel();

        expect(webModel.id, equals('log-123'));
        expect(webModel.accountId, equals('account-456'));
        expect(webModel.eventType, equals('vape'));
        expect(webModel.eventAt, equals(eventAt));
        expect(webModel.duration, equals(30.0));
        expect(webModel.unit, equals('seconds'));
        expect(webModel.note, equals('Test note'));
        expect(webModel.reasons, containsAll(['stress', 'social']));
        expect(webModel.moodRating, equals(7.0));
        expect(webModel.physicalRating, equals(8.0));
        expect(webModel.latitude, equals(40.7128));
        expect(webModel.longitude, equals(-74.0060));
        expect(webModel.isDeleted, isFalse);
        expect(webModel.createdAt, equals(createdAt));
        expect(webModel.updatedAt, equals(updatedAt));
      });

      test('toWebModel handles null optional fields', () {
        final logRecord = LogRecord.create(
          logId: 'minimal-log',
          accountId: 'account-789',
          eventType: EventType.inhale,
          eventAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          duration: 5.0,
          unit: Unit.hits,
          source: Source.manual,
        );

        final webModel = logRecord.toWebModel();

        expect(webModel.note, isNull);
        expect(webModel.reasons, isNull);
        expect(webModel.moodRating, isNull);
        expect(webModel.physicalRating, isNull);
        expect(webModel.latitude, isNull);
        expect(webModel.longitude, isNull);
      });

      test('fromWebModel converts web model back to log record', () {
        final eventAt = DateTime(2024, 6, 1, 12, 0);
        final createdAt = DateTime(2024, 6, 1, 12, 0);
        final updatedAt = DateTime(2024, 6, 1, 13, 0);
        final webLogRecord = WebLogRecord(
          id: 'web-log-123',
          accountId: 'web-account-456',
          eventType: 'vape',
          eventAt: eventAt,
          duration: 45.0,
          unit: 'seconds',
          note: 'Web note',
          reasons: ['recreational', 'social'],
          moodRating: 6.0,
          physicalRating: 5.0,
          latitude: 51.5074,
          longitude: -0.1278,
          isDeleted: false,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final logRecord = LogRecordWebConversion.fromWebModel(
          webLogRecord,
          id: 999,
        );

        expect(logRecord.logId, equals('web-log-123'));
        expect(logRecord.accountId, equals('web-account-456'));
        expect(logRecord.eventType, equals(EventType.vape));
        expect(logRecord.eventAt, equals(eventAt));
        expect(logRecord.duration, equals(45.0));
        expect(logRecord.unit, equals(Unit.seconds));
        expect(logRecord.note, equals('Web note'));
        expect(
          logRecord.reasons,
          containsAll([LogReason.recreational, LogReason.social]),
        );
        expect(logRecord.moodRating, equals(6.0));
        expect(logRecord.physicalRating, equals(5.0));
        expect(logRecord.latitude, equals(51.5074));
        expect(logRecord.longitude, equals(-0.1278));
        expect(logRecord.isDeleted, isFalse);
        expect(logRecord.createdAt, equals(createdAt));
        expect(logRecord.updatedAt, equals(updatedAt));
        expect(logRecord.id, equals(999));
      });

      test(
        'fromWebModel uses default EventType.inhale for unknown event type',
        () {
          final webLogRecord = WebLogRecord(
            id: 'unknown-event-log',
            accountId: 'account',
            eventType: 'unknown_event_type',
            eventAt: DateTime.now(),
            duration: 10.0,
            isDeleted: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          final logRecord = LogRecordWebConversion.fromWebModel(webLogRecord);

          expect(logRecord.eventType, equals(EventType.inhale));
        },
      );

      test('fromWebModel uses default Unit.seconds for unknown unit', () {
        final webLogRecord = WebLogRecord(
          id: 'unknown-unit-log',
          accountId: 'account',
          eventType: 'vape',
          eventAt: DateTime.now(),
          duration: 10.0,
          unit: 'unknown_unit',
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final logRecord = LogRecordWebConversion.fromWebModel(webLogRecord);

        expect(logRecord.unit, equals(Unit.seconds));
      });

      test('fromWebModel uses default LogReason.other for unknown reasons', () {
        final webLogRecord = WebLogRecord(
          id: 'unknown-reason-log',
          accountId: 'account',
          eventType: 'vape',
          eventAt: DateTime.now(),
          duration: 10.0,
          reasons: ['unknown_reason'],
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final logRecord = LogRecordWebConversion.fromWebModel(webLogRecord);

        expect(logRecord.reasons, contains(LogReason.other));
      });

      test('fromWebModel handles extraFields for sync metadata', () {
        final syncedAt = DateTime(2024, 7, 1);
        final lastRemoteUpdateAt = DateTime(2024, 7, 2);
        final webLogRecord = WebLogRecord(
          id: 'synced-log',
          accountId: 'account',
          eventType: 'vape',
          eventAt: DateTime.now(),
          duration: 10.0,
          isDeleted: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final logRecord = LogRecordWebConversion.fromWebModel(
          webLogRecord,
          extraFields: {
            'syncState': 'synced',
            'syncedAt': syncedAt.toIso8601String(),
            'lastRemoteUpdateAt': lastRemoteUpdateAt.toIso8601String(),
            'revision': 5,
            'syncError': null,
          },
        );

        expect(logRecord.syncState, equals(SyncState.synced));
        expect(logRecord.syncedAt, equals(syncedAt));
        expect(logRecord.lastRemoteUpdateAt, equals(lastRemoteUpdateAt));
        expect(logRecord.revision, equals(5));
      });

      test('fromWebModel handles deleted record', () {
        final deletedAt = DateTime(2024, 7, 15);
        final webLogRecord = WebLogRecord(
          id: 'deleted-log',
          accountId: 'account',
          eventType: 'vape',
          eventAt: DateTime.now(),
          duration: 10.0,
          isDeleted: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final logRecord = LogRecordWebConversion.fromWebModel(
          webLogRecord,
          extraFields: {'deletedAt': deletedAt.toIso8601String()},
        );

        expect(logRecord.isDeleted, isTrue);
        expect(logRecord.deletedAt, equals(deletedAt));
      });

      test('round-trip conversion preserves data', () {
        final eventAt = DateTime(2024, 8, 1, 10, 30);
        final original = LogRecord.create(
          logId: 'roundtrip-log',
          accountId: 'roundtrip-account',
          eventType: EventType.vape,
          eventAt: eventAt,
          createdAt: eventAt,
          updatedAt: eventAt,
          duration: 60.0,
          unit: Unit.seconds,
          note: 'Roundtrip note',
          reasons: [LogReason.habit, LogReason.other],
          moodRating: 5.0,
          physicalRating: 6.0,
          source: Source.manual,
        )..id = 777;

        final webModel = original.toWebModel();
        final restored = LogRecordWebConversion.fromWebModel(webModel, id: 777);

        expect(restored.logId, equals(original.logId));
        expect(restored.accountId, equals(original.accountId));
        expect(restored.eventType, equals(original.eventType));
        expect(restored.eventAt, equals(original.eventAt));
        expect(restored.duration, equals(original.duration));
        expect(restored.unit, equals(original.unit));
        expect(restored.note, equals(original.note));
        expect(restored.moodRating, equals(original.moodRating));
        expect(restored.physicalRating, equals(original.physicalRating));
      });
    });

    group('WebAccount JSON Serialization', () {
      test('toJson converts account to JSON', () {
        final createdAt = DateTime(2024, 1, 1, 10, 0);
        final updatedAt = DateTime(2024, 1, 15, 14, 30);
        final webAccount = WebAccount(
          id: '123',
          userId: 'user-json',
          email: 'json@example.com',
          displayName: 'JSON User',
          photoUrl: 'https://example.com/json.jpg',
          isActive: true,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = webAccount.toJson();

        expect(json['id'], equals('123'));
        expect(json['userId'], equals('user-json'));
        expect(json['email'], equals('json@example.com'));
        expect(json['displayName'], equals('JSON User'));
        expect(json['photoUrl'], equals('https://example.com/json.jpg'));
        expect(json['isActive'], isTrue);
        expect(json['createdAt'], equals(createdAt.toIso8601String()));
        expect(json['updatedAt'], equals(updatedAt.toIso8601String()));
      });

      test('fromJson creates account from JSON', () {
        final json = {
          'id': '456',
          'userId': 'from-json-user',
          'email': 'fromjson@example.com',
          'displayName': 'From JSON User',
          'photoUrl': null,
          'isActive': false,
          'createdAt': '2024-02-01T10:00:00.000',
          'updatedAt': '2024-02-15T14:30:00.000',
        };

        final webAccount = WebAccount.fromJson(json);

        expect(webAccount.id, equals('456'));
        expect(webAccount.userId, equals('from-json-user'));
        expect(webAccount.email, equals('fromjson@example.com'));
        expect(webAccount.displayName, equals('From JSON User'));
        expect(webAccount.photoUrl, isNull);
        expect(webAccount.isActive, isFalse);
      });

      test('JSON round-trip preserves data', () {
        final original = WebAccount(
          id: 'roundtrip-web',
          userId: 'web-roundtrip-user',
          email: 'webroundtrip@example.com',
          displayName: 'Web Roundtrip',
          photoUrl: 'https://example.com/web.jpg',
          isActive: true,
          createdAt: DateTime(2024, 3, 1),
          updatedAt: DateTime(2024, 3, 15),
        );

        final json = original.toJson();
        final restored = WebAccount.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.userId, equals(original.userId));
        expect(restored.email, equals(original.email));
        expect(restored.displayName, equals(original.displayName));
        expect(restored.photoUrl, equals(original.photoUrl));
        expect(restored.isActive, equals(original.isActive));
      });
    });

    group('WebLogRecord JSON Serialization', () {
      test('toJson converts log record to JSON', () {
        final eventAt = DateTime(2024, 5, 1, 12, 0);
        final createdAt = DateTime(2024, 5, 1, 12, 0);
        final updatedAt = DateTime(2024, 5, 1, 13, 0);
        final webLogRecord = WebLogRecord(
          id: 'json-log',
          accountId: 'json-account',
          eventType: 'vape',
          eventAt: eventAt,
          duration: 30.0,
          unit: 'seconds',
          note: 'JSON note',
          reasons: ['stress'],
          moodRating: 7.0,
          physicalRating: 8.0,
          latitude: 40.7128,
          longitude: -74.0060,
          isDeleted: false,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final json = webLogRecord.toJson();

        expect(json['id'], equals('json-log'));
        expect(json['accountId'], equals('json-account'));
        expect(json['eventType'], equals('vape'));
        expect(json['duration'], equals(30.0));
        expect(json['unit'], equals('seconds'));
        expect(json['note'], equals('JSON note'));
        expect(json['reasons'], equals(['stress']));
        expect(json['moodRating'], equals(7.0));
        expect(json['physicalRating'], equals(8.0));
        expect(json['latitude'], equals(40.7128));
        expect(json['longitude'], equals(-74.0060));
        expect(json['isDeleted'], isFalse);
      });

      test('fromJson creates log record from JSON', () {
        final json = {
          'id': 'from-json-log',
          'accountId': 'from-json-account',
          'eventType': 'inhale',
          'eventAt': '2024-06-01T12:00:00.000',
          'duration': 45,
          'unit': 'hits',
          'note': 'From JSON note',
          'reasons': ['habit', 'social'],
          'moodRating': 6,
          'physicalRating': 5,
          'latitude': 51.5074,
          'longitude': -0.1278,
          'isDeleted': false,
          'createdAt': '2024-06-01T12:00:00.000',
          'updatedAt': '2024-06-01T13:00:00.000',
        };

        final webLogRecord = WebLogRecord.fromJson(json);

        expect(webLogRecord.id, equals('from-json-log'));
        expect(webLogRecord.accountId, equals('from-json-account'));
        expect(webLogRecord.eventType, equals('inhale'));
        expect(webLogRecord.duration, equals(45.0));
        expect(webLogRecord.unit, equals('hits'));
        expect(webLogRecord.note, equals('From JSON note'));
        expect(webLogRecord.reasons, containsAll(['habit', 'social']));
        expect(webLogRecord.moodRating, equals(6.0));
        expect(webLogRecord.physicalRating, equals(5.0));
      });

      test('fromJson handles missing optional fields', () {
        final json = {
          'id': 'minimal-json-log',
          'accountId': 'minimal-account',
          'eventType': 'vape',
          'eventAt': '2024-07-01T12:00:00.000',
          'createdAt': '2024-07-01T12:00:00.000',
          'updatedAt': '2024-07-01T12:00:00.000',
        };

        final webLogRecord = WebLogRecord.fromJson(json);

        expect(webLogRecord.duration, equals(0.0));
        expect(webLogRecord.unit, isNull);
        expect(webLogRecord.note, isNull);
        expect(webLogRecord.reasons, isNull);
        expect(webLogRecord.moodRating, isNull);
        expect(webLogRecord.physicalRating, isNull);
        expect(webLogRecord.latitude, isNull);
        expect(webLogRecord.longitude, isNull);
        expect(webLogRecord.isDeleted, isFalse);
      });

      test('JSON round-trip preserves data', () {
        final original = WebLogRecord(
          id: 'roundtrip-json-log',
          accountId: 'roundtrip-json-account',
          eventType: 'vape',
          eventAt: DateTime(2024, 8, 1, 10, 30),
          duration: 60.0,
          unit: 'seconds',
          note: 'Roundtrip JSON note',
          reasons: ['boredom'],
          moodRating: 5.0,
          physicalRating: 6.0,
          latitude: 35.6762,
          longitude: 139.6503,
          isDeleted: false,
          createdAt: DateTime(2024, 8, 1, 10, 30),
          updatedAt: DateTime(2024, 8, 1, 11, 0),
        );

        final json = original.toJson();
        final restored = WebLogRecord.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.accountId, equals(original.accountId));
        expect(restored.eventType, equals(original.eventType));
        expect(restored.duration, equals(original.duration));
        expect(restored.unit, equals(original.unit));
        expect(restored.note, equals(original.note));
        expect(restored.reasons, equals(original.reasons));
        expect(restored.moodRating, equals(original.moodRating));
        expect(restored.physicalRating, equals(original.physicalRating));
        expect(restored.latitude, equals(original.latitude));
        expect(restored.longitude, equals(original.longitude));
      });
    });

    group('WebUserAccount JSON Serialization', () {
      test('toJson converts user account to JSON', () {
        final createdAt = DateTime(2024, 1, 1);
        final webUserAccount = WebUserAccount(
          id: 'user-account-1',
          userId: 'user-123',
          displayName: 'Test User',
          avatarUrl: 'https://example.com/avatar.jpg',
          createdAt: createdAt,
        );

        final json = webUserAccount.toJson();

        expect(json['id'], equals('user-account-1'));
        expect(json['userId'], equals('user-123'));
        expect(json['displayName'], equals('Test User'));
        expect(json['avatarUrl'], equals('https://example.com/avatar.jpg'));
        expect(json['createdAt'], equals(createdAt.toIso8601String()));
      });

      test('fromJson creates user account from JSON', () {
        final json = {
          'id': 'from-json-user-account',
          'userId': 'from-json-user-id',
          'displayName': 'From JSON User',
          'avatarUrl': null,
          'createdAt': '2024-02-01T10:00:00.000',
        };

        final webUserAccount = WebUserAccount.fromJson(json);

        expect(webUserAccount.id, equals('from-json-user-account'));
        expect(webUserAccount.userId, equals('from-json-user-id'));
        expect(webUserAccount.displayName, equals('From JSON User'));
        expect(webUserAccount.avatarUrl, isNull);
      });

      test('JSON round-trip preserves data', () {
        final original = WebUserAccount(
          id: 'roundtrip-user-account',
          userId: 'roundtrip-user-id',
          displayName: 'Roundtrip User',
          avatarUrl: 'https://example.com/roundtrip.jpg',
          createdAt: DateTime(2024, 3, 1),
        );

        final json = original.toJson();
        final restored = WebUserAccount.fromJson(json);

        expect(restored.id, equals(original.id));
        expect(restored.userId, equals(original.userId));
        expect(restored.displayName, equals(original.displayName));
        expect(restored.avatarUrl, equals(original.avatarUrl));
      });
    });

    group('Edge Cases', () {
      test('handles special characters in strings', () {
        final account = Account.create(
          userId: 'user-with-special-"chars"',
          email: 'test+special@example.com',
          displayName: "User's Name with \"quotes\"",
        )..id = 1;

        final webModel = account.toWebModel();

        expect(webModel.displayName, contains('"'));
        expect(webModel.displayName, contains("'"));
      });

      test('handles Unicode characters', () {
        final account = Account.create(
          userId: 'unicode-user',
          email: 'test@例え.jp',
          displayName: '日本語ユーザー 🎉',
        )..id = 1;

        final webModel = account.toWebModel();

        expect(webModel.displayName, contains('日本語'));
        expect(webModel.displayName, contains('🎉'));
      });

      test('handles empty strings', () {
        final account = Account.create(userId: '', email: '', displayName: '')
          ..id = 1;

        final webModel = account.toWebModel();

        expect(webModel.userId, equals(''));
        expect(webModel.email, equals(''));
        expect(webModel.displayName, equals(''));
      });

      test('handles extreme numeric values', () {
        final logRecord = LogRecord.create(
          logId: 'extreme-values-log',
          accountId: 'account',
          eventType: EventType.vape,
          eventAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          duration: 999999999.999,
          unit: Unit.seconds,
          moodRating: 1.0,
          physicalRating: 10.0,
          latitude: 90.0,
          longitude: 180.0,
          source: Source.manual,
        );

        final webModel = logRecord.toWebModel();

        expect(webModel.duration, equals(999999999.999));
        expect(webModel.moodRating, equals(1.0));
        expect(webModel.physicalRating, equals(10.0));
        expect(webModel.latitude, equals(90.0));
        expect(webModel.longitude, equals(180.0));
      });

      test('handles dates at boundaries', () {
        final earlyDate = DateTime(1970, 1, 1);
        final lateDate = DateTime(2099, 12, 31, 23, 59, 59);

        final account = Account.create(
          userId: 'date-boundary-user',
          email: 'dates@example.com',
          createdAt: earlyDate,
          lastSyncedAt: lateDate,
        )..id = 1;

        final webModel = account.toWebModel();

        expect(webModel.createdAt, equals(earlyDate));
        expect(webModel.updatedAt, equals(lateDate));
      });
    });
  });
}

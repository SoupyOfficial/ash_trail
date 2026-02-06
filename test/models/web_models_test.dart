import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/web_models.dart';

void main() {
  group('WebAccount', () {
    final now = DateTime.now();
    final tokenExpires = now.add(const Duration(hours: 1));

    group('constructor', () {
      test('creates with all required fields', () {
        final account = WebAccount(
          id: 'acc-1',
          userId: 'user-1',
          email: 'test@example.com',
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );

        expect(account.id, 'acc-1');
        expect(account.userId, 'user-1');
        expect(account.email, 'test@example.com');
        expect(account.isActive, true);
        expect(account.isLoggedIn, false);
        expect(account.authProvider, 'email');
      });

      test('creates with all optional fields', () {
        final account = WebAccount(
          id: 'acc-1',
          userId: 'user-1',
          email: 'test@example.com',
          displayName: 'Test User',
          photoUrl: 'https://example.com/photo.jpg',
          isActive: true,
          isLoggedIn: true,
          authProvider: 'google',
          createdAt: now,
          updatedAt: now,
          lastAccessedAt: now,
          refreshToken: 'refresh-token',
          accessToken: 'access-token',
          tokenExpiresAt: tokenExpires,
        );

        expect(account.displayName, 'Test User');
        expect(account.photoUrl, 'https://example.com/photo.jpg');
        expect(account.isLoggedIn, true);
        expect(account.authProvider, 'google');
        expect(account.lastAccessedAt, now);
        expect(account.refreshToken, 'refresh-token');
        expect(account.accessToken, 'access-token');
        expect(account.tokenExpiresAt, tokenExpires);
      });

      test('defaults isLoggedIn to false', () {
        final account = WebAccount(
          id: 'acc-1',
          userId: 'user-1',
          email: 'test@example.com',
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );

        expect(account.isLoggedIn, false);
      });

      test('defaults authProvider to email', () {
        final account = WebAccount(
          id: 'acc-1',
          userId: 'user-1',
          email: 'test@example.com',
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );

        expect(account.authProvider, 'email');
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final account = WebAccount(
          id: 'acc-1',
          userId: 'user-1',
          email: 'test@example.com',
          displayName: 'Test User',
          photoUrl: 'https://example.com/photo.jpg',
          isActive: true,
          isLoggedIn: true,
          authProvider: 'google',
          createdAt: now,
          updatedAt: now,
          lastAccessedAt: now,
          refreshToken: 'refresh-token',
          accessToken: 'access-token',
          tokenExpiresAt: tokenExpires,
        );

        final json = account.toJson();

        expect(json['id'], 'acc-1');
        expect(json['userId'], 'user-1');
        expect(json['email'], 'test@example.com');
        expect(json['displayName'], 'Test User');
        expect(json['photoUrl'], 'https://example.com/photo.jpg');
        expect(json['isActive'], true);
        expect(json['isLoggedIn'], true);
        expect(json['authProvider'], 'google');
        expect(json['createdAt'], now.toIso8601String());
        expect(json['updatedAt'], now.toIso8601String());
        expect(json['lastAccessedAt'], now.toIso8601String());
        expect(json['refreshToken'], 'refresh-token');
        expect(json['accessToken'], 'access-token');
        expect(json['tokenExpiresAt'], tokenExpires.toIso8601String());
      });

      test('serializes null optional fields', () {
        final account = WebAccount(
          id: 'acc-1',
          userId: 'user-1',
          email: 'test@example.com',
          isActive: true,
          createdAt: now,
          updatedAt: now,
        );

        final json = account.toJson();

        expect(json['displayName'], isNull);
        expect(json['photoUrl'], isNull);
        expect(json['lastAccessedAt'], isNull);
        expect(json['refreshToken'], isNull);
        expect(json['accessToken'], isNull);
        expect(json['tokenExpiresAt'], isNull);
      });
    });

    group('fromJson', () {
      test('deserializes all fields correctly', () {
        final json = {
          'id': 'acc-1',
          'userId': 'user-1',
          'email': 'test@example.com',
          'displayName': 'Test User',
          'photoUrl': 'https://example.com/photo.jpg',
          'isActive': true,
          'isLoggedIn': true,
          'authProvider': 'google',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'lastAccessedAt': now.toIso8601String(),
          'refreshToken': 'refresh-token',
          'accessToken': 'access-token',
          'tokenExpiresAt': tokenExpires.toIso8601String(),
        };

        final account = WebAccount.fromJson(json);

        expect(account.id, 'acc-1');
        expect(account.userId, 'user-1');
        expect(account.email, 'test@example.com');
        expect(account.displayName, 'Test User');
        expect(account.photoUrl, 'https://example.com/photo.jpg');
        expect(account.isActive, true);
        expect(account.isLoggedIn, true);
        expect(account.authProvider, 'google');
      });

      test('handles missing optional fields with defaults', () {
        final json = {
          'id': 'acc-1',
          'userId': 'user-1',
          'email': 'test@example.com',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final account = WebAccount.fromJson(json);

        expect(account.isActive, true);
        expect(account.isLoggedIn, false);
        expect(account.authProvider, 'email');
        expect(account.displayName, isNull);
        expect(account.photoUrl, isNull);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'acc-1',
          'userId': 'user-1',
          'email': 'test@example.com',
          'displayName': null,
          'photoUrl': null,
          'isActive': true,
          'isLoggedIn': false,
          'authProvider': 'email',
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'lastAccessedAt': null,
          'refreshToken': null,
          'accessToken': null,
          'tokenExpiresAt': null,
        };

        final account = WebAccount.fromJson(json);

        expect(account.displayName, isNull);
        expect(account.photoUrl, isNull);
        expect(account.lastAccessedAt, isNull);
        expect(account.refreshToken, isNull);
        expect(account.accessToken, isNull);
        expect(account.tokenExpiresAt, isNull);
      });
    });

    group('round trip', () {
      test('toJson then fromJson preserves all fields', () {
        final original = WebAccount(
          id: 'acc-1',
          userId: 'user-1',
          email: 'test@example.com',
          displayName: 'Test User',
          photoUrl: 'https://example.com/photo.jpg',
          isActive: true,
          isLoggedIn: true,
          authProvider: 'apple',
          createdAt: now,
          updatedAt: now,
          lastAccessedAt: now,
          refreshToken: 'refresh',
          accessToken: 'access',
          tokenExpiresAt: tokenExpires,
        );

        final json = original.toJson();
        final restored = WebAccount.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.userId, original.userId);
        expect(restored.email, original.email);
        expect(restored.displayName, original.displayName);
        expect(restored.photoUrl, original.photoUrl);
        expect(restored.isActive, original.isActive);
        expect(restored.isLoggedIn, original.isLoggedIn);
        expect(restored.authProvider, original.authProvider);
      });
    });
  });

  group('WebLogRecord', () {
    final now = DateTime.now();

    group('constructor', () {
      test('creates with all required fields', () {
        final record = WebLogRecord(
          id: 'rec-1',
          accountId: 'acc-1',
          eventType: 'vape',
          eventAt: now,
          duration: 30.0,
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
        );

        expect(record.id, 'rec-1');
        expect(record.accountId, 'acc-1');
        expect(record.eventType, 'vape');
        expect(record.duration, 30.0);
        expect(record.isDeleted, false);
      });

      test('creates with all optional fields', () {
        final record = WebLogRecord(
          id: 'rec-1',
          accountId: 'acc-1',
          eventType: 'inhale',
          eventAt: now,
          duration: 5.0,
          unit: 'hits',
          note: 'Test note',
          reasons: ['stress', 'boredom'],
          moodRating: 7.0,
          physicalRating: 8.0,
          latitude: 37.7749,
          longitude: -122.4194,
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
        );

        expect(record.unit, 'hits');
        expect(record.note, 'Test note');
        expect(record.reasons, ['stress', 'boredom']);
        expect(record.moodRating, 7.0);
        expect(record.physicalRating, 8.0);
        expect(record.latitude, 37.7749);
        expect(record.longitude, -122.4194);
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final record = WebLogRecord(
          id: 'rec-1',
          accountId: 'acc-1',
          eventType: 'vape',
          eventAt: now,
          duration: 30.0,
          unit: 'seconds',
          note: 'Test note',
          reasons: ['relaxation'],
          moodRating: 6.5,
          physicalRating: 7.5,
          latitude: 40.7128,
          longitude: -74.0060,
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
        );

        final json = record.toJson();

        expect(json['id'], 'rec-1');
        expect(json['accountId'], 'acc-1');
        expect(json['eventType'], 'vape');
        expect(json['eventAt'], now.toIso8601String());
        expect(json['duration'], 30.0);
        expect(json['unit'], 'seconds');
        expect(json['note'], 'Test note');
        expect(json['reasons'], ['relaxation']);
        expect(json['moodRating'], 6.5);
        expect(json['physicalRating'], 7.5);
        expect(json['latitude'], 40.7128);
        expect(json['longitude'], -74.0060);
        expect(json['isDeleted'], false);
        expect(json['createdAt'], now.toIso8601String());
        expect(json['updatedAt'], now.toIso8601String());
      });

      test('serializes null optional fields', () {
        final record = WebLogRecord(
          id: 'rec-1',
          accountId: 'acc-1',
          eventType: 'note',
          eventAt: now,
          duration: 0.0,
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
        );

        final json = record.toJson();

        expect(json['unit'], isNull);
        expect(json['note'], isNull);
        expect(json['reasons'], isNull);
        expect(json['moodRating'], isNull);
        expect(json['physicalRating'], isNull);
        expect(json['latitude'], isNull);
        expect(json['longitude'], isNull);
      });
    });

    group('fromJson', () {
      test('deserializes all fields correctly', () {
        final json = {
          'id': 'rec-1',
          'accountId': 'acc-1',
          'eventType': 'sessionStart',
          'eventAt': now.toIso8601String(),
          'duration': 60.0,
          'unit': 'minutes',
          'note': 'Session note',
          'reasons': ['social', 'habit'],
          'moodRating': 8.0,
          'physicalRating': 9.0,
          'latitude': 51.5074,
          'longitude': -0.1278,
          'isDeleted': false,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final record = WebLogRecord.fromJson(json);

        expect(record.id, 'rec-1');
        expect(record.accountId, 'acc-1');
        expect(record.eventType, 'sessionStart');
        expect(record.duration, 60.0);
        expect(record.unit, 'minutes');
        expect(record.note, 'Session note');
        expect(record.reasons, ['social', 'habit']);
        expect(record.moodRating, 8.0);
        expect(record.physicalRating, 9.0);
        expect(record.latitude, 51.5074);
        expect(record.longitude, -0.1278);
        expect(record.isDeleted, false);
      });

      test('handles missing optional fields', () {
        final json = {
          'id': 'rec-1',
          'accountId': 'acc-1',
          'eventType': 'vape',
          'eventAt': now.toIso8601String(),
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final record = WebLogRecord.fromJson(json);

        expect(record.duration, 0);
        expect(record.unit, isNull);
        expect(record.note, isNull);
        expect(record.reasons, isNull);
        expect(record.moodRating, isNull);
        expect(record.physicalRating, isNull);
        expect(record.latitude, isNull);
        expect(record.longitude, isNull);
        expect(record.isDeleted, false);
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'rec-1',
          'accountId': 'acc-1',
          'eventType': 'vape',
          'eventAt': now.toIso8601String(),
          'duration': 0,
          'unit': null,
          'note': null,
          'reasons': null,
          'moodRating': null,
          'physicalRating': null,
          'latitude': null,
          'longitude': null,
          'isDeleted': false,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final record = WebLogRecord.fromJson(json);

        expect(record.unit, isNull);
        expect(record.note, isNull);
        expect(record.reasons, isNull);
        expect(record.moodRating, isNull);
        expect(record.physicalRating, isNull);
        expect(record.latitude, isNull);
        expect(record.longitude, isNull);
      });

      test('converts integer duration to double', () {
        final json = {
          'id': 'rec-1',
          'accountId': 'acc-1',
          'eventType': 'vape',
          'eventAt': now.toIso8601String(),
          'duration': 30, // integer
          'isDeleted': false,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final record = WebLogRecord.fromJson(json);

        expect(record.duration, 30.0);
        expect(record.duration, isA<double>());
      });

      test('converts integer ratings to double', () {
        final json = {
          'id': 'rec-1',
          'accountId': 'acc-1',
          'eventType': 'vape',
          'eventAt': now.toIso8601String(),
          'duration': 30,
          'moodRating': 7, // integer
          'physicalRating': 8, // integer
          'isDeleted': false,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final record = WebLogRecord.fromJson(json);

        expect(record.moodRating, 7.0);
        expect(record.physicalRating, 8.0);
      });
    });

    group('round trip', () {
      test('toJson then fromJson preserves all fields', () {
        final original = WebLogRecord(
          id: 'rec-1',
          accountId: 'acc-1',
          eventType: 'vape',
          eventAt: now,
          duration: 45.5,
          unit: 'seconds',
          note: 'Test',
          reasons: ['habit'],
          moodRating: 6.0,
          physicalRating: 7.0,
          latitude: 35.6762,
          longitude: 139.6503,
          isDeleted: false,
          createdAt: now,
          updatedAt: now,
        );

        final json = original.toJson();
        final restored = WebLogRecord.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.accountId, original.accountId);
        expect(restored.eventType, original.eventType);
        expect(restored.duration, original.duration);
        expect(restored.unit, original.unit);
        expect(restored.note, original.note);
        expect(restored.reasons, original.reasons);
        expect(restored.moodRating, original.moodRating);
        expect(restored.physicalRating, original.physicalRating);
        expect(restored.latitude, original.latitude);
        expect(restored.longitude, original.longitude);
        expect(restored.isDeleted, original.isDeleted);
      });
    });
  });

  group('WebUserAccount', () {
    final now = DateTime.now();

    group('constructor', () {
      test('creates with required fields', () {
        final user = WebUserAccount(
          id: 'user-1',
          userId: 'uid-1',
          displayName: 'Test User',
          createdAt: now,
        );

        expect(user.id, 'user-1');
        expect(user.userId, 'uid-1');
        expect(user.displayName, 'Test User');
        expect(user.createdAt, now);
        expect(user.avatarUrl, isNull);
      });

      test('creates with optional avatarUrl', () {
        final user = WebUserAccount(
          id: 'user-1',
          userId: 'uid-1',
          displayName: 'Test User',
          avatarUrl: 'https://example.com/avatar.png',
          createdAt: now,
        );

        expect(user.avatarUrl, 'https://example.com/avatar.png');
      });
    });

    group('toJson', () {
      test('serializes all fields correctly', () {
        final user = WebUserAccount(
          id: 'user-1',
          userId: 'uid-1',
          displayName: 'Test User',
          avatarUrl: 'https://example.com/avatar.png',
          createdAt: now,
        );

        final json = user.toJson();

        expect(json['id'], 'user-1');
        expect(json['userId'], 'uid-1');
        expect(json['displayName'], 'Test User');
        expect(json['avatarUrl'], 'https://example.com/avatar.png');
        expect(json['createdAt'], now.toIso8601String());
      });

      test('serializes null avatarUrl', () {
        final user = WebUserAccount(
          id: 'user-1',
          userId: 'uid-1',
          displayName: 'Test User',
          createdAt: now,
        );

        final json = user.toJson();

        expect(json['avatarUrl'], isNull);
      });
    });

    group('fromJson', () {
      test('deserializes all fields correctly', () {
        final json = {
          'id': 'user-1',
          'userId': 'uid-1',
          'displayName': 'Test User',
          'avatarUrl': 'https://example.com/avatar.png',
          'createdAt': now.toIso8601String(),
        };

        final user = WebUserAccount.fromJson(json);

        expect(user.id, 'user-1');
        expect(user.userId, 'uid-1');
        expect(user.displayName, 'Test User');
        expect(user.avatarUrl, 'https://example.com/avatar.png');
      });

      test('handles null avatarUrl', () {
        final json = {
          'id': 'user-1',
          'userId': 'uid-1',
          'displayName': 'Test User',
          'avatarUrl': null,
          'createdAt': now.toIso8601String(),
        };

        final user = WebUserAccount.fromJson(json);

        expect(user.avatarUrl, isNull);
      });

      test('handles missing avatarUrl', () {
        final json = {
          'id': 'user-1',
          'userId': 'uid-1',
          'displayName': 'Test User',
          'createdAt': now.toIso8601String(),
        };

        final user = WebUserAccount.fromJson(json);

        expect(user.avatarUrl, isNull);
      });
    });

    group('round trip', () {
      test('toJson then fromJson preserves all fields', () {
        final original = WebUserAccount(
          id: 'user-1',
          userId: 'uid-1',
          displayName: 'Test User',
          avatarUrl: 'https://example.com/avatar.png',
          createdAt: now,
        );

        final json = original.toJson();
        final restored = WebUserAccount.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.userId, original.userId);
        expect(restored.displayName, original.displayName);
        expect(restored.avatarUrl, original.avatarUrl);
      });
    });
  });
}

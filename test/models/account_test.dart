import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/account.dart';
import 'package:ash_trail/models/enums.dart';

void main() {
  group('Account Model Tests', () {
    test('Account.create() should create account with required fields', () {
      final account = Account.create(
        userId: 'test_user_123',
        email: 'test@example.com',
      );

      expect(account.userId, 'test_user_123');
      expect(account.email, 'test@example.com');
      expect(account.isActive, false);
      expect(account.displayName, null);
      expect(account.createdAt, isNotNull);
    });

    test('Account.create() should accept optional display name', () {
      final account = Account.create(
        userId: 'test_user_123',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      expect(account.displayName, 'Test User');
    });

    test('Account.create() should mark as active when specified', () {
      final account = Account.create(
        userId: 'test_user_123',
        email: 'test@example.com',
        isActive: true,
      );

      expect(account.isActive, true);
    });

    test('Account.create() should store session tokens', () {
      final expiresAt = DateTime.now().add(const Duration(hours: 48));
      final account = Account.create(
        userId: 'test_user_123',
        email: 'test@example.com',
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_456',
        tokenExpiresAt: expiresAt,
      );

      expect(account.accessToken, 'access_token_123');
      expect(account.refreshToken, 'refresh_token_456');
      expect(account.tokenExpiresAt, expiresAt);
    });

    test('Account() default constructor should create empty account', () {
      final account = Account();

      // Should have default values
      expect(account.id, isNotNull);
    });

    test('Account.create() should accept all optional fields', () {
      final createdAt = DateTime(2025, 1, 1, 10, 0);
      final lastModifiedAt = DateTime(2025, 1, 2, 15, 30);
      final lastSyncedAt = DateTime(2025, 1, 3, 9, 0);
      final tokenExpiresAt = DateTime.now().add(const Duration(hours: 48));

      final account = Account.create(
        userId: 'test_user_123',
        email: 'test@example.com',
        remoteId: 'remote-id-456',
        displayName: 'Test User',
        firstName: 'Test',
        lastName: 'User',
        photoUrl: 'https://example.com/photo.jpg',
        authProvider: AuthProvider.gmail,
        isActive: true,
        createdAt: createdAt,
        lastModifiedAt: lastModifiedAt,
        lastSyncedAt: lastSyncedAt,
        activeProfileId: 'profile-789',
        accessToken: 'access-token-123',
        refreshToken: 'refresh-token-456',
        tokenExpiresAt: tokenExpiresAt,
      );

      expect(account.userId, 'test_user_123');
      expect(account.email, 'test@example.com');
      expect(account.remoteId, 'remote-id-456');
      expect(account.displayName, 'Test User');
      expect(account.firstName, 'Test');
      expect(account.lastName, 'User');
      expect(account.photoUrl, 'https://example.com/photo.jpg');
      expect(account.authProvider, AuthProvider.gmail);
      expect(account.isActive, true);
      expect(account.createdAt, createdAt);
      expect(account.lastModifiedAt, lastModifiedAt);
      expect(account.lastSyncedAt, lastSyncedAt);
      expect(account.activeProfileId, 'profile-789');
      expect(account.accessToken, 'access-token-123');
      expect(account.refreshToken, 'refresh-token-456');
      expect(account.tokenExpiresAt, tokenExpiresAt);
    });

    test('Account.create() defaults authProvider to anonymous', () {
      final account = Account.create(
        userId: 'test_user_123',
        email: 'test@example.com',
      );

      expect(account.authProvider, AuthProvider.anonymous);
    });

    test('Account.create() defaults createdAt to current time', () {
      final before = DateTime.now();
      final account = Account.create(
        userId: 'test_user_123',
        email: 'test@example.com',
      );
      final after = DateTime.now();

      expect(
        account.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
        true,
      );
      expect(
        account.createdAt.isBefore(after.add(const Duration(seconds: 1))),
        true,
      );
    });

    group('isAnonymous', () {
      test('returns true for anonymous auth provider', () {
        final account = Account.create(
          userId: 'test_user_123',
          email: 'test@example.com',
          authProvider: AuthProvider.anonymous,
        );

        expect(account.isAnonymous, true);
      });

      test('returns false for google auth provider', () {
        final account = Account.create(
          userId: 'test_user_123',
          email: 'test@example.com',
          authProvider: AuthProvider.gmail,
        );

        expect(account.isAnonymous, false);
      });

      test('returns false for email auth provider', () {
        final account = Account.create(
          userId: 'test_user_123',
          email: 'test@example.com',
          authProvider: AuthProvider.email,
        );

        expect(account.isAnonymous, false);
      });
    });

    group('fullName', () {
      test('returns null when both firstName and lastName are null', () {
        final account = Account.create(
          userId: 'test_user_123',
          email: 'test@example.com',
        );

        expect(account.fullName, null);
      });

      test('returns firstName when lastName is null', () {
        final account = Account.create(
          userId: 'test_user_123',
          email: 'test@example.com',
          firstName: 'John',
        );

        expect(account.fullName, 'John');
      });

      test('returns lastName when firstName is null', () {
        final account = Account.create(
          userId: 'test_user_123',
          email: 'test@example.com',
          lastName: 'Doe',
        );

        expect(account.fullName, 'Doe');
      });

      test('returns full name when both are provided', () {
        final account = Account.create(
          userId: 'test_user_123',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
        );

        expect(account.fullName, 'John Doe');
      });

      test('joins firstName and lastName with space', () {
        final account = Account.create(
          userId: 'test_user_123',
          email: 'test@example.com',
          firstName: 'John',
          lastName: 'Doe',
        );

        expect(account.fullName, 'John Doe');
      });
    });

    group('copyWith', () {
      test('updates multiple fields while preserving unchanged ones', () {
        final tokenExpiry = DateTime.now().add(const Duration(days: 7));
        final original = Account.create(
          userId: 'user-123',
          email: 'original@example.com',
          displayName: 'Original Name',
          firstName: 'John',
          lastName: 'Doe',
          authProvider: AuthProvider.anonymous,
          isActive: false,
          accessToken: 'old-access',
          refreshToken: 'old-refresh',
        );
        original.id = 42;

        final copy = original.copyWith(
          email: 'new@example.com',
          displayName: 'New Name',
          authProvider: AuthProvider.gmail,
          isActive: true,
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
          tokenExpiresAt: tokenExpiry,
        );

        // Updated fields
        expect(copy.email, 'new@example.com');
        expect(copy.displayName, 'New Name');
        expect(copy.authProvider, AuthProvider.gmail);
        expect(copy.isActive, true);
        expect(copy.accessToken, 'new-access');
        expect(copy.refreshToken, 'new-refresh');
        expect(copy.tokenExpiresAt, tokenExpiry);

        // Preserved fields
        expect(copy.id, 42);
        expect(copy.userId, 'user-123');
        expect(copy.firstName, 'John');
        expect(copy.lastName, 'Doe');
      });

      test('updates timestamps and metadata fields', () {
        final original = Account.create(
          userId: 'user-123',
          email: 'test@example.com',
        );

        final newModified = DateTime(2025, 2, 1);
        final newSynced = DateTime(2025, 2, 2);
        final copy = original.copyWith(
          remoteId: 'remote-789',
          photoUrl: 'https://example.com/photo.jpg',
          activeProfileId: 'profile-999',
          lastModifiedAt: newModified,
          lastSyncedAt: newSynced,
        );

        expect(copy.remoteId, 'remote-789');
        expect(copy.photoUrl, 'https://example.com/photo.jpg');
        expect(copy.activeProfileId, 'profile-999');
        expect(copy.lastModifiedAt, newModified);
        expect(copy.lastSyncedAt, newSynced);
      });
    });
  });
}

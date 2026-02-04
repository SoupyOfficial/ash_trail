import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/user_account.dart';
import 'package:ash_trail/models/enums.dart';

void main() {
  group('UserAccount', () {
    group('default constructor', () {
      test('creates with default id of 0', () {
        final account = UserAccount();
        expect(account.id, 0);
      });
    });

    group('UserAccount.create', () {
      test('creates with required fields', () {
        final account = UserAccount.create(
          accountId: 'acc-123',
          displayName: 'Test User',
          authProvider: AuthProvider.gmail,
        );

        expect(account.accountId, 'acc-123');
        expect(account.displayName, 'Test User');
        expect(account.authProvider, AuthProvider.gmail);
        expect(account.isActive, false);
      });

      test('creates with all optional fields', () {
        final now = DateTime.now();
        final tokenExpires = now.add(const Duration(hours: 1));

        final account = UserAccount.create(
          accountId: 'acc-123',
          displayName: 'Test User',
          authProvider: AuthProvider.apple,
          email: 'test@example.com',
          photoUrl: 'https://example.com/photo.jpg',
          createdAt: now,
          updatedAt: now,
          activeProfileId: 'profile-1',
          isActive: true,
          lastSyncedAt: now,
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          tokenExpiresAt: tokenExpires,
        );

        expect(account.email, 'test@example.com');
        expect(account.photoUrl, 'https://example.com/photo.jpg');
        expect(account.createdAt, now);
        expect(account.updatedAt, now);
        expect(account.activeProfileId, 'profile-1');
        expect(account.isActive, true);
        expect(account.lastSyncedAt, now);
        expect(account.accessToken, 'access-token');
        expect(account.refreshToken, 'refresh-token');
        expect(account.tokenExpiresAt, tokenExpires);
      });

      test('defaults isActive to false', () {
        final account = UserAccount.create(
          accountId: 'acc-123',
          displayName: 'Test User',
          authProvider: AuthProvider.anonymous,
        );

        expect(account.isActive, false);
      });

      test('defaults createdAt to now when not provided', () {
        final before = DateTime.now();
        final account = UserAccount.create(
          accountId: 'acc-123',
          displayName: 'Test User',
          authProvider: AuthProvider.gmail,
        );
        final after = DateTime.now();

        expect(account.createdAt.isAfter(before) || 
               account.createdAt.isAtSameMomentAs(before), isTrue);
        expect(account.createdAt.isBefore(after) || 
               account.createdAt.isAtSameMomentAs(after), isTrue);
      });

      test('optional fields default to null', () {
        final account = UserAccount.create(
          accountId: 'acc-123',
          displayName: 'Test User',
          authProvider: AuthProvider.gmail,
        );

        expect(account.email, isNull);
        expect(account.photoUrl, isNull);
        expect(account.updatedAt, isNull);
        expect(account.activeProfileId, isNull);
        expect(account.lastSyncedAt, isNull);
        expect(account.accessToken, isNull);
        expect(account.refreshToken, isNull);
        expect(account.tokenExpiresAt, isNull);
      });
    });

    group('copyWith', () {
      late UserAccount original;
      late DateTime originalTime;

      setUp(() {
        originalTime = DateTime.now();
        original = UserAccount.create(
          accountId: 'acc-123',
          displayName: 'Original Name',
          authProvider: AuthProvider.gmail,
          email: 'original@example.com',
          createdAt: originalTime,
          isActive: false,
        );
        original.id = 42;
      });

      test('preserves original values when no arguments provided', () {
        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.accountId, original.accountId);
        expect(copy.displayName, original.displayName);
        expect(copy.authProvider, original.authProvider);
        expect(copy.email, original.email);
        expect(copy.createdAt, original.createdAt);
        expect(copy.isActive, original.isActive);
      });

      test('updates accountId', () {
        final copy = original.copyWith(accountId: 'new-acc-id');
        expect(copy.accountId, 'new-acc-id');
        expect(copy.displayName, original.displayName);
      });

      test('updates displayName', () {
        final copy = original.copyWith(displayName: 'New Name');
        expect(copy.displayName, 'New Name');
        expect(copy.accountId, original.accountId);
      });

      test('updates email', () {
        final copy = original.copyWith(email: 'new@example.com');
        expect(copy.email, 'new@example.com');
      });

      test('updates authProvider', () {
        final copy = original.copyWith(authProvider: AuthProvider.apple);
        expect(copy.authProvider, AuthProvider.apple);
      });

      test('updates photoUrl', () {
        final copy = original.copyWith(photoUrl: 'https://new.url/photo.png');
        expect(copy.photoUrl, 'https://new.url/photo.png');
      });

      test('updates createdAt', () {
        final newTime = DateTime(2023, 1, 1);
        final copy = original.copyWith(createdAt: newTime);
        expect(copy.createdAt, newTime);
      });

      test('updates updatedAt', () {
        final newTime = DateTime(2023, 6, 15);
        final copy = original.copyWith(updatedAt: newTime);
        expect(copy.updatedAt, newTime);
      });

      test('updates activeProfileId', () {
        final copy = original.copyWith(activeProfileId: 'profile-99');
        expect(copy.activeProfileId, 'profile-99');
      });

      test('updates isActive', () {
        final copy = original.copyWith(isActive: true);
        expect(copy.isActive, true);
        expect(original.isActive, false); // Original unchanged
      });

      test('updates lastSyncedAt', () {
        final syncTime = DateTime.now();
        final copy = original.copyWith(lastSyncedAt: syncTime);
        expect(copy.lastSyncedAt, syncTime);
      });

      test('updates accessToken', () {
        final copy = original.copyWith(accessToken: 'new-access-token');
        expect(copy.accessToken, 'new-access-token');
      });

      test('updates refreshToken', () {
        final copy = original.copyWith(refreshToken: 'new-refresh-token');
        expect(copy.refreshToken, 'new-refresh-token');
      });

      test('updates tokenExpiresAt', () {
        final expiry = DateTime.now().add(const Duration(hours: 2));
        final copy = original.copyWith(tokenExpiresAt: expiry);
        expect(copy.tokenExpiresAt, expiry);
      });

      test('updates multiple fields at once', () {
        final newTime = DateTime.now();
        final copy = original.copyWith(
          displayName: 'Updated Name',
          isActive: true,
          lastSyncedAt: newTime,
          accessToken: 'token-123',
        );

        expect(copy.displayName, 'Updated Name');
        expect(copy.isActive, true);
        expect(copy.lastSyncedAt, newTime);
        expect(copy.accessToken, 'token-123');
        // Unchanged fields
        expect(copy.accountId, original.accountId);
        expect(copy.email, original.email);
      });

      test('preserves id field', () {
        original.id = 123;
        final copy = original.copyWith(displayName: 'New Name');
        expect(copy.id, 123);
      });

      test('creates independent copy', () {
        final copy = original.copyWith(displayName: 'Modified');
        
        expect(copy.displayName, 'Modified');
        expect(original.displayName, 'Original Name');
      });
    });

    group('all AuthProvider types', () {
      test('works with gmail provider', () {
        final account = UserAccount.create(
          accountId: 'acc-1',
          displayName: 'Gmail User',
          authProvider: AuthProvider.gmail,
        );
        expect(account.authProvider, AuthProvider.gmail);
      });

      test('works with apple provider', () {
        final account = UserAccount.create(
          accountId: 'acc-2',
          displayName: 'Apple User',
          authProvider: AuthProvider.apple,
        );
        expect(account.authProvider, AuthProvider.apple);
      });

      test('works with anonymous provider', () {
        final account = UserAccount.create(
          accountId: 'acc-3',
          displayName: 'Anonymous User',
          authProvider: AuthProvider.anonymous,
        );
        expect(account.authProvider, AuthProvider.anonymous);
      });

      test('works with email provider', () {
        final account = UserAccount.create(
          accountId: 'acc-4',
          displayName: 'Email User',
          authProvider: AuthProvider.email,
        );
        expect(account.authProvider, AuthProvider.email);
      });

      test('works with devStatic provider', () {
        final account = UserAccount.create(
          accountId: 'acc-5',
          displayName: 'Dev User',
          authProvider: AuthProvider.devStatic,
        );
        expect(account.authProvider, AuthProvider.devStatic);
      });
    });

    group('mutable fields', () {
      test('can set id directly', () {
        final account = UserAccount();
        account.id = 999;
        expect(account.id, 999);
      });

      test('can set accountId directly', () {
        final account = UserAccount();
        account.accountId = 'direct-id';
        expect(account.accountId, 'direct-id');
      });

      test('can set displayName directly', () {
        final account = UserAccount();
        account.displayName = 'Direct Name';
        expect(account.displayName, 'Direct Name');
      });

      test('can set isActive directly', () {
        final account = UserAccount();
        account.isActive = true;
        expect(account.isActive, true);
      });

      test('can set all optional fields directly', () {
        final account = UserAccount();
        final now = DateTime.now();
        
        account.email = 'direct@example.com';
        account.photoUrl = 'https://example.com/direct.png';
        account.updatedAt = now;
        account.activeProfileId = 'profile-direct';
        account.lastSyncedAt = now;
        account.accessToken = 'direct-access';
        account.refreshToken = 'direct-refresh';
        account.tokenExpiresAt = now;

        expect(account.email, 'direct@example.com');
        expect(account.photoUrl, 'https://example.com/direct.png');
        expect(account.updatedAt, now);
        expect(account.activeProfileId, 'profile-direct');
        expect(account.lastSyncedAt, now);
        expect(account.accessToken, 'direct-access');
        expect(account.refreshToken, 'direct-refresh');
        expect(account.tokenExpiresAt, now);
      });
    });

    group('typical usage scenarios', () {
      test('creating a new Gmail sign-in user', () {
        final account = UserAccount.create(
          accountId: 'google-uid-123',
          displayName: 'John Doe',
          authProvider: AuthProvider.gmail,
          email: 'john.doe@gmail.com',
          photoUrl: 'https://lh3.googleusercontent.com/photo.jpg',
          isActive: true,
        );

        expect(account.accountId, 'google-uid-123');
        expect(account.email, 'john.doe@gmail.com');
        expect(account.authProvider, AuthProvider.gmail);
        expect(account.isActive, true);
      });

      test('creating an anonymous user', () {
        final account = UserAccount.create(
          accountId: 'anon-device-id',
          displayName: 'Anonymous',
          authProvider: AuthProvider.anonymous,
        );

        expect(account.authProvider, AuthProvider.anonymous);
        expect(account.email, isNull);
        expect(account.photoUrl, isNull);
      });

      test('upgrading anonymous to Gmail account', () {
        var account = UserAccount.create(
          accountId: 'anon-id',
          displayName: 'Anonymous',
          authProvider: AuthProvider.anonymous,
        );

        // Simulate upgrade
        account = account.copyWith(
          accountId: 'google-uid-456',
          displayName: 'Jane Smith',
          authProvider: AuthProvider.gmail,
          email: 'jane@gmail.com',
        );

        expect(account.authProvider, AuthProvider.gmail);
        expect(account.email, 'jane@gmail.com');
        expect(account.displayName, 'Jane Smith');
      });

      test('updating tokens after refresh', () {
        final account = UserAccount.create(
          accountId: 'acc-1',
          displayName: 'User',
          authProvider: AuthProvider.gmail,
        );

        final newExpiry = DateTime.now().add(const Duration(hours: 1));
        final updated = account.copyWith(
          accessToken: 'new-access-token',
          refreshToken: 'new-refresh-token',
          tokenExpiresAt: newExpiry,
        );

        expect(updated.accessToken, 'new-access-token');
        expect(updated.refreshToken, 'new-refresh-token');
        expect(updated.tokenExpiresAt, newExpiry);
      });
    });
  });
}

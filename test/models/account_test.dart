import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/models/account.dart';

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
  });
}

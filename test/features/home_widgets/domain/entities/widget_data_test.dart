import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_data.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_size.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_tap_action.dart';

void main() {
  group('WidgetData Entity Tests', () {
    late WidgetData sampleWidgetData;
    late DateTime fixedDateTime;

    setUp(() {
      fixedDateTime = DateTime(2023, 1, 15, 10, 30);
      sampleWidgetData = WidgetData(
        id: 'widget_123',
        accountId: 'account_456',
        size: WidgetSize.medium,
        tapAction: WidgetTapAction.openApp,
        todayHitCount: 5,
        currentStreak: 3,
        lastSyncAt: fixedDateTime,
        createdAt: fixedDateTime.subtract(const Duration(days: 1)),
        updatedAt: fixedDateTime,
        showStreak: true,
        showLastSync: true,
      );
    });

    group('Constructor and Properties', () {
      test('should create widget data with all required fields', () {
        final widgetData = WidgetData(
          id: 'test_id',
          accountId: 'test_account',
          size: WidgetSize.small,
          tapAction: WidgetTapAction.recordOverlay,
          todayHitCount: 10,
          currentStreak: 7,
          lastSyncAt: fixedDateTime,
          createdAt: fixedDateTime,
        );

        expect(widgetData.id, equals('test_id'));
        expect(widgetData.accountId, equals('test_account'));
        expect(widgetData.size, equals(WidgetSize.small));
        expect(widgetData.tapAction, equals(WidgetTapAction.recordOverlay));
        expect(widgetData.todayHitCount, equals(10));
        expect(widgetData.currentStreak, equals(7));
        expect(widgetData.lastSyncAt, equals(fixedDateTime));
        expect(widgetData.createdAt, equals(fixedDateTime));
        expect(widgetData.updatedAt, isNull);
        expect(widgetData.showStreak, isNull);
        expect(widgetData.showLastSync, isNull);
      });

      test('should create widget data with optional fields', () {
        final widgetData = WidgetData(
          id: 'test_id',
          accountId: 'test_account',
          size: WidgetSize.large,
          tapAction: WidgetTapAction.viewLogs,
          todayHitCount: 0,
          currentStreak: 0,
          lastSyncAt: fixedDateTime,
          createdAt: fixedDateTime,
          updatedAt: fixedDateTime.add(const Duration(hours: 1)),
          showStreak: false,
          showLastSync: false,
        );

        expect(widgetData.updatedAt, equals(fixedDateTime.add(const Duration(hours: 1))));
        expect(widgetData.showStreak, isFalse);
        expect(widgetData.showLastSync, isFalse);
      });
    });

    group('shouldShowStreak Logic', () {
      test('should show streak when explicitly enabled', () {
        final widgetData = sampleWidgetData.copyWith(
          showStreak: true,
          size: WidgetSize.small,
          currentStreak: 0,
        );

        expect(widgetData.shouldShowStreak, isTrue);
      });

      test('should auto-show streak for non-small widgets with positive streak', () {
        final widgetData = sampleWidgetData.copyWith(
          showStreak: null,
          size: WidgetSize.medium,
          currentStreak: 5,
        );

        expect(widgetData.shouldShowStreak, isTrue);
      });

      test('should not show streak for small widgets with positive streak when not explicitly enabled', () {
        final widgetData = sampleWidgetData.copyWith(
          showStreak: null,
          size: WidgetSize.small,
          currentStreak: 5,
        );

        expect(widgetData.shouldShowStreak, isFalse);
      });

      test('should not show streak when current streak is zero', () {
        final widgetData = sampleWidgetData.copyWith(
          showStreak: null,
          size: WidgetSize.medium,
          currentStreak: 0,
        );

        expect(widgetData.shouldShowStreak, isFalse);
      });

      test('should show streak when auto-show is true even if explicitly disabled', () {
        // Note: Current business logic uses OR, so auto-show overrides explicit disable
        final widgetData = sampleWidgetData.copyWith(
          showStreak: false,
          size: WidgetSize.large,
          currentStreak: 10,
        );

        expect(widgetData.shouldShowStreak, isTrue);
      });

      test('should not show streak when explicitly disabled and auto-show does not apply', () {
        final widgetData = sampleWidgetData.copyWith(
          showStreak: false,
          size: WidgetSize.small, // small widgets can't auto-show
          currentStreak: 10,
        );

        expect(widgetData.shouldShowStreak, isFalse);
      });
    });

    group('shouldShowLastSync Logic', () {
      test('should show last sync for large widgets when enabled (default)', () {
        final widgetData = sampleWidgetData.copyWith(
          size: WidgetSize.large,
          showLastSync: null, // defaults to true
        );

        expect(widgetData.shouldShowLastSync, isTrue);
      });

      test('should show last sync for medium widgets when enabled', () {
        final widgetData = sampleWidgetData.copyWith(
          size: WidgetSize.medium,
          showLastSync: true,
        );

        expect(widgetData.shouldShowLastSync, isTrue);
      });

      test('should not show last sync for small widgets even when enabled', () {
        final widgetData = sampleWidgetData.copyWith(
          size: WidgetSize.small,
          showLastSync: true,
        );

        expect(widgetData.shouldShowLastSync, isFalse);
      });

      test('should not show last sync when explicitly disabled', () {
        final widgetData = sampleWidgetData.copyWith(
          size: WidgetSize.large,
          showLastSync: false,
        );

        expect(widgetData.shouldShowLastSync, isFalse);
      });
    });

    group('Text Formatting Methods', () {
      group('streakText', () {
        test('should return empty string for zero streak', () {
          final widgetData = sampleWidgetData.copyWith(currentStreak: 0);
          expect(widgetData.streakText, equals(''));
        });

        test('should return singular format for 1 day streak', () {
          final widgetData = sampleWidgetData.copyWith(currentStreak: 1);
          expect(widgetData.streakText, equals('1 day streak'));
        });

        test('should return plural format for multiple day streak', () {
          final widgetData = sampleWidgetData.copyWith(currentStreak: 7);
          expect(widgetData.streakText, equals('7 day streak'));
        });

        test('should return empty string for negative streak', () {
          final widgetData = sampleWidgetData.copyWith(currentStreak: -1);
          expect(widgetData.streakText, equals(''));
        });
      });

      group('hitCountText', () {
        test('should return singular format for 1 hit', () {
          final widgetData = sampleWidgetData.copyWith(todayHitCount: 1);
          expect(widgetData.hitCountText, equals('1 hit today'));
        });

        test('should return plural format for zero hits', () {
          final widgetData = sampleWidgetData.copyWith(todayHitCount: 0);
          expect(widgetData.hitCountText, equals('0 hits today'));
        });

        test('should return plural format for multiple hits', () {
          final widgetData = sampleWidgetData.copyWith(todayHitCount: 15);
          expect(widgetData.hitCountText, equals('15 hits today'));
        });
      });

      group('timeSinceSync', () {
        test('should return "Just now" for very recent sync', () {
          final now = DateTime.now();
          final widgetData = sampleWidgetData.copyWith(
            lastSyncAt: now.subtract(const Duration(seconds: 30)),
          );
          expect(widgetData.timeSinceSync, equals('Just now'));
        });

        test('should return minutes format for sync within an hour', () {
          final now = DateTime.now();
          final widgetData = sampleWidgetData.copyWith(
            lastSyncAt: now.subtract(const Duration(minutes: 15)),
          );
          expect(widgetData.timeSinceSync, equals('15m ago'));
        });

        test('should return hours format for sync within a day', () {
          final now = DateTime.now();
          final widgetData = sampleWidgetData.copyWith(
            lastSyncAt: now.subtract(const Duration(hours: 3)),
          );
          expect(widgetData.timeSinceSync, equals('3h ago'));
        });

        test('should return days format for sync older than a day', () {
          final now = DateTime.now();
          final widgetData = sampleWidgetData.copyWith(
            lastSyncAt: now.subtract(const Duration(days: 2)),
          );
          expect(widgetData.timeSinceSync, equals('2d ago'));
        });
      });
    });

    group('Business Logic Validation', () {
      group('isValid', () {
        test('should return true for valid widget data', () {
          expect(sampleWidgetData.isValid, isTrue);
        });

        test('should return false for empty id', () {
          final widgetData = sampleWidgetData.copyWith(id: '');
          expect(widgetData.isValid, isFalse);
        });

        test('should return false for empty account id', () {
          final widgetData = sampleWidgetData.copyWith(accountId: '');
          expect(widgetData.isValid, isFalse);
        });

        test('should return false for negative hit count', () {
          final widgetData = sampleWidgetData.copyWith(todayHitCount: -1);
          expect(widgetData.isValid, isFalse);
        });

        test('should return false for negative streak', () {
          final widgetData = sampleWidgetData.copyWith(currentStreak: -5);
          expect(widgetData.isValid, isFalse);
        });

        test('should return false for future sync time beyond clock skew tolerance', () {
          final futureTime = DateTime.now().add(const Duration(minutes: 10));
          final widgetData = sampleWidgetData.copyWith(lastSyncAt: futureTime);
          expect(widgetData.isValid, isFalse);
        });

        test('should return true for future sync time within clock skew tolerance', () {
          final futureTime = DateTime.now().add(const Duration(minutes: 3));
          final widgetData = sampleWidgetData.copyWith(lastSyncAt: futureTime);
          expect(widgetData.isValid, isTrue);
        });
      });

      group('isSyncStale', () {
        test('should return false for recent sync', () {
          final recentSync = DateTime.now().subtract(const Duration(minutes: 30));
          final widgetData = sampleWidgetData.copyWith(lastSyncAt: recentSync);
          expect(widgetData.isSyncStale, isFalse);
        });

        test('should return true for sync older than 1 hour', () {
          final staleSync = DateTime.now().subtract(const Duration(hours: 2));
          final widgetData = sampleWidgetData.copyWith(lastSyncAt: staleSync);
          expect(widgetData.isSyncStale, isTrue);
        });

        test('should return false for sync exactly 59 minutes ago', () {
          final almostStaleSync = DateTime.now().subtract(const Duration(minutes: 59));
          final widgetData = sampleWidgetData.copyWith(lastSyncAt: almostStaleSync);
          expect(widgetData.isSyncStale, isFalse);
        });

        test('should return true for sync exactly 1 hour ago', () {
          final staleSync = DateTime.now().subtract(const Duration(hours: 1));
          final widgetData = sampleWidgetData.copyWith(lastSyncAt: staleSync);
          expect(widgetData.isSyncStale, isTrue);
        });
      });
    });

    group('Update Methods', () {
      group('updateHitCount', () {
        test('should update hit count and sync timestamp', () {
          final originalTime = sampleWidgetData.lastSyncAt;
          
          // Wait a bit to ensure timestamp changes
          final updatedData = sampleWidgetData.updateHitCount(10);

          expect(updatedData.todayHitCount, equals(10));
          expect(updatedData.lastSyncAt.isAfter(originalTime), isTrue);
          expect(updatedData.updatedAt, isNotNull);
          expect(updatedData.updatedAt!.isAfter(originalTime), isTrue);
          
          // Other fields should remain the same
          expect(updatedData.id, equals(sampleWidgetData.id));
          expect(updatedData.accountId, equals(sampleWidgetData.accountId));
          expect(updatedData.currentStreak, equals(sampleWidgetData.currentStreak));
        });

        test('should handle zero hit count update', () {
          final updatedData = sampleWidgetData.updateHitCount(0);
          expect(updatedData.todayHitCount, equals(0));
        });
      });

      group('updateStreak', () {
        test('should update streak and sync timestamp', () {
          final originalTime = sampleWidgetData.lastSyncAt;
          
          final updatedData = sampleWidgetData.updateStreak(15);

          expect(updatedData.currentStreak, equals(15));
          expect(updatedData.lastSyncAt.isAfter(originalTime), isTrue);
          expect(updatedData.updatedAt, isNotNull);
          expect(updatedData.updatedAt!.isAfter(originalTime), isTrue);
          
          // Other fields should remain the same
          expect(updatedData.id, equals(sampleWidgetData.id));
          expect(updatedData.accountId, equals(sampleWidgetData.accountId));
          expect(updatedData.todayHitCount, equals(sampleWidgetData.todayHitCount));
        });

        test('should handle zero streak update', () {
          final updatedData = sampleWidgetData.updateStreak(0);
          expect(updatedData.currentStreak, equals(0));
        });
      });
    });

    group('copyWith Method', () {
      test('should copy with new values', () {
        final updatedData = sampleWidgetData.copyWith(
          id: 'new_id',
          size: WidgetSize.large,
          todayHitCount: 99,
        );

        expect(updatedData.id, equals('new_id'));
        expect(updatedData.size, equals(WidgetSize.large));
        expect(updatedData.todayHitCount, equals(99));
        
        // Unchanged fields should remain the same
        expect(updatedData.accountId, equals(sampleWidgetData.accountId));
        expect(updatedData.currentStreak, equals(sampleWidgetData.currentStreak));
        expect(updatedData.lastSyncAt, equals(sampleWidgetData.lastSyncAt));
      });

      test('should handle null values in copyWith', () {
        final updatedData = sampleWidgetData.copyWith(
          updatedAt: null,
          showStreak: null,
          showLastSync: null,
        );

        expect(updatedData.updatedAt, isNull);
        expect(updatedData.showStreak, isNull);
        expect(updatedData.showLastSync, isNull);
      });
    });

    group('Equality and Hash Code', () {
      test('should be equal for same data', () {
        final widgetData1 = WidgetData(
          id: 'test',
          accountId: 'account',
          size: WidgetSize.medium,
          tapAction: WidgetTapAction.openApp,
          todayHitCount: 5,
          currentStreak: 3,
          lastSyncAt: fixedDateTime,
          createdAt: fixedDateTime,
        );

        final widgetData2 = WidgetData(
          id: 'test',
          accountId: 'account',
          size: WidgetSize.medium,
          tapAction: WidgetTapAction.openApp,
          todayHitCount: 5,
          currentStreak: 3,
          lastSyncAt: fixedDateTime,
          createdAt: fixedDateTime,
        );

        expect(widgetData1, equals(widgetData2));
        expect(widgetData1.hashCode, equals(widgetData2.hashCode));
      });

      test('should not be equal for different data', () {
        final widgetData1 = sampleWidgetData;
        final widgetData2 = sampleWidgetData.copyWith(id: 'different_id');

        expect(widgetData1, isNot(equals(widgetData2)));
        expect(widgetData1.hashCode, isNot(equals(widgetData2.hashCode)));
      });
    });
  });
}
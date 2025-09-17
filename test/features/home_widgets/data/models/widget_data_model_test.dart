import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/home_widgets/data/models/widget_data_model.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_data.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_size.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_tap_action.dart';

void main() {
  group('WidgetDataModel', () {
    late DateTime fixedDateTime;
    late DateTime createdDateTime;
    late WidgetData sampleEntity;
    late WidgetDataModel sampleModel;
    late Map<String, dynamic> sampleJson;

    setUp(() {
      fixedDateTime = DateTime(2023, 1, 15, 10, 30);
      createdDateTime = DateTime(2023, 1, 14, 10, 30);

      sampleEntity = WidgetData(
        id: 'widget_123',
        accountId: 'account_456',
        size: WidgetSize.medium,
        tapAction: WidgetTapAction.openApp,
        todayHitCount: 5,
        currentStreak: 3,
        lastSyncAt: fixedDateTime,
        createdAt: createdDateTime,
        updatedAt: fixedDateTime,
        showStreak: true,
        showLastSync: false,
      );

      sampleModel = WidgetDataModel(
        id: 'widget_123',
        accountId: 'account_456',
        size: 'medium',
        tapAction: 'openApp',
        todayHitCount: 5,
        currentStreak: 3,
        lastSyncAt: fixedDateTime,
        createdAt: createdDateTime,
        updatedAt: fixedDateTime,
        showStreak: true,
        showLastSync: false,
      );

      sampleJson = {
        'id': 'widget_123',
        'account_id': 'account_456',
        'size': 'medium',
        'tap_action': 'openApp',
        'today_hit_count': 5,
        'current_streak': 3,
        'last_sync_at': fixedDateTime.toIso8601String(),
        'created_at': createdDateTime.toIso8601String(),
        'updated_at': fixedDateTime.toIso8601String(),
        'show_streak': true,
        'show_last_sync': false,
      };
    });

    group('Constructor and Properties', () {
      test('should create model with all required fields', () {
        final model = WidgetDataModel(
          id: 'test_id',
          accountId: 'test_account',
          size: 'small',
          tapAction: 'recordOverlay',
          todayHitCount: 10,
          currentStreak: 7,
          lastSyncAt: fixedDateTime,
          createdAt: createdDateTime,
        );

        expect(model.id, equals('test_id'));
        expect(model.accountId, equals('test_account'));
        expect(model.size, equals('small'));
        expect(model.tapAction, equals('recordOverlay'));
        expect(model.todayHitCount, equals(10));
        expect(model.currentStreak, equals(7));
        expect(model.lastSyncAt, equals(fixedDateTime));
        expect(model.createdAt, equals(createdDateTime));
        expect(model.updatedAt, isNull);
        expect(model.showStreak, isNull);
        expect(model.showLastSync, isNull);
      });

      test('should create model with optional fields', () {
        final model = WidgetDataModel(
          id: 'test_id',
          accountId: 'test_account',
          size: 'large',
          tapAction: 'viewLogs',
          todayHitCount: 0,
          currentStreak: 0,
          lastSyncAt: fixedDateTime,
          createdAt: createdDateTime,
          updatedAt: fixedDateTime.add(const Duration(hours: 1)),
          showStreak: false,
          showLastSync: true,
        );

        expect(model.updatedAt, equals(fixedDateTime.add(const Duration(hours: 1))));
        expect(model.showStreak, isFalse);
        expect(model.showLastSync, isTrue);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final json = sampleModel.toJson();

        expect(json['id'], equals('widget_123'));
        expect(json['account_id'], equals('account_456'));
        expect(json['size'], equals('medium'));
        expect(json['tap_action'], equals('openApp'));
        expect(json['today_hit_count'], equals(5));
        expect(json['current_streak'], equals(3));
        expect(json['last_sync_at'], equals(fixedDateTime.toIso8601String()));
        expect(json['created_at'], equals(createdDateTime.toIso8601String()));
        expect(json['updated_at'], equals(fixedDateTime.toIso8601String()));
        expect(json['show_streak'], isTrue);
        expect(json['show_last_sync'], isFalse);
      });

      test('should serialize to JSON with null optional fields', () {
        final model = WidgetDataModel(
          id: 'widget_123',
          accountId: 'account_456',
          size: 'small',
          tapAction: 'quickRecord',
          todayHitCount: 1,
          currentStreak: 0,
          lastSyncAt: fixedDateTime,
          createdAt: createdDateTime,
        );

        final json = model.toJson();

        expect(json['updated_at'], isNull);
        expect(json['show_streak'], isNull);
        expect(json['show_last_sync'], isNull);
        // Ensure nulls are included in JSON
        expect(json.containsKey('updated_at'), isTrue);
        expect(json.containsKey('show_streak'), isTrue);
        expect(json.containsKey('show_last_sync'), isTrue);
      });

      test('should deserialize from JSON correctly', () {
        final model = WidgetDataModel.fromJson(sampleJson);

        expect(model.id, equals('widget_123'));
        expect(model.accountId, equals('account_456'));
        expect(model.size, equals('medium'));
        expect(model.tapAction, equals('openApp'));
        expect(model.todayHitCount, equals(5));
        expect(model.currentStreak, equals(3));
        expect(model.lastSyncAt, equals(fixedDateTime));
        expect(model.createdAt, equals(createdDateTime));
        expect(model.updatedAt, equals(fixedDateTime));
        expect(model.showStreak, isTrue);
        expect(model.showLastSync, isFalse);
      });

      test('should handle JSON with missing optional fields', () {
        final jsonWithNulls = Map<String, dynamic>.from(sampleJson);
        jsonWithNulls.remove('updated_at');
        jsonWithNulls.remove('show_streak');
        jsonWithNulls.remove('show_last_sync');

        final model = WidgetDataModel.fromJson(jsonWithNulls);

        expect(model.updatedAt, isNull);
        expect(model.showStreak, isNull);
        expect(model.showLastSync, isNull);
        // Required fields should still be present
        expect(model.id, equals('widget_123'));
        expect(model.todayHitCount, equals(5));
      });

      test('should handle JSON with explicit null values', () {
        final jsonWithExplicitNulls = Map<String, dynamic>.from(sampleJson);
        jsonWithExplicitNulls['updated_at'] = null;
        jsonWithExplicitNulls['show_streak'] = null;
        jsonWithExplicitNulls['show_last_sync'] = null;

        final model = WidgetDataModel.fromJson(jsonWithExplicitNulls);

        expect(model.updatedAt, isNull);
        expect(model.showStreak, isNull);
        expect(model.showLastSync, isNull);
      });
    });

    group('Entity Conversion', () {
      group('fromEntity', () {
        test('should convert from domain entity correctly', () {
          final model = WidgetDataModel.fromEntity(sampleEntity);

          expect(model.id, equals(sampleEntity.id));
          expect(model.accountId, equals(sampleEntity.accountId));
          expect(model.size, equals('medium'));
          expect(model.tapAction, equals('openApp'));
          expect(model.todayHitCount, equals(sampleEntity.todayHitCount));
          expect(model.currentStreak, equals(sampleEntity.currentStreak));
          expect(model.lastSyncAt, equals(sampleEntity.lastSyncAt));
          expect(model.createdAt, equals(sampleEntity.createdAt));
          expect(model.updatedAt, equals(sampleEntity.updatedAt));
          expect(model.showStreak, equals(sampleEntity.showStreak));
          expect(model.showLastSync, equals(sampleEntity.showLastSync));
        });

        test('should convert all widget sizes correctly', () {
          for (final size in WidgetSize.values) {
            final entity = sampleEntity.copyWith(size: size);
            final model = WidgetDataModel.fromEntity(entity);
            
            expect(model.size, equals(size.name), 
                   reason: 'Failed for size: ${size.name}');
          }
        });

        test('should convert all tap actions correctly', () {
          for (final action in WidgetTapAction.values) {
            final entity = sampleEntity.copyWith(tapAction: action);
            final model = WidgetDataModel.fromEntity(entity);
            
            expect(model.tapAction, equals(action.name), 
                   reason: 'Failed for action: ${action.name}');
          }
        });

        test('should handle entity with null optional fields', () {
          final entityWithNulls = WidgetData(
            id: 'widget_nulls',
            accountId: 'account_nulls',
            size: WidgetSize.small,
            tapAction: WidgetTapAction.quickRecord,
            todayHitCount: 0,
            currentStreak: 0,
            lastSyncAt: fixedDateTime,
            createdAt: createdDateTime,
            // updatedAt, showStreak, showLastSync are null by default
          );

          final model = WidgetDataModel.fromEntity(entityWithNulls);

          expect(model.updatedAt, isNull);
          expect(model.showStreak, isNull);
          expect(model.showLastSync, isNull);
        });
      });

      group('toEntity', () {
        test('should convert to domain entity correctly', () {
          final entity = sampleModel.toEntity();

          expect(entity.id, equals(sampleModel.id));
          expect(entity.accountId, equals(sampleModel.accountId));
          expect(entity.size, equals(WidgetSize.medium));
          expect(entity.tapAction, equals(WidgetTapAction.openApp));
          expect(entity.todayHitCount, equals(sampleModel.todayHitCount));
          expect(entity.currentStreak, equals(sampleModel.currentStreak));
          expect(entity.lastSyncAt, equals(sampleModel.lastSyncAt));
          expect(entity.createdAt, equals(sampleModel.createdAt));
          expect(entity.updatedAt, equals(sampleModel.updatedAt));
          expect(entity.showStreak, equals(sampleModel.showStreak));
          expect(entity.showLastSync, equals(sampleModel.showLastSync));
        });

        test('should parse all widget sizes correctly', () {
          for (final size in WidgetSize.values) {
            final model = sampleModel.copyWith(size: size.name);
            final entity = model.toEntity();
            
            expect(entity.size, equals(size), 
                   reason: 'Failed for size: ${size.name}');
          }
        });

        test('should parse all tap actions correctly', () {
          for (final action in WidgetTapAction.values) {
            final model = sampleModel.copyWith(tapAction: action.name);
            final entity = model.toEntity();
            
            expect(entity.tapAction, equals(action), 
                   reason: 'Failed for action: ${action.name}');
          }
        });

        test('should use default size for invalid size string', () {
          final model = sampleModel.copyWith(size: 'invalid_size');
          final entity = model.toEntity();

          expect(entity.size, equals(WidgetSize.medium));
        });

        test('should use default action for invalid action string', () {
          final model = sampleModel.copyWith(tapAction: 'invalid_action');
          final entity = model.toEntity();

          expect(entity.tapAction, equals(WidgetTapAction.defaultAction));
        });

        test('should handle model with null optional fields', () {
          final model = WidgetDataModel(
            id: 'widget_nulls',
            accountId: 'account_nulls',
            size: 'small',
            tapAction: 'quickRecord',
            todayHitCount: 0,
            currentStreak: 0,
            lastSyncAt: fixedDateTime,
            createdAt: createdDateTime,
            // updatedAt, showStreak, showLastSync are null
          );

          final entity = model.toEntity();

          expect(entity.updatedAt, isNull);
          expect(entity.showStreak, isNull);
          expect(entity.showLastSync, isNull);
        });
      });
    });

    group('Round-trip Conversion', () {
      test('should maintain data integrity through entity -> model -> entity conversion', () {
        final originalEntity = sampleEntity;
        final model = WidgetDataModel.fromEntity(originalEntity);
        final convertedEntity = model.toEntity();

        expect(convertedEntity.id, equals(originalEntity.id));
        expect(convertedEntity.accountId, equals(originalEntity.accountId));
        expect(convertedEntity.size, equals(originalEntity.size));
        expect(convertedEntity.tapAction, equals(originalEntity.tapAction));
        expect(convertedEntity.todayHitCount, equals(originalEntity.todayHitCount));
        expect(convertedEntity.currentStreak, equals(originalEntity.currentStreak));
        expect(convertedEntity.lastSyncAt, equals(originalEntity.lastSyncAt));
        expect(convertedEntity.createdAt, equals(originalEntity.createdAt));
        expect(convertedEntity.updatedAt, equals(originalEntity.updatedAt));
        expect(convertedEntity.showStreak, equals(originalEntity.showStreak));
        expect(convertedEntity.showLastSync, equals(originalEntity.showLastSync));
      });

      test('should maintain data integrity through JSON -> model -> JSON conversion', () {
        final originalJson = sampleJson;
        final model = WidgetDataModel.fromJson(originalJson);
        final convertedJson = model.toJson();

        expect(convertedJson['id'], equals(originalJson['id']));
        expect(convertedJson['account_id'], equals(originalJson['account_id']));
        expect(convertedJson['size'], equals(originalJson['size']));
        expect(convertedJson['tap_action'], equals(originalJson['tap_action']));
        expect(convertedJson['today_hit_count'], equals(originalJson['today_hit_count']));
        expect(convertedJson['current_streak'], equals(originalJson['current_streak']));
        expect(convertedJson['last_sync_at'], equals(originalJson['last_sync_at']));
        expect(convertedJson['created_at'], equals(originalJson['created_at']));
        expect(convertedJson['updated_at'], equals(originalJson['updated_at']));
        expect(convertedJson['show_streak'], equals(originalJson['show_streak']));
        expect(convertedJson['show_last_sync'], equals(originalJson['show_last_sync']));
      });

      test('should handle full round-trip: entity -> model -> JSON -> model -> entity', () {
        final originalEntity = sampleEntity;
        final model1 = WidgetDataModel.fromEntity(originalEntity);
        final json = model1.toJson();
        final model2 = WidgetDataModel.fromJson(json);
        final finalEntity = model2.toEntity();

        // Verify complete data integrity
        expect(finalEntity, equals(originalEntity));
      });
    });

    group('Edge Cases', () {
      test('should handle empty string values appropriately', () {
        final json = {
          'id': '',
          'account_id': '',
          'size': '',
          'tap_action': '',
          'today_hit_count': 0,
          'current_streak': 0,
          'last_sync_at': fixedDateTime.toIso8601String(),
          'created_at': createdDateTime.toIso8601String(),
        };

        final model = WidgetDataModel.fromJson(json);
        final entity = model.toEntity();

        expect(entity.id, equals(''));
        expect(entity.accountId, equals(''));
        expect(entity.size, equals(WidgetSize.medium)); // Default for invalid size
        expect(entity.tapAction, equals(WidgetTapAction.defaultAction)); // Default for invalid action
      });

      test('should handle extreme integer values', () {
        final json = {
          'id': 'extreme_test',
          'account_id': 'account_extreme',
          'size': 'large',
          'tap_action': 'openApp',
          'today_hit_count': 2147483647, // Max int
          'current_streak': 999999,
          'last_sync_at': fixedDateTime.toIso8601String(),
          'created_at': createdDateTime.toIso8601String(),
        };

        final model = WidgetDataModel.fromJson(json);
        final entity = model.toEntity();

        expect(entity.todayHitCount, equals(2147483647));
        expect(entity.currentStreak, equals(999999));
      });

      test('should handle case sensitivity in size parsing', () {
        final model = WidgetDataModel(
          id: 'case_test',
          accountId: 'account_case',
          size: 'MEDIUM', // Uppercase
          tapAction: 'openApp',
          todayHitCount: 1,
          currentStreak: 1,
          lastSyncAt: fixedDateTime,
          createdAt: createdDateTime,
        );

        final entity = model.toEntity();
        
        // Should fall back to default since case doesn't match
        expect(entity.size, equals(WidgetSize.medium));
      });
    });

    group('Equality and Hash Code', () {
      test('should be equal for same data', () {
        final model1 = WidgetDataModel(
          id: 'test',
          accountId: 'account',
          size: 'medium',
          tapAction: 'openApp',
          todayHitCount: 5,
          currentStreak: 3,
          lastSyncAt: fixedDateTime,
          createdAt: createdDateTime,
        );

        final model2 = WidgetDataModel(
          id: 'test',
          accountId: 'account',
          size: 'medium',
          tapAction: 'openApp',
          todayHitCount: 5,
          currentStreak: 3,
          lastSyncAt: fixedDateTime,
          createdAt: createdDateTime,
        );

        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal for different data', () {
        final model1 = sampleModel;
        final model2 = sampleModel.copyWith(id: 'different_id');

        expect(model1, isNot(equals(model2)));
        expect(model1.hashCode, isNot(equals(model2.hashCode)));
      });
    });
  });
}
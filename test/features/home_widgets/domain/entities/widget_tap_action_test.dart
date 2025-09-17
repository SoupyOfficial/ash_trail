import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_tap_action.dart';

void main() {
  group('WidgetTapAction Enum Tests', () {
    group('Constructor and Properties', () {
      test('should have correct display names for all actions', () {
        expect(WidgetTapAction.openApp.displayName, equals('Open App'));
        expect(WidgetTapAction.recordOverlay.displayName,
            equals('Record Overlay'));
        expect(WidgetTapAction.viewLogs.displayName, equals('View Logs'));
        expect(WidgetTapAction.quickRecord.displayName, equals('Quick Record'));
      });
    });

    group('Default Action', () {
      test('should have openApp as default action', () {
        expect(WidgetTapAction.defaultAction, equals(WidgetTapAction.openApp));
      });
    });

    group('Deep Link Paths', () {
      test('should return correct deep link path for openApp', () {
        expect(WidgetTapAction.openApp.deepLinkPath, equals('/'));
      });

      test('should return correct deep link path for recordOverlay', () {
        expect(WidgetTapAction.recordOverlay.deepLinkPath, equals('/record'));
      });

      test('should return correct deep link path for viewLogs', () {
        expect(WidgetTapAction.viewLogs.deepLinkPath, equals('/logs'));
      });

      test('should return correct deep link path for quickRecord', () {
        expect(WidgetTapAction.quickRecord.deepLinkPath,
            equals('/record?quick=true'));
      });

      test('should have unique deep link paths for all actions', () {
        final paths =
            WidgetTapAction.values.map((action) => action.deepLinkPath).toSet();
        expect(paths, hasLength(WidgetTapAction.values.length));
      });
    });

    group('Authentication Requirements', () {
      test('should not require auth for openApp', () {
        expect(WidgetTapAction.openApp.requiresAuth, isFalse);
      });

      test('should require auth for recordOverlay', () {
        expect(WidgetTapAction.recordOverlay.requiresAuth, isTrue);
      });

      test('should require auth for viewLogs', () {
        expect(WidgetTapAction.viewLogs.requiresAuth, isTrue);
      });

      test('should require auth for quickRecord', () {
        expect(WidgetTapAction.quickRecord.requiresAuth, isTrue);
      });
    });

    group('Enum Values Coverage', () {
      test('should have all expected enum values', () {
        final allActions = WidgetTapAction.values;
        expect(allActions, hasLength(4));
        expect(allActions, contains(WidgetTapAction.openApp));
        expect(allActions, contains(WidgetTapAction.recordOverlay));
        expect(allActions, contains(WidgetTapAction.viewLogs));
        expect(allActions, contains(WidgetTapAction.quickRecord));
      });

      test('should maintain consistent ordering', () {
        final allActions = WidgetTapAction.values;
        expect(allActions[0], equals(WidgetTapAction.openApp));
        expect(allActions[1], equals(WidgetTapAction.recordOverlay));
        expect(allActions[2], equals(WidgetTapAction.viewLogs));
        expect(allActions[3], equals(WidgetTapAction.quickRecord));
      });
    });

    group('Equality and Hash Code', () {
      test('should be equal to itself', () {
        expect(WidgetTapAction.openApp, equals(WidgetTapAction.openApp));
        expect(WidgetTapAction.recordOverlay,
            equals(WidgetTapAction.recordOverlay));
        expect(WidgetTapAction.viewLogs, equals(WidgetTapAction.viewLogs));
        expect(
            WidgetTapAction.quickRecord, equals(WidgetTapAction.quickRecord));
      });

      test('should have consistent hash codes', () {
        expect(WidgetTapAction.openApp.hashCode,
            equals(WidgetTapAction.openApp.hashCode));
        expect(WidgetTapAction.recordOverlay.hashCode,
            equals(WidgetTapAction.recordOverlay.hashCode));
        expect(WidgetTapAction.viewLogs.hashCode,
            equals(WidgetTapAction.viewLogs.hashCode));
        expect(WidgetTapAction.quickRecord.hashCode,
            equals(WidgetTapAction.quickRecord.hashCode));
      });

      test('should not be equal to different enum values', () {
        expect(WidgetTapAction.openApp,
            isNot(equals(WidgetTapAction.recordOverlay)));
        expect(WidgetTapAction.recordOverlay,
            isNot(equals(WidgetTapAction.viewLogs)));
        expect(WidgetTapAction.viewLogs,
            isNot(equals(WidgetTapAction.quickRecord)));
      });
    });

    group('String Representation', () {
      test('should have meaningful string representation', () {
        expect(WidgetTapAction.openApp.toString(),
            equals('WidgetTapAction.openApp'));
        expect(WidgetTapAction.recordOverlay.toString(),
            equals('WidgetTapAction.recordOverlay'));
        expect(WidgetTapAction.viewLogs.toString(),
            equals('WidgetTapAction.viewLogs'));
        expect(WidgetTapAction.quickRecord.toString(),
            equals('WidgetTapAction.quickRecord'));
      });
    });

    group('Business Logic Edge Cases', () {
      test('should handle switch expression exhaustively', () {
        // This test ensures all enum values are handled in the switch expression
        for (final action in WidgetTapAction.values) {
          expect(() => action.deepLinkPath, returnsNormally);
          expect(action.deepLinkPath, isA<String>());
          expect(action.deepLinkPath.isNotEmpty, isTrue);
        }
      });

      test('should have valid deep link paths', () {
        for (final action in WidgetTapAction.values) {
          final path = action.deepLinkPath;
          expect(path.startsWith('/'), isTrue,
              reason: 'Path $path should start with /');
        }
      });

      test('should have display names for all actions', () {
        for (final action in WidgetTapAction.values) {
          expect(action.displayName.isNotEmpty, isTrue,
              reason: 'Action $action should have a display name');
        }
      });
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/home_widgets/domain/entities/widget_size.dart';

void main() {
  group('WidgetSize Enum Tests', () {
    group('Constructor and Properties', () {
      test('should have correct width and height for small widget', () {
        expect(WidgetSize.small.width, equals(2));
        expect(WidgetSize.small.height, equals(2));
      });

      test('should have correct width and height for medium widget', () {
        expect(WidgetSize.medium.width, equals(4));
        expect(WidgetSize.medium.height, equals(2));
      });

      test('should have correct width and height for large widget', () {
        expect(WidgetSize.large.width, equals(4));
        expect(WidgetSize.large.height, equals(4));
      });

      test('should have correct width and height for extra large widget', () {
        expect(WidgetSize.extraLarge.width, equals(8));
        expect(WidgetSize.extraLarge.height, equals(4));
      });
    });

    group('Size Check Properties', () {
      test('isSmall should return true only for small size', () {
        expect(WidgetSize.small.isSmall, isTrue);
        expect(WidgetSize.medium.isSmall, isFalse);
        expect(WidgetSize.large.isSmall, isFalse);
        expect(WidgetSize.extraLarge.isSmall, isFalse);
      });

      test('isMedium should return true only for medium size', () {
        expect(WidgetSize.small.isMedium, isFalse);
        expect(WidgetSize.medium.isMedium, isTrue);
        expect(WidgetSize.large.isMedium, isFalse);
        expect(WidgetSize.extraLarge.isMedium, isFalse);
      });

      test('isLarge should return true only for large size', () {
        expect(WidgetSize.small.isLarge, isFalse);
        expect(WidgetSize.medium.isLarge, isFalse);
        expect(WidgetSize.large.isLarge, isTrue);
        expect(WidgetSize.extraLarge.isLarge, isFalse);
      });

      test('isExtraLarge should return true only for extra large size', () {
        expect(WidgetSize.small.isExtraLarge, isFalse);
        expect(WidgetSize.medium.isExtraLarge, isFalse);
        expect(WidgetSize.large.isExtraLarge, isFalse);
        expect(WidgetSize.extraLarge.isExtraLarge, isTrue);
      });
    });

    group('Capability Properties', () {
      group('canShowDetails', () {
        test('should return false for small widgets (width < 4)', () {
          expect(WidgetSize.small.canShowDetails, isFalse);
        });

        test('should return true for medium widgets (width >= 4)', () {
          expect(WidgetSize.medium.canShowDetails, isTrue);
        });

        test('should return true for large widgets (width >= 4)', () {
          expect(WidgetSize.large.canShowDetails, isTrue);
        });

        test('should return true for extra large widgets (width >= 4)', () {
          expect(WidgetSize.extraLarge.canShowDetails, isTrue);
        });
      });

      group('canShowStreak', () {
        test('should return false for small widgets', () {
          expect(WidgetSize.small.canShowStreak, isFalse);
        });

        test('should return true for medium widgets', () {
          expect(WidgetSize.medium.canShowStreak, isTrue);
        });

        test('should return true for large widgets', () {
          expect(WidgetSize.large.canShowStreak, isTrue);
        });

        test('should return true for extra large widgets', () {
          expect(WidgetSize.extraLarge.canShowStreak, isTrue);
        });
      });
    });

    group('Enum Values Coverage', () {
      test('should have all expected enum values', () {
        final allSizes = WidgetSize.values;
        expect(allSizes, hasLength(4));
        expect(allSizes, contains(WidgetSize.small));
        expect(allSizes, contains(WidgetSize.medium));
        expect(allSizes, contains(WidgetSize.large));
        expect(allSizes, contains(WidgetSize.extraLarge));
      });

      test('should maintain consistent ordering', () {
        final allSizes = WidgetSize.values;
        expect(allSizes[0], equals(WidgetSize.small));
        expect(allSizes[1], equals(WidgetSize.medium));
        expect(allSizes[2], equals(WidgetSize.large));
        expect(allSizes[3], equals(WidgetSize.extraLarge));
      });
    });

    group('Equality and Hash Code', () {
      test('should be equal to itself', () {
        expect(WidgetSize.small, equals(WidgetSize.small));
        expect(WidgetSize.medium, equals(WidgetSize.medium));
        expect(WidgetSize.large, equals(WidgetSize.large));
        expect(WidgetSize.extraLarge, equals(WidgetSize.extraLarge));
      });

      test('should have consistent hash codes', () {
        expect(WidgetSize.small.hashCode, equals(WidgetSize.small.hashCode));
        expect(WidgetSize.medium.hashCode, equals(WidgetSize.medium.hashCode));
        expect(WidgetSize.large.hashCode, equals(WidgetSize.large.hashCode));
        expect(WidgetSize.extraLarge.hashCode, equals(WidgetSize.extraLarge.hashCode));
      });

      test('should not be equal to different enum values', () {
        expect(WidgetSize.small, isNot(equals(WidgetSize.medium)));
        expect(WidgetSize.medium, isNot(equals(WidgetSize.large)));
        expect(WidgetSize.large, isNot(equals(WidgetSize.extraLarge)));
      });
    });

    group('String Representation', () {
      test('should have meaningful string representation', () {
        expect(WidgetSize.small.toString(), equals('WidgetSize.small'));
        expect(WidgetSize.medium.toString(), equals('WidgetSize.medium'));
        expect(WidgetSize.large.toString(), equals('WidgetSize.large'));
        expect(WidgetSize.extraLarge.toString(), equals('WidgetSize.extraLarge'));
      });
    });
  });
}
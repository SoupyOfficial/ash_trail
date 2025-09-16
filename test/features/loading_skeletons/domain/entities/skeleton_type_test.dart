import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/loading_skeletons/domain/entities/skeleton_type.dart';

void main() {
  group('SkeletonType', () {
    test('should define all required skeleton types', () {
      expect(SkeletonType.list, isA<SkeletonType>());
      expect(SkeletonType.chart, isA<SkeletonType>());
      expect(SkeletonType.tile, isA<SkeletonType>());
      expect(SkeletonType.text, isA<SkeletonType>());
      expect(SkeletonType.avatar, isA<SkeletonType>());
    });

    test('should have distinct values for each type', () {
      final types = [
        SkeletonType.list,
        SkeletonType.chart,
        SkeletonType.tile,
        SkeletonType.text,
        SkeletonType.avatar,
      ];

      final uniqueTypes = types.toSet();
      expect(uniqueTypes.length, equals(types.length));
    });
  });
}

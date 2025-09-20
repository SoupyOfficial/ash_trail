import 'package:ash_trail/features/responsive/responsive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Responsive Feature Exports', () {
    test('should export all public APIs', () {
      // Test that all exports are accessible
      expect(Breakpoint.mobile, equals(Breakpoint.mobile));
      expect(LayoutConfig, isA<Type>());
      expect(breakpointProvider, isNotNull);
      expect(AdaptiveLayout, isA<Type>());
      expect(BreakpointBuilder, isA<Type>());
      expect(MinTapTarget, isA<Type>());
      expect(ResponsivePadding, isA<Type>());
    });
  });
}

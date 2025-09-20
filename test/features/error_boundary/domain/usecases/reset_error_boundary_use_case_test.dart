import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/error_boundary/domain/usecases/reset_error_boundary_use_case.dart';

void main() {
  group('ResetErrorBoundaryUseCase', () {
    late ResetErrorBoundaryUseCase useCase;

    setUp(() {
      useCase = const ResetErrorBoundaryUseCase();
    });

    test('should successfully reset error boundary', () async {
      // Act
      final result = await useCase();

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Expected success but got failure: $failure'),
        (unit) => expect(unit, isNotNull),
      );
    });
  });
}

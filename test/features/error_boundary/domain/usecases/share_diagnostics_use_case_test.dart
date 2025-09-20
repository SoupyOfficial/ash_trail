import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/error_boundary/domain/usecases/share_diagnostics_use_case.dart';
import 'package:ash_trail/features/error_boundary/domain/entities/error_event.dart';
import 'package:ash_trail/features/error_boundary/data/services/share_service.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class MockShareService implements ShareService {
  bool shouldFail = false;
  String? lastSharedText;
  String? lastSubject;

  @override
  Future<Either<AppFailure, Unit>> shareText({
    required String text,
    String? subject,
  }) async {
    lastSharedText = text;
    lastSubject = subject;

    if (shouldFail) {
      return left(const AppFailure.unexpected(message: 'Share failed'));
    }

    return right(unit);
  }

  @override
  Future<Either<AppFailure, Unit>> shareTextFromRect({
    required String text,
    String? subject,
    required double x,
    required double y,
    required double width,
    required double height,
  }) async {
    return shareText(text: text, subject: subject);
  }
}

void main() {
  group('ShareDiagnosticsUseCase', () {
    late MockShareService mockShareService;
    late ShareDiagnosticsUseCase useCase;

    setUp(() {
      mockShareService = MockShareService();
      useCase = ShareDiagnosticsUseCase(shareService: mockShareService);
    });

    test('should share diagnostic information successfully', () async {
      // Arrange
      final errorEvent = ErrorEvent(
        timestamp: DateTime(2023, 1, 1),
        errorType: 'TestError',
        message: 'Test message',
        wasAnalyticsOptIn: true,
      );

      // Act
      final result = await useCase(errorEvent: errorEvent);

      // Assert
      expect(result.isRight(), isTrue);
      expect(
          mockShareService.lastSharedText, contains('AshTrail Error Report'));
      expect(mockShareService.lastSharedText, contains('TestError'));
      expect(mockShareService.lastSubject, equals('AshTrail Error Report'));
    });

    test('should share redacted information for analytics opt-out', () async {
      // Arrange
      final errorEvent = ErrorEvent(
        timestamp: DateTime(2023, 1, 1),
        errorType: 'TestError',
        message: 'Sensitive message',
        wasAnalyticsOptIn: false,
      );

      // Act
      final result = await useCase(errorEvent: errorEvent);

      // Assert
      expect(result.isRight(), isTrue);
      expect(
          mockShareService.lastSharedText, contains('AshTrail Error Report'));
      expect(mockShareService.lastSharedText,
          contains('[Redacted - Analytics opt-out]'));
      expect(mockShareService.lastSharedText,
          isNot(contains('Sensitive message')));
    });

    test('should handle share service failures', () async {
      // Arrange
      mockShareService.shouldFail = true;
      final errorEvent = ErrorEvent(
        timestamp: DateTime.now(),
        errorType: 'TestError',
        message: 'Test message',
        wasAnalyticsOptIn: true,
      );

      // Act
      final result = await useCase(errorEvent: errorEvent);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.displayMessage, contains('Share failed')),
        (_) => fail('Expected failure'),
      );
    });

    test('should share with additional context when provided', () async {
      // Arrange
      final errorEvent = ErrorEvent(
        timestamp: DateTime(2023, 1, 1),
        errorType: 'TestError',
        message: 'Test message',
        wasAnalyticsOptIn: true,
      );
      const userDescription = 'User was trying to save a log';
      final appContext = {'screen': 'logs', 'version': '1.0.0'};

      // Act
      final result = await useCase.callWithContext(
        errorEvent: errorEvent,
        userDescription: userDescription,
        appContext: appContext,
      );

      // Assert
      expect(result.isRight(), isTrue);
      expect(mockShareService.lastSharedText, contains('User Description:'));
      expect(mockShareService.lastSharedText, contains(userDescription));
      expect(mockShareService.lastSharedText, contains('App Context:'));
      expect(mockShareService.lastSharedText, contains('screen: logs'));
      expect(mockShareService.lastSubject,
          equals('AshTrail Error Report (With Context)'));
    });

    test('should not include app context when analytics opt-out', () async {
      // Arrange
      final errorEvent = ErrorEvent(
        timestamp: DateTime(2023, 1, 1),
        errorType: 'TestError',
        message: 'Test message',
        wasAnalyticsOptIn: false,
      );
      const userDescription = 'Error occurred';
      final appContext = {'sensitive': 'data'};

      // Act
      final result = await useCase.callWithContext(
        errorEvent: errorEvent,
        userDescription: userDescription,
        appContext: appContext,
      );

      // Assert
      expect(result.isRight(), isTrue);
      expect(mockShareService.lastSharedText, contains('User Description:'));
      expect(mockShareService.lastSharedText, contains(userDescription));
      expect(mockShareService.lastSharedText, isNot(contains('App Context:')));
      expect(mockShareService.lastSharedText, isNot(contains('sensitive')));
    });
  });
}

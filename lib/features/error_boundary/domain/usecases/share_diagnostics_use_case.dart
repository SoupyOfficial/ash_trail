import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';
import '../entities/error_event.dart';
import '../../data/services/share_service.dart';

/// Use case for sharing diagnostic information from error events.
/// Respects privacy settings and uses native platform sharing when available.
class ShareDiagnosticsUseCase {
  const ShareDiagnosticsUseCase({
    required ShareService shareService,
  }) : _shareService = shareService;

  final ShareService _shareService;

  /// Shares diagnostic information from an error event.
  /// The shared content respects the analytics opt-in preference.
  Future<Either<AppFailure, Unit>> call({
    required ErrorEvent errorEvent,
  }) async {
    try {
      final diagnosticText = errorEvent.diagnosticInfo;

      final result = await _shareService.shareText(
        text: diagnosticText,
        subject: 'AshTrail Error Report',
      );

      return result.fold(
        (failure) => left(failure),
        (_) => right(unit),
      );
    } catch (e, st) {
      return left(AppFailure.unexpected(
        message: 'Failed to share diagnostics',
        cause: e,
        stackTrace: st,
      ));
    }
  }

  /// Shares diagnostic information with additional context.
  /// Useful for including app state or user-provided description.
  Future<Either<AppFailure, Unit>> callWithContext({
    required ErrorEvent errorEvent,
    String? userDescription,
    Map<String, dynamic>? appContext,
  }) async {
    try {
      final buffer = StringBuffer();

      if (userDescription != null && userDescription.isNotEmpty) {
        buffer.writeln('User Description:');
        buffer.writeln(userDescription);
        buffer.writeln();
      }

      buffer.writeln(errorEvent.diagnosticInfo);

      if (appContext != null &&
          appContext.isNotEmpty &&
          errorEvent.wasAnalyticsOptIn) {
        buffer.writeln();
        buffer.writeln('App Context:');
        for (final entry in appContext.entries) {
          buffer.writeln('${entry.key}: ${entry.value}');
        }
      }

      final result = await _shareService.shareText(
        text: buffer.toString(),
        subject: 'AshTrail Error Report (With Context)',
      );

      return result.fold(
        (failure) => left(failure),
        (_) => right(unit),
      );
    } catch (e, st) {
      return left(AppFailure.unexpected(
        message: 'Failed to share diagnostics with context',
        cause: e,
        stackTrace: st,
      ));
    }
  }
}

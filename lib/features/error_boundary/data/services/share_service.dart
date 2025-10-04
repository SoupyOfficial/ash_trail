import 'package:fpdart/fpdart.dart';
import '../../../../core/failures/app_failure.dart';

/// Abstract service for sharing text content using platform-specific sharing mechanisms.
/// On iOS, this should use the native share sheet.
abstract class ShareService {
  /// Shares text content with an optional subject.
  /// Returns success if sharing was initiated, failure if sharing failed.
  Future<Either<AppFailure, Unit>> shareText({
    required String text,
    String? subject,
  });

  /// Shares text content from a specific source rect (for iPad positioning).
  /// Falls back to regular sharing if platform doesn't support positioning.
  Future<Either<AppFailure, Unit>> shareTextFromRect({
    required String text,
    String? subject,
    required double x,
    required double y,
    required double width,
    required double height,
  });
}

/// Platform-specific implementation of ShareService.
/// Uses native iOS share sheet when available.
class PlatformShareService implements ShareService {
  @override
  Future<Either<AppFailure, Unit>> shareText({
    required String text,
    String? subject,
  }) async {
    try {
      // TODO: Implement platform-specific sharing
      // For iOS: Use UIActivityViewController
      // For Android: Use Intent.ACTION_SEND
      // For now, this is a placeholder that logs the share attempt

      // In a real implementation, this would:
      // 1. Check the current platform
      // 2. Use platform channels to invoke native sharing
      // 3. Handle platform-specific errors

      return left(const AppFailure.unexpected(
        message: 'Platform sharing not yet implemented',
      ));
    } catch (e, st) {
      return left(AppFailure.unexpected(
        message: 'Failed to share text',
        cause: e,
        stackTrace: st,
      ));
    }
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
    // For now, fall back to regular sharing
    // iPad-specific positioning can be added later
    return shareText(text: text, subject: subject);
  }
}

/// Debug implementation for testing and development.
/// Logs share attempts instead of actually sharing.
class DebugShareService implements ShareService {
  @override
  Future<Either<AppFailure, Unit>> shareText({
    required String text,
    String? subject,
  }) async {
    // ignore: avoid_print
    print('DEBUG SHARE: ${subject ?? 'No Subject'}');
    // ignore: avoid_print
    print(
        'Content: ${text.length > 100 ? '${text.substring(0, 100)}...' : text}');
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
    // ignore: avoid_print
    print(
        'DEBUG SHARE FROM RECT ($x, $y, $width, $height): ${subject ?? 'No Subject'}');
    return shareText(text: text, subject: subject);
  }
}

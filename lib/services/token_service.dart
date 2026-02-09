import 'dart:convert';
import 'package:http/http.dart' as http;
import '../logging/app_logger.dart';

/// Service to interact with the custom token generation Cloud Function.
///
/// This service enables seamless multi-account switching by generating
/// Firebase custom tokens that can be used with signInWithCustomToken().
/// Custom tokens are valid for 48 hours (Firebase limit).
class TokenService {
  static final _log = AppLogger.logger('TokenService');
  static const String _tokenEndpoint =
      'https://us-central1-smokelog-17303.cloudfunctions.net/generate_refresh_token';

  /// Create a TokenService instance.
  /// This is a stateless service, so creating multiple instances is fine.
  TokenService();

  /// Generate a custom Firebase token valid for 48 hours for the given user ID.
  ///
  /// This calls the Cloud Function which uses Firebase Admin SDK to create
  /// a custom token. The token can be used with FirebaseAuth.signInWithCustomToken()
  /// to authenticate as this user without requiring user interaction.
  ///
  /// Returns a map containing:
  /// - 'customToken': The Firebase custom token string
  /// - 'expiresIn': Token validity in seconds (default 172800 = 48 hours)
  ///
  /// Throws an exception if the Cloud Function call fails.
  Future<Map<String, dynamic>> generateCustomToken(String uid) async {
    final stopwatch = Stopwatch()..start();
    try {
      _log.w('[TOKEN_GEN_START] Requesting custom token for uid=$uid');
      _log.d('[TOKEN_GEN] POST $_tokenEndpoint');

      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uid': uid}),
      );

      stopwatch.stop();
      _log.w(
        '[TOKEN_GEN] Response: HTTP ${response.statusCode} '
        'in ${stopwatch.elapsedMilliseconds}ms, '
        'bodyLength=${response.body.length}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tokenLength = (data['customToken'] as String?)?.length ?? 0;
        final expiresIn = data['expiresIn'] ?? 172800;
        _log.w(
          '[TOKEN_GEN_END] Custom token received: '
          '${tokenLength} chars, expiresIn=${expiresIn}s '
          '(${(expiresIn as int) ~/ 3600}h)',
        );
        return {'customToken': data['customToken'], 'expiresIn': expiresIn};
      } else {
        final errorMsg =
            'Failed to generate custom token: HTTP ${response.statusCode}, ${response.body}';
        _log.e(
          '[TOKEN_GEN_FAIL] $errorMsg (took ${stopwatch.elapsedMilliseconds}ms)',
        );
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (stopwatch.isRunning) stopwatch.stop();
      _log.e(
        '[TOKEN_GEN_FAIL] Error after ${stopwatch.elapsedMilliseconds}ms: '
        'type=${e.runtimeType}',
        error: e,
      );
      rethrow;
    }
  }

  /// Check if the Cloud Function endpoint is reachable.
  ///
  /// This can be used to verify connectivity before attempting token generation.
  Future<bool> isEndpointReachable() async {
    final stopwatch = Stopwatch()..start();
    try {
      _log.d('[TOKEN_HEALTH] Checking endpoint reachability...');
      final response = await http
          .post(
            Uri.parse(_tokenEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'uid': 'connectivity_check'}),
          )
          .timeout(const Duration(seconds: 5));

      stopwatch.stop();
      final reachable = response.statusCode < 500;
      _log.w(
        '[TOKEN_HEALTH] Endpoint ${reachable ? "REACHABLE" : "UNREACHABLE"}: '
        'HTTP ${response.statusCode} in ${stopwatch.elapsedMilliseconds}ms',
      );
      return reachable;
    } catch (e) {
      stopwatch.stop();
      _log.w(
        '[TOKEN_HEALTH] Endpoint UNREACHABLE after ${stopwatch.elapsedMilliseconds}ms',
        error: e,
      );
      return false;
    }
  }
}

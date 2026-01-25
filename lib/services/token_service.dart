import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service to interact with the custom token generation Cloud Function.
///
/// This service enables seamless multi-account switching by generating
/// Firebase custom tokens that can be used with signInWithCustomToken().
/// Custom tokens are valid for 48 hours (Firebase limit).
class TokenService {
  static const String _tokenEndpoint =
      'https://us-central1-smokelog-17303.cloudfunctions.net/generate_refresh_token';

  // Singleton pattern
  static final TokenService _instance = TokenService._internal();
  static TokenService get instance => _instance;

  factory TokenService() => _instance;

  TokenService._internal();

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
    try {
      debugPrint('🔑 [TokenService] Requesting custom token for user: $uid');

      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uid': uid}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('🔑 [TokenService] Custom token received successfully');
        return {
          'customToken': data['customToken'],
          'expiresIn': data['expiresIn'] ?? 172800, // Default 48 hours in seconds
        };
      } else {
        final errorMsg =
            'Failed to generate custom token: HTTP ${response.statusCode}, ${response.body}';
        debugPrint('🔑 [TokenService] ❌ $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('🔑 [TokenService] ❌ Error generating custom token: $e');
      rethrow;
    }
  }

  /// Check if the Cloud Function endpoint is reachable.
  ///
  /// This can be used to verify connectivity before attempting token generation.
  Future<bool> isEndpointReachable() async {
    try {
      // Just check if we can reach the endpoint (OPTIONS or HEAD would be better but
      // Cloud Functions may not support them, so we'll just catch errors on POST)
      final response = await http
          .post(
            Uri.parse(_tokenEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'uid': 'connectivity_check'}),
          )
          .timeout(const Duration(seconds: 5));

      // Even a 400 error means the endpoint is reachable
      return response.statusCode < 500;
    } catch (e) {
      debugPrint('🔑 [TokenService] Endpoint not reachable: $e');
      return false;
    }
  }
}

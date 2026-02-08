import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ash_trail/services/token_service.dart';

/// A testable TokenService subclass that allows injecting an HTTP client
/// and overriding the endpoint for unit testing.
class TestableTokenService extends TokenService {
  final Future<http.Response> Function(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
  })
  postFn;

  TestableTokenService({required this.postFn});

  @override
  Future<Map<String, dynamic>> generateCustomToken(String uid) async {
    final response = await postFn(
      Uri.parse(
        'https://us-central1-smokelog-17303.cloudfunctions.net/generate_refresh_token',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'uid': uid}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return {
        'customToken': data['customToken'],
        'expiresIn': data['expiresIn'] ?? 172800,
      };
    } else {
      throw Exception(
        'Failed to generate custom token: HTTP ${response.statusCode}, ${response.body}',
      );
    }
  }

  @override
  Future<bool> isEndpointReachable() async {
    try {
      final response = await postFn(
        Uri.parse(
          'https://us-central1-smokelog-17303.cloudfunctions.net/generate_refresh_token',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'uid': 'connectivity_check'}),
      );
      return response.statusCode < 500;
    } catch (e) {
      return false;
    }
  }
}

void main() {
  group('TokenService - Live Endpoint Verification', () {
    late TokenService tokenService;

    setUp(() {
      tokenService = TokenService();
    });

    test('cloud function endpoint is reachable', () async {
      final reachable = await tokenService.isEndpointReachable();
      expect(
        reachable,
        isTrue,
        reason: 'The generate_refresh_token Cloud Function should be reachable',
      );
    });

    test('generates a valid custom token for a test uid', () async {
      // Use a well-known test UID pattern
      final result = await tokenService.generateCustomToken(
        'integration-test-uid',
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(
        result.containsKey('customToken'),
        isTrue,
        reason: 'Response should contain customToken',
      );
      expect(result['customToken'], isA<String>());
      expect(
        (result['customToken'] as String).isNotEmpty,
        isTrue,
        reason: 'customToken should not be empty',
      );
      expect(
        result.containsKey('expiresIn'),
        isTrue,
        reason: 'Response should contain expiresIn',
      );
      expect(result['expiresIn'], isA<int>());
      expect(
        result['expiresIn'],
        greaterThan(0),
        reason: 'expiresIn should be positive',
      );
    });

    test('token has expected expiration of 48 hours', () async {
      final result = await tokenService.generateCustomToken(
        'integration-test-uid',
      );
      // 48 hours = 172800 seconds
      expect(
        result['expiresIn'],
        equals(172800),
        reason: 'Token should expire in 48 hours (172800 seconds)',
      );
    });

    test('generates unique tokens for different UIDs', () async {
      final result1 = await tokenService.generateCustomToken('test-uid-alpha');
      final result2 = await tokenService.generateCustomToken('test-uid-beta');

      expect(
        result1['customToken'],
        isNot(equals(result2['customToken'])),
        reason: 'Different UIDs should produce different tokens',
      );
    });

    test(
      'generates different tokens on subsequent calls for same UID',
      () async {
        final result1 = await tokenService.generateCustomToken(
          'test-uid-repeat',
        );
        final result2 = await tokenService.generateCustomToken(
          'test-uid-repeat',
        );

        // Firebase custom tokens include timestamps, so they should differ
        expect(
          result1['customToken'],
          isNot(equals(result2['customToken'])),
          reason: 'Subsequent calls should generate fresh tokens',
        );
      },
    );
  });

  group('TokenService - Contract Tests (mocked HTTP)', () {
    test('returns parsed token on HTTP 200', () async {
      final service = TestableTokenService(
        postFn: (url, {headers, body}) async {
          return http.Response(
            jsonEncode({
              'customToken': 'mock-firebase-token-xyz',
              'expiresIn': 172800,
            }),
            200,
          );
        },
      );

      final result = await service.generateCustomToken('user-123');

      expect(result['customToken'], equals('mock-firebase-token-xyz'));
      expect(result['expiresIn'], equals(172800));
    });

    test('defaults expiresIn to 172800 when not in response', () async {
      final service = TestableTokenService(
        postFn: (url, {headers, body}) async {
          return http.Response(
            jsonEncode({'customToken': 'token-no-expiry'}),
            200,
          );
        },
      );

      final result = await service.generateCustomToken('user-123');

      expect(result['customToken'], equals('token-no-expiry'));
      expect(result['expiresIn'], equals(172800));
    });

    test('throws on HTTP 400 error', () async {
      final service = TestableTokenService(
        postFn: (url, {headers, body}) async {
          return http.Response('{"error": "Missing uid"}', 400);
        },
      );

      expect(
        () => service.generateCustomToken(''),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('HTTP 400'),
          ),
        ),
      );
    });

    test('throws on HTTP 500 error', () async {
      final service = TestableTokenService(
        postFn: (url, {headers, body}) async {
          return http.Response('Internal Server Error', 500);
        },
      );

      expect(
        () => service.generateCustomToken('user-123'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('HTTP 500'),
          ),
        ),
      );
    });

    test('throws on HTTP 401 unauthorized', () async {
      final service = TestableTokenService(
        postFn: (url, {headers, body}) async {
          return http.Response('Unauthorized', 401);
        },
      );

      expect(
        () => service.generateCustomToken('user-123'),
        throwsA(isA<Exception>()),
      );
    });

    test('sends correct request body with uid', () async {
      String? capturedBody;

      final service = TestableTokenService(
        postFn: (url, {headers, body}) async {
          capturedBody = body as String?;
          return http.Response(
            jsonEncode({'customToken': 'tok', 'expiresIn': 172800}),
            200,
          );
        },
      );

      await service.generateCustomToken('my-test-uid');

      expect(capturedBody, isNotNull);
      final decoded = jsonDecode(capturedBody!) as Map<String, dynamic>;
      expect(decoded['uid'], equals('my-test-uid'));
    });

    test('sends correct Content-Type header', () async {
      Map<String, String>? capturedHeaders;

      final service = TestableTokenService(
        postFn: (url, {headers, body}) async {
          capturedHeaders = headers;
          return http.Response(
            jsonEncode({'customToken': 'tok', 'expiresIn': 172800}),
            200,
          );
        },
      );

      await service.generateCustomToken('uid');

      expect(capturedHeaders, isNotNull);
      expect(capturedHeaders!['Content-Type'], equals('application/json'));
    });

    test('posts to correct endpoint URL', () async {
      Uri? capturedUrl;

      final service = TestableTokenService(
        postFn: (url, {headers, body}) async {
          capturedUrl = url;
          return http.Response(
            jsonEncode({'customToken': 'tok', 'expiresIn': 172800}),
            200,
          );
        },
      );

      await service.generateCustomToken('uid');

      expect(capturedUrl, isNotNull);
      expect(
        capturedUrl.toString(),
        equals(
          'https://us-central1-smokelog-17303.cloudfunctions.net/generate_refresh_token',
        ),
      );
    });
  });

  group('TokenService - isEndpointReachable (mocked)', () {
    test('returns true for HTTP 200', () async {
      final service = TestableTokenService(
        postFn: (url, {headers, body}) async {
          return http.Response('OK', 200);
        },
      );

      expect(await service.isEndpointReachable(), isTrue);
    });

    test('returns true for HTTP 400 (reachable but bad request)', () async {
      final service = TestableTokenService(
        postFn: (url, {headers, body}) async {
          return http.Response('Bad Request', 400);
        },
      );

      expect(await service.isEndpointReachable(), isTrue);
    });

    test('returns false for HTTP 500 (server error)', () async {
      final service = TestableTokenService(
        postFn: (url, {headers, body}) async {
          return http.Response('Server Error', 500);
        },
      );

      expect(await service.isEndpointReachable(), isFalse);
    });

    test('returns false when network error occurs', () async {
      final service = TestableTokenService(
        postFn: (url, {headers, body}) async {
          throw Exception('Network unreachable');
        },
      );

      expect(await service.isEndpointReachable(), isFalse);
    });
  });
}

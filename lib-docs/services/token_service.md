# token_service

> **Source:** `lib/services/token_service.dart`

## Purpose

Stateless HTTP client that calls a Firebase Cloud Function endpoint to generate custom authentication tokens for multi-account switching. Also provides a health-check method to verify endpoint reachability before attempting token generation.

## Dependencies

- `dart:convert` — JSON encoding/decoding
- `package:http/http.dart` — HTTP POST/GET requests
- `../logging/app_logger.dart` — Structured logging via `AppLogger`

## Pseudo-Code

### Class: TokenService

#### Constants
- `_endpoint` = `'https://us-central1-smokelog-17303.cloudfunctions.net/generate_refresh_token'`

#### Fields
- `_log` — static logger tagged `'TokenService'`

---

#### `generateCustomToken(String uid) → Future<Map<String, dynamic>?>`

```
LOG [TOKEN] Requesting custom token for uid

TRY:
  response = AWAIT http.POST(
    _endpoint,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.encode({ 'uid': uid })
  )

  IF response.statusCode == 200:
    data = JSON.decode(response.body)
    // Expected: { "customToken": "...", "expiresIn": 172800 }
    LOG [TOKEN] Token generated successfully
    RETURN data
  ELSE:
    LOG ERROR [TOKEN] Failed: status=${response.statusCode}, body=${response.body}
    RETURN null

CATCH e:
  LOG ERROR [TOKEN] Exception generating token: $e
  RETURN null
```

---

#### `isEndpointReachable() → Future<bool>`

```
TRY:
  response = AWAIT http.GET(
    _endpoint,
    timeout: 5 seconds
  )
  RETURN response.statusCode < 500    // 2xx/4xx = reachable, 5xx = down
CATCH e:
  LOG WARNING [TOKEN] Endpoint unreachable: $e
  RETURN false
```

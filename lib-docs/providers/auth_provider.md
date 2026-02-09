# auth_provider

> **Source:** `lib/providers/auth_provider.dart`

## Purpose

Riverpod providers for Firebase authentication state. Exposes the `AuthService` singleton and derived providers for auth state stream, authentication status, current user ID, email, and display name.

## Dependencies

- `package:firebase_auth/firebase_auth.dart` — Firebase User type
- `package:flutter_riverpod/flutter_riverpod.dart` — Provider, StreamProvider
- `../services/auth_service.dart` — AuthService wrapper

## Pseudo-Code

### Providers

```
PROVIDER authServiceProvider -> AuthService
  RETURN new AuthService()
END

STREAM_PROVIDER authStateProvider -> User?
  READ authService from authServiceProvider
  RETURN authService.authStateChanges    // Firebase auth state stream
END

PROVIDER isAuthenticatedProvider -> bool
  WATCH authStateProvider
  RETURN authState has data AND user != null
  DEFAULT false
END

PROVIDER currentUserIdProvider -> String?
  WATCH authStateProvider
  RETURN user?.uid if data available
  DEFAULT null
END

PROVIDER currentUserEmailProvider -> String?
  WATCH authStateProvider
  RETURN user?.email if data available
  DEFAULT null
END

PROVIDER currentUserDisplayNameProvider -> String?
  WATCH authStateProvider
  RETURN user?.displayName if data available
  DEFAULT null
END
```

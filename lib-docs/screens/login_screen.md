# login_screen

> **Source:** `lib/screens/login_screen.dart`

## Purpose

Authentication landing screen offering email/password, Google, and Apple sign-in methods. On success, pops back to root so the AuthWrapper rebuilds and shows the home screen. All errors are wrapped as `AppError` and reported via `ErrorReportingService`.

## Dependencies

- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter_riverpod/flutter_riverpod.dart` — State management
- `../logging/app_logger.dart` — Structured logging (`AppLogger`)
- `../models/app_error.dart` — `AppError.from(e, st)` for typed error wrapping
- `../services/account_integration_service.dart` — `accountIntegrationServiceProvider`
- `../services/error_reporting_service.dart` — `ErrorReportingService.instance.report()`
- `../widgets/auth_button.dart` — `AuthButton`, `AuthButtonType`
- `signup_screen.dart` — `SignupScreen`

## Pseudo-Code

### Class: LoginScreen (ConsumerStatefulWidget)

### Class: _LoginScreenState

#### Fields

```
  _log: AppLogger (tagged 'LoginScreen')
  _formKey: GlobalKey<FormState>
  _emailController: TextEditingController
  _passwordController: TextEditingController
  _isLoading: bool = false
  _obscurePassword: bool = true
  _errorMessage: String?
```

#### `dispose()`

```
DISPOSE _emailController, _passwordController
```

---

#### `_signInWithEmail()` -> Future<void>

```
IF form invalid -> RETURN

SET _isLoading = true, _errorMessage = null

TRY:
  integrationService = ref.read(accountIntegrationServiceProvider)
  AWAIT integrationService.signInWithEmail(email, password)
  IF mounted -> Navigator.popUntil(isFirst)

CATCH (e, st):
  appError = AppError.from(e, st)
  ErrorReportingService.instance.report(appError, stackTrace: st,
    context: 'LoginScreen.signInWithEmail')
  SET _errorMessage = appError.message, _isLoading = false
```

#### `_signInWithGoogle()` -> Future<void>

```
LOG '[LOGIN_SCREEN] User tapped Google sign-in button'
SET _isLoading = true, _errorMessage = null

TRY:
  integrationService = ref.read(accountIntegrationServiceProvider)
  LOG 'Calling integrationService.signInWithGoogle()'
  account = AWAIT integrationService.signInWithGoogle()
  LOG 'Google sign-in SUCCESS: uid, email, provider'
  IF mounted -> Navigator.popUntil(isFirst)

CATCH (e, st):
  LOG '[LOGIN_SCREEN] Google sign-in FAILED'
  appError = AppError.from(e, st)
  ErrorReportingService.instance.report(appError, stackTrace: st,
    context: 'LoginScreen.signInWithGoogle')
  SET _errorMessage = appError.message, _isLoading = false
```

#### `_signInWithApple()` -> Future<void>

```
SET _isLoading = true, _errorMessage = null

TRY:
  integrationService = ref.read(accountIntegrationServiceProvider)
  AWAIT integrationService.signInWithApple()
  IF mounted -> Navigator.popUntil(isFirst)

CATCH (e, st):
  appError = AppError.from(e, st)
  ErrorReportingService.instance.report(appError, stackTrace: st,
    context: 'LoginScreen.signInWithApple')
  SET _errorMessage = appError.message, _isLoading = false
```

#### `_navigateToSignup()`

```
Navigator.push -> MaterialPageRoute(
  settings: RouteSettings(name: 'SignupScreen'),
  builder: SignupScreen()
)
```

---

#### `build(context)` -> Widget

```
Scaffold -> SafeArea -> Center -> SingleChildScrollView(padding: 24) ->
  ConstrainedBox(maxWidth: 400) -> Form(key: _formKey) -> Column:

    // Branding
    Icon(local_fire_department, size: 80, primary)
    'Ash Trail' (headlineLarge, bold)
    'Track your journey' (bodyLarge, muted)

    // Inline error banner
    IF _errorMessage != null ->
      Container(errorContainer bg, rounded) -> Text(_errorMessage)

    // Email input (Key: 'email-input')
    TextFormField(email, prefixIcon, validator: non-empty + contains '@')

    // Password input (Key: 'password-input')
    TextFormField(obscure, toggle suffix, onFieldSubmitted -> _signInWithEmail)

    // Primary login
    ElevatedButton(Key: 'login-button', onPressed: _signInWithEmail)
      IF _isLoading -> CircularProgressIndicator(strokeWidth: 2)
      ELSE -> 'Log In'

    // OR divider
    Row(Divider -- 'OR' -- Divider)

    // Social sign-in
    AuthButton(text: 'Continue with Google', type: google, isLoading)
    AuthButton(text: 'Continue with Apple', type: apple, isLoading)

    // Navigation
    Row: "Don't have an account?" + TextButton('Sign Up') -> _navigateToSignup
    TextButton('Forgot Password?') -> SnackBar 'coming soon' (TODO)
```

## Notes

- All three sign-in catch blocks follow the same pattern: `AppError.from(e, st)` -> `ErrorReportingService.instance.report()` -> show `appError.message` in UI.
- Google sign-in has additional diagnostic logging at warning level for TestFlight debugging.
- The `accountIntegrationServiceProvider` is used (not `AuthService` directly) to ensure account creation and sync happen atomically with login.
- Forgot Password is a placeholder (shows a SnackBar "Password reset coming soon!").
- All inputs are disabled while `_isLoading` is true to prevent double submission.

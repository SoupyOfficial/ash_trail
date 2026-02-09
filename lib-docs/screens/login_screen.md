# login_screen

> **Source:** `lib/screens/login_screen.dart`

## Purpose

Authentication screen for signing into existing accounts via email/password, Google, or Apple sign-in. On successful authentication, pops all navigation back to the root so `AuthWrapper` can rebuild and show the Home screen. Provides a link to the Signup screen and a placeholder for forgot-password functionality.

## Dependencies

- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter_riverpod/flutter_riverpod.dart` — Riverpod state management
- `../logging/app_logger.dart` — Structured logging (`AppLogger`)
- `../services/account_integration_service.dart` — `accountIntegrationServiceProvider` (signInWithEmail, signInWithGoogle, signInWithApple)
- `../widgets/auth_button.dart` — `AuthButton`, `AuthButtonType` (styled social auth buttons)
- `signup_screen.dart` — Navigation target for new account creation

## Pseudo-Code

### Class: LoginScreen (ConsumerStatefulWidget)

Creates `_LoginScreenState`.

### Class: _LoginScreenState (ConsumerState)

#### State

```
_log:                AppLogger('LoginScreen')
_formKey:            GlobalKey<FormState>
_emailController:    TextEditingController
_passwordController: TextEditingController
_isLoading:          bool = false
_obscurePassword:    bool = true
_errorMessage:       String? = null
```

#### Lifecycle: dispose()

```
_emailController.dispose()
_passwordController.dispose()
```

#### Method: _signInWithEmail() -> Future<void>

```
IF !_formKey.currentState!.validate() -> RETURN

SET _isLoading = true, _errorMessage = null

TRY:
  integrationService = ref.read(accountIntegrationServiceProvider)
  AWAIT integrationService.signInWithEmail(email: trimmed, password: raw)
  IF mounted -> Navigator.popUntil(isFirst)   // back to auth wrapper
CATCH:
  SET _errorMessage = e.toString(), _isLoading = false
```

#### Method: _signInWithGoogle() -> Future<void>

```
LOG "User tapped Google sign-in button"
SET _isLoading = true, _errorMessage = null

TRY:
  integrationService = ref.read(accountIntegrationServiceProvider)
  account = AWAIT integrationService.signInWithGoogle()
  LOG success with uid, email, provider
  IF mounted -> Navigator.popUntil(isFirst)
CATCH:
  LOG error
  SET _errorMessage = e.toString(), _isLoading = false
```

#### Method: _signInWithApple() -> Future<void>

```
SET _isLoading = true, _errorMessage = null

TRY:
  integrationService = ref.read(accountIntegrationServiceProvider)
  AWAIT integrationService.signInWithApple()
  IF mounted -> Navigator.popUntil(isFirst)
CATCH:
  SET _errorMessage = e.toString(), _isLoading = false
```

#### Method: _navigateToSignup() -> void

```
Navigator.push(SignupScreen)
```

#### Method: build(context) -> Widget

```
RETURN Scaffold (no appBar):
  body = SafeArea:
    Center:
      SingleChildScrollView (padding 24):
        ConstrainedBox (maxWidth 400):
          Form (key: _formKey):
            Column (center, stretch):

              [1] LOGO / TITLE
                Icon: local_fire_department (80, primary)
                "Ash Trail" headlineLarge bold
                "Track your journey" bodyLarge

              [2] ERROR MESSAGE (conditional)
                IF _errorMessage != null:
                  Container (errorContainer bg, rounded 8):
                    Text(_errorMessage, onErrorContainer color)

              [3] EMAIL FIELD
                TextFormField (key: email-input):
                  controller = _emailController
                  labelText = "Email", prefixIcon = email
                  keyboardType = emailAddress, textInputAction = next
                  enabled = !_isLoading
                  validator: required, must contain '@'

              [4] PASSWORD FIELD
                TextFormField (key: password-input):
                  controller = _passwordController
                  labelText = "Password", prefixIcon = lock
                  suffixIcon = visibility toggle -> toggle _obscurePassword
                  obscureText = _obscurePassword
                  textInputAction = done
                  enabled = !_isLoading
                  onFieldSubmitted -> _signInWithEmail()
                  validator: required

              [5] LOGIN BUTTON
                ElevatedButton (key: login-button):
                  onPressed = !_isLoading ? _signInWithEmail : null
                  child = _isLoading ? CircularProgressIndicator : "Log In"

              [6] "OR" DIVIDER
                Row: Divider — "OR" — Divider

              [7] SOCIAL AUTH BUTTONS
                AuthButton("Continue with Google",  _signInWithGoogle, google, _isLoading)
                AuthButton("Continue with Apple",   _signInWithApple,  apple,  _isLoading)

              [8] SIGN UP LINK
                Row: "Don't have an account?" + TextButton "Sign Up" -> _navigateToSignup()

              [9] FORGOT PASSWORD
                TextButton "Forgot Password?":
                  onPressed -> SnackBar "Password reset coming soon!"  // TODO
```

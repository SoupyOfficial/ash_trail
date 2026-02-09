# signup_screen

> **Source:** `lib/screens/signup_screen.dart`

## Purpose

Account creation screen for new users via email/password registration (with optional username), Google sign-in, or Apple sign-in. On successful account creation, pops all navigation back to the root so `AuthWrapper` can rebuild and show the Home screen. Includes client-side form validation for email format and password strength.

## Dependencies

- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter_riverpod/flutter_riverpod.dart` — Riverpod state management
- `../services/account_integration_service.dart` — `accountIntegrationServiceProvider` (signUpWithEmail, signInWithGoogle, signInWithApple)
- `../widgets/auth_button.dart` — `AuthButton`, `AuthButtonType` (styled social auth buttons)

## Pseudo-Code

### Class: SignupScreen (ConsumerStatefulWidget)

Creates `_SignupScreenState`.

### Class: _SignupScreenState (ConsumerState)

#### State

```
_formKey:                   GlobalKey<FormState>
_emailController:           TextEditingController
_usernameController:        TextEditingController
_passwordController:        TextEditingController
_confirmPasswordController: TextEditingController
_isLoading:                 bool = false
_obscurePassword:           bool = true
_obscureConfirmPassword:    bool = true
_errorMessage:              String? = null
```

#### Lifecycle: dispose()

```
dispose all 4 controllers
```

#### Method: _signUpWithEmail() -> Future<void>

```
IF !_formKey.currentState!.validate() -> RETURN

SET _isLoading = true, _errorMessage = null

TRY:
  integrationService = ref.read(accountIntegrationServiceProvider)
  AWAIT integrationService.signUpWithEmail(
    email:       trimmed email,
    password:    raw password,
    displayName: trimmed username
  )
  IF mounted -> Navigator.popUntil(isFirst)   // back to auth wrapper
CATCH:
  SET _errorMessage = e.toString(), _isLoading = false
```

#### Method: _signInWithGoogle() -> Future<void>

```
SET _isLoading = true, _errorMessage = null

TRY:
  integrationService = ref.read(accountIntegrationServiceProvider)
  AWAIT integrationService.signInWithGoogle()
  IF mounted -> Navigator.popUntil(isFirst)
CATCH:
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

#### Method: build(context) -> Widget

```
RETURN Scaffold:
  appBar = AppBar(title: "Create Account")

  body = SafeArea:
    Center:
      SingleChildScrollView (padding 24):
        ConstrainedBox (maxWidth 400):
          Form (key: _formKey):
            Column (center, stretch):

              [1] LOGO / TITLE
                Icon: local_fire_department (64, primary)
                "Join Ash Trail" headlineMedium bold

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
                  validator:
                    IF empty -> "Please enter your email"
                    IF missing '@' -> "Please enter a valid email"

              [4] USERNAME FIELD (optional)
                TextFormField (key: username-input):
                  controller = _usernameController
                  labelText = "Username (optional)", prefixIcon = person
                  textInputAction = next
                  enabled = !_isLoading
                  // no validator — optional field

              [5] PASSWORD FIELD
                TextFormField (key: password-input):
                  controller = _passwordController
                  labelText = "Password", prefixIcon = lock
                  suffixIcon = visibility toggle -> toggle _obscurePassword
                  obscureText = _obscurePassword
                  textInputAction = next
                  enabled = !_isLoading
                  helperText = "At least 8 characters with a number"
                  validator:
                    IF empty -> "Please enter a password"
                    IF length < 8 -> "Password must be at least 8 characters"
                    IF no digit (regex [0-9]) -> "Must contain at least one number"

              [6] CONFIRM PASSWORD FIELD
                TextFormField (key: confirm-password-input):
                  controller = _confirmPasswordController
                  labelText = "Confirm Password", prefixIcon = lock_outline
                  suffixIcon = visibility toggle -> toggle _obscureConfirmPassword
                  obscureText = _obscureConfirmPassword
                  textInputAction = done
                  enabled = !_isLoading
                  onFieldSubmitted -> _signUpWithEmail()
                  validator:
                    IF empty -> "Please confirm your password"
                    IF != _passwordController.text -> "Passwords do not match"

              [7] SIGN UP BUTTON
                ElevatedButton (key: signup-button):
                  onPressed = !_isLoading ? _signUpWithEmail : null
                  child = _isLoading ? CircularProgressIndicator : "Sign Up"

              [8] "OR" DIVIDER
                Row: Divider — "OR" — Divider

              [9] SOCIAL AUTH BUTTONS
                AuthButton("Continue with Google", _signInWithGoogle, google, _isLoading)
                AuthButton("Continue with Apple",  _signInWithApple,  apple,  _isLoading)

              [10] TERMS / PRIVACY
                Text (centered, faded):
                  "By signing up, you agree to our Terms of Service and Privacy Policy"
```

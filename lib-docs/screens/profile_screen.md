# profile_screen

> **Source:** `lib/screens/profile_screen.dart`

## Purpose

Profile management screen for viewing and editing account information (display name, email), changing passwords (for email/password users), and deleting the account. Uses Firebase Auth state directly via `authStateProvider` for reading current user data and `accountIntegrationServiceProvider` for mutations.

## Dependencies

- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter_riverpod/flutter_riverpod.dart` — Riverpod state management
- `../providers/auth_provider.dart` — `authStateProvider` (Firebase User stream)
- `../services/account_integration_service.dart` — `accountIntegrationServiceProvider` (updateProfile, updateEmail, changePassword, deleteAccount)

## Pseudo-Code

### Class: ProfileScreen (ConsumerStatefulWidget)

Creates `_ProfileScreenState`.

### Class: _ProfileScreenState (ConsumerState)

#### State

```
_displayNameController:    TextEditingController
_emailController:          TextEditingController
_currentPasswordController: TextEditingController
_newPasswordController:     TextEditingController
_confirmPasswordController: TextEditingController

_isEditing:          bool = false
_isLoading:          bool = false
_isChangingPassword: bool = false
_errorMessage:       String? = null
_successMessage:     String? = null
```

#### Lifecycle: initState()

```
super.initState()
_loadUserData()
```

#### Lifecycle: dispose()

```
dispose all 5 controllers
```

#### Method: _loadUserData() -> void

```
authState = ref.read(authStateProvider)
authState.whenData((user):
  IF user != null:
    _displayNameController.text = user.displayName ?? ''
    _emailController.text = user.email ?? ''
)
```

#### Method: _updateProfile() -> Future<void>

```
SET _isLoading = true, clear messages

TRY:
  integrationService = ref.read(accountIntegrationServiceProvider)
  AWAIT integrationService.updateProfile(
    displayName: trimmed or null if empty
  )
  SET _isEditing = false, _successMessage = "Profile updated successfully"
CATCH:
  SET _errorMessage = e.toString()
FINALLY:
  SET _isLoading = false
```

#### Method: _updateEmail() -> Future<void>

```
newEmail = _emailController.text.trim()
IF empty or missing '@' -> SET _errorMessage, RETURN

SET _isLoading = true, clear messages

TRY:
  AWAIT integrationService.updateEmail(newEmail)
  SET _isEditing = false
  SET _successMessage = "Email updated. Please verify your new email."
CATCH:
  SET _errorMessage = e.toString()
FINALLY:
  SET _isLoading = false
```

#### Method: _changePassword() -> Future<void>

```
VALIDATE:
  current password not empty
  new password >= 8 chars
  new password == confirm password

SET _isLoading = true, clear messages

TRY:
  AWAIT integrationService.changePassword(currentPassword, newPassword)
  SET _isChangingPassword = false
  CLEAR all 3 password controllers
  SET _successMessage = "Password changed successfully"
CATCH:
  SET _errorMessage = e.toString()
FINALLY:
  SET _isLoading = false
```

#### Method: _deleteAccount() -> Future<void>

```
STEP 1: SHOW AlertDialog "Delete Account"
  "Are you sure? This action cannot be undone."
  Cancel / "Delete Account" (red)

IF not confirmed -> RETURN

STEP 2: SHOW password confirmation dialog
  TextField (obscureText, "Password")
  Cancel / "Confirm" (red)

IF password empty -> RETURN

SET _isLoading = true, _errorMessage = null

TRY:
  AWAIT integrationService.deleteAccount(password)
  // User auto-logged out via auth state change
CATCH:
  SET _errorMessage, _isLoading = false
```

#### Method: build(context) -> Widget

```
WATCH authState = ref.watch(authStateProvider)

RETURN Scaffold:
  appBar = AppBar(title: "Profile"):
    actions:
      IF !_isEditing AND !_isChangingPassword:
        IconButton (edit) -> SET _isEditing = true, clear messages

  body = authState.when:
    data(user):
      IF user == null -> "Not logged in"

      SingleChildScrollView (padding 16):
        Column (stretch):

          [1] PROFILE PHOTO
            Center: Stack:
              CircleAvatar (radius 60):
                IF photoURL -> NetworkImage
                ELSE -> first letter of name/email (fontSize 48)
              IF _isEditing:
                Positioned camera button -> SnackBar "Photo upload coming soon!"

          [2] SUCCESS / ERROR MESSAGES (conditional)
            green container for success
            errorContainer for error

          [3] ACCOUNT INFORMATION CARD
            TextField "Display Name" (editable if _isEditing)
            TextField "Email" (editable if _isEditing, helper: "requires re-verification")
            TextField "User ID" (always disabled, shows user.uid)

            Wrap of provider Chips:
              FOR EACH providerData:
                google.com -> Google chip
                password   -> Email/Password chip
                default    -> providerId chip

            IF _isEditing:
              Row:
                OutlinedButton "Cancel" -> reset editing, reload data
                ElevatedButton "Save":
                  onPressed -> _updateProfile()
                  IF email changed -> _updateEmail()
                  Shows spinner while loading

          [4] CHANGE PASSWORD CARD (only for email/password providers)
            IF !_isChangingPassword:
              ElevatedButton.icon "Change Password" -> toggle _isChangingPassword
            ELSE:
              TextField "Current Password" (obscured)
              TextField "New Password" (obscured, helper: >=8 chars)
              TextField "Confirm New Password" (obscured)
              Row:
                OutlinedButton "Cancel" -> reset, clear controllers
                ElevatedButton "Update Password" -> _changePassword()

          [5] DANGER ZONE CARD (red tinted)
            Title: "Danger Zone" (red)
            "Once you delete your account, there is no going back."
            OutlinedButton.icon "Delete Account" (red border) -> _deleteAccount()

    loading -> CircularProgressIndicator
    error   -> "Error: $error"
```

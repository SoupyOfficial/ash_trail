# Account CRUD Operations Guide

## Complete Account Management Implementation ✅

AshTrail now supports full **Create, Read, Update, Delete (CRUD)** operations for user accounts and profile information.

---

## Features Implemented

### 1. **Create (C)** - Account Creation ✅
- Sign up with email/password
- Sign up with Google
- Automatic local account record creation
- Email validation and password requirements

**Location:** [login_screen.dart](lib/screens/login_screen.dart), [signup_screen.dart](lib/screens/signup_screen.dart)

**Test Keys:**
- `email-input`
- `username-input`
- `password-input`
- `confirm-password-input`
- `signup-button`

---

### 2. **Read (R)** - View Account Information ✅
- View profile information
- Display name
- Email address
- User ID (Firebase UID)
- Profile photo (if set)
- Authentication providers (Google, Email/Password)
- Account metadata

**Location:** [profile_screen.dart](lib/screens/profile_screen.dart)

**Access:** Accounts Screen → Profile Icon (top right)

---

### 3. **Update (U)** - Edit Account Information ✅

#### Update Profile
- ✅ Change display name
- ✅ Update profile photo (UI ready, upload pending)
- ✅ Changes sync to Firebase and local database
- ✅ Real-time validation

#### Update Email
- ✅ Change email address
- ✅ Requires email verification
- ✅ Security confirmation required
- ✅ Updates all sessions

#### Change Password
- ✅ Available for email/password accounts
- ✅ Requires current password verification
- ✅ Password strength requirements enforced
- ✅ Secure re-authentication

**Location:** [profile_screen.dart](lib/screens/profile_screen.dart)

---

### 4. **Delete (D)** - Account Deletion ✅
- ✅ Permanent account deletion
- ✅ Two-step confirmation process
- ✅ Password re-authentication required
- ✅ Deletes Firebase Auth account
- ✅ Deletes all local data
- ✅ Cannot be undone - user warned

**Location:** [profile_screen.dart](lib/screens/profile_screen.dart) - Danger Zone section

---

## Architecture

### Services Layer

#### [auth_service.dart](lib/services/auth_service.dart)
Core Firebase Auth operations:
- `signUpWithEmail()` - Create new account
- `signInWithEmail()` - Authenticate existing user
- `signInWithGoogle()` - Google OAuth
- `updateProfile()` - Update display name/photo
- `updateEmail()` - Change email address
- `changePassword()` - Update password with re-auth
- `deleteAccount()` - Remove account permanently
- `signOut()` - End session

#### [account_integration_service.dart](lib/services/account_integration_service.dart)
Syncs Firebase Auth with local Account records:
- `syncAccountFromFirebaseUser()` - Create/update local Account
- `signUpWithEmail()` - Create Firebase user + local Account
- `signInWithEmail()` - Authenticate + sync local Account
- `signInWithGoogle()` - Google auth + sync local Account
- `updateProfile()` - Update Firebase + sync local
- `updateEmail()` - Update Firebase + sync local
- `changePassword()` - Update Firebase password
- `deleteAccount()` - Delete Firebase account + local data
- `signOut()` - Sign out Firebase + deactivate local

#### [account_service.dart](lib/services/account_service.dart)
Local Account database operations:
- `getAllAccounts()` - Fetch all accounts
- `getActiveAccount()` - Get current account
- `getAccountByUserId()` - Find by Firebase UID
- `saveAccount()` - Create or update
- `setActiveAccount()` - Mark as active
- `deleteAccount()` - Remove account and data
- `watchActiveAccount()` - Real-time updates
- `watchAllAccounts()` - Real-time list

---

## User Flow

### Profile Management Flow

```
1. User navigates to Accounts Screen
2. Clicks Profile icon (top right)
3. Views Profile Screen with:
   - Avatar/photo
   - Display name
   - Email
   - User ID
   - Auth providers

4. Click Edit button to enable editing
5. Make changes:
   - Update display name
   - Change email (requires verification)
   - Upload new photo (coming soon)

6. Click Save → Changes applied
7. Success message shown

8. Optional: Change Password
   - Enter current password
   - Enter new password (8+ chars)
   - Confirm new password
   - Click Update Password

9. Optional: Delete Account
   - Click Delete Account in Danger Zone
   - Confirm deletion intent
   - Enter password for verification
   - Account permanently deleted
   - Automatic logout and redirect
```

---

## UI Components

### Profile Screen Layout

```
┌─────────────────────────────────────┐
│  Profile                 [Edit] 🎨  │
├─────────────────────────────────────┤
│                                     │
│          ┌─────────┐                │
│          │ Avatar  │  📷           │
│          └─────────┘                │
│                                     │
│  ╔═══════════════════════════════╗ │
│  ║ Account Information           ║ │
│  ╠═══════════════════════════════╣ │
│  ║ Display Name: [____________]  ║ │
│  ║ Email:        [____________]  ║ │
│  ║ User ID:      abc123 (locked) ║ │
│  ║ Providers:    [Email] [Google]║ │
│  ║                               ║ │
│  ║     [Cancel]  [Save]          ║ │
│  ╚═══════════════════════════════╝ │
│                                     │
│  ╔═══════════════════════════════╗ │
│  ║ Change Password               ║ │
│  ╠═══════════════════════════════╣ │
│  ║ [Change Password Button]      ║ │
│  ╚═══════════════════════════════╝ │
│                                     │
│  ╔═══════════════════════════════╗ │
│  ║ ⚠️  Danger Zone                ║ │
│  ╠═══════════════════════════════╣ │
│  ║ Once you delete your account, ║ │
│  ║ there is no going back.       ║ │
│  ║                               ║ │
│  ║ [🗑️  Delete Account]          ║ │
│  ╚═══════════════════════════════╝ │
└─────────────────────────────────────┘
```

---

## Security Features

### Re-authentication
Sensitive operations require password re-authentication:
- ✅ Email updates
- ✅ Password changes
- ✅ Account deletion

### Validation
- Email format validation
- Password strength requirements (8+ chars, must include number)
- Confirm password matching
- Display name sanitization

### Error Handling
Comprehensive error messages for:
- Network failures
- Invalid credentials
- Weak passwords
- Email already in use
- User not found
- Too many requests
- Operation not allowed

---

## Testing

### Manual Testing Checklist

#### Create Account
- [ ] Sign up with email/password
- [ ] Sign up with Google
- [ ] Verify account appears in Accounts Screen
- [ ] Check Firebase Console for user

#### Read Profile
- [ ] Navigate to Profile Screen
- [ ] Verify all fields display correctly
- [ ] Check avatar shows first letter of name/email
- [ ] Verify provider badges show

#### Update Profile
- [ ] Click Edit button
- [ ] Change display name
- [ ] Click Save
- [ ] Verify success message
- [ ] Check name updated in UI
- [ ] Navigate away and back - changes persist

#### Update Email
- [ ] Click Edit button
- [ ] Change email address
- [ ] Click Save
- [ ] Verify verification email sent
- [ ] Check Firebase Console for pending email

#### Change Password
- [ ] Click Change Password
- [ ] Enter current password
- [ ] Enter new password (8+ chars)
- [ ] Confirm new password
- [ ] Click Update Password
- [ ] Verify success message
- [ ] Log out and log in with new password

#### Delete Account
- [ ] Click Delete Account
- [ ] Confirm deletion intent
- [ ] Enter password
- [ ] Click Confirm
- [ ] Verify account deleted
- [ ] Check automatic redirect to login
- [ ] Verify Firebase Console user removed
- [ ] Verify local data cleared

---

## API Reference

### AuthService Methods

```dart
// Profile updates
Future<void> updateProfile({
  String? displayName,
  String? photoURL,
})

Future<void> updateEmail(String newEmail)

Future<void> changePassword({
  required String currentPassword,
  required String newPassword,
})

Future<void> deleteAccount(String password)
```

### AccountIntegrationService Methods

```dart
// Syncs Firebase changes with local Account records
Future<Account> updateProfile({
  String? displayName,
  String? photoURL,
})

Future<Account> updateEmail(String newEmail)

Future<void> changePassword({
  required String currentPassword,
  required String newPassword,
})

Future<void> deleteAccount(String password)
```

---

## Upcoming Features

### Photo Upload 📷
- Profile photo upload to Firebase Storage
- Image cropping/resizing
- Multiple photo formats support

### Email Verification ✉️
- Send verification emails
- Check verification status
- Enforce verification for sensitive actions

### Account Recovery
- Forgot password flow
- Email-based recovery
- Security questions

### Profile Enhancements
- Bio/description field
- Custom profile URL
- Privacy settings
- Notification preferences

### Multi-factor Authentication 🔐
- SMS verification
- Authenticator app support
- Backup codes

---

## Troubleshooting

### "Email requires verification"
After changing email, user must verify via link sent to new address. Old email remains active until verification complete.

### "Wrong password" on deletion
Ensure password is correct. For Google-authenticated users without password, this won't work - they need to set a password first.

### Changes not syncing
- Check network connection
- Verify Firebase project configuration
- Check console for errors
- Ensure `firebase_options.dart` is correct

### Profile screen not accessible
- Ensure user is authenticated
- Check AccountsScreen has profile icon button
- Verify import statements

---

## File Structure

```
lib/
├── services/
│   ├── auth_service.dart               # Firebase Auth CRUD
│   ├── account_integration_service.dart # Sync Firebase ↔ Local
│   └── account_service.dart            # Local database CRUD
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart           # READ + LOGIN
│   │   └── signup_screen.dart          # CREATE
│   ├── profile/
│   │   └── profile_screen.dart         # READ + UPDATE + DELETE
│   └── accounts_screen.dart            # LIST + NAVIGATION
├── providers/
│   ├── auth_provider.dart              # Auth state management
│   └── account_provider.dart           # Local account state
└── models/
    └── account.dart                    # Account data model
```

---

## Firebase Console Tasks

### Enable Features
1. Go to [Authentication](https://console.firebase.google.com/project/smokelog-17303/authentication/providers)
2. Enable Email/Password provider
3. Enable Google provider
4. Configure OAuth consent screen

### Monitor Users
1. Go to [Users Tab](https://console.firebase.google.com/project/smokelog-17303/authentication/users)
2. View all registered users
3. Manually disable/delete users if needed
4. Check last sign-in times

### Security Rules
Ensure Firestore security rules protect user data:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## Summary

✅ **Create** - Sign up with email/password or Google  
✅ **Read** - View profile information in Profile Screen  
✅ **Update** - Edit display name, email, password  
✅ **Delete** - Permanently remove account with confirmation  

All operations are secure, validated, and sync between Firebase Auth and local database. Users have complete control over their account data with clear UI flows and proper confirmations for destructive actions.

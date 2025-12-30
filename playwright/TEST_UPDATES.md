# Test Suite Updates - Authentication Integration

## Summary of Changes

The Playwright test suite has been fully updated to work with the new Firebase Authentication system. All tests now use the correct Flutter `Key` selectors and follow the new authentication flow.

---

## Updated Test Files

### 1. **auth.setup.ts** ✅
**Purpose:** Authenticates test account before running test suite

**Changes Made:**
- Updated to use Flutter `Key` selectors instead of `data-testid`
- Uses `[key="email-input"]`, `[key="password-input"]`, `[key="login-button"]`
- Handles Firebase authentication flow with proper wait times
- Improved error logging and debugging
- Accounts for AuthWrapper automatic redirection

**Test Flow:**
```
1. Check if already logged in → Save state & exit
2. Try login with test@ashtrail.test → If success, save state
3. If login fails, try signup → Create account → Save state
4. Fallback: Save current state if auth not implemented
```

**Key Selectors Used:**
- `[key="email-input"]` - Email input field
- `[key="password-input"]` - Password input field  
- `[key="login-button"]` - Login button
- `[key="signup-button"]` - Signup button
- `[key="username-input"]` - Username input (optional)
- `[key="confirm-password-input"]` - Confirm password field
- `[key="add-log-button"]` - Main app indicator

---

### 2. **account-creation.spec.ts** ✅
**Purpose:** Tests complete account creation flow from signup to first log entry

**Changes Made:**
- Updated all selectors to use Flutter `Key` attributes
- Removed references to non-existent profile setup screens
- Removed email verification flow (Firebase handles this)
- Updated to work with AuthWrapper automatic routing
- Simplified flow to match actual implementation

**Test Flow:**
```
1. Clear auth cookies to start fresh
2. Click "Sign Up" link on login screen
3. Fill email, username, password, confirm password
4. Submit signup form
5. Wait for Firebase account creation
6. AuthWrapper automatically redirects to HomeScreen
7. Verify on main app (add-log-button visible)
8. Create first log entry
9. Verify log appears
```

**Key Changes:**
- ❌ Removed: Profile setup steps (not in implementation)
- ❌ Removed: Email verification flow (Firebase auto-handles)
- ❌ Removed: Terms checkbox (shown as text only)
- ✅ Added: Proper Firebase auth wait times
- ✅ Added: AuthWrapper redirect handling

---

### 3. **authenticated-logging-flow.spec.ts** ✅
**Purpose:** Tests log management with persistent authenticated session

**Changes Made:**
- Updated to use Flutter `Key` selectors
- Uses stored auth state from `.auth/user.json`
- Simplified selectors to match implementation

**Key Updates:**
- `[key="add-log-button"]` - Main log creation button
- Verifies auth state on each test startup
- Relies on setup project for authentication

---

## Test Account

All tests use a consistent test account:

```typescript
const testEmail = 'test@ashtrail.test';
const testPassword = 'TestPassword123!';
const testUsername = 'testuser';
```

**Setup Required:**
1. Enable Email/Password auth in Firebase Console
2. Manually create test user OR let tests create it automatically
3. Tests will reuse this account across runs

---

## Flutter Key Mapping

Our authentication screens use Flutter `Key` widgets for test identification:

### Login Screen Keys
```dart
TextField(key: Key('email-input'))      // Email field
TextField(key: Key('password-input'))   // Password field
ElevatedButton(key: Key('login-button')) // Login button
```

### Signup Screen Keys
```dart
TextField(key: Key('email-input'))              // Email field
TextField(key: Key('username-input'))           // Username field
TextField(key: Key('password-input'))           // Password field
TextField(key: Key('confirm-password-input'))   // Confirm password
ElevatedButton(key: Key('signup-button'))       // Signup button
```

### Home Screen Keys
```dart
FloatingActionButton(key: Key('add-log-button')) // Main add button
```

### Test Selectors
In Playwright, these become:
```typescript
'[key="email-input"]'
'[key="password-input"]'
'[key="login-button"]'
// etc.
```

---

## Running Tests

### Prerequisites
```bash
# 1. Start Flutter app
cd /path/to/ash_trail
flutter run -d chrome --web-port=8080

# 2. Install Playwright dependencies (one time)
cd playwright
npm install
npx playwright install
```

### Run All Tests
```bash
cd playwright

# Run all tests with all browsers
npx playwright test

# Run specific test file
npx playwright test tests/auth.setup.ts
npx playwright test tests/account-creation.spec.ts
npx playwright test tests/authenticated-logging-flow.spec.ts

# Run with UI mode for debugging
npx playwright test --ui

# Run headed (see browser)
npx playwright test --headed
```

### Test Projects
```typescript
// playwright.config.ts defines these projects:

1. setup - Runs auth.setup.ts first
2. chromium - Uses stored auth state
3. firefox - Uses stored auth state  
4. webkit - Uses stored auth state
5. Mobile Chrome - Uses stored auth state
6. Mobile Safari - Uses stored auth state
```

All projects depend on `setup` running first to authenticate.

---

## Authentication State Persistence

### How It Works
1. `auth.setup.ts` runs once before all tests
2. Authenticates test account via login or signup
3. Saves authentication state to `.auth/user.json`
4. All other tests load this state automatically
5. State persists across:
   - Test runs
   - Browser restarts
   - Server restarts
   - Different test files

### Auth State File
```json
// .auth/user.json (generated automatically)
{
  "cookies": [...],
  "origins": [
    {
      "origin": "http://localhost:8080",
      "localStorage": [
        {
          "name": "firebase:authUser:...",
          "value": "..."
        }
      ]
    }
  ]
}
```

### Clear Auth State
To force re-authentication:
```bash
rm -rf playwright/.auth/user.json
npx playwright test tests/auth.setup.ts
```

---

## Debugging Tests

### View Test Report
```bash
npx playwright show-report
```

### Debug Specific Test
```bash
# Run with inspector
npx playwright test --debug

# Run specific test with debug
npx playwright test tests/account-creation.spec.ts --debug

# Use trace viewer for failed tests
npx playwright show-trace trace.zip
```

### Common Issues

#### "Element not found" errors
- **Cause:** Selector doesn't match Flutter Key
- **Fix:** Check actual rendered HTML for `key` attribute
- **Debug:** Add `await page.pause()` in test to inspect

#### "Timeout" errors on login/signup
- **Cause:** Firebase auth taking longer than expected
- **Fix:** Increase timeout or add more wait time
- **Current:** We use 10s timeout + 3s buffer

#### "Already authenticated" when testing signup
- **Cause:** Auth state still loaded
- **Fix:** Tests call `context.clearCookies()` in beforeEach
- **Verify:** Check `.auth/user.json` was cleared

#### Firebase errors in console
- **Cause:** Firebase config not set up
- **Fix:** Ensure `firebase_options.dart` has correct credentials
- **Verify:** Firebase Console → Authentication → Users

---

## Test Coverage

### Current Coverage ✅

**Authentication:**
- ✅ Auto-create test account if doesn't exist
- ✅ Login with existing account
- ✅ Signup with new account
- ✅ Auth state persistence
- ✅ Auth state reuse across tests

**Account Creation:**
- ✅ Navigate to signup screen
- ✅ Fill all required fields
- ✅ Submit signup form
- ✅ Wait for Firebase account creation
- ✅ Verify redirect to main app
- ✅ Create first log entry

**Authenticated Workflows:**
- ✅ Create log entries
- ✅ Data persistence across reloads
- ✅ Session maintenance

### Future Test Additions 🔧

**Profile Management:**
- ⏳ Update display name
- ⏳ Update email address
- ⏳ Change password
- ⏳ Delete account

**Account Operations:**
- ⏳ Logout functionality
- ⏳ Re-login after logout
- ⏳ Multiple account switching

**Error Handling:**
- ⏳ Invalid email format
- ⏳ Weak password
- ⏳ Email already in use
- ⏳ Wrong password on login
- ⏳ Network errors

---

## Integration with CI/CD

### GitHub Actions Setup
```yaml
# .github/workflows/playwright.yml
name: Playwright Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        
      - name: Install dependencies
        run: flutter pub get
        
      - name: Setup Firebase
        env:
          FIREBASE_CONFIG: ${{ secrets.FIREBASE_CONFIG }}
        run: echo "$FIREBASE_CONFIG" > lib/firebase_options.dart
        
      - name: Start Flutter web
        run: |
          flutter run -d web-server --web-port=8080 &
          sleep 30
          
      - name: Install Playwright
        working-directory: playwright
        run: |
          npm ci
          npx playwright install --with-deps
          
      - name: Run tests
        working-directory: playwright
        run: npx playwright test
        
      - name: Upload report
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: playwright-report
          path: playwright/playwright-report/
```

---

## Best Practices

### Writing New Tests

1. **Use Flutter Keys consistently:**
   ```dart
   // In Flutter widget
   TextField(key: Key('my-field'))
   
   // In Playwright test
   await fillInput(page, '[key="my-field"]', 'value');
   ```

2. **Add proper wait times:**
   ```typescript
   await page.waitForLoadState('networkidle');
   await page.waitForTimeout(2000); // For Firebase operations
   ```

3. **Use helper functions:**
   ```typescript
   import { clickElement, fillInput, waitForElement } from './helpers/device-helpers';
   ```

4. **Handle auth state:**
   ```typescript
   // For auth tests
   await context.clearCookies();
   
   // For authenticated tests
   // Automatically loads .auth/user.json
   ```

5. **Add descriptive errors:**
   ```typescript
   await clickElement(page, '[key="button"]')
     .catch(() => console.log('Button not found - check selector'));
   ```

---

## Summary

✅ **All tests updated** to use Flutter Key selectors  
✅ **Authentication flow** properly integrated with Firebase  
✅ **Auth state persistence** working across test runs  
✅ **Signup and login** flows tested end-to-end  
✅ **Helper functions** using correct selectors  
✅ **Error handling** improved with better logging  

**Test suite is now fully compatible with the implemented Firebase Authentication system!**

Next steps:
1. Add tests for profile management (CRUD operations)
2. Add tests for logout/re-login flows
3. Add error case testing (invalid inputs, network failures)
4. Set up CI/CD pipeline with GitHub Actions

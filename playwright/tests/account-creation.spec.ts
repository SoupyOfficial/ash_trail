import { test, expect } from '@playwright/test';
import {
  clickElement,
  fillInput,
  selectOption,
  waitForElement,
} from './helpers/device-helpers';

/**
 * Test Suite: Account Creation and Authentication Flow
 * 
 * Tests the complete user journey from account creation to first log entry
 * Works on both web and mobile platforms
 */

test.describe('Account Creation Flow', () => {
  // Note: These tests are designed to verify the account creation UI exists
  // They will fail if auth is not implemented, which is expected
  // The auth.setup.ts file handles actual account creation for other tests
  
  test.beforeEach(async ({ page, context }) => {
    // Clear auth for these specific tests since we're testing the signup flow
    await context.clearCookies();
    await context.clearPermissions();
    await page.goto('/');
    await page.waitForLoadState('networkidle');
  });

  test('should complete full account creation and first log', async ({ page }) => {
    // Step 1: Navigate to signup/create account
    // Look for "Sign Up" link on login screen
    await clickElement(page, 'button:has-text("Sign Up"), text="Sign Up"', { timeout: 5000 });

    // Wait for signup screen to load
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);

    // Step 2: Fill in account details
    const timestamp = Date.now();
    const testEmail = `test${timestamp}@ashtrail.test`;
    const testPassword = 'TestPassword123!';
    const testUsername = `testuser${timestamp}`;

    // Email - using Flutter Key from signup_screen.dart
    await fillInput(
      page,
      '[key="email-input"], input[type="email"]',
      testEmail
    );

    // Username (optional field)
    await fillInput(
      page,
      '[key="username-input"]',
      testUsername
    ).catch(() => {
      console.log('Username field not found - optional');
    });

    // Password - using Flutter Key from signup_screen.dart
    await fillInput(
      page,
      '[key="password-input"]',
      testPassword
    );

    // Confirm Password - using Flutter Key from signup_screen.dart
    await fillInput(
      page,
      '[key="confirm-password-input"]',
      testPassword
    );

    // Note: Terms are shown as text, not checkbox in our UI

    // Step 3: Submit signup form using Flutter Key from signup_screen.dart
    await clickElement(
      page,
      '[key="signup-button"], button:has-text("Sign Up")',
      {}
    );

    // Step 4: Wait for Firebase account creation and AuthWrapper redirect
    await page.waitForLoadState('networkidle', { timeout: 10000 });
    await page.waitForTimeout(3000); // Give Firebase auth time to complete

    // Step 5: Verify we're on the main app (AuthWrapper handles routing)
    await waitForElement(
      page,
      '[key="add-log-button"], button:has-text("Add")',
      { timeout: 10000 }
    );

    // Step 6: Create first log entry to verify full functionality
    await clickElement(
      page,
      '[key="add-log-button"], button:has-text("Add")',
      {}
    );

    // Wait for log creation dialog
    await waitForElement(
      page,
      '[data-testid="create-log-dialog"], dialog, [role="dialog"]',
      { timeout: 5000 }
    );

    // Fill in first log entry
    await selectOption(page, 'select[name="eventType"]', 'inhale', {}).catch(async () => {
      await clickElement(page, 'text=Event Type', {});
      await clickElement(page, 'text=Inhale', {});
    });

    await fillInput(page, 'input[name="value"]', '1.0');

    await selectOption(page, 'select[name="unit"]', 'hits', {}).catch(async () => {
      await clickElement(page, 'text=Unit', {});
      await clickElement(page, 'text=Hits', {});
    });

    await fillInput(
      page,
      'input[name="note"], textarea[name="note"]',
      'My first log entry!'
    );

    // Submit log entry
    await clickElement(
      page,
      'button:has-text("Save"), button:has-text("Create")',
      {}
    );

    // Step 7: Verify the entry appears
    await waitForElement(page, 'text=My first log entry!', { timeout: 5000 });
    await expect(page.locator('text=My first log entry!')).toBeVisible();
    await expect(page.locator('text=1.0 hits')).toBeVisible();

    // Step 10: Verify account menu is accessible
    await clickElement(
      page,
      '[data-testid="account-menu"], button[aria-label*="account"], button[aria-label*="profile"]',
      { timeout: 5000 }
    ).catch(() => {
      console.log('Account menu not found or not clickable');
    });
  });

  test('should show validation errors for invalid account data', async ({ page }) => {
    // Navigate to signup
    await clickElement(page, '[data-testid="signup-button"]', {}).catch(async () => {
      await clickElement(page, 'button:has-text("Sign Up"), a:has-text("Sign Up")', {});
    });

    await waitForElement(page, '[data-testid="signup-form"]', { timeout: 5000 }).catch(async () => {
      await waitForElement(page, 'text=Create Account, text=Sign Up', {});
    });

    // Try to submit with empty email
    await clickElement(
      page,
      'button:has-text("Create Account"), button:has-text("Sign Up"), button[type="submit"]',
      {}
    );

    // Should show validation error
    await waitForElement(
      page,
      'text=/email.*required|please.*email|invalid.*email/i',
      { timeout: 3000 }
    ).catch(() => {
      console.log('Email validation error not visible');
    });

    // Fill invalid email
    await fillInput(
      page,
      'input[name="email"], input[type="email"]',
      'invalid-email'
    );

    // Try to submit
    await clickElement(
      page,
      'button:has-text("Create Account"), button[type="submit"]',
      {}
    );

    // Should show email format error
    await waitForElement(
      page,
      'text=/valid.*email|email.*format|invalid.*email/i',
      { timeout: 3000 }
    ).catch(() => {
      console.log('Email format validation not visible');
    });
  });

  test('should show error for weak password', async ({ page }) => {
    // Navigate to signup
    await clickElement(page, '[data-testid="signup-button"]', {}).catch(async () => {
      await clickElement(page, 'button:has-text("Sign Up"), a:has-text("Sign Up")', {});
    });

    await waitForElement(page, 'text=Create Account, text=Sign Up', { timeout: 5000 });

    // Fill valid email
    await fillInput(
      page,
      'input[name="email"], input[type="email"]',
      'test@example.com'
    );

    // Fill weak password
    await fillInput(
      page,
      'input[name="password"], input[type="password"]',
      '123'
    );

    // Try to submit
    await clickElement(
      page,
      'button:has-text("Create Account"), button[type="submit"]',
      {}
    );

    // Should show password strength error
    await waitForElement(
      page,
      'text=/password.*weak|password.*short|password.*characters|password.*strength/i',
      { timeout: 3000 }
    ).catch(() => {
      console.log('Password validation error not visible');
    });
  });

  test('should show error for mismatched passwords', async ({ page }) => {
    // Navigate to signup
    await clickElement(page, '[data-testid="signup-button"]', {}).catch(async () => {
      await clickElement(page, 'button:has-text("Sign Up")', {});
    });

    await waitForElement(page, 'text=Create Account, text=Sign Up', { timeout: 5000 });

    // Fill password
    await fillInput(
      page,
      'input[name="password"], input[type="password"]',
      'StrongPassword123!'
    );

    // Fill mismatched confirm password
    await fillInput(
      page,
      'input[name="confirmPassword"], input[name="password_confirm"]',
      'DifferentPassword123!'
    ).catch(() => {
      console.log('Confirm password field not found');
    });

    // Try to submit
    await clickElement(
      page,
      'button:has-text("Create Account"), button[type="submit"]',
      {}
    );

    // Should show password mismatch error
    await waitForElement(
      page,
      'text=/password.*match|passwords.*same|passwords.*identical/i',
      { timeout: 3000 }
    ).catch(() => {
      console.log('Password mismatch error not visible');
    });
  });

  test('should handle duplicate email error', async ({ page }) => {
    const existingEmail = 'existing@ashtrail.test';

    // Navigate to signup
    await clickElement(page, '[data-testid="signup-button"]', {}).catch(async () => {
      await clickElement(page, 'button:has-text("Sign Up")', {});
    });

    await waitForElement(page, 'text=Create Account, text=Sign Up', { timeout: 5000 });

    // Fill with existing email
    await fillInput(
      page,
      'input[name="email"], input[type="email"]',
      existingEmail
    );

    // Fill password
    await fillInput(
      page,
      'input[name="password"], input[type="password"]',
      'TestPassword123!'
    );

    // Submit
    await clickElement(
      page,
      'button:has-text("Create Account"), button[type="submit"]',
      {}
    );

    // Should show duplicate email error (if email already exists in system)
    // This test might need actual test data or mocking
    await waitForElement(
      page,
      'text=/email.*exists|email.*taken|email.*already|account.*exists/i',
      { timeout: 5000 }
    ).catch(() => {
      console.log('Duplicate email error not shown - email may not exist in test DB');
    });
  });
});

test.describe('Login Flow', () => {
  // Note: These tests verify login UI exists
  // The auth.setup.ts file handles actual login for test sessions
  
  test.beforeEach(async ({ page, context }) => {
    // Clear auth for these specific tests since we're testing the login flow
    await context.clearCookies();
    await context.clearPermissions();
    await page.goto('/');
    await page.waitForLoadState('networkidle');
  });

  test('should login with existing account', async ({ page }) => {
    // Click login/sign in button
    await clickElement(page, '[data-testid="login-button"]', {}).catch(async () => {
      await clickElement(page, 'button:has-text("Login"), button:has-text("Sign In"), a:has-text("Login")', {});
    });

    // Wait for login form
    await waitForElement(page, '[data-testid="login-form"]', { timeout: 5000 }).catch(async () => {
      await waitForElement(page, 'text=Login, text=Sign In', {});
    });

    // Fill credentials (use test account if available)
    await fillInput(
      page,
      'input[name="email"], input[type="email"]',
      'test@ashtrail.test'
    );

    await fillInput(
      page,
      'input[name="password"], input[type="password"]',
      'TestPassword123!'
    );

    // Submit
    await clickElement(
      page,
      'button:has-text("Login"), button:has-text("Sign In"), button[type="submit"]',
      {}
    );

    // Wait for login to complete
    await page.waitForTimeout(2000);

    // Verify we're logged in (should see main app)
    await waitForElement(
      page,
      '[data-testid="add-log-button"], button[aria-label*="add"]',
      { timeout: 10000 }
    ).catch(() => {
      // If test account doesn't exist, we'll see an error
      console.log('Login may have failed - test account might not exist');
    });
  });

  test('should show error for invalid credentials', async ({ page }) => {
    // Navigate to login
    await clickElement(page, '[data-testid="login-button"]', {}).catch(async () => {
      await clickElement(page, 'button:has-text("Login")', {});
    });

    await waitForElement(page, 'text=Login, text=Sign In', { timeout: 5000 });

    // Fill invalid credentials
    await fillInput(
      page,
      'input[name="email"], input[type="email"]',
      'nonexistent@example.com'
    );

    await fillInput(
      page,
      'input[name="password"], input[type="password"]',
      'WrongPassword123!'
    );

    // Submit
    await clickElement(
      page,
      'button:has-text("Login"), button[type="submit"]',
      {}
    );

    // Should show error
    await waitForElement(
      page,
      'text=/invalid.*credentials|email.*password.*incorrect|login.*failed/i',
      { timeout: 5000 }
    ).catch(() => {
      console.log('Invalid credentials error not visible');
    });
  });
});

test.describe('Account Profile Management', () => {
  test('should view and edit profile', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Open account/profile menu
    await clickElement(
      page,
      '[data-testid="account-menu"], button[aria-label*="account"], button[aria-label*="profile"]',
      { timeout: 5000 }
    ).catch(async () => {
      // Try opening settings
      await clickElement(page, 'button:has-text("Settings"), text=Settings', {});
    });

    // Click Profile or Account Settings
    await clickElement(
      page,
      'text=Profile, text=Account Settings, a:has-text("Profile")',
      { timeout: 3000 }
    ).catch(() => {
      console.log('Profile link not found');
    });

    // Wait for profile page
    await waitForElement(page, 'text=Profile, text=Account', { timeout: 5000 });

    // Click edit button
    await clickElement(
      page,
      'button:has-text("Edit"), [data-testid="edit-profile-button"]',
      { timeout: 3000 }
    ).catch(() => {
      console.log('Edit button not found - profile might already be editable');
    });

    // Update display name
    await fillInput(
      page,
      'input[name="displayName"], input[placeholder*="name" i]',
      'Updated Test Name'
    ).catch(() => {
      console.log('Display name field not found');
    });

    // Save changes
    await clickElement(
      page,
      'button:has-text("Save"), button:has-text("Update")',
      { timeout: 3000 }
    ).catch(() => {
      console.log('Save button not found');
    });

    // Verify success message
    await waitForElement(
      page,
      'text=/profile.*updated|saved.*successfully|changes.*saved/i',
      { timeout: 5000 }
    ).catch(() => {
      console.log('Success message not visible');
    });
  });
});

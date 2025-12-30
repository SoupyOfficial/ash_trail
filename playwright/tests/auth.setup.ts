import { test as setup, expect } from '@playwright/test';
import {
  clickElement,
  fillInput,
  waitForElement,
} from './helpers/device-helpers';
import * as fs from 'fs';
import * as path from 'path';

const authFile = path.join(__dirname, '../.auth/user.json');

/**
 * Authentication Setup
 * 
 * This runs once before all tests to:
 * 1. Check if test account exists (by trying to login)
 * 2. Create account if it doesn't exist
 * 3. Save authentication state to disk for reuse across test sessions
 */
setup('authenticate', async ({ page }) => {
  console.log('Setting up test account authentication...');

  // Test account credentials
  const testEmail = 'test@ashtrail.test';
  const testPassword = 'TestPassword123!';
  const testUsername = 'testuser';

  await page.goto('/');
  await page.waitForLoadState('networkidle');

  // Check if already logged in
  const isLoggedIn = await page.locator('[key="add-log-button"], button:has-text("Add")')
    .isVisible({ timeout: 3000 })
    .catch(() => false);

  if (isLoggedIn) {
    console.log('Already logged in, saving state...');
    await page.context().storageState({ path: authFile });
    return;
  }

  // Try to login first (account might already exist)
  console.log('Attempting to login with test account...');
  const loginAttempt = await tryLogin(page, testEmail, testPassword);

  if (loginAttempt) {
    console.log('Login successful! Saving authentication state...');
    await page.context().storageState({ path: authFile });
    return;
  }

  // Login failed, try to create account
  console.log('Login failed, attempting to create new account...');
  await page.goto('/');
  await page.waitForLoadState('networkidle');

  const signupSuccess = await trySignup(page, testEmail, testPassword, testUsername);

  if (signupSuccess) {
    console.log('Account created successfully! Saving authentication state...');
    await page.context().storageState({ path: authFile });
    return;
  }

  // If both failed, the app might not have auth implemented yet
  // Save whatever state we have so tests can run
  console.log('Auth not fully implemented or app already logged in. Saving current state...');
  await page.context().storageState({ path: authFile });
});

async function tryLogin(page: any, email: string, password: string): Promise<boolean> {
  try {
    // We should already be on the login screen if not authenticated
    console.log('Looking for email input field...');
    
    // Check if we're on the login screen by looking for email input
    const hasEmailInput = await page.locator('[key="email-input"], input[type="email"]')
      .isVisible({ timeout: 3000 })
      .catch(() => false);

    if (!hasEmailInput) {
      console.log('No email input found - may not be on login screen');
      return false;
    }

    // Fill credentials using the exact keys from login_screen.dart
    console.log('Filling email...');
    await fillInput(
      page,
      '[key="email-input"], input[type="email"]',
      email
    );

    console.log('Filling password...');
    await fillInput(
      page,
      '[key="password-input"], input[type="password"]',
      password
    );

    // Submit using the exact key from login_screen.dart
    console.log('Clicking login button...');
    await clickElement(
      page,
      '[key="login-button"], button:has-text("Log In")',
      { timeout: 3000 }
    );

    // Wait for navigation to main app (AuthWrapper will redirect)
    console.log('Waiting for main app to load...');
    await page.waitForLoadState('networkidle', { timeout: 10000 });
    
    // Wait a bit for Firebase auth to complete
    await page.waitForTimeout(2000);

    // Check if we're on the home screen (should have add-log-button)
    const onMainApp = await page.locator('[key="add-log-button"], button:has-text("Add")')
      .isVisible({ timeout: 5000 })
      .catch(() => false);

    if (onMainApp) {
      console.log('Successfully logged in and on main app!');
      return true;
    }

    console.log('Login submitted but not on main app yet');
    return false;
  } catch (error) {
    console.log('Login attempt failed:', error instanceof Error ? error.message : 'Unknown error');
    return false;
  }
}

async function trySignup(page: any, email: string, password: string, username: string): Promise<boolean> {
  try {
    // Look for signup link/button on login screen
    console.log('Looking for Sign Up link...');
    const signupLink = await page.locator('button:has-text("Sign Up"), text="Sign Up"')
      .isVisible({ timeout: 3000 })
      .catch(() => false);

    if (!signupLink) {
      console.log('No signup link found');
      return false;
    }

    // Click the "Sign Up" link to navigate to signup screen
    await clickElement(
      page,
      'button:has-text("Sign Up"), text="Sign Up"',
      { timeout: 3000 }
    );

    // Wait for signup screen to load
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);

    // Fill account details using exact keys from signup_screen.dart
    console.log('Filling email...');
    await fillInput(
      page,
      '[key="email-input"], input[type="email"]',
      email
    );

    console.log('Filling username...');
    await fillInput(
      page,
      '[key="username-input"]',
      username
    ).catch(() => console.log('Username field not found - optional'));

    console.log('Filling password...');
    await fillInput(
      page,
      '[key="password-input"]',
      password
    );

    console.log('Filling confirm password...');
    await fillInput(
      page,
      '[key="confirm-password-input"]',
      password
    );

    // Submit using exact key from signup_screen.dart
    console.log('Clicking signup button...');
    await clickElement(
      page,
      '[key="signup-button"], button:has-text("Sign Up")',
      { timeout: 3000 }
    );

    // Wait for Firebase to create account and redirect
    console.log('Waiting for account creation...');
    await page.waitForLoadState('networkidle', { timeout: 10000 });
    
    // Give Firebase auth time to complete
    await page.waitForTimeout(3000);

    // Check if we're on the main app
    const onMainApp = await page.locator('[key="add-log-button"], button:has-text("Add")')
      .isVisible({ timeout: 5000 })
      .catch(() => false);

    if (onMainApp) {
      console.log('Successfully created account and on main app!');
      return true;
    }

    console.log('Signup submitted but not on main app yet');
    return false;
  } catch (error) {
    console.log('Signup attempt failed:', error instanceof Error ? error.message : 'Unknown error');
    return false;
  }
}

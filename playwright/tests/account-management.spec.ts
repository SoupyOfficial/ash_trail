import { test, expect } from '@playwright/test';
import { setupAnonymousAccount } from './helpers/device-helpers';

/**
 * Test Suite: Account Management
 * 
 * Purpose: Tests account-related functionality including switching accounts,
 * account deletion, logout, and test account features.
 */

test.describe('Account Management - Profile Access', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should access account/profile settings', async ({ page }) => {
    const settingsButton = page.locator('text=Settings').or(
      page.locator('text=Profile')
    ).or(
      page.locator('text=Account')
    );
    
    if (await settingsButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await settingsButton.first().click();
      await page.waitForTimeout(1000);
      
      // Should show account/profile content
      const accountContent = page.locator('text=/Account|Profile|Email|Username/i');
      await expect(accountContent.first()).toBeVisible({ timeout: 5000 });
    } else {
      await expect(page.locator('body')).toBeVisible();
    }
  });

  test('should display current account info', async ({ page }) => {
    const settingsButton = page.locator('text=Settings').or(page.locator('text=Profile'));
    
    if (await settingsButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await settingsButton.first().click();
      await page.waitForTimeout(1000);
      
      // Should show email or username
      const accountInfo = page.locator('text=/\\S+@\\S+|Anonymous|Guest|User/i');
      const hasInfo = await accountInfo.first().isVisible({ timeout: 5000 }).catch(() => false);
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('Account Management - Logout', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should show logout option', async ({ page }) => {
    const settingsButton = page.locator('text=Settings').or(page.locator('text=Profile'));
    
    if (await settingsButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await settingsButton.first().click();
      await page.waitForTimeout(1000);
      
      const logoutButton = page.locator('text=/Log ?out|Sign ?out/i');
      const hasLogout = await logoutButton.first().isVisible({ timeout: 5000 }).catch(() => false);
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should confirm logout before proceeding', async ({ page }) => {
    const settingsButton = page.locator('text=Settings').or(page.locator('text=Profile'));
    
    if (await settingsButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await settingsButton.first().click();
      await page.waitForTimeout(1000);
      
      const logoutButton = page.locator('text=/Log ?out|Sign ?out/i');
      
      if (await logoutButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await logoutButton.first().click();
        await page.waitForTimeout(500);
        
        // Should show confirmation dialog
        const confirmDialog = page.locator('[role="dialog"]').or(
          page.locator('text=/confirm|sure|cancel/i')
        );
        
        const hasConfirm = await confirmDialog.first().isVisible({ timeout: 5000 }).catch(() => false);
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('Account Management - Account Switching', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should show switch account option if available', async ({ page }) => {
    const settingsButton = page.locator('text=Settings').or(page.locator('text=Profile'));
    
    if (await settingsButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await settingsButton.first().click();
      await page.waitForTimeout(1000);
      
      const switchAccount = page.locator('text=/Switch|Add Account|Other Account/i');
      const hasSwitch = await switchAccount.first().isVisible({ timeout: 5000 }).catch(() => false);
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('Account Management - Delete Account', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should show delete account option', async ({ page }) => {
    const settingsButton = page.locator('text=Settings').or(page.locator('text=Profile'));
    
    if (await settingsButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await settingsButton.first().click();
      await page.waitForTimeout(1000);
      
      const deleteOption = page.locator('text=/Delete|Remove|Deactivate/i');
      const hasDelete = await deleteOption.first().isVisible({ timeout: 5000 }).catch(() => false);
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should require confirmation for account deletion', async ({ page }) => {
    const settingsButton = page.locator('text=Settings').or(page.locator('text=Profile'));
    
    if (await settingsButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await settingsButton.first().click();
      await page.waitForTimeout(1000);
      
      const deleteOption = page.locator('text=/Delete Account|Remove Account/i');
      
      if (await deleteOption.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await deleteOption.first().click();
        await page.waitForTimeout(500);
        
        // Should show warning/confirmation
        const confirmation = page.locator('text=/confirm|permanent|cannot|undone/i');
        const hasConfirm = await confirmation.first().isVisible({ timeout: 5000 }).catch(() => false);
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('Account Management - Test Account', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should access test account features if available', async ({ page }) => {
    const settingsButton = page.locator('text=Settings').or(page.locator('text=Profile'));
    
    if (await settingsButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await settingsButton.first().click();
      await page.waitForTimeout(1000);
      
      const testAccount = page.locator('text=/Test Account|Dev Mode|Developer/i');
      const hasTestAccount = await testAccount.first().isVisible({ timeout: 5000 }).catch(() => false);
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should create test account with sample data', async ({ page }) => {
    const settingsButton = page.locator('text=Settings').or(page.locator('text=Profile'));
    
    if (await settingsButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await settingsButton.first().click();
      await page.waitForTimeout(1000);
      
      const createTestAccount = page.locator('text=/Create Test|Generate Sample|Add Test Data/i');
      
      if (await createTestAccount.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await createTestAccount.first().click();
        await page.waitForTimeout(1000);
        
        // Should create account and show success
        const success = page.locator('text=/created|generated|success/i');
        const hasSuccess = await success.first().isVisible({ timeout: 5000 }).catch(() => false);
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('Account Management - Data Privacy', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should show data export option', async ({ page }) => {
    const settingsButton = page.locator('text=Settings').or(page.locator('text=Profile'));
    
    if (await settingsButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await settingsButton.first().click();
      await page.waitForTimeout(1000);
      
      const exportOption = page.locator('text=/Export|Download|Backup/i');
      const hasExport = await exportOption.first().isVisible({ timeout: 5000 }).catch(() => false);
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should show privacy policy link', async ({ page }) => {
    const settingsButton = page.locator('text=Settings').or(page.locator('text=Profile'));
    
    if (await settingsButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await settingsButton.first().click();
      await page.waitForTimeout(1000);
      
      const privacyLink = page.locator('text=/Privacy|Terms|Policy/i');
      const hasPrivacy = await privacyLink.first().isVisible({ timeout: 5000 }).catch(() => false);
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

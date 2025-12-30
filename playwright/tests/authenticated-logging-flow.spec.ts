import { test, expect } from '@playwright/test';
import {
  clickElement,
  fillInput,
  selectOption,
  waitForElement,
} from './helpers/device-helpers';

/**
 * Test Suite: Authenticated Logging Flow
 * 
 * These tests run with a persistent authenticated session
 * The auth state is maintained across test runs and server restarts
 */

test.describe('Authenticated User - Log Record Management', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the app - auth state is already loaded
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Verify we're logged in using Flutter Key from home_screen.dart
    await expect(page.locator('[key="add-log-button"], button:has-text("Add")'))
      .toBeVisible({ timeout: 10000 });
  });

  test('should create a new log entry', async ({ page }) => {
    // Click the "Add Log" button using Flutter Key
    await clickElement(page, '[key="add-log-button"], button:has-text("Add")', { timeout: 5000 });

    // Wait for dialog to appear
    await waitForElement(page, '[data-testid="create-log-dialog"]', { timeout: 5000 }).catch(async () => {
      await waitForElement(page, 'dialog, [role="dialog"]', {});
    });

    // Fill in the form
    await selectOption(page, 'select[name="eventType"]', 'inhale', {}).catch(async () => {
      await clickElement(page, 'text=Event Type', {});
      await clickElement(page, 'text=Inhale', {});
    });

    await fillInput(page, 'input[name="value"]', '2.0');

    await selectOption(page, 'select[name="unit"]', 'hits', {}).catch(async () => {
      await clickElement(page, 'text=Unit', {});
      await clickElement(page, 'text=Hits', {});
    });

    await fillInput(page, 'input[name="note"], textarea[name="note"]', 'Authenticated session test');

    await fillInput(page, 'input[name="tags"]', 'test,automated');

    // Submit the form
    await clickElement(page, 'button:has-text("Save"), button:has-text("Create")', {});

    // Wait for the entry to appear in the list
    await waitForElement(page, 'text=Authenticated session test', { timeout: 5000 });

    // Verify the entry is visible
    await expect(page.locator('text=Authenticated session test')).toBeVisible();
  });

  test('should persist data after page reload', async ({ page }) => {
    // Create a unique log entry
    const uniqueNote = `Persist test ${Date.now()}`;
    
    await clickElement(page, '[key="add-log-button"], button:has-text("Add")', { timeout: 5000 });

    await waitForElement(page, '[data-testid="create-log-dialog"], dialog', { timeout: 5000 });

    await fillInput(page, 'input[name="value"]', '1.0');
    await fillInput(page, 'input[name="note"], textarea[name="note"]', uniqueNote);
    await clickElement(page, 'button:has-text("Save"), button:has-text("Create")', {});
    
    await waitForElement(page, `text=${uniqueNote}`, { timeout: 5000 });

    // Reload the page
    await page.reload();
    await page.waitForLoadState('networkidle');

    // Verify still logged in
    await expect(page.locator('[data-testid="add-log-button"], button[aria-label*="add"]'))
      .toBeVisible({ timeout: 10000 });

    // Verify the entry still exists
    await expect(page.locator(`text=${uniqueNote}`)).toBeVisible({ timeout: 5000 });
  });

  test('should edit an existing log entry', async ({ page }) => {
    // First create an entry
    await clickElement(page, '[data-testid="add-log-button"]', {}).catch(async () => {
      await clickElement(page, 'button[aria-label*="add"]', {});
    });

    await waitForElement(page, 'dialog', { timeout: 5000 });
    await fillInput(page, 'input[name="value"]', '1.0');
    await fillInput(page, 'input[name="note"], textarea[name="note"]', 'Original note');
    await clickElement(page, 'button:has-text("Save"), button:has-text("Create")', {});
    await waitForElement(page, 'text=Original note', { timeout: 5000 });

    // Click on the entry
    await clickElement(page, 'text=Original note', {}).catch(async () => {
      await clickElement(page, '[data-testid="log-entry-tile"]:has-text("Original note")', {});
    });

    // Wait for action menu
    await waitForElement(page, 'text=Edit, text=Delete', { timeout: 5000 }).catch(async () => {
      await clickElement(page, '[data-testid="edit-button"]', {});
    });

    // Click Edit
    await clickElement(page, 'text=Edit', {}).catch(async () => {
      await clickElement(page, 'button:has-text("Edit")', {});
    });

    // Wait for edit dialog
    await waitForElement(page, 'dialog', { timeout: 5000 });

    // Update the note
    await fillInput(page, 'textarea[name="note"], input[name="note"]', 'Updated note text');

    // Save changes
    await clickElement(page, 'button:has-text("Update"), button:has-text("Save")', {});

    await page.waitForTimeout(1000);

    // Verify the update
    await expect(page.locator('text=Updated note text')).toBeVisible();
  });

  test('should delete a log entry', async ({ page }) => {
    // Create an entry to delete
    await clickElement(page, '[data-testid="add-log-button"]', {}).catch(async () => {
      await clickElement(page, 'button[aria-label*="add"]', {});
    });

    await waitForElement(page, 'dialog', { timeout: 5000 });
    const deleteNote = `Delete test ${Date.now()}`;
    await fillInput(page, 'input[name="value"]', '1.0');
    await fillInput(page, 'input[name="note"], textarea[name="note"]', deleteNote);
    await clickElement(page, 'button:has-text("Save"), button:has-text("Create")', {});
    await waitForElement(page, `text=${deleteNote}`, { timeout: 5000 });

    // Click on the entry
    await clickElement(page, `text=${deleteNote}`, {});

    // Wait for action menu
    await waitForElement(page, 'text=Delete', { timeout: 5000 });

    // Click Delete
    await clickElement(page, 'text=Delete', {}).catch(async () => {
      await clickElement(page, 'button:has-text("Delete")', {});
    });

    // Confirm deletion
    await waitForElement(page, 'text=Delete Log Record, text=Confirm', { timeout: 5000 });
    await clickElement(page, 'button:has-text("Delete"), button:has-text("Confirm")', {});

    // Wait a moment
    await page.waitForTimeout(1000);

    // Verify the entry is gone (or shows as deleted)
    const stillVisible = await page.locator(`text=${deleteNote}`)
      .isVisible({ timeout: 2000 })
      .catch(() => false);
    
    expect(stillVisible).toBe(false);
  });

  test('should search log entries', async ({ page }) => {
    // Create searchable entries
    const searchTerm = `searchable${Date.now()}`;
    
    await clickElement(page, '[data-testid="add-log-button"]', {}).catch(async () => {
      await clickElement(page, 'button[aria-label*="add"]', {});
    });

    await waitForElement(page, 'dialog', { timeout: 5000 });
    await fillInput(page, 'input[name="value"]', '1.0');
    await fillInput(page, 'input[name="note"], textarea[name="note"]', searchTerm);
    await clickElement(page, 'button:has-text("Save"), button:has-text("Create")', {});
    await waitForElement(page, `text=${searchTerm}`, { timeout: 5000 });

    // Perform search
    await fillInput(page, 'input[placeholder*="Search"]', searchTerm);

    // Wait for filtered results
    await page.waitForTimeout(500);

    // Verify search result is visible
    await expect(page.locator(`text=${searchTerm}`)).toBeVisible();
  });
});

test.describe('Authenticated User - Session Persistence', () => {
  test('should remain logged in after multiple page navigations', async ({ page }) => {
    // Navigate to home
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('[data-testid="add-log-button"], button[aria-label*="add"]'))
      .toBeVisible({ timeout: 10000 });

    // Try navigating to analytics (if exists)
    const hasAnalytics = await page.locator('text=Analytics, [data-testid="analytics-tab"]')
      .isVisible({ timeout: 2000 })
      .catch(() => false);

    if (hasAnalytics) {
      await clickElement(page, 'text=Analytics', {}).catch(async () => {
        await clickElement(page, '[data-testid="analytics-tab"]', {});
      });
      await page.waitForTimeout(1000);

      // Navigate back to home
      await clickElement(page, 'text=Home, text=Logs', {}).catch(async () => {
        await page.goto('/');
      });
      await page.waitForLoadState('networkidle');

      // Verify still logged in
      await expect(page.locator('[data-testid="add-log-button"], button[aria-label*="add"]'))
        .toBeVisible({ timeout: 10000 });
    }
  });

  test('should maintain auth state in new tab', async ({ context, page }) => {
    // Verify logged in on first page
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await expect(page.locator('[data-testid="add-log-button"], button[aria-label*="add"]'))
      .toBeVisible({ timeout: 10000 });

    // Open new tab
    const newPage = await context.newPage();
    await newPage.goto('/');
    await newPage.waitForLoadState('networkidle');

    // Verify logged in on new tab
    await expect(newPage.locator('[data-testid="add-log-button"], button[aria-label*="add"]'))
      .toBeVisible({ timeout: 10000 });

    await newPage.close();
  });
});

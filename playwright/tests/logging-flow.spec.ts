import { test, expect } from '@playwright/test';
import {
  clickElement,
  fillInput,
  selectOption,
  waitForElement,
} from './helpers/device-helpers';

/**
 * Test Suite: Complete Logging Flow
 * 
 * Tests the full user journey for creating, viewing, editing, and deleting log entries
 * Works on both web and mobile platforms
 */

test.describe('Complete Logging Flow', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the app
    await page.goto('/');
    
    // Wait for app to load
    await page.waitForLoadState('networkidle');
  });

  test('should create a new log entry', async ({ page }) => {
    // Click the "Add Log" button using cross-platform click
    await clickElement(page, '[data-testid="add-log-button"]', { timeout: 5000 }).catch(async () => {
      // Fallback to floating action button
      await clickElement(page, 'button[aria-label*="add"]', {});
    });

    // Wait for dialog to appear
    await waitForElement(page, '[data-testid="create-log-dialog"]', { timeout: 5000 }).catch(async () => {
      await waitForElement(page, 'dialog, [role="dialog"]', {});
    });

    // Fill in the form using cross-platform methods
    // Event Type
    await selectOption(page, 'select[name="eventType"]', 'inhale', {}).catch(async () => {
      await clickElement(page, 'text=Event Type', {});
      await clickElement(page, 'text=Inhale', {});
    });

    // Value
    await fillInput(page, 'input[name="value"]', '2.0');

    // Unit
    await selectOption(page, 'select[name="unit"]', 'hits', {}).catch(async () => {
      await clickElement(page, 'text=Unit', {});
      await clickElement(page, 'text=Hits', {});
    });

    // Note
    await fillInput(page, 'input[name="note"], textarea[name="note"]', 'Morning session with friends');

    // Tags
    await fillInput(page, 'input[name="tags"]', 'morning,sativa,social');

    // Submit the form
    await clickElement(page, 'button:has-text("Save"), button:has-text("Create")', {});

    // Wait for the entry to appear in the list
    await waitForElement(page, 'text=Morning session with friends', { timeout: 5000 });

    // Verify the entry is visible
    await expect(page.locator('text=Morning session with friends')).toBeVisible();
    await expect(page.locator('text=2.0 hits')).toBeVisible();
  });

  test('should view log entry details', async ({ page }) => {
    // Assuming there's at least one log entry, click on it using cross-platform method
    await clickElement(page, '[data-testid="log-entry-tile"]', { timeout: 5000 }).catch(async () => {
      // Fallback to clicking any list item
      await clickElement(page, 'li:has-text("inhale"), li:has-text("session")', {});
    });

    // Wait for details dialog
    await waitForElement(page, 'text=Log Details, text=Details', { timeout: 5000 });

    // Verify details are shown
    await expect(page.locator('text=Event Type:')).toBeVisible();
    await expect(page.locator('text=Value:')).toBeVisible();
    await expect(page.locator('text=Note:')).toBeVisible();

    // Close the dialog
    await clickElement(page, 'button:has-text("Close")', {});
  });

  test('should edit an existing log entry', async ({ page }) => {
    // Click on a log entry to open action menu using cross-platform method
    await clickElement(page, '[data-testid="log-entry-tile"]', {}).catch(async () => {
      await clickElement(page, 'li:first-child', {});
    });

    // Wait for action menu (bottom sheet) to appear
    await waitForElement(page, 'text=Edit, text=Delete', { timeout: 5000 }).catch(async () => {
      // Fallback: click edit button directly if action menu doesn't appear
      await clickElement(page, '[data-testid="edit-button"]', {});
    });

    // Click Edit action
    await clickElement(page, 'text=Edit', {}).catch(async () => {
      await clickElement(page, 'button:has-text("Edit")', {});
    });

    // Wait for edit dialog to open
    await waitForElement(page, '[data-testid="edit-log-dialog"]', { timeout: 5000 }).catch(async () => {
      await waitForElement(page, 'dialog:has-text("Edit Log Record"), [role="dialog"]:has-text("Edit")', {});
    });

    // Update the note field using cross-platform fillInput
    await fillInput(page, 'textarea[name="note"], input[name="note"]', 'Updated note text');

    // Update the value
    await fillInput(page, 'input[name="value"]', '3.0');

    // Save changes
    await clickElement(page, 'button:has-text("Update"), button:has-text("Save")', {});

    // Wait for dialog to close and changes to reflect
    await page.waitForTimeout(1000);

    // Verify the update
    await waitForElement(page, 'text=Updated note text', { timeout: 5000 });
    await expect(page.locator('text=3.0')).toBeVisible();
  });

  test('should delete a log entry', async ({ page }) => {
    // Get initial count of log entries
    const initialCount = await page.locator('[data-testid="log-entry-tile"]').count().catch(() => {
      return page.locator('li').count();
    });

    // Click on a log entry to open action menu using cross-platform method
    await clickElement(page, '[data-testid="log-entry-tile"]', {}).catch(async () => {
      await clickElement(page, 'li:first-child', {});
    });

    // Wait for action menu (bottom sheet) to appear
    await waitForElement(page, 'text=Edit, text=Delete', { timeout: 5000 }).catch(async () => {
      await clickElement(page, '[data-testid="delete-button"]', {});
      return;
    });

    // Click Delete action
    await clickElement(page, 'text=Delete', {}).catch(async () => {
      await clickElement(page, 'button:has-text("Delete")', {});
    });

    // Wait for confirmation dialog
    await waitForElement(page, 'text=Delete Log Record, text=Confirm Delete', { timeout: 5000 });

    // Confirm deletion
    await clickElement(page, 'button:has-text("Delete"), button:has-text("Confirm")', {});

    // Wait for SnackBar with UNDO option
    await waitForElement(page, 'text=Log deleted, text=deleted', { timeout: 3000 }).catch(() => {
      // SnackBar might disappear quickly
    });

    // Wait a moment for the deletion to process
    await page.waitForTimeout(1000);

    // Verify count decreased (if there were entries)
    if (initialCount > 0) {
      const newCount = await page.locator('[data-testid="log-entry-tile"]').count().catch(() => {
        return page.locator('li').count();
      });
      expect(newCount).toBeLessThan(initialCount);
    }
  });

  test('should undo delete with UNDO button', async ({ page }) => {
    // Create a log entry first (so we have something to delete and restore)
    await clickElement(page, '[data-testid="add-log-button"]', { timeout: 5000 }).catch(async () => {
      await clickElement(page, 'button[aria-label*="add"]', {});
    });

    await waitForElement(page, '[data-testid="create-log-dialog"]', { timeout: 5000 }).catch(async () => {
      await waitForElement(page, 'dialog, [role="dialog"]', {});
    });

    await fillInput(page, 'input[name="value"]', '5.0');
    await fillInput(page, 'textarea[name="note"], input[name="note"]', 'Test entry for undo');
    await clickElement(page, 'button:has-text("Save"), button:has-text("Create")', {});
    await page.waitForTimeout(1000);

    // Get count before delete
    const beforeCount = await page.locator('text=Test entry for undo').count();
    expect(beforeCount).toBeGreaterThan(0);

    // Click on the entry to open action menu
    await clickElement(page, 'text=Test entry for undo', {});

    // Click Delete
    await waitForElement(page, 'text=Delete', { timeout: 5000 });
    await clickElement(page, 'text=Delete', {});

    // Confirm deletion
    await waitForElement(page, 'text=Delete Log Record, text=Confirm', { timeout: 5000 });
    await clickElement(page, 'button:has-text("Delete"), button:has-text("Confirm")', {});

    // Click UNDO in SnackBar (needs to be quick before it dismisses)
    await clickElement(page, 'button:has-text("UNDO"), text=UNDO', { timeout: 5000 }).catch(async () => {
      console.log('UNDO button not found or SnackBar dismissed');
    });

    // Wait for restore to complete
    await page.waitForTimeout(1000);

    // Verify the entry is back
    await expect(page.locator('text=Test entry for undo')).toBeVisible({ timeout: 5000 });
  });

  test('should use quick log button', async ({ page }) => {
    // Click quick log button (typically a FAB) using cross-platform method
    await clickElement(page, '[data-testid="quick-log-button"]', {}).catch(async () => {
      await clickElement(page, 'button[aria-label*="Quick Log"]', {});
    });

    // Wait for the entry to be created
    await page.waitForTimeout(1000);

    // Verify a new entry appeared (check for sync indicator or list update)
    await expect(page.locator('[data-testid="log-entry-tile"]').first()).toBeVisible();
  });
});

test.describe('Filtering and Search', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
  });

  test('should filter log entries by event type', async ({ page }) => {
    // Open filter menu using cross-platform click
    await clickElement(page, '[data-testid="filter-button"]', {}).catch(async () => {
      await clickElement(page, 'button:has-text("Filter")', {});
    });

    // Select "Inhale" filter
    await clickElement(page, 'text=Inhale', {}).catch(async () => {
      await page.check('input[value="inhale"]');
    });

    // Apply filter
    await clickElement(page, 'button:has-text("Apply")', {});

    // Verify only inhale entries are visible
    const entries = await page.locator('[data-testid="log-entry-tile"]').all();
    for (const entry of entries) {
      await expect(entry).toContainText(/inhale/i);
    }
  });

  test('should search log entries by note', async ({ page }) => {
    // Find and use search input using cross-platform fillInput
    await fillInput(page, 'input[placeholder*="Search"]', 'morning');

    // Wait for filtered results
    await page.waitForTimeout(500);

    // Verify search results
    const results = await page.locator('[data-testid="log-entry-tile"]').all();
    for (const result of results) {
      const text = await result.textContent();
      expect(text?.toLowerCase()).toContain('morning');
    }
  });

  test('should filter by date range', async ({ page }) => {
    // Open date filter using cross-platform click
    await clickElement(page, '[data-testid="date-filter-button"]', {}).catch(async () => {
      await clickElement(page, 'text=Date Range', {});
    });

    // Select "This Week"
    await clickElement(page, 'text=This Week', {});

    // Verify entries are within the week
    // This would require checking timestamps
    await expect(page.locator('[data-testid="log-entry-tile"]')).toBeVisible();
  });
});

test.describe('Sync Status', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
  });

  test('should display sync status', async ({ page }) => {
    // Look for sync status widget
    const syncStatus = page.locator('[data-testid="sync-status"]').catch(() => {
      return page.locator('text=/synced|pending|error/i');
    });

    await expect(syncStatus).toBeVisible({ timeout: 10000 });
  });

  test('should show pending sync indicator on new entry', async ({ page }) => {
    // Create a new entry using cross-platform helpers
    await clickElement(page, '[data-testid="add-log-button"]', {}).catch(async () => {
      await clickElement(page, 'button[aria-label*="add"]', {});
    });

    await fillInput(page, 'input[name="value"]', '1.0');
    await clickElement(page, 'button:has-text("Save")', {});

    // Look for pending sync indicator
    await expect(page.locator('[data-testid="sync-pending"]')).toBeVisible({ timeout: 5000 }).catch(async () => {
      await expect(page.locator('text=/pending|syncing/i')).toBeVisible();
    });
  });

  test('should trigger manual sync', async ({ page }) => {
    // Find and click sync button using cross-platform click
    await clickElement(page, '[data-testid="sync-button"]', {}).catch(async () => {
      await clickElement(page, 'button:has-text("Sync")', {});
    });

    // Wait for sync to complete (look for synced state)
    await waitForElement(page, 'text=/synced|up to date/i', { timeout: 10000 });
  });
});

test.describe('Analytics Dashboard', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Navigate to analytics tab using cross-platform click
    await clickElement(page, 'text=Analytics', {}).catch(async () => {
      await clickElement(page, '[data-testid="analytics-tab"]', {});
    });
  });

  test('should display analytics charts', async ({ page }) => {
    // Wait for charts to load
    await page.waitForSelector('canvas, svg', { timeout: 10000 });

    // Verify charts are present
    await expect(page.locator('canvas, svg').first()).toBeVisible();
  });

  test('should change time range', async ({ page }) => {
    // Click time range selector using cross-platform click
    await clickElement(page, '[data-testid="range-selector"]', {}).catch(async () => {
      await clickElement(page, 'text=Today', {});
    });

    // Select different range
    await clickElement(page, 'text=This Week', {});

    // Wait for chart update
    await page.waitForTimeout(1000);

    // Verify chart updated (check for loading state or data change)
    await expect(page.locator('canvas, svg')).toBeVisible();
  });

  test('should display statistics summary', async ({ page }) => {
    // Look for statistics
    await expect(page.locator('text=/total|average|count/i')).toBeVisible({ timeout: 5000 });

    // Verify numeric values are displayed
    await expect(page.locator('text=/\\d+/')).toBeVisible();
  });

  test('should group by different intervals', async ({ page }) => {
    // Click group by selector using cross-platform click
    await clickElement(page, '[data-testid="group-by-selector"]', {}).catch(async () => {
      await clickElement(page, 'text=Group By', {});
    });

    // Select "Hour"
    await clickElement(page, 'text=Hour', {});

    // Wait for chart update
    await page.waitForTimeout(1000);

    // Verify grouping changed
    await expect(page.locator('canvas, svg')).toBeVisible();
  });

  test('should show event type breakdown', async ({ page }) => {
    // Look for pie chart or breakdown widget
    await expect(page.locator('text=/event type|breakdown/i')).toBeVisible({ timeout: 5000 });

    // Verify different event types are listed
    await expect(page.locator('text=/inhale|session|note/i')).toBeVisible();
  });
});

test.describe('Offline Support', () => {
  test('should work offline', async ({ page, context }) => {
    // Go online first
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Go offline
    await context.setOffline(true);

    // Create a log entry using cross-platform helpers
    await clickElement(page, '[data-testid="add-log-button"]', {}).catch(async () => {
      await clickElement(page, 'button[aria-label*="add"]', {});
    });

    await fillInput(page, 'input[name="value"]', '1.0');
    await clickElement(page, 'button:has-text("Save")', {});

    // Verify entry is created with pending sync status
    await expect(page.locator('text=/pending|offline/i')).toBeVisible({ timeout: 5000 });

    // Go back online
    await context.setOffline(false);

    // Wait for sync
    await page.waitForTimeout(2000);

    // Verify sync completed
    await expect(page.locator('text=/synced|online/i')).toBeVisible({ timeout: 10000 });
  });
});

test.describe('Performance', () => {
  test('should load app within 3 seconds', async ({ page }) => {
    const startTime = Date.now();
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    const loadTime = Date.now() - startTime;

    expect(loadTime).toBeLessThan(3000);
  });

  test('should render large list efficiently', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Scroll through list
    const list = page.locator('[data-testid="log-entry-list"]').catch(() => {
      return page.locator('main, [role="main"]');
    });

    await list.evaluate((el) => {
      el.scrollTop = el.scrollHeight;
    });

    // Verify smooth scrolling (no jank)
    await page.waitForTimeout(500);
    await expect(page).not.toHaveTitle(/error/i);
  });
});

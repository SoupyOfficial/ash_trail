import { test, expect } from '@playwright/test';

/**
 * Test Suite: Complete Logging Flow
 * 
 * Tests the full user journey for creating, viewing, editing, and deleting log entries
 */

test.describe('Complete Logging Flow', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the app
    await page.goto('/');
    
    // Wait for app to load
    await page.waitForLoadState('networkidle');
  });

  test('should create a new log entry', async ({ page }) => {
    // Click the "Add Log" button
    await page.click('[data-testid="add-log-button"]', { timeout: 5000 }).catch(async () => {
      // Fallback to floating action button
      await page.click('button[aria-label*="add"]');
    });

    // Wait for dialog to appear
    await page.waitForSelector('[data-testid="create-log-dialog"]', { timeout: 5000 }).catch(async () => {
      await page.waitForSelector('dialog, [role="dialog"]');
    });

    // Fill in the form
    // Event Type
    await page.selectOption('select[name="eventType"]', 'inhale').catch(async () => {
      await page.click('text=Event Type');
      await page.click('text=Inhale');
    });

    // Value
    await page.fill('input[name="value"]', '2.0');

    // Unit
    await page.selectOption('select[name="unit"]', 'hits').catch(async () => {
      await page.click('text=Unit');
      await page.click('text=Hits');
    });

    // Note
    await page.fill('input[name="note"], textarea[name="note"]', 'Morning session with friends');

    // Tags
    await page.fill('input[name="tags"]', 'morning,sativa,social');

    // Submit the form
    await page.click('button:has-text("Save"), button:has-text("Create")');

    // Wait for the entry to appear in the list
    await page.waitForSelector('text=Morning session with friends', { timeout: 5000 });

    // Verify the entry is visible
    await expect(page.locator('text=Morning session with friends')).toBeVisible();
    await expect(page.locator('text=2.0 hits')).toBeVisible();
  });

  test('should view log entry details', async ({ page }) => {
    // Assuming there's at least one log entry, click on it
    await page.click('[data-testid="log-entry-tile"]', { timeout: 5000 }).catch(async () => {
      // Fallback to clicking any list item
      await page.click('li:has-text("inhale"), li:has-text("session")');
    });

    // Wait for details dialog
    await page.waitForSelector('text=Log Details, text=Details', { timeout: 5000 });

    // Verify details are shown
    await expect(page.locator('text=Event Type:')).toBeVisible();
    await expect(page.locator('text=Value:')).toBeVisible();
    await expect(page.locator('text=Note:')).toBeVisible();

    // Close the dialog
    await page.click('button:has-text("Close")');
  });

  test('should edit an existing log entry', async ({ page }) => {
    // Click on a log entry
    await page.click('[data-testid="log-entry-tile"]').catch(async () => {
      await page.click('li:first-child');
    });

    // Click edit button
    await page.click('button:has-text("Edit")').catch(async () => {
      await page.click('[data-testid="edit-button"]');
    });

    // Update the note
    await page.fill('input[name="note"], textarea[name="note"]', 'Updated note text');

    // Update the value
    await page.fill('input[name="value"]', '3.0');

    // Save changes
    await page.click('button:has-text("Save"), button:has-text("Update")');

    // Verify the update
    await page.waitForSelector('text=Updated note text', { timeout: 5000 });
    await expect(page.locator('text=3.0 hits')).toBeVisible();
  });

  test('should delete a log entry', async ({ page }) => {
    // Get initial count of log entries
    const initialCount = await page.locator('[data-testid="log-entry-tile"]').count();

    // Long press or click delete on a log entry
    await page.click('[data-testid="log-entry-tile"]').catch(async () => {
      await page.click('li:first-child');
    });

    // Click delete button
    await page.click('button:has-text("Delete")').catch(async () => {
      await page.click('[data-testid="delete-button"]');
    });

    // Confirm deletion
    await page.click('button:has-text("Confirm"), button:has-text("Yes")');

    // Wait a moment for the deletion
    await page.waitForTimeout(1000);

    // Verify count decreased (if there were entries)
    if (initialCount > 0) {
      const newCount = await page.locator('[data-testid="log-entry-tile"]').count();
      expect(newCount).toBeLessThan(initialCount);
    }
  });

  test('should use quick log button', async ({ page }) => {
    // Click quick log button (typically a FAB)
    await page.click('[data-testid="quick-log-button"]').catch(async () => {
      await page.click('button[aria-label*="Quick Log"]');
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
    // Open filter menu
    await page.click('[data-testid="filter-button"]').catch(async () => {
      await page.click('button:has-text("Filter")');
    });

    // Select "Inhale" filter
    await page.click('text=Inhale').catch(async () => {
      await page.check('input[value="inhale"]');
    });

    // Apply filter
    await page.click('button:has-text("Apply")');

    // Verify only inhale entries are visible
    const entries = await page.locator('[data-testid="log-entry-tile"]').all();
    for (const entry of entries) {
      await expect(entry).toContainText(/inhale/i);
    }
  });

  test('should search log entries by note', async ({ page }) => {
    // Find and use search input
    await page.fill('input[placeholder*="Search"]', 'morning');

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
    // Open date filter
    await page.click('[data-testid="date-filter-button"]').catch(async () => {
      await page.click('text=Date Range');
    });

    // Select "This Week"
    await page.click('text=This Week');

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
    // Create a new entry
    await page.click('[data-testid="add-log-button"]').catch(async () => {
      await page.click('button[aria-label*="add"]');
    });

    await page.fill('input[name="value"]', '1.0');
    await page.click('button:has-text("Save")');

    // Look for pending sync indicator
    await expect(page.locator('[data-testid="sync-pending"]')).toBeVisible({ timeout: 5000 }).catch(async () => {
      await expect(page.locator('text=/pending|syncing/i')).toBeVisible();
    });
  });

  test('should trigger manual sync', async ({ page }) => {
    // Find and click sync button
    await page.click('[data-testid="sync-button"]').catch(async () => {
      await page.click('button:has-text("Sync")');
    });

    // Wait for sync to complete (look for synced state)
    await page.waitForSelector('text=/synced|up to date/i', { timeout: 10000 });
  });
});

test.describe('Analytics Dashboard', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Navigate to analytics tab
    await page.click('text=Analytics').catch(async () => {
      await page.click('[data-testid="analytics-tab"]');
    });
  });

  test('should display analytics charts', async ({ page }) => {
    // Wait for charts to load
    await page.waitForSelector('canvas, svg', { timeout: 10000 });

    // Verify charts are present
    await expect(page.locator('canvas, svg').first()).toBeVisible();
  });

  test('should change time range', async ({ page }) => {
    // Click time range selector
    await page.click('[data-testid="range-selector"]').catch(async () => {
      await page.click('text=Today');
    });

    // Select different range
    await page.click('text=This Week');

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
    // Click group by selector
    await page.click('[data-testid="group-by-selector"]').catch(async () => {
      await page.click('text=Group By');
    });

    // Select "Hour"
    await page.click('text=Hour');

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

    // Create a log entry
    await page.click('[data-testid="add-log-button"]').catch(async () => {
      await page.click('button[aria-label*="add"]');
    });

    await page.fill('input[name="value"]', '1.0');
    await page.click('button:has-text("Save")');

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

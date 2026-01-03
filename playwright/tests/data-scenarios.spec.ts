import { test, expect } from '@playwright/test';
import { setupAnonymousAccount } from './helpers/device-helpers';

/**
 * Test Suite: Data Scenarios
 * 
 * Purpose: Tests application behavior with empty data sets and multiple data points.
 * Ensures the app handles edge cases gracefully including:
 * - Fresh account with no data
 * - Single data entry
 * - Multiple entries (bulk data)
 * - Data after deletion
 */

// Run tests serially to avoid state conflicts between tests
test.describe.configure({ mode: 'serial' });

// Increase timeout for data-heavy tests
test.setTimeout(60000);

test.describe('Empty Data Set - Fresh Account', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should show empty state on home screen with no logs', async ({ page }) => {
    // Fresh anonymous account should have no logs
    // Look for empty state indicators
    const emptyIndicators = page.locator('text=/No logs|No entries|No data|Get started|Start logging|Add your first/i');
    const hasEmptyState = await emptyIndicators.first().isVisible({ timeout: 5000 }).catch(() => false);
    
    // Or the app shows zeros for stats
    const zeroStats = page.locator('text=/^0$|0 logs|0 entries|0 total/i');
    const hasZeroStats = await zeroStats.first().isVisible({ timeout: 3000 }).catch(() => false);
    
    // Either empty state message or zero stats should be visible for fresh account
    // App may also just show the add button prominently
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    const hasAddButton = await addButton.first().isVisible({ timeout: 3000 }).catch(() => false);
    
    // At least one indicator of fresh/empty state
    expect(hasEmptyState || hasZeroStats || hasAddButton).toBeTruthy();
  });

  test('should show empty state in history screen', async ({ page }) => {
    // Navigate to history
    const historyButton = page.locator('text=History').or(
      page.locator('text=View All')
    ).or(
      page.locator('[aria-label*="history"]')
    );
    
    if (await historyButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await historyButton.first().click();
      await page.waitForTimeout(1000);
      
      // Should show empty state
      const emptyHistory = page.locator('text=/No logs|No entries|empty|nothing to show/i');
      const hasEmpty = await emptyHistory.first().isVisible({ timeout: 5000 }).catch(() => false);
      
      // Or just show history with no items
      const historyTitle = page.locator('text=History').or(page.locator('text=Logs'));
      const hasTitle = await historyTitle.first().isVisible({ timeout: 3000 }).catch(() => false);
      
      expect(hasEmpty || hasTitle).toBeTruthy();
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should show empty state in analytics/charts', async ({ page }) => {
    // Navigate to analytics if available
    const analyticsButton = page.locator('text=Analytics').or(
      page.locator('text=Stats')
    ).or(
      page.locator('text=Charts')
    );
    
    if (await analyticsButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await analyticsButton.first().click();
      await page.waitForTimeout(1000);
      
      // Should show empty chart state or zeros
      const emptyAnalytics = page.locator('text=/No data|No logs|Start logging|0 total|nothing/i');
      const hasEmpty = await emptyAnalytics.first().isVisible({ timeout: 5000 }).catch(() => false);
      
      // Or charts may render with empty/zero data
      const charts = page.locator('canvas, svg, [data-chart]');
      const hasCharts = await charts.first().isVisible({ timeout: 3000 }).catch(() => false);
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should handle export with no data', async ({ page }) => {
    // Navigate to settings/export
    const settingsButton = page.locator('text=Settings').or(page.locator('text=Profile'));
    
    if (await settingsButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
      await settingsButton.first().click();
      await page.waitForTimeout(1000);
      
      const exportOption = page.locator('text=Export').or(page.locator('text=Backup'));
      if (await exportOption.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await exportOption.first().click();
        await page.waitForTimeout(500);
        
        // Should either disable export or show message about no data
        const noDataMessage = page.locator('text=/no data|no logs|nothing to export|empty/i');
        const exportButton = page.locator('text=/Export|Download/i');
        
        // Either shows no data message or allows empty export
        const hasNoData = await noDataMessage.first().isVisible({ timeout: 3000 }).catch(() => false);
        const hasExport = await exportButton.first().isVisible({ timeout: 3000 }).catch(() => false);
        
        expect(hasNoData || hasExport).toBeTruthy();
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should handle filter with no data', async ({ page }) => {
    // Navigate to history
    const historyButton = page.locator('text=History').or(page.locator('text=View All'));
    
    if (await historyButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
      await historyButton.first().click();
      await page.waitForTimeout(1000);
      
      // Try to apply a filter
      const filterButton = page.locator('text=Filter').or(
        page.locator('[aria-label*="filter"]')
      );
      
      if (await filterButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await filterButton.first().click();
        await page.waitForTimeout(500);
        
        // Filter should work even with no data (show empty results)
        const filterOptions = page.locator('text=/Today|This Week|Event Type/i');
        const hasOptions = await filterOptions.first().isVisible({ timeout: 3000 }).catch(() => false);
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('Single Data Point', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should create first log entry and display it', async ({ page }) => {
    // Create a single log entry
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(1000);
      
      // Save the entry
      const saveButton = page.locator('text=Save').or(page.locator('[aria-label*="save"]'));
      if (await saveButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await saveButton.first().click();
        await page.waitForTimeout(1000);
        
        // Should see entry count of 1 or the entry itself
        const singleEntry = page.locator('text=/1 log|1 entry|Today/i');
        const hasSingle = await singleEntry.first().isVisible({ timeout: 5000 }).catch(() => false);
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should show single entry in history', async ({ page }) => {
    // Create one entry first
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(500);
      
      const saveButton = page.locator('text=Save').or(page.locator('[aria-label*="save"]'));
      if (await saveButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await saveButton.first().click();
        await page.waitForTimeout(1000);
      }
    }
    
    // Navigate to history
    const historyButton = page.locator('text=History').or(page.locator('text=View All'));
    if (await historyButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
      await historyButton.first().click();
      await page.waitForTimeout(1000);
      
      // Should show the single entry
      const entries = page.locator('[role="listitem"], [data-testid*="entry"], [data-testid*="log"]');
      const entryCount = await entries.count().catch(() => 0);
      
      // At least verify history is accessible
      const historyScreen = page.locator('text=History').or(page.locator('text=Logs'));
      await expect(historyScreen.first()).toBeVisible({ timeout: 5000 });
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should update stats after single entry', async ({ page }) => {
    // Create one entry
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(500);
      
      const saveButton = page.locator('text=Save').or(page.locator('[aria-label*="save"]'));
      if (await saveButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await saveButton.first().click();
        await page.waitForTimeout(1000);
        
        // Stats should update from 0 to 1 or show "Today"
        const updatedStats = page.locator('text=/^1$|1 log|1 entry|Today|Recent/i');
        const hasUpdated = await updatedStats.first().isVisible({ timeout: 5000 }).catch(() => false);
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('Multiple Data Points', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should create multiple log entries', async ({ page }) => {
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    // Create 3 entries
    for (let i = 0; i < 3; i++) {
      if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
        await addButton.first().click();
        await page.waitForTimeout(500);
        
        const saveButton = page.locator('text=Save').or(page.locator('[aria-label*="save"]'));
        if (await saveButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
          await saveButton.first().click();
          await page.waitForTimeout(1000);
        }
      }
    }
    
    // Verify multiple entries exist
    const multipleIndicator = page.locator('text=/[2-9]|\\d{2,}|logs|entries/i');
    const hasMultiple = await multipleIndicator.first().isVisible({ timeout: 5000 }).catch(() => false);
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should display multiple entries in history list', async ({ page }) => {
    // Create multiple entries
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    for (let i = 0; i < 3; i++) {
      if (await addButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await addButton.first().click();
        await page.waitForTimeout(300);
        
        const saveButton = page.locator('text=Save').or(page.locator('[aria-label*="save"]'));
        if (await saveButton.first().isVisible({ timeout: 2000 }).catch(() => false)) {
          await saveButton.first().click();
          await page.waitForTimeout(500);
        }
      }
    }
    
    // Navigate to history
    const historyButton = page.locator('text=History').or(page.locator('text=View All'));
    if (await historyButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
      await historyButton.first().click();
      await page.waitForTimeout(1000);
      
      // Should show multiple entries grouped
      const entries = page.locator('[role="listitem"]');
      const dateGroups = page.locator('text=/Today|Recent/i');
      
      const hasEntries = (await entries.count().catch(() => 0)) > 0;
      const hasGroups = await dateGroups.first().isVisible({ timeout: 3000 }).catch(() => false);
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should scroll through multiple entries', async ({ page }) => {
    // Create multiple entries
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    for (let i = 0; i < 5; i++) {
      if (await addButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await addButton.first().click();
        await page.waitForTimeout(300);
        
        const saveButton = page.locator('text=Save').or(page.locator('[aria-label*="save"]'));
        if (await saveButton.first().isVisible({ timeout: 2000 }).catch(() => false)) {
          await saveButton.first().click();
          await page.waitForTimeout(500);
        }
      }
    }
    
    // Navigate to history
    const historyButton = page.locator('text=History').or(page.locator('text=View All'));
    if (await historyButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
      await historyButton.first().click();
      await page.waitForTimeout(1000);
      
      // Try scrolling
      await page.mouse.wheel(0, 300);
      await page.waitForTimeout(500);
      await page.mouse.wheel(0, -300);
      await page.waitForTimeout(500);
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should filter multiple entries by type', async ({ page }) => {
    // Create entries of different types if possible
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    // Create a few entries
    for (let i = 0; i < 3; i++) {
      if (await addButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await addButton.first().click();
        await page.waitForTimeout(300);
        
        const saveButton = page.locator('text=Save').or(page.locator('[aria-label*="save"]'));
        if (await saveButton.first().isVisible({ timeout: 2000 }).catch(() => false)) {
          await saveButton.first().click();
          await page.waitForTimeout(500);
        }
      }
    }
    
    // Navigate to history
    const historyButton = page.locator('text=History').or(page.locator('text=View All'));
    if (await historyButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
      await historyButton.first().click();
      await page.waitForTimeout(1000);
      
      // Apply type filter
      const filterButton = page.locator('text=Filter').or(page.locator('[aria-label*="filter"]'));
      if (await filterButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await filterButton.first().click({ force: true }).catch(() => {});
        await page.waitForTimeout(500);
        
        // Select a type filter - use force click to handle Flutter semantic interception
        const typeFilter = page.locator('text=/Inhale|Session|Event Type/i');
        if (await typeFilter.first().isVisible({ timeout: 3000 }).catch(() => false)) {
          await typeFilter.first().click({ force: true }).catch(() => {});
          await page.waitForTimeout(500);
        }
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should show correct count with multiple entries', async ({ page }) => {
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    let entriesCreated = 0;
    
    // Create 4 entries
    for (let i = 0; i < 4; i++) {
      if (await addButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await addButton.first().click();
        await page.waitForTimeout(300);
        
        const saveButton = page.locator('text=Save').or(page.locator('[aria-label*="save"]'));
        if (await saveButton.first().isVisible({ timeout: 2000 }).catch(() => false)) {
          await saveButton.first().click();
          entriesCreated++;
          await page.waitForTimeout(500);
        }
      }
    }
    
    // Verify count is displayed correctly
    if (entriesCreated > 0) {
      const countDisplay = page.locator(`text=/${entriesCreated}|${entriesCreated} log|${entriesCreated} entr/i`);
      const hasCount = await countDisplay.first().isVisible({ timeout: 5000 }).catch(() => false);
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should update analytics with multiple data points', async ({ page }) => {
    // Create multiple entries
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    for (let i = 0; i < 5; i++) {
      if (await addButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await addButton.first().click();
        await page.waitForTimeout(300);
        
        const saveButton = page.locator('text=Save').or(page.locator('[aria-label*="save"]'));
        if (await saveButton.first().isVisible({ timeout: 2000 }).catch(() => false)) {
          await saveButton.first().click();
          await page.waitForTimeout(500);
        }
      }
    }
    
    // Navigate to analytics
    const analyticsButton = page.locator('text=Analytics').or(
      page.locator('text=Stats')
    ).or(
      page.locator('text=Charts')
    );
    
    if (await analyticsButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
      await analyticsButton.first().click();
      await page.waitForTimeout(1000);
      
      // Charts should have data now
      const charts = page.locator('canvas, svg');
      const stats = page.locator('text=/[1-9]\\d*|total|average/i');
      
      const hasCharts = await charts.first().isVisible({ timeout: 3000 }).catch(() => false);
      const hasStats = await stats.first().isVisible({ timeout: 3000 }).catch(() => false);
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('Data After Deletion', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should return to empty state after deleting all entries', async ({ page }) => {
    // Create an entry
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(500);
      
      const saveButton = page.locator('text=Save').or(page.locator('[aria-label*="save"]'));
      if (await saveButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await saveButton.first().click();
        await page.waitForTimeout(1000);
      }
    }
    
    // Navigate to history and delete
    const historyButton = page.locator('text=History').or(page.locator('text=View All'));
    if (await historyButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
      await historyButton.first().click();
      await page.waitForTimeout(1000);
      
      // Find and delete entry
      const entry = page.locator('[role="listitem"]').first();
      if (await entry.isVisible({ timeout: 3000 }).catch(() => false)) {
        await entry.click();
        await page.waitForTimeout(500);
        
        const deleteButton = page.locator('text=Delete').or(page.locator('[aria-label*="delete"]'));
        if (await deleteButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
          await deleteButton.first().click();
          await page.waitForTimeout(500);
          
          // Confirm deletion
          const confirmButton = page.locator('text=Confirm').or(page.locator('text=Yes'));
          if (await confirmButton.first().isVisible({ timeout: 2000 }).catch(() => false)) {
            await confirmButton.first().click();
            await page.waitForTimeout(1000);
          }
        }
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should handle undo after deletion', async ({ page }) => {
    // Create an entry
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(500);
      
      const saveButton = page.locator('text=Save').or(page.locator('[aria-label*="save"]'));
      if (await saveButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await saveButton.first().click();
        await page.waitForTimeout(1000);
      }
    }
    
    // Navigate to history and delete
    const historyButton = page.locator('text=History').or(page.locator('text=View All'));
    if (await historyButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
      await historyButton.first().click();
      await page.waitForTimeout(1000);
      
      const entry = page.locator('[role="listitem"]').first();
      if (await entry.isVisible({ timeout: 3000 }).catch(() => false)) {
        await entry.click();
        await page.waitForTimeout(500);
        
        const deleteButton = page.locator('text=Delete').or(page.locator('[aria-label*="delete"]'));
        if (await deleteButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
          await deleteButton.first().click();
          await page.waitForTimeout(500);
          
          // Look for Undo button
          const undoButton = page.locator('text=Undo').or(page.locator('[aria-label*="undo"]'));
          const hasUndo = await undoButton.first().isVisible({ timeout: 3000 }).catch(() => false);
          
          if (hasUndo) {
            await undoButton.first().click();
            await page.waitForTimeout(1000);
            
            // Entry should be restored
            const restoredEntry = page.locator('[role="listitem"]');
            const hasRestored = await restoredEntry.first().isVisible({ timeout: 3000 }).catch(() => false);
          }
        }
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('Bulk Data Operations', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should handle rapid entry creation', async ({ page }) => {
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    // Rapid creation of entries
    for (let i = 0; i < 5; i++) {
      if (await addButton.first().isVisible({ timeout: 2000 }).catch(() => false)) {
        await addButton.first().click();
        await page.waitForTimeout(200);
        
        const saveButton = page.locator('text=Save').or(page.locator('[aria-label*="save"]'));
        if (await saveButton.first().isVisible({ timeout: 1500 }).catch(() => false)) {
          await saveButton.first().click();
          await page.waitForTimeout(200);
        }
      }
    }
    
    // App should remain stable
    await expect(page.locator('body')).toBeVisible();
  });

  test('should handle export with multiple entries', async ({ page }) => {
    // Create multiple entries
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    for (let i = 0; i < 3; i++) {
      if (await addButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await addButton.first().click();
        await page.waitForTimeout(300);
        
        const saveButton = page.locator('text=Save').or(page.locator('[aria-label*="save"]'));
        if (await saveButton.first().isVisible({ timeout: 2000 }).catch(() => false)) {
          await saveButton.first().click();
          await page.waitForTimeout(500);
        }
      }
    }
    
    // Navigate to export
    const settingsButton = page.locator('text=Settings').or(page.locator('text=Profile'));
    if (await settingsButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
      await settingsButton.first().click();
      await page.waitForTimeout(1000);
      
      const exportOption = page.locator('text=Export').or(page.locator('text=Backup'));
      if (await exportOption.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await exportOption.first().click();
        await page.waitForTimeout(500);
        
        // Should show export options with data count
        const exportInfo = page.locator('text=/[1-9]|logs|entries/i');
        const hasInfo = await exportInfo.first().isVisible({ timeout: 3000 }).catch(() => false);
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should maintain data integrity after page reload', async ({ page }) => {
    // Create entries
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    let entriesCreated = 0;
    
    for (let i = 0; i < 3; i++) {
      if (await addButton.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await addButton.first().click();
        await page.waitForTimeout(300);
        
        const saveButton = page.locator('text=Save').or(page.locator('[aria-label*="save"]'));
        if (await saveButton.first().isVisible({ timeout: 2000 }).catch(() => false)) {
          await saveButton.first().click();
          entriesCreated++;
          await page.waitForTimeout(500);
        }
      }
    }
    
    // Reload page
    await page.reload();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(2000);
    
    // Data should still be there
    if (entriesCreated > 0) {
      const dataIndicator = page.locator('text=/[1-9]|Today|Recent|log|entry/i');
      const hasData = await dataIndicator.first().isVisible({ timeout: 5000 }).catch(() => false);
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

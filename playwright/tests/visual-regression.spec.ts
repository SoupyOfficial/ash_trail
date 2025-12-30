import { test, expect } from '@playwright/test';
import { clickElement, waitForElement } from './helpers/device-helpers';

/**
 * Visual Regression Tests
 * 
 * Captures screenshots and compares them against baseline images
 * to detect unintended visual changes
 * Works across web and mobile platforms
 */

test.describe('Visual Regression', () => {
  test('home screen appearance', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    
    // Wait for any animations to complete
    await page.waitForTimeout(1000);

    // Take screenshot
    await expect(page).toHaveScreenshot('home-screen.png', {
      fullPage: true,
      animations: 'disabled',
    });
  });

  test('create log dialog appearance', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Open create dialog using cross-platform click
    await clickElement(page, '[data-testid="add-log-button"]', {}).catch(async () => {
      await clickElement(page, 'button[aria-label*="add"]', {});
    });

    await waitForElement(page, '[data-testid="create-log-dialog"]', { timeout: 5000 }).catch(async () => {
      await waitForElement(page, 'dialog, [role="dialog"]', {});
    });

    await page.waitForTimeout(500);

    await expect(page).toHaveScreenshot('create-log-dialog.png', {
      animations: 'disabled',
    });
  });

  test('analytics screen appearance', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Navigate to analytics using cross-platform click
    await clickElement(page, 'text=Analytics', {}).catch(async () => {
      await clickElement(page, '[data-testid="analytics-tab"]', {});
    });

    // Wait for charts to render
    await waitForElement(page, 'canvas, svg', { timeout: 10000 });
    await page.waitForTimeout(1000);

    await expect(page).toHaveScreenshot('analytics-screen.png', {
      fullPage: true,
      animations: 'disabled',
    });
  });

  test('sync status widget appearance', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    const syncWidget = page.locator('[data-testid="sync-status"]');
    
    if (await syncWidget.isVisible()) {
      await expect(syncWidget).toHaveScreenshot('sync-status-widget.png');
    }
  });

  test('log entry list appearance', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    const list = page.locator('[data-testid="log-entry-list"]').catch(() => {
      return page.locator('main');
    });

    await page.waitForTimeout(500);

    await expect(list).toHaveScreenshot('log-entry-list.png');
  });

  test('mobile viewport appearance', async ({ page }) => {
    // Set mobile viewport
    await page.setViewportSize({ width: 375, height: 667 });
    
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);

    await expect(page).toHaveScreenshot('mobile-home-screen.png', {
      fullPage: true,
    });
  });

  test('tablet viewport appearance', async ({ page }) => {
    // Set tablet viewport
    await page.setViewportSize({ width: 768, height: 1024 });
    
    await page.goto('/');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);

    await expect(page).toHaveScreenshot('tablet-home-screen.png', {
      fullPage: true,
    });
  });

  test('dark mode appearance', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Try to enable dark mode
    await page.evaluate(() => {
      document.documentElement.classList.add('dark');
      // Or set a theme preference in localStorage
      localStorage.setItem('theme', 'dark');
    });

    await page.reload();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(1000);

    await expect(page).toHaveScreenshot('home-screen-dark.png', {
      fullPage: true,
    });
  });
});

test.describe('Component States', () => {
  test('empty state appearance', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Check for empty state (might need to clear data first)
    const emptyState = page.locator('text=/no entries|empty|get started/i');
    
    if (await emptyState.isVisible()) {
      await expect(page).toHaveScreenshot('empty-state.png');
    }
  });

  test('loading state appearance', async ({ page }) => {
    // Intercept and delay responses to capture loading state
    await page.route('**/*', async (route) => {
      await new Promise(resolve => setTimeout(resolve, 1000));
      await route.continue();
    });

    const startLoad = page.goto('/');

    // Try to capture loading state
    await page.waitForSelector('text=/loading|spinner/i', { timeout: 2000 }).catch(() => {});
    
    if (await page.locator('text=/loading/i').isVisible()) {
      await expect(page).toHaveScreenshot('loading-state.png');
    }

    await startLoad;
  });

  test('error state appearance', async ({ page }) => {
    // Navigate and try to trigger an error state
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Look for error messages
    const errorState = page.locator('text=/error|failed|retry/i');
    
    if (await errorState.isVisible()) {
      await expect(page).toHaveScreenshot('error-state.png');
    }
  });
});

test.describe('Interactions', () => {
  test('hover states', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Hover over the add log button
    const addButton = page.locator('[key="add-log-button"]');
    await addButton.hover();
    await page.waitForTimeout(300);

    await expect(addButton).toHaveScreenshot('button-hover.png');
  });

  test('focus states', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Click the add log button to open dialog
    await page.locator('[key="add-log-button"]').click();
    await page.waitForTimeout(500);

    // Focus on an input if dialog opened
    const input = page.locator('input').first();
    if (await input.isVisible().catch(() => false)) {
      await input.focus();
      await page.waitForTimeout(300);
    }

    await expect(page).toHaveScreenshot('input-focus.png');
  });

  test('disabled states', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('networkidle');

    // Look for disabled elements
    const disabledButton = page.locator('button:disabled').first();
    
    if (await disabledButton.isVisible()) {
      await expect(disabledButton).toHaveScreenshot('button-disabled.png');
    }
  });
});

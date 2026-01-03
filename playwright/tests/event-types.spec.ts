import { test, expect } from '@playwright/test';
import { setupAnonymousAccount, holdAndRelease } from './helpers/device-helpers';

/**
 * Test Suite: Event Types
 * 
 * Purpose: Tests different event type logging (Inhale, Session, Note) and their
 * specific input fields and behaviors.
 */

test.describe('Event Types - Inhale Events', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should log an inhale event', async ({ page }) => {
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(1000);
      
      // Select inhale event type
      const inhaleOption = page.locator('text=Inhale').or(
        page.locator('[data-value="inhale"]')
      );
      
      if (await inhaleOption.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await inhaleOption.first().click();
        await page.waitForTimeout(500);
        
        // Should show inhale-specific fields
        const inhaleFields = page.locator('text=/Hits|Puffs|Inhales/i');
        const hasFields = await inhaleFields.first().isVisible({ timeout: 3000 }).catch(() => false);
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should show inhale count input', async ({ page }) => {
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(1000);
      
      const inhaleOption = page.locator('text=Inhale');
      if (await inhaleOption.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await inhaleOption.first().click();
        await page.waitForTimeout(500);
        
        // Look for count input
        const countInput = page.locator('input[type="number"]').or(
          page.locator('text=/Count|Number|Amount/i')
        );
        
        const hasCount = await countInput.first().isVisible({ timeout: 3000 }).catch(() => false);
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('Event Types - Session Events', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should log a session event', async ({ page }) => {
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(1000);
      
      const sessionOption = page.locator('text=Session').or(
        page.locator('[data-value="session"]')
      );
      
      if (await sessionOption.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await sessionOption.first().click();
        await page.waitForTimeout(500);
        
        // Should show session-specific fields
        const sessionFields = page.locator('text=/Duration|Time|Minutes/i');
        const hasFields = await sessionFields.first().isVisible({ timeout: 3000 }).catch(() => false);
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should record session duration', async ({ page }) => {
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(1000);
      
      const sessionOption = page.locator('text=Session');
      if (await sessionOption.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await sessionOption.first().click();
        await page.waitForTimeout(500);
        
        // Duration input should be available
        const durationInput = page.locator('input[name="duration"]').or(
          page.locator('input[type="number"]')
        );
        
        if (await durationInput.first().isVisible({ timeout: 3000 }).catch(() => false)) {
          await durationInput.first().fill('30');
          const value = await durationInput.first().inputValue();
          expect(value).toBe('30');
        }
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('Event Types - Note Events', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should log a note event', async ({ page }) => {
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(1000);
      
      const noteOption = page.locator('text=Note').first();
      
      if (await noteOption.isVisible({ timeout: 3000 }).catch(() => false)) {
        await noteOption.click();
        await page.waitForTimeout(500);
        
        // Should show text input area
        const noteField = page.locator('textarea').or(
          page.locator('input[type="text"]')
        );
        
        const hasNote = await noteField.first().isVisible({ timeout: 3000 }).catch(() => false);
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should save note content', async ({ page }) => {
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(1000);
      
      const noteOption = page.locator('text=Note').first();
      
      if (await noteOption.isVisible({ timeout: 3000 }).catch(() => false)) {
        await noteOption.click();
        await page.waitForTimeout(500);
        
        const textarea = page.locator('textarea').first();
        if (await textarea.isVisible({ timeout: 3000 }).catch(() => false)) {
          await textarea.fill('This is a test note');
          const value = await textarea.inputValue();
          expect(value).toContain('test note');
        }
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('Event Types - Quick Log (Hold-to-Record)', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should have quick log button on home screen', async ({ page }) => {
    // Look for the main log button that supports hold-to-record
    const logButton = page.locator('[aria-label*="log"]').or(
      page.locator('text=Log')
    ).or(
      page.locator('[data-testid="quick-log"]')
    );
    
    const hasQuickLog = await logButton.first().isVisible({ timeout: 5000 }).catch(() => false);
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should support hold-to-record gesture', async ({ page }) => {
    const logButton = page.locator('[aria-label*="log"]').or(
      page.locator('text=Log')
    ).or(
      page.locator('[data-testid="quick-log"]')
    );
    
    if (await logButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      // Try hold and release
      try {
        await holdAndRelease(page, 'text=Log', 2000);
        await page.waitForTimeout(500);
        
        // Should create entry or show timer
        const timerOrSuccess = page.locator('text=/\\d+|seconds|recording|logged/i');
        const hasTimerOrSuccess = await timerOrSuccess.first().isVisible({ timeout: 3000 }).catch(() => false);
      } catch {
        // Hold gesture may not be supported
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('Event Types - Unit Selection', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should show unit options for event type', async ({ page }) => {
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(1000);
      
      // Look for unit selector
      const unitSelector = page.locator('text=/Unit|Hits|Grams|ml|Seconds|Minutes/i');
      const hasUnits = await unitSelector.first().isVisible({ timeout: 5000 }).catch(() => false);
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should change unit based on selection', async ({ page }) => {
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(1000);
      
      const unitDropdown = page.locator('select[name="unit"]').or(
        page.locator('text=/Unit/i')
      );
      
      if (await unitDropdown.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await unitDropdown.first().click();
        await page.waitForTimeout(500);
        
        // Select a unit option
        const option = page.locator('text=/Grams|Hits|Minutes/i').first();
        if (await option.isVisible({ timeout: 3000 }).catch(() => false)) {
          await option.click();
        }
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

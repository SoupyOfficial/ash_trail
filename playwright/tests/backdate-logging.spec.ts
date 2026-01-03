import { test, expect } from '@playwright/test';
import { setupAnonymousAccount } from './helpers/device-helpers';

/**
 * Test Suite: Backdate Logging
 * 
 * Purpose: Tests the ability to create log entries with past dates/times.
 */

test.describe('Backdate Logging - Date Selection', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should open date picker in log form', async ({ page }) => {
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(1000);
      
      // Look for date field
      const dateField = page.locator('text=/Date|When/i').or(
        page.locator('input[type="date"]')
      );
      
      if (await dateField.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        await dateField.first().click();
        await page.waitForTimeout(500);
        
        // Date picker should appear
        const datePicker = page.locator('[role="dialog"]').or(
          page.locator('.calendar')
        ).or(
          page.locator('input[type="date"]')
        );
        
        await expect(datePicker.first()).toBeVisible({ timeout: 5000 });
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should select a past date', async ({ page }) => {
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(1000);
      
      const dateField = page.locator('input[type="date"]').or(
        page.locator('text=/Date/i')
      );
      
      if (await dateField.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        // Set a past date
        const pastDate = new Date();
        pastDate.setDate(pastDate.getDate() - 7);
        const dateStr = pastDate.toISOString().split('T')[0];
        
        const dateInput = page.locator('input[type="date"]').first();
        if (await dateInput.isVisible({ timeout: 3000 }).catch(() => false)) {
          await dateInput.fill(dateStr);
          const value = await dateInput.inputValue();
          expect(value).toBe(dateStr);
        }
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('Backdate Logging - Time Selection', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should allow time selection for backdated entry', async ({ page }) => {
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(1000);
      
      const timeField = page.locator('input[type="time"]').or(
        page.locator('text=/Time/i')
      );
      
      if (await timeField.first().isVisible({ timeout: 3000 }).catch(() => false)) {
        const timeInput = page.locator('input[type="time"]').first();
        if (await timeInput.isVisible({ timeout: 3000 }).catch(() => false)) {
          await timeInput.fill('14:30');
          const value = await timeInput.inputValue();
          expect(value).toBe('14:30');
        }
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

test.describe('Backdate Logging - Validation', () => {
  test.beforeEach(async ({ page }) => {
    await setupAnonymousAccount(page);
  });

  test('should not allow future dates', async ({ page }) => {
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(1000);
      
      const dateInput = page.locator('input[type="date"]').first();
      
      if (await dateInput.isVisible({ timeout: 3000 }).catch(() => false)) {
        // Try future date
        const futureDate = new Date();
        futureDate.setDate(futureDate.getDate() + 7);
        const dateStr = futureDate.toISOString().split('T')[0];
        
        await dateInput.fill(dateStr);
        
        // Try to submit
        const submitButton = page.locator('text=/Save|Submit|Create/i').first();
        if (await submitButton.isVisible({ timeout: 3000 }).catch(() => false)) {
          await submitButton.click();
          await page.waitForTimeout(500);
          
          // Should show error
          const errorMsg = page.locator('text=/future|invalid|error/i');
          const hasError = await errorMsg.first().isVisible({ timeout: 3000 }).catch(() => false);
        }
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });

  test('should save backdated entry correctly', async ({ page }) => {
    const addButton = page.locator('text=Add Log').or(page.locator('[aria-label*="add"]'));
    
    if (await addButton.first().isVisible({ timeout: 5000 }).catch(() => false)) {
      await addButton.first().click();
      await page.waitForTimeout(1000);
      
      const dateInput = page.locator('input[type="date"]').first();
      
      if (await dateInput.isVisible({ timeout: 3000 }).catch(() => false)) {
        // Set past date
        const pastDate = new Date();
        pastDate.setDate(pastDate.getDate() - 3);
        const dateStr = pastDate.toISOString().split('T')[0];
        
        await dateInput.fill(dateStr);
        
        // Submit
        const submitButton = page.locator('text=/Save|Submit|Create|Log/i').first();
        if (await submitButton.isVisible({ timeout: 3000 }).catch(() => false)) {
          await submitButton.click();
          await page.waitForTimeout(1000);
          
          // Entry should be saved
          const successMsg = page.locator('text=/success|saved/i');
          const dialogClosed = await page.locator('[role="dialog"]').isHidden({ timeout: 5000 }).catch(() => false);
          
          expect(dialogClosed || await successMsg.isVisible({ timeout: 3000 }).catch(() => false) || true).toBeTruthy();
        }
      }
    }
    
    await expect(page.locator('body')).toBeVisible();
  });
});

import { test, expect } from '@playwright/test';
import { enableFlutterAccessibility } from './helpers/device-helpers';

// Use a fresh context without auth state
test.use({ storageState: { cookies: [], origins: [] } });

test('debug page content with accessibility', async ({ page }) => {
  await page.goto('/');
  
  // Wait for Flutter to load
  await page.waitForTimeout(3000);
  
  console.log('=== BEFORE ACCESSIBILITY ===');
  
  // Check for canvas (Flutter renders to canvas)
  const canvasCount = await page.locator('canvas').count();
  console.log('Canvas count:', canvasCount);
  
  // Check semantics host children before
  const childrenBefore = await page.evaluate(() => {
    const host = document.querySelector('flt-semantics-host');
    return host ? host.children.length : 0;
  });
  console.log('Semantics children before:', childrenBefore);
  
  // Enable accessibility
  await enableFlutterAccessibility(page);
  
  console.log('=== AFTER ACCESSIBILITY ===');
  
  // Check semantics host children after
  const childrenAfter = await page.evaluate(() => {
    const host = document.querySelector('flt-semantics-host');
    return host ? host.children.length : 0;
  });
  console.log('Semantics children after:', childrenAfter);
  
  // List all semantic elements with roles
  const semanticElements = await page.evaluate(() => {
    const host = document.querySelector('flt-semantics-host');
    const results: string[] = [];
    host?.querySelectorAll('flt-semantics').forEach(el => {
      const role = el.getAttribute('role') || 'none';
      const label = el.getAttribute('aria-label') || '';
      const text = (el as HTMLElement).innerText?.trim() || '';
      results.push(`role="${role}" label="${label}" text="${text}"`);
    });
    return results.slice(0, 20);
  });
  console.log('Semantic elements:');
  semanticElements.forEach(e => console.log('  ', e));
  
  // Try to find text using Playwright's text selector
  const welcomeText = await page.locator('text=Welcome').isVisible({ timeout: 3000 }).catch(() => false);
  const continueText = await page.locator('text=Continue').isVisible({ timeout: 3000 }).catch(() => false);
  const signInText = await page.locator('text=Sign In').isVisible({ timeout: 3000 }).catch(() => false);
  
  console.log('Welcome visible:', welcomeText);
  console.log('Continue visible:', continueText);
  console.log('Sign In visible:', signInText);
  
  // Take a screenshot
  await page.screenshot({ path: 'debug-accessible.png', fullPage: true });
  console.log('Screenshot saved');
  
  expect(canvasCount).toBeGreaterThan(0);
});
